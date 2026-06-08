from PIL import Image
import os
import glob
import math
from pathlib import Path

def make_dir(dpath):
    if not os.path.exists(dpath):
        os.makedirs(dpath)
    return dpath

def stich_folder(folder_path, outputDir):
    path =folder_path+"/*.png"
    print(path)
    pngFilesList =  glob.glob(path)
    fParts= os.path.split(folder_path)
    finalNamePart=fParts[len(fParts)-1]
    beforeName=""
    if len(fParts) > 1:
        beforeName=fParts[len(fParts)-2]

    print(finalNamePart)
    outputPath=outputDir+""+os.path.basename(beforeName)+"-"+finalNamePart+".png"
    print("OUTPUT TO:"+outputPath)
    count = len(pngFilesList)
    if count > 1 and count < 1000:
        sqr = (math.sqrt(count))
        sqr=sqr+0.999999999
        intSqr = int(sqr)
        pngFilesList.sort() 
        firstImg=Image.open(pngFilesList[0])
        w=firstImg.width
        h=firstImg.height
        totalW=w*intSqr
        totalH=h*intSqr
        newim = Image.new(mode="RGBA", size=(totalW, totalH))
        x=0
        y=0
        for file in pngFilesList:
            print("OPEN:"+file)
            img = Image.open(file)
            newim.paste(img, (x,y))
            x=x+w
            if x>=totalW:
                x=0
                y=y+h
        print(outputPath)
        newim.save(outputPath, quality=100)

rootDir = '/Workspaces/base-image'

outputDir=rootDir+"/../stiched-image-dir/"
make_dir(outputDir)
    
for dirName, subdirList, fileList in os.walk(rootDir):
    stich_folder(dirName, outputDir)