# pip install --upgrade pip
# pip install transformers
# pip install tensorflow
# pip install tf-keras
# pip install sentencepiece

from transformers import pipeline

corrector = pipeline("text2text-generation", model="bmd1905/vietnamese-correction-v2")
# Example
MAX_LENGTH = 512

# Define the text samples
texts = [
    "côn viec kin doanh thì rất kho khan nên toi quyết dinh chuyển sang nghề khac  ",
    "toi dang là sinh diên nam hai ở truong đạ hoc khoa jọc tự nhiên , trogn năm ke tiep toi sẽ chọn chuyen nganh về trí tue nhana tạo",
    "Tôi  đang học AI ở trun tam AI viet nam  ",
    "Nhưng sức huỷ divt của cơn bão mitch vẫn chưa thấm vào đâu lsovớithảm hoạ tại Bangladesh ăm 1970 ",
    "Lần này anh Phươngqyết xếp hàng mua bằng được 1 chiếc",
    "một số chuyen gia tài chính ngâSn hànG của Việt Nam cũng chung quan điểmnày",
    "Cac so liệu cho thay ngươi dân viet nam đang sống trong 1 cuôc sóng không duojc nhu mong đọi",
    "Nefn kinh té thé giới đang đúng trươc nguyen co của mọt cuoc suy thoai",
    "Khong phai tất ca nhưng gi chung ta thấy dideu là sụ that",
    "chinh phủ luôn cố găng het suc để naggna cao chat luong nền giáo duc =cua nuoc nhà",
    "nèn kinh te thé giới đang đứng trươc nguy co của mọt cuoc suy thoai",
    "kinh tế viet nam dang dứng truoc 1 thoi ky đổi mơi chưa tung có tienf lệ trong lịch sử"
]

# Batch prediction
predictions = corrector(texts, max_length=MAX_LENGTH)

# Print predictions
for text, pred in zip(texts, predictions):
    print("- " + pred['generated_text'])
