function [temp croppedImage] = takeTempReadingFromThermalImage(thermIm, x,y)
    %%
    x = round(x);
    y = round(y);
    %temp = thermIm(y,x);
    
    window = 3;
    
    %Define cropping window
    ymin = y - window;
    ymax = y+ window;
    xmin = x - window;
    xmax = x+window;
    
    
    %Make sure cropped area doesn't extend beyond image borders
    if xmin < 1
        xmin = 1;
    end
    
    if xmax > size(thermIm,2)
        xmax = size(thermIm,2);
    end
    
    if  ymin < 1
        ymin = 1;
    end
    
    if ymax > size(thermIm,1)
        ymax = size(thermIm,1);
    end
    croppedImage = thermIm(ymin:ymax, xmin:xmax);
    %croppedImageSm = smooth2a(croppedImage, round(window/10), round(window/10));
    temp = median(median(croppedImage)); %median or max?