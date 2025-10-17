import fitz 
import xlsxwriter

from xlsxwriter.workbook import Workbook

file = 'LCPv.001.pdf'
pdf_file = fitz.open(file)

workbook = Workbook('text_pdf.xlsx')
worksheet = workbook.add_worksheet()

worksheet.write(0, 0, 'SinoNom Char')
worksheet.write(0, 1, 'Chữ Quốc Ngữ')

row, col = (1, 0)
# res = []

for page_index in range(len(pdf_file)):
    
    page = pdf_file.load_page(page_index)
    image_list = page.get_images()

    if image_list:
        
        xref = image_list[0][0]
        base_image = pdf_file.extract_image(xref)

        ext = base_image['ext']
        with open(f'LCPv.001.{page_index + 1}.{ext}', 'wb') as F:
            F.write(base_image['image'])
    
    else:
        
        page_text = page.get_text() + chr(12)
        dictionary_elements = page.get_text('dict')
        
        for block in dictionary_elements['blocks']:
            line_text = ''
            for line in block['lines']:
                for span in line['spans']:
                    worksheet.write(row, col, span['text'])
                    # res.append([span['text'], (row, col)])
                    col += 1
                    col %= 2
            if (col == 0): row += 1
    
workbook.close()

