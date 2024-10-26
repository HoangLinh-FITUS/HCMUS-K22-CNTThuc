from xlsxwriter.workbook import Workbook
import pandas as  pd
import json 
import ast

# global variable
text_pdf = pd.read_excel("text_pdf.xlsx")
file_sinoNom = pd.read_excel('SinoNom_similar_Dic.xlsx')
file_quocNgu = pd.read_excel('QuocNgu_SinoNom_Dic.xlsx')

workbook = Workbook('output.xlsx')
worksheet = workbook.add_worksheet()
red = workbook.add_format({'color': 'red'})
blue = workbook.add_format({'color': 'blue'})
green = workbook.add_format({'color': 'green'})

input_sinoNom_similar = dict(zip(file_sinoNom[file_sinoNom.keys()[0]].values, file_sinoNom[file_sinoNom.keys()[1]].values))

input_quocNgu_sinoNom = {}
for x, y in zip(file_quocNgu[file_quocNgu.keys()[0]].values, file_quocNgu[file_quocNgu.keys()[1]].values):
    input_quocNgu_sinoNom.setdefault(x, []).append(y)

# #######
def process_word(arrChr):
    for i in range(len(arrChr)):
        for special in ['.', ',', ':']:
            arrChr[i] = arrChr[i].replace(special, "")
    return arrChr

def sortOCR(data):
    j = 0
    while j < len(data) and not (data[j]['points'][0][1] >= data[0]['points'][2][1]): j += 1
    
    if j == len(data): 
        data.reverse()
        return data
    
    res = []
    prevJ = j
    i = 0
    while i < prevJ: 
        Ai_x = data[i]['points'][0][0]
        Bi_x = data[i]['points'][1][0]
        Aj_x = data[j]['points'][0][0]
        Bj_x = data[j]['points'][1][0]
        if not (Bi_x < Aj_x or Bj_x < Ai_x): 
            res.append(data[j])
            res.append(data[i])
            j += 1
            i += 1
        else: 
            if Ai_x < Aj_x:
                res.append(data[i])
                i += 1
            else:
                res.append(data[j])
                j += 1

    res.reverse()
    return res

def pixel_avg_of_words(OCR, TEXT):
    Min = min(len(OCR), len(TEXT))
    sumLenText = sumPixel = 0
    for i in range(Min): 
        sumLenText += len(TEXT[i].split())  
        sumPixel += (OCR[i]['points'][2][1] - OCR[i]['points'][0][1])

    return sumPixel / sumLenText 


def match_bbox(a: list, b: list, cmp): 

    dp = [[0 for _ in range(len(b) + 1)] for __ in range(len(a) + 1)]
    trace = [[(0, 0, 0) for _ in range(len(b) + 1)] for __ in range(len(a) + 1)]

    for i in range(len(a)):
        for j in range(len(b)):
            
            dp[i + 1][j + 1] = min(dp[i][j + 1], dp[i + 1][j]) + 1
            if (dp[i][j + 1] < dp[i + 1][j]): 
                trace[i + 1][j + 1] = (i, j + 1, 0)
            else: 
                trace[i + 1][j + 1] = (i + 1, j, 0)

            if (dp[i + 1][j + 1] > dp[i][j] + 1): 
                dp[i + 1][j + 1] = dp[i][j] + 1
                trace[i + 1][j + 1] = (i, j, 0)

            if cmp(a[i], b[j]):
                dp[i + 1][j + 1] = dp[i][j]
                trace[i + 1][j + 1] = (i, j, 1)

    n, m = len(a), len(b)
    match = {}
    while n > 0 and m > 0:
        if trace[n][m][2]:
            match[n - 1] = m - 1
        (n, m, chs) = trace[n][m]
    
    return match

