function []  = diagnoseBackgroundSubstraction(vid,backIm, thresh)

%Inputs:
%vid - video for tracking
%backIm - reference background (same dimensions as vid)
%thresh - intensity threshold for difference from background
for i = 1:vid.NumberOfFrames
    im  = rgb2gray(read(vid,i));
    %subplot(1,2,1);
    imshow(im);
    hold on
    imdiff = abs(int8(im)-int8(backIm)) > thresh;
    h = imshow(cat(3,ones(size(im)), zeros(size(im)),zeros(size(im))));
    set(h, 'AlphaData', imdiff.*0.5);
    hold off
    %subplot(1,2,2);
    %imshow(forBackIm);
    drawnow
end