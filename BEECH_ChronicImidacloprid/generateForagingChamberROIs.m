%Load masterData manually and navigate to correct folder

im = masterData(1).colonyData(4).forBackIm;
imshow(im);

[nectarMask nectarX nectarY] = roipoly();

[pollenMask pollenX pollenY] = roipoly();

%% Check validity across different colonies

red = cat(3, ones(size(im)), zeros(size(im)), zeros(size(im)));
green = cat(3, zeros(size(im)), ones(size(im)), zeros(size(im)));


for i = 1:numel(masterData)
    
    imshow(masterData(i).colonyData(6).forBackIm)
    hold on;
    h = imshow(red);
    set(h, 'AlphaData', nectarMask.*0.3);
    
    h = imshow(green);
    set(h, 'AlphaData', pollenMask.*0.3);
    pause(1);
end

%% Save ROIs

save('foragingROIs', 'nectarMask', 'nectarX', 'nectarY', 'pollenMask', 'pollenX', 'pollenY');