from xlsxwriter.workbook import Workbook
import pandas as  pd
import functools
import json 
import ast

RED_COLOR = 0
DEFAULT_COLOR = 1
BLUE_COLOR = 2
GREEN_COLOR = 3
SPECIAL_CHARS = [
    '.', ',', ':', '-', '!', '?', ';', '(', ')', '[', ']', '{', 
    '}', '"', "'", '%', '*', '+', '=', '/', '\\', '&', '#', '_'
]

_PATH_TYPE = 'dang2/'
_FILE_OUTPUT = 'output.xlsx'
_FILE_NAME = 'text_Kieu1866page045.xlsx'
_FILE_SINONOM_SIMILAR_DIC = 'SinoNom_similar_Dic.xlsx'
_FILE_QUOCNGU_SINONOM_DIC = 'QuocNgu_SinoNom_Dic.xlsx'

TEXT_PDF = pd.read_excel(_FILE_NAME)

workbook = Workbook(_FILE_OUTPUT)
worksheet = workbook.add_worksheet()

file_sinoNom = pd.read_excel(_FILE_SINONOM_SIMILAR_DIC) # lay ra du lieu sinom trong file chi dinh 
file_quocNgu = pd.read_excel(_FILE_QUOCNGU_SINONOM_DIC) # lay ra du lieu quocngu trong file chi dinh 

sinoNom_similar_dic = dict(
    zip(
        file_sinoNom[file_sinoNom.keys()[0]].values, # du lieu cua cot 0  
        file_sinoNom[file_sinoNom.keys()[1]].values  # du lieu cua cot 1
    ) # lay du lieu theo tung hang cua cot 0, cot 1
)

quocngu_sinoNom_dic = {}
for x, y in zip(
    file_quocNgu[file_quocNgu.keys()[0]].values, # du lieu cua cot 0
    file_quocNgu[file_quocNgu.keys()[1]].values  # du lieu cua cot 1
):
    # tao list doi voi tu x: VD: {'x': ['a', 'ab', 'cd', ....]}
    quocngu_sinoNom_dic.setdefault(x, []).append(y)

row_output_xlsx = 1 # hang bat dau trong file output.xlsx

def matching(
    a: list, b: list, cmp, choose = 0
) -> dict: 
    ''' tim cap ghep 

    ghep cap cua day a voi day b neu phan tu 
    cua cmp(a, b) thoa man True thi tien hanh ghep cap 

    args: 
        a: danh sach duoc ghep
        b: danh sach ghep
        cmp: thuoc function dung de so sanh 2 phan tu -> bool
        choose: chon nhan truy van nhung phan tu co the thay doi khong ?
    
    returns:
        danh sach nhung cap a se ghep voi b
    '''

    MAX_VALUE = int('9' * 10)
    dp = [[MAX_VALUE for _ in range(len(b) + 1)] for __ in range(len(a) + 1)]
    trace = [[(0, 0, 0) for _ in range(len(b) + 1)] for __ in range(len(a) + 1)]

    dp[0][0] = 0
    for i in range(len(a) + 1): dp[i][0] = i 
    for i in range(len(b) + 1): dp[0][i] = i
    
    for i in range(len(a)):
        for j in range(len(b)):
            
            dp[i + 1][j + 1] = min(dp[i][j + 1], dp[i + 1][j]) + 1
            dp[i + 1][j + 1] = min(dp[i + 1][j + 1], dp[i][j] + 1)
            
            if dp[i + 1][j + 1] == dp[i][j + 1] + 1:
                trace[i + 1][j + 1] = (i, j + 1, 0)
            
            if dp[i + 1][j + 1] == dp[i + 1][j] + 1:
                trace[i + 1][j + 1] = (i + 1, j, 0)
            
            if dp[i + 1][j + 1] == dp[i][j] + 1:
                trace[i + 1][j + 1] = (i, j, choose)

            if cmp(a[i], b[j]):
                dp[i + 1][j + 1] = dp[i][j]
                trace[i + 1][j + 1] = (i, j, 1)

    #truy van ghep cap 
    n, m = len(a), len(b)
    match = {}
    while n > 0 and m > 0:
        if trace[n][m][2]:
            match[n - 1] = m - 1
        (n, m, chs) = trace[n][m]
    
    return match

