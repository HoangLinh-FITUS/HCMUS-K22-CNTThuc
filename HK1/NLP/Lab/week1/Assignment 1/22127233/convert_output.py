import pytesseract
import pandas as  pd
import json 

from functools import cmp_to_key
from PIL import Image

# global variable
text_pdf = pd.read_excel("text_pdf.xlsx")

#######


def sortOCR(data):
    j = 0
    while j < len(data) and not (data[j]['points'][0][1] >= data[0]['points'][2][1]): j += 1
    
    res = []
    prevJ = j
    for i in range(prevJ):
        Ai_x = data[i]['points'][0][0]
        Bi_x = data[i]['points'][1][0]
        Aj_x = data[j]['points'][0][0]
        Bj_x = data[j]['points'][1][0]
        if not (Bi_x < Aj_x or Bj_x < Ai_x): 
            res.append(data[j])
            res.append(data[i])
            j += 1
        else: 
            res.append('')
            res.append(data[i])
        
    res.reverse()
    return res

def bboxAlignment(OCR, TEXT):   
    

    
def solve(nameImage, page_index):
    print("name image", nameImage, page_index)
    
    dataOCR = json.loads(img_I[1])
    dataOCR = sortOCR(dataOCR)
    bboxAlignment(dataOCR, text_pdf[text_pdf.keys()[1]].values)

if __name__ == '__main__':

    with open('Label.txt', 'r') as fileOCR:
        data = fileOCR.read().split('\n')
        data = [_.split('\t')  for _ in data if len(_.split('\t')) > 1]

        for img_I in data:
            
            nameImage = img_I[0].split('/')[-1]
            page_index = nameImage.split('.')[-2]

            solve(nameImage, page_index)


