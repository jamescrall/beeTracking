%Get user inputs for folder
[filename pathname] = uigetfile('*.avi', 'select first movie');
[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');

%Read in taglist
taglist = csvread([tagpathname '/' tagfile]);

%% Create list of movie pairs
cd(pathname);
list = dir('*NC.avi');

%% generate manual inputs of nest outlines
backgroundImages = struct();

for zz = 1:numel(list)
    
    vid = VideoReader(list(zz).name);
    bIm = medianImage(vid,30);
    % calculate background for both nest and
    imshow(bIm);
    title('outline nest structure');
    nestOutline = roipoly();
    backgroundImages(zz).bIm = bIm;
    backgroundImages(zz).filename = list(zz).name;
    backgroundImages(zz).path = pathname;
    backgroundImages(zz).nestOutline = nestOutline
    
    clear bIm
    clear nestOutline
end

%%
vis = 0;
for zz = 1:numel(list)
    filename = list(zz).name
    %Create VideoReader object
    vid = VideoReader([pathname '/' filename]);
    
    nframes = vid.NumberOfFrames;
    
    
    %% Track!
    %parpool(4);
    
    %% Track nest video
    
    % Set tracking parameters
    brFilt = [12 12];
    brThresh = 0.1;
    
    %run tracking
    nestTrackingData = trackCCNestVideoP(vid,brFilt, brThresh, backgroundImages(zz).bIm, backgroundImages(zz).nestOutline, taglist, 20);
    %% Track foraging chamber video
    forFilename = strrep(filename, 'NC', 'FC');
    forVid = VideoReader([pathname '/' forFilename]);
    forBackIm = medianImage(forVid, 30);
    
    brFilt = [9 9];
    brThresh = 0.01;
    forageTrackingData = trackCCForageVideoP(forVid, brFilt, brThresh, forBackIm, taglist, 20);
    
    %% Interpolate
    for j = 1:4
        nestTrackingData(:,:,j) = fixShortNanGaps(nestTrackingData(:,:,j),10);
        forageTrackingData(:,:,j) = fixShortNanGaps(forageTrackingData(:,:,j),10);
    end
    
    %% Save data
    bIm = backgroundImages(zz).bIm;
    nestOutline = backgroundImages(zz).nestOutline;
    save(strrep(vid.Name, '.avi', 'mat'), 'nestTrackingData', 'forageTrackingData', 'bIm', 'nestOutline');
    
    %% visualization check, untested
    if vis == 1
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
    end
end