from PIL import Image
import os
import glob
import math
import sys
from pathlib import Path

#def stich_folder(folder_path, outputDir):
#    path =folder_path+"/*.png"
#    pngFilesList =  glob.glob(path)
#    fParts= os.path.split(folder_path)
#    finalNamePart=fParts[len(fParts)-1]
#    beforeName=""
#    if len(fParts) > 1:
#        beforeName=fParts[len(fParts)-2]
#
#    print(finalNamePart)
#    outputPath=outputDir+""+os.path.basename(beforeName)+"-"+finalNamePart+".png"
#    print("OUTPUT TO:"+outputPath)
#    count = len(pngFilesList)
#    if count > 1 and count < 100:
#        sqr = (math.sqrt(count))
#        sqr=sqr+0.999999999
#        intSqr = int(sqr)
#        pngFilesList.sort() 
#        firstImg=Image.open(pngFilesList[0])
#        w=firstImg.width
#        h=firstImg.height
#        totalW=w*intSqr
#        totalH=h*intSqr
#        newim = Image.new(mode="RGBA", size=(totalW, totalH))
#        x=0
#        y=0
#        for file in pngFilesList:
#            print("OPEN:"+file)
#            img = Image.open(file)
#            newim.paste(img, (x,y))
#            x=x+w
#            if x>=totalW:
#                x=0
#                y=y+h
#        print(outputPath)
#        newim.save(outputPath, quality=100)

def get_alpha(maskPixel):
    #print(str(maskPixel[0])+","+str(maskPixel[1])+","+str(maskPixel[2]))
    if maskPixel[0]==0 and maskPixel[1]==0 and maskPixel[2]==0:
        return 0
    if maskPixel[0]==0 and maskPixel[1]==0 and maskPixel[2]==255:
        return 205
    if maskPixel[0]==0 and maskPixel[1]==128 and maskPixel[2]==0:
        return 50
    if maskPixel[0]==0 and maskPixel[1]==255 and maskPixel[2]==0:
        return 100
    if maskPixel[0]==0 and maskPixel[1]==255 and maskPixel[2]==255:
        return 150
    return 255

outputPath="./automasked.png"

source_file = sys.argv[1]
print ("load file:" + source_file)
source_image=Image.open(source_file)

mask_template = Image.open("AUTO_MASK_TEMPLATE.png")

newImage = Image.new(mode="RGBA", size=(source_image.width, source_image.height))

px = newImage.load()

for y in range (0, source_image.height):
  for x in range (0, source_image.height):
      sourcePixel = source_image.getpixel( (x,y) )
      maskPixel = mask_template.getpixel( (x,y) )
      px[x,y] = (sourcePixel[0], sourcePixel[1],sourcePixel[2], get_alpha(maskPixel))


#newImage.paste(source_image,0,0)
newImage.save(outputPath, quality=100)

print("done!" + outputPath)