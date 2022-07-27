# Resize images in a folder while maintaining aspect ratio.
import PIL
import os
import os.path
from PIL import Image

f = r'C:\Users\xxx\xxx\imgs_folder'
for file in os.listdir(f):
    f_img = f+"/"+file
    img = Image.open(f_img)
    img.thumbnail((400, 400)) # Set Max height and Width
    img.save(f_img)
    print(img.size)
