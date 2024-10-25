import fitz 

file = 'LCPv.001.pdf'

pdf_file = fitz.open(file)

for page_index in range(len(pdf_file)):
    
    page = pdf_file.load_page(page_index)
    image_list = page.get_images()

    if image_list:
        
        xref = image_list[0][0]
        base_image = pdf_file.extract_image(xref)

        ext = base_image['ext']
        with open(f'LCPv.001.{ext}', 'wb') as F:
            F.write(base_image['image'])
    
    else:

        print(f'page of {page_index}')
        page_text = page.get_text() + chr(12)
        print(page_text)

        dictionary_elements = page.get_text('dict')

        print(dictionary_elements)
        
        for block in dictionary_elements['blocks']:
            line_text = ''
            for line in block['lines']:
                for span in line['spans']:
                    line_text += ' ' + span['text']
            print('\t' + line_text)
        break