class Bbox:
    def __init__(self, transcription: str, points: list[list[int]]):
        self.transcription = transcription
        self.points = points

    def cmp_points(self, other_points: list[list[int]]) -> bool:
        ''' so sanh voi toa do cua bbox 

        args:
            other_points: toa do bbox can so sanh

            example: 
                points = [[1, 2], [3, 4], [5, 6], [7, 8]]
        
        returns:
            True: 
                neu hoanh do cua 2 bbox giao nhau va 
                bbox thu 1 nam o tren bbox thu 2
        '''
        A1, C1 = self.points[0], self.points[2] 
        A2, C2 = other_points[0], other_points[2]
        
        # kiem tra hoanh do 2 diem giao nhau
        if C2[0] < A1[0] or C1[0] < A2[0]: # range (A1[0], C1[0]) and (A2[0], C2[0])
            return A1[0] >= A2[0]
        
        return C1[1] <= C2[1] 

def sort_bbox(data: list[Bbox]):

    for i in range(len(data)):
        for j in range(i + 1, len(data), 1): 

            if data[i].cmp_points(data[j].points) == False:
                data[i], data[j] = data[j], data[i]
    
    return data

class AlignmentWithBbox:
    
    def __init__(self, ocr: list[Bbox], text_of_file: list[str]):
        self.ocr = ocr 
        self.text_of_file = text_of_file
    
    def _remove_special_char(self, arr: list[str]) -> list[str]:
        ''' xoa nhung ki tu dac biet 

        xoa nhung ki tu dac biet trong khong phai la ki tu 
        trong mang SPECIAL_CHARS

        args:
            arr: la mang chua nhung ki tu can xu ly 

        returns: 
            mang ki tu sau khi xoa nhung ki tu dac biet  
        '''
        for i in range(len(arr)):
            for special in SPECIAL_CHARS:
                if special == '-':
                    arr[i] = arr[i].replace(special, ' ')
                else:
                    arr[i] = arr[i].replace(special, "")

        return [i for i in arr if i != '']
    
    def _pixel_avg_of_words(self) -> int:
        ''' tinh toan 1 tu trong bbox chiem bao nhieu pixel 

        returns: 
            gia tri pixel trung binh cua 1 tu trong bbox 
        '''
        sumLenText = sum(len(text.split()) for text in self.text_of_file)
        avg_text = sumLenText // len(self.text_of_file) # trung binh 1 cau co (avg_text) tu 
        
        sumPixel = sum(
            abs(text.points[2][1] - text.points[0][1]) // avg_text
            for text in self.ocr
        )

        avg_pixel = sumPixel // len(self.ocr) # trung binh 1 cau co (avg_pixel) pixel 

        return avg_pixel 

    def _cnt_word_in_bbox(self) -> list[int]:
        ''' dem so luong tu trong 1 bbox

        returns:   
            danh sach so luong tu tuong ung voi tung bbox
        '''

        pixel_avg_of_word = self._pixel_avg_of_words() 

        list_cnt_word = []
        for bbox in self.ocr: 
            x = abs(bbox.points[2][1] - bbox.points[0][1])
            cnt_word = (pixel_avg_of_word + 2 * x) //  (2 * pixel_avg_of_word)

            cnt_word = len(bbox.transcription) # thu nghiem !!!!!!!!!!!!!!!!!!!!!!!!!!!
            list_cnt_word.append(int(cnt_word))

        return list_cnt_word

    def _cnt_word_in_text_of_file(self) -> list[int]:
        ''' so luong tu tuong ung voi tung text trong file 

        returns:
            danh sach so luong tu tuong ung voi tung cau 
        '''
        list_cnt_word = []
        for sentences in self.text_of_file:
            sentences = self._remove_special_char([sentences])
            sentences = sentences[0]
            list_cnt_word.append(
                len(sentences.split())
            )
            # print(sentences, len(sentences.split())) 
        
        return list_cnt_word

    def matching_by_cnt_word(self) -> list[dict]:
        ''' ghep cap theo so luong tu 

        returns:
            danh sach sau nhung cau tuong ung 
            sau khi da ghep theo so luong tu 
        '''
        cnt_word_of_ocr = self._cnt_word_in_bbox()
        cnt_word_of_text = self._cnt_word_in_text_of_file()
        
        match = matching(
            cnt_word_of_ocr, 
            cnt_word_of_text, 
            cmp = lambda a, b: a == b,
            choose=0
        )

        # tao danh sach cua cau ocr duoc voi cau quoc ngu trong file text 
        # kem theo nhung thong in phu nhu bbox points and thu tu cua cau  
        result = []
        id = 0
        for index in range(len(self.ocr)):
            
            sentence_ocr = self.ocr[index].transcription
            bbox_points_ocr = self.ocr[index].points
            
            if index not in match:
                result.append({
                    'sentence_ocr': sentence_ocr, 
                    'id_match': -1, 
                    'points': bbox_points_ocr, 
                    'id_sentence': index
                })

            else:
                result.append({
                    'sentence_ocr': sentence_ocr, 
                    'id_match': match[index], 
                    'points': bbox_points_ocr, 
                    'id_sentence': index 
                })
        
        return result

