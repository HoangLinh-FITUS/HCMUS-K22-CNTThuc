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
        pdf_file: open file pdf 
        WORKSHEET: write text of file to xlsx
    '''

    pdf_file = fitz.open(pdf_file_name)
 
    row_xlsx = 2
    for page_index in range(len(pdf_file)):
        row_xlsx = extract_continuous.process_page(
            pdf_file_name, 
            folder_save_image, 
            page_index, 
            row_xlsx
        )
        
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

    extract_pdf(PDF_FILE_NAME, FOLDER_SAVE_IMAGE)







