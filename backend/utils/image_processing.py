from PIL import Image
import os

def resize_image(input_path, output_path, size):
    with Image.open(input_path) as img:
        img = img.resize(size)
        img.save(output_path)

def convert_image(input_path, output_format):
    img = Image.open(input_path)
    output_path = f"{os.path.splitext(input_path)[0]}.{output_format}"
    img.save(output_path, output_format.upper())
    return output_path

def enhance_image(input_path, output_path, brightness_factor):
    from PIL import ImageEnhance
    with Image.open(input_path) as img:
        enhancer = ImageEnhance.Brightness(img)
        enhanced_img = enhancer.enhance(brightness_factor)
        enhanced_img.save(output_path)
