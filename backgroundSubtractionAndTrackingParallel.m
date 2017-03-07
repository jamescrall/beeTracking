%Get user inputs for files - automate later
[filename pathname] = uigetfile('*.avi', 'select movie');
[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');

%Read in taglist
taglist = csvread([tagpathname '/' tagfile]);

%Create VideoReader object
vid = VideoReader([pathname '/' filename]);

nframes = vid.NumberOfFrames;

%% calculate background
bIm = medianImage(vid,30);
imshow(bIm);
title('outline nest structure');
nestOutline = roipoly();

%% Set tracking parameters
brFilt = [12 12];
brThresh = 0.1;

%% Set up dummy variables
tags = taglist(:,1);
xcent = nan(nframes, numel(tags));
ycent = nan(nframes, numel(tags));
frontx = nan(nframes, numel(tags));
fronty = nan(nframes, numel(tags));
occupiedNestPixels = nan(nframes);
occupiedNonNestPixels = nan(nframes);
nBeeChunks = nan(nframes);
ntags = numel(tags);

%% Track!
parpool(2);

%% Create progressbar pobject
hbar = parfor_progressbar(nframes,'Tracking tags...')
tic

%
parfor i = 1:nframes
    %%
    try
        
        thr = 10;
        im = rgb2gray(read(vid,i));
        imd = abs(int8(bIm) - int8(im));
        imd = imd > thr;
        
        %Segment into individual bees
        se = strel('disk',6);
        ime = imerode(imd,se);
        
        %More permissive dilation to capture tags
        se = strel('disk',30);
        
        impd = imdilate(imd,se); %im permissive dilation
        
        imf = im.*uint8(impd);
        F = locateCodes(imf,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', brFilt, 'bradleyThreshold', brThresh, 'vis', 0);
        rtags = [F.number];
        for j = 1:ntags
            
            rt = F(rtags == tags(j));
            
            if numel(rt) == 1
                xcent(i,j) = rt.Centroid(1);
                ycent(i,j) = rt.Centroid(2);
                frontx(i,j) = rt.frontX;
                fronty(i,j) = rt.frontY;
            end
        end
    catch
        continue
    end
    
    %%
    se = strel('disk', 12);
    ims = imdilate(imd,se);
    occMap = regionprops(ims);
    
    sizeTh = 12000;
    occMap = occMap([occMap.Area] > sizeTh);
    occupiedNestPixels(i) = sum(sum(ims(nestOutline))); %nestPixelsOccupied
    occupiedNonNestPixels = sum(sum(ims(~nestOutline))); %nonNestPixelsOccupied
    nBeeChunks(i) = numel(occMap);
    
    %Report progress
    hbar.iterate(1);
end

toc
trackingData = nan(nframes, ntags, 4);
trackingData(:,:,1) = xcent;
trackingData(:,:,2) = ycent;
trackingData(:,:,3) = frontx;
trackingData(:,:,4) = fronty;

save(strcat(filename, '_tracked.mat'), 'trackingData', 'taglist', 'bIm');

%% Interpolate
for j = 1:4
    trackingData(:,:,j) = fixShortNanGaps(trackingData(:,:,j),10);
end
%% visualization check
for i = 1:500
    im = read(vid,i);
    imshow(imadjust(rgb2gray(im)));
    hold on;
    plot(trackingData(i,:,1), trackingData(i,:,2), 'r.', 'MarkerSize', 20);
    hold off
    drawnow
end