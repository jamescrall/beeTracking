function [temp croppedImage] = takeTempReadingFromThermalImage(thermIm, x,y)
    %%
    x = round(x);
    y = round(y);
    %temp = thermIm(y,x);
    
    window = 20;
    croppedImage = thermIm((y - window):(y+window), (x-window):(x+window));
    %croppedImageSm = smooth2a(croppedImage, round(window/10), round(window/10));
    temp = max(max(croppedImage));