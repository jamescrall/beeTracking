parpool(8); %Open up parallel computing pool
cd(uigetdir());
optimize = 0;
%% Load tag data

tagfile = dir('*taglist*csv'); %Find taglist csv file
taglist = csvread(tagfile(1).name, 0,0); %Load tag data


%% Track all nest videos

filelist = dir('**/*NC.avi');


% Optimize tracking parameters on one of the videos
if optimize == 1
    threshVals = [0.01 0.1 0.5 0.8 1 1.5 2 2.5 3 4 5];
    filtVals = [5 8 10 11 12 13 14 15 16 18 20 25 30];
    
    nframes = 20;
    ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
    vid = VideoReader([filelist(ind).folder '/' filelist(ind).name]);
    
    metadata = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist);
    save('nestTrackingOptimization.mat', 'metadata');
    
else
    % manually set values
    brThresh = 2;
    brFilt = 14;
end

% Loop across videos
h = waitbar(0, 'tracking progress...')
for i = 1:numel(filelist)
    try
        vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
        trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
        filelist(i).trackingData = trackingData;
        filelist(i).taglist = taglist;
        waitbar(i/numel(filelist), h)
    catch
        disp(['Error tracking video ', num2str(i), ', skipping']);
        continue
    end
end

nestTrackingData = filelist;
outfile = 'trackingDataMaster.mat';
save(outfile, 'nestTrackingData')

%% Track all foraging chamber videos

filelist = dir('**/*FC.avi');


% Optimize tracking parameters on one of the videos
if optimize == 1
    threshVals = [0.01 0.1 0.5 0.8 1 1.5 2 2.5 3 4 5];
    filtVals = [5 8 10 11 12 13 14 15 16 18 20 25 30];
    
    nframes = 20;
    ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
    vid = VideoReader([filelist(ind).folder '/' filelist(ind).name]);
    
    [brThresh brFilt optTime] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist)
else
    % manually set values
    brThresh = 3;
    brFilt = 15;
end

% Loop across videos
for i = 1:numel(filelist)
    vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
    trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
    filelist(i).trackingData = trackingData;
    filelist(i).taglist = taglist;
    i
end

forageTrackingData = filelist;

%% Save output
outfile = 'trackingDataMaster.mat';
save(outfile, 'forageTrackingData', 'nestTrackingData')