class AligmentWithWord(AlignmentWithBbox):
    
    def __init__(self, ocr_matched: list[dict], text_of_file: list[str]):
        self.ocr_matched = ocr_matched
        self.text_of_file = text_of_file
    
    def _is_number(self, number) -> bool:
        ''' kiem tra number co phai la so nguyen khong ? 

        '''
        try:
            int(number)
            return True
        except ValueError:
            return False
        
    
        
    def _get_sinoNom_similar_dic(self, word: str) -> list[str]:
        ''' lay ra day chu tuong dong voi word 

        args:   
            word: chu han nom
        returns:
            danh sach nhung chu han nom tuong dong 

        '''
        if word in sinoNom_similar_dic:
            return [word] + ast.literal_eval(sinoNom_similar_dic[word])
        return [word]

    def _get_quocngu_sinoNom_dic(self, word: str) -> list[str]:
        ''' lay ra danh sach han nom

        lay ra nhung tu han nom duoc dich tu chu quoc ngu 

        args:
            word: chu quoc ngu 
        '''
        word = word.lower()
        if word not in quocngu_sinoNom_dic:
            return []
        
        return quocngu_sinoNom_dic[word.lower()]

    def _cmp_word(self, word_HN, word_QN) -> int:
        ''' kiem tra 2 tu co giong nhau khong 

        args:
            word_HN: tuong ung voi chu han nom 
            word_QN: tuong ung voi chu quoc ngu 
        
        returns:
            to mau tuong ung cho tu han nom
        '''

        if word_HN in SPECIAL_CHARS: return DEFAULT_COLOR 

        if word_QN in SPECIAL_CHARS: return DEFAULT_COLOR 

        if self._is_number(word_QN) and self._is_number(word_HN):
            return DEFAULT_COLOR

        S1 = self._get_sinoNom_similar_dic(word_HN)
        S2 = self._get_quocngu_sinoNom_dic(word_QN)

        if word_HN in S2: return DEFAULT_COLOR 
        
        l = len(set(S1) & set(S2))

        if l != 0: return BLUE_COLOR    
        return RED_COLOR

    def matching_by_word(self) -> list[dict]:
        ''' ghep cac tu tuong ung trong nhung cau da ocr 

        returns:
            (color, sentence_ocr, points, id_sentence_quocngu) 
        '''
        results = []
        for sentence in self.ocr_matched:

            sentence_ocr = sentence['sentence_ocr']
            id_sentence_quocngu = sentence['id_match']
            points = sentence['points']
            
            color = [GREEN_COLOR for _ in range(len(sentence_ocr))]

            if id_sentence_quocngu != -1:
                sentence_quocngu = self.text_of_file[id_sentence_quocngu]
                sentence_quocngu = super()._remove_special_char(
                    sentence_quocngu.split()
                )
        
                matching_word = matching(
                    sentence_ocr, 
                    sentence_quocngu, 
                    cmp=self._cmp_word,
                    choose=0
                )

                for index in range(len(sentence_ocr)):
                    if index in matching_word:
                        color[index] = self._cmp_word(
                            sentence_ocr[index], 
                            sentence_quocngu[matching_word[index]]
                        )
                    else:
                        color[index] = RED_COLOR
        
                results.append((color, sentence_ocr, 
                                points, id_sentence_quocngu))

            else:
                results.append((color, sentence_ocr, 
                                points, -1))
            
        return results

def extract_text_in_file(
    start_page: int, stop_page: int
) -> list:
    ''' trich nhung noi dung trong file pdf 

    args:
        start_page: page bat dau noi dung 
        stop_page: page dung khong can can doc noi dung sau do 

    returns: 
        phan chia tung cau tuong ung voi chu quoc ngu va chu han nom 
    '''

    text_HN,text_QN = [], []
    col0 = TEXT_PDF.keys()[0]
    col1 = TEXT_PDF.keys()[1]
    col2 = TEXT_PDF.keys()[2]
    
    for page_id, HN, QN in zip(
        TEXT_PDF[col0].values, 
        TEXT_PDF[col1].values, 
        TEXT_PDF[col2].values
    ):
        if start_page < int(page_id) and int(page_id) < stop_page:
            text_HN.append(HN)
            text_QN.append(QN)
    
    return text_HN, text_QN

