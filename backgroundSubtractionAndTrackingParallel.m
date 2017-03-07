%Get user inputs for files - automate later
[filename pathname] = uigetfile('*.avi', 'select movie');
[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');

%Read in taglist
taglist = csvread([tagpathname '/' tagfile]);

%Create VideoReader object
vid = VideoReader([pathname '/' filename]);

nframes = vid.NumberOfFrames;

%% calculate background for both nest and
bIm = medianImage(vid,30);
imshow(bIm);
title('outline nest structure');
nestOutline = roipoly();

%% Track!
parpool(4);

%% Track nest video

% Set tracking parameters
brFilt = [12 12];
brThresh = 0.1;

%run tracking
nestTrackingData = trackCCNestVideoP(vid,brFilt, brThresh, bIm, nestOutline, taglist);

%% Track foraging chamber video
forFilename = strrep(filename, 'NC', 'FC');
forVid = VideoReader([pathname '/' forFilename]);
forBackIm = medianImage(forVid, 30);

brFilt = [9 9];
brThresh = 0.01;
forageTrackingData = trackCCForageVideoP(forVid, brFilt, brThresh, forBackIm, taglist);


%% Interpolate
for j = 1:4
    nestTrackingData(:,:,j) = fixShortNanGaps(nestTrackingData(:,:,j),10);
    forageTrackingData(:,:,j) = fixShortNanGaps(forageTrackingData(:,:,j),10);
end

%% visualization check, untested
for i = 1:300
    subplot(2,1,1);
    im = read(vid,i);
    imshow(imadjust(rgb2gray(im)));
    hold on;
    plot(nestTrackingData(i,:,1), nestTrackingData(i,:,2), 'r.', 'MarkerSize', 20);
    hold off
    
    subplot(2,1,2);
        subplot(2,1,1);
    im = read(forVid,i);
    imshow(imadjust(rgb2gray(im)));
    hold on;
    plot(forageTrackingData(i,:,1), forageTrackingData(i,:,2), 'r.', 'MarkerSize', 20);
    hold off
    drawnow
end