def bboxAlignment(OCR, TEXT, TEXT_HN):   
    pixel_avg_of_word = pixel_avg_of_words(OCR, TEXT)
 
    OCR_cntWord = []
    for block in OCR: 
        x = (block['points'][2][1] - block['points'][0][1])
        cnt_word = pixel_avg_of_word + 2 * x
        cnt_word //= (2 * pixel_avg_of_word)
        OCR_cntWord.append(int(cnt_word))

    TEXT_cntWord = []
    for sentences in TEXT:
        TEXT_cntWord.append(len(sentences.split()))

    match = match_bbox(OCR_cntWord, TEXT_cntWord, cmp = lambda a, b: a == b)

    result = []
    id = 0
    for index in range(len(OCR)):
        id += 1
        if (index not in match):
            result.append({
                'HN_OCR': OCR[index]['transcription'], 
                'QN': '', 'appear': False, 
                'TEXT_HN': '', 
                'points': str(OCR[index]['points']), 
                'id_sentence': id})
        else:
            result.append({
                'HN_OCR': OCR[index]['transcription'], 
                'QN': TEXT[match[index]], 
                'appear': True, 
                'TEXT_HN': TEXT_HN[match[index]], 
                'points': str(OCR[index]['points']), 
                'id_sentence': str(id)})
    
    return result


def sinoNom_similar_process(ch):
    if ch in input_sinoNom_similar:
        return [ch] + ast.literal_eval(input_sinoNom_similar[ch])
    return [ch]

def quocNgu_SinoNom(ch):
    return input_quocNgu_sinoNom[ch.lower()]

def cmp_word(word_HN, word_QN):

    S1 = sinoNom_similar_process(word_HN)
    S2 = quocNgu_SinoNom(word_QN)

    if word_HN in S2: return 1 # color default
    
    l = len(set(S1) & set(S2))
    if l == 1: return 1 # color default 
    if l > 1: return 2 # color blue 
    
    return 0 # color red


def solve(nameImage, page_index):
    worksheet.write(0, 0, 'ID')
    worksheet.write(0, 1, 'Image Box')
    worksheet.write(0, 2, 'SinoNom OCR')
    worksheet.write(0, 3, 'SinoNom Char')
    worksheet.write(0, 4, 'Chữ Quốc ngữ')
    
    dataOCR = json.loads(img_I[1])
    dataOCR = sortOCR(dataOCR)
    # for i in dataOCR: 
    #     print(i['points'])
    # exit(0)
    aligenment = bboxAlignment(dataOCR, text_pdf[text_pdf.keys()[1]].values, text_pdf[text_pdf.keys()[0]].values)

    row = 1
    for index in aligenment:
        sentenceHN_OCR = list(index['HN_OCR']) # sentence #index
        color = [0 for _ in range(len(sentenceHN_OCR))]
        
        worksheet.write(row, 0, str('LCPv.001' + f'.{page_index}' + '.' + index['id_sentence']))
        worksheet.write(row, 1, index['points'])
        
        if index['appear'] == True:
            sentenceQN = process_word(index['QN'].split())
            match = match_bbox(sentenceHN_OCR, sentenceQN, cmp_word)
            for i in range(len(sentenceHN_OCR)):
                if i in match:
                    color[i] = cmp_word(sentenceHN_OCR[i], sentenceQN[match[i]])

            worksheet.write(row, 3, index['TEXT_HN'])
            worksheet.write(row, 4, index['QN'])
        else:
            color = [3 for _ in range(len(sentenceHN_OCR))]

        format_pairs = []
        for i in range(len(color)):
            if color[i] == 1: 
                format_pairs.append(sentenceHN_OCR[i])
            elif color[i] == 2:
                format_pairs.extend((blue, sentenceHN_OCR[i]))
            elif color[i] == 0: 
                format_pairs.extend((red, sentenceHN_OCR[i]))
            else:
                format_pairs.extend((green, sentenceHN_OCR[i]))

        worksheet.write_rich_string(row, 2, *format_pairs)
        row += 1

    workbook.close()

if __name__ == '__main__':

    with open('Label.txt', 'r') as fileOCR:
        data = fileOCR.read().split('\n')
        data = [_.split('\t')  for _ in data if len(_.split('\t')) > 1]

        for img_I in data:
            
            nameImage = img_I[0].split('/')[-1]
            page_index = nameImage.split('.')[-2]

            solve(nameImage, page_index)