def write_output(
    start_row: int, 
    result: list[dict], 
    text_HN: list[str],
    text_QN: list[str],
    name_image: str,
) -> int:
    ''' xuat noi dung ra file ouput.xlsx 
    
    args:
        start_row: hang bat dau trong file output 
        result: du lieu dung de dua ra file 
        text_HN: noi dung cau han nom trong file pdf
        text_QN: noi dung cau quoc ngu trong file pdf 
        name_image: ten file anh 

    returns:
        hang cuoi cung sau khi in ra noi dung trong file xlsx
    '''
    red = workbook.add_format({'color': 'red'})
    blue = workbook.add_format({'color': 'blue'})
    green = workbook.add_format({'color': 'green'})
    default_color = workbook.add_format({'font_color': 'black'})
    
    column_title = ['ID', 'Image Box', 'SinoNom OCR', 'SinoNom Char', 'Chữ Quốc ngữ']
    for i in range(len(column_title)): 
        worksheet.write(0, i, column_title[i])
    
    row = start_row
    page_index = name_image.split('.')[1]
    name_image = name_image.split('.')[0]
    id_sentence_ocr = 1


    for (color, sentence_ocr, points, id_sentence_quocngu) in result:
    
        worksheet.write(row, 0, str(name_image + '.' + str(page_index) + '.' + str(id_sentence_ocr)))
        id_sentence_ocr += 1
        worksheet.write(row, 1, str(points))
        
        if id_sentence_quocngu != -1:
            worksheet.write(row, 3, text_HN[id_sentence_quocngu])
            worksheet.write(row, 4, text_QN[id_sentence_quocngu])

        format_pairs = []
        for i in range(len(color)):
            if color[i] == DEFAULT_COLOR: 
                format_pairs.extend((default_color, sentence_ocr[i]))
            elif color[i] == BLUE_COLOR:
                format_pairs.extend((blue, sentence_ocr[i]))
            elif color[i] == RED_COLOR: 
                format_pairs.extend((red, sentence_ocr[i]))
            else:
                format_pairs.extend((green, sentence_ocr[i]))

        worksheet.write_rich_string(row, 2, *format_pairs)

        row += 1

    return row 

def solve(
    name_image: str, 
    start_page_index: int, stop_page_index: int, 
    data_ocr: str
) -> None:
    
    data_ocr = json.loads(data_ocr) 
    data_ocr = [
        Bbox(bbox_i['transcription'], bbox_i['points']) 
        for bbox_i in data_ocr
    ]

    data_ocr = sort_bbox(data_ocr)
    text_HN, text_QN = extract_text_in_file(
        start_page_index, 
        stop_page_index
    )
    
    alignment_bbox = AlignmentWithBbox(data_ocr, text_QN)
    resuls_alignment_by_cnt_word = alignment_bbox.matching_by_cnt_word()

    results = AligmentWithWord(resuls_alignment_by_cnt_word, text_QN)
    
    results = results.matching_by_word()
    
    global row_output_xlsx
    row_output_xlsx = write_output(
        row_output_xlsx, 
        results, 
        text_HN,
        text_QN,
        name_image
    )

def main():

    with open(_PATH_TYPE + 'Label.txt', 'r') as fileOCR:
        data = fileOCR.read().split('\n')
        data = [_.split('\t')  for _ in data if len(_.split('\t')) > 1]
        
        list_img = []
        for [name_image, data_ocr] in data:
            
            name_image = name_image.split('/')[-1]
            page_index = name_image.split('.')[-2]

            list_img.append((name_image, page_index, data_ocr))

        next_page_index = [
            int(page_index)
            for _, page_index, __ in list_img
        ]

        next_page_index.append(int(1e9))

        id = 0
        for name_image, page_index, data_ocr in list_img:
            
            name_image = '.'.join(name_image.split('.')[:2])

            id += 1

            start_page_index = int(page_index)
            stop_page_index = next_page_index[id]
            
            solve(name_image, start_page_index, stop_page_index, data_ocr)
    

    workbook.close()

main()
    
