function [backIm backStack usable] = calculateBackgroundFromFilelist_thermal(filelist, nvid, qntl, frameNumber)

% Inputs
%   filelist - list of video files to calculate a collective background
%   image for
%
%   nvid - how many videos to sample
%
%  frameNumber - what frame number to choose from vid?
%
% qntl - quantile to calculate for background. If single number, single
% image is returned in 'backIm'. If vector, an image stack is return with a
% corresponding image for each qntl supplied in 'backIm'
%
% Output
%
%   backIm - background image


ind = floor(linspace(1,numel(filelist),nvid)); %create video index

usable = logical(zeros((size(ind))));

for i = 1:nvid
    %%
    filename = [filelist(ind(i)).folder '/' filelist(ind(i)).name];
    try
        mov = VideoReader(filename);
        im = read(mov,frameNumber); %read frame
        im = convertThermalImage(im); %Convert to thermal image
        
        im = double(im - median(median(im))); % Adjust for absolute changes in scale
        
        if ~exist('backStack') %If we're on the first rep, create empty matrix for all frames
            backStack = double(zeros(size(im,1), size(im,2), nvid));
        end
        
        backStack(:,:,i) = im;
        
        if var(reshape(im, numel(im), 1)) > 0
            usable(i) = 1;
        else
            usable(i) = 0;
        end
    catch
        usable(i) = 0;
        continue
    end
end

%% Calculate median image
nQtl = numel(qntl);

if nQtl == 1
    backIm =  quantile(backStack(:,:,usable),qntl, 3);
else
    backIm = double(zeros(size(im,1), size(im,2), nQtl));
    for i = 1:nQtl
        backIm(:,:,i) = quantile(backStack(:,:,usable),qntl(i), 3);
    end
end


