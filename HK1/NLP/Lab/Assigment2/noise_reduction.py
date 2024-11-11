from PIL import ImageEnhance, Image, ImageFilter
import matplotlib.pyplot as plt

def resize_image(path_image, max_size=5000):
    img = Image.open(path_image)
    width, height = img.size
    total_size = width + height

    if total_size > max_size:
        scale_factor = max_size / total_size
        new_width = int(width * scale_factor)
        new_height = int(height * scale_factor)
        img = img.resize((new_width, new_height), Image.LANCZOS)

    img.save(path_image)

def change_brightness(img: Image, brightness_value: float) -> Image:
    ''' Change the brightness of the photo

    args:
        img: image 
        brightness_value: value to change the brightness of the photo 
    
    returns:
        photo after brightness increase 
    '''

    # increase image brightness by brightness_value
    image_enhanced_brightness = ImageEnhance.Brightness(img)
    image_enhanced_brightness = image_enhanced_brightness.enhance(brightness_value) 

    return image_enhanced_brightness

def change_contrast(img: Image, contrast_value: float) -> Image:
    ''' Change the contrast of the photo

    args:
        img: image 
        contrast_value: value to change the contrast of the photo 
    
    returns:
        photo after contrast increase 
    '''

    # increase image contrast by contrast_value
    image_enhanced_contrast = ImageEnhance.Contrast(img)
    image_enhanced_contrast = image_enhanced_contrast.enhance(contrast_value) 
    
    return image_enhanced_contrast

def image_preprocessing(
    img: Image, 
    brightness: float = 1.5,
    contrast: float = 3.0,
    blur: float = 0.8
) -> Image:
    ''' Image preprocessing enhances OCR capabilities

    Change the blur, brightness, contrast, and size of 
    the photo so that the text in the photo stands out the most and reduces noise. 

    args: 
        img: image
        brightness: thay doi do sang 
        contrast: thay doi do tuong phan 
        blur_value: thay doi do mo
    '''

    img = img.filter(ImageFilter.BoxBlur(blur))

    image_enhanced_brightness = change_brightness(img, brightness)
    image_enhanced_contrast = change_contrast(img, contrast)

    image_process = change_contrast(image_enhanced_brightness, contrast)

    # plt.subplot(1, 3, 1)
    # plt.imshow(image_enhanced_brightness)
    # plt.subplot(1, 3, 2)
    # plt.imshow(image_enhanced_contrast)
    # plt.subplot(1, 3, 3)
    # plt.imshow(image_process) 
    # plt.show()
    
    return image_process