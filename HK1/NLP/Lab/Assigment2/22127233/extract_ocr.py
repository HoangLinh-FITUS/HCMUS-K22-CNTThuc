import os
import cv2
import fitz 
import easyocr
from PIL import Image
from noise_reduction import resize_image
import extract_continuous
from transformers import pipeline

corrector = pipeline("text2text-generation", model="bmd1905/vietnamese-correction-v2")

def draw_bounding_boxes(image, detections, threshold=0.25):

    for bbox, text, score in detections:
        if score > threshold:

            cv2.rectangle(image, tuple(map(int, bbox[0])), tuple(map(int, bbox[2])), (0, 255, 0), 5)

            cv2.putText(image, text, tuple(map(int, bbox[0])), cv2.FONT_HERSHEY_COMPLEX_SMALL, 0.65, (255, 0, 0), 2)

def merge_into_sentences_on_a_line(
    text_detections: list[dict],
    threshold
) -> list[str]:

    ''' ghep nhung bbox roi rac thanh 1 dong

    bbox roi rac bi phat tac tren 1 dong 
    lien ket nhung bbox nay lai thanh 1 dong hoan chinh 

    args: 
        text_detections: nhung cau ma easyocr phan tich duoc 
        threshold: do chenh lech cho phep duoc xem 1 bbox duoc coi la cung 1 hang 

    returns:   
        nhung cau dau khi da ghep theo dong 
    '''
    results = []
    sentence = ''
    for _, text, score in text_detections:
        if score >= threshold:
            sentence += ' ' + text 
        else: 
            if sentence:
                results.append(sentence.replace('  ', ' '))
            sentence = ''

    if sentence: 
        results.append(sentence.replace('  ', ' '))

    return results 


def extract_text(
    pdf_file_name: str,
    folder_save_image: str, 
    page_index: int
)-> tuple:

    ''' trich xuat text cua file pdf 
    
    args:
        pdf_file_name: ten file pdf can trich xuat 
        folder_save_image: folder se luu tru anh sau khi trich xuat duoc 
        page_index: vi tri page can trich xuat
    
    returns:
        cau han ngu va quoc ngu sau trich xuat 
    '''
    img, ext = extract_continuous.extract_image(pdf_file_name, page_index)
    full_file_name = pdf_file_name[:pdf_file_name.find('.')] + '.' + str(page_index + 1) +'.' + ext 
    image_save_path = folder_save_image + full_file_name

    resize_image(image_save_path)

    reader = easyocr.Reader(['vi'])
    
    img = cv2.imread(image_save_path)
    text_detections = reader.readtext(img)

    sentences_quocngu = merge_into_sentences_on_a_line(text_detections, threshold=0.25)

    reader = easyocr.Reader(['ch_sim'])
    
    img = cv2.imread(image_save_path)
    text_detections = reader.readtext(img)
    sentences_hannom = merge_into_sentences_on_a_line(text_detections, threshold=0.0001)

    # sua loi chinh ta tieng viet
    predictions = corrector(sentences_quocngu, max_length=512)
    sentences_quocngu = [pred['generated_text'] for pred in predictions]

    ## xoa anh 
    os.remove(image_save_path)
    
    return sentences_hannom, sentences_quocngu

def extract_pdf(
    pdf_file_name: str, 
    folder_save_image: str
) -> None:
    ''' extract images and text from file pdf

    args:
        pdf_file_name: ten file pdf can trich xuat 
        folder_save_image: folder luu tru anh sau khi trich xuat
    '''

    pdf_file = fitz.open(pdf_file_name)
 
    row_xlsx = 2
    for page_index in range(len(pdf_file)):
        row_xlsx = extract_continuous.process_page(
            pdf_file_name, 
            folder_save_image, 
            page_index, 
            row_xlsx,
            have_image_preprocessing=False
        )
        
        # nhan thay page le thuong la phan dich cua page truoc do 
        # page le , (page - 1) chan nen page ban dau luon la anh (page initial = 0)
        if page_index % 2:

            sentences_HN, sentences_QN = extract_text(pdf_file_name, folder_save_image, page_index)
            
            file_output = 'text_' + pdf_file_name[:pdf_file_name.find('.')] + '.xlsx'
            
            row_xlsx = extract_continuous.print_xlsx(
                file_output, 
                row_xlsx, 
                sentences_HN, 
                sentences_QN, 
                page_index
            )
            

if __name__ == '__main__':
    PDF_FILE_NAME = 'Kieu1866page045.pdf'
    FOLDER_SAVE_IMAGE = 'dang2/'

    try:
        os.mkdir(FOLDER_SAVE_IMAGE)
    except FileExistsError:
        pass
    
    extract_pdf(PDF_FILE_NAME, FOLDER_SAVE_IMAGE)