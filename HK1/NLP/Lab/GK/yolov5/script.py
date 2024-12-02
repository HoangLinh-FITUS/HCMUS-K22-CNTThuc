import os
from pathlib import Path
import torch
from PIL import Image

model = torch.hub.load('ultralytics/yolov5', 'custom', path='./weights/best.pt')
model.conf = 0.5

print("Model loaded successfully")

# Adjust the directories as needed
images_dir = './dataset2/images/'
annotations_dir = './dataset2/labels/'
os.makedirs(annotations_dir, exist_ok=True)

def normalize_bbox(x_center, y_center, width, height, img_width, img_height):
    x_center /= img_width
    y_center /= img_height
    width /= img_width
    height /= img_height
    return x_center, y_center, width, height

for image_path in Path(images_dir).glob("*.*"):
    if image_path.suffix.lower() not in [".jpg", ".jpeg", ".png"]:
        continue
    
    results = model(str(image_path))
    
    with Image.open(image_path) as img:
        img_width, img_height = img.size
        
    predictions = results.xywh[0]  # Predictions in xywh format (x_center, y_center, width, height)
    annotation_path = os.path.join(annotations_dir, f"{image_path.stem}.txt")

    with open(annotation_path, "w") as f:
        for *box, conf, cls in predictions:
            x_center, y_center, width, height = box

            x_center, y_center, width, height = normalize_bbox(
                x_center.item(), y_center.item(), width.item(), height.item(), img_width, img_height
            )

            class_id = int(cls)
            f.write(f"{class_id} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}\n")

    print(f"Annotated {image_path.name}, saved to {annotation_path}")

print(f"Annotations saved to {annotations_dir}")
