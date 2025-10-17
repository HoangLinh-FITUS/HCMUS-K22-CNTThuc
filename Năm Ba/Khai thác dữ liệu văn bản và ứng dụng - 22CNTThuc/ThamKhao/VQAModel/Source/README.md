# Nhóm 1 - ViVQA

## Thành viên:

| MSSV     | Họ tên            |
| -------- | ----------------- |
| 20120240 | Dương Thị An      |
| 20120270 | Cao Tấn Đức       |
| 20120284 | Lê Đức Hậu        |
| 20120288 | Nguyễn Trung Hiếu |

## Cấu trúc thư mục source:

```bash
.
├── BARTPho_BEiT_Generate.ipynb
├── BARTPho_ViT_Generate.ipynb
├── BEiT_mBERT_Classification.ipynb
├── ViT5_ViT_Generate.ipynb
├── ViT_PhoBERT_Classification.ipynb
├── ViT_mBERT_Classification.ipynb
│
├── ViVQA-Models
│   ├── Link-Model-Result.txt
│   ├── bartpho_beit_generate.yaml
│   ├── bartpho_vit_generate.yaml
│   ├── beit_mbert_classification.yaml
│   ├── vit5_vit_generate.yaml
│   ├── vit_mbert_classification.yaml
│   └── vit_phobert_classification.yaml
│
└── vivqa-dataset
    └── LinkDataset.txt
```

1. Các file notebook (ipynb): Chứa code của các mô hình bao gồm các quá trình:

- Preprocess data
- Build dataset (train/valid/test - cố định randomstate)
- Kiến trúc model
- Train
- Predict và xuất kết quả.

2. Folder "ViVQA-Models":

- Link download folder bao gồm:
  - Các file config (yaml) chứa config (lr, pretrained_name,...) của các mô hình.
  - Các folder con, mỗi folder ứng với kết quả của một mô hình, bao gồm:
    - File save model (best model/last model)
    - result.csv - kết quả dự đoán
    - log.txt - Training log

3. Folder "vivqa-dataset" chứa link download dataset gốc (không gồm ảnh COCO) và link download của nhóm đã xử lý (có chứa ảnh COCO trong dataset).

## Hướng dẫn chạy code

### Local

- Yêu cầu: Python >= 3.10
- Cài đặt các thư viện cần thiết
- Download đầy đủ các file config (yaml)
- GPU có hỗ trợ CUDA

Chạy lần lượt các notebook ứng với tên model và kết quả sẽ được tạo tại folder "ViVQA-Models".

### Colab

- Upload các file notebook trên lên Colab hoặc tạo bản sao từ folder của nhóm chia sẻ - [Folder Notebook](https://drive.google.com/drive/folders/1wApHJ3myrcopp_ggQ1Sb5uwvasLzDUr3?usp=drive_link)

- Tạo folder "ViVQA-Models" ngay tại MyDrive và upload các file config (yaml)

- Chạy file notebook và kết quả sẽ được tạo tại folder "ViVQA-Models".
