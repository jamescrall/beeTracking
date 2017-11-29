%base = 'Volumes/homes/home04/jcrall'; %Use this line if working from lapto
%(e.g. interactive session)
base = '/n/home04/jcrall';
addpath(['/' base]);
addpath(['/' base '/BEEtag']);
addpath(['/' base '/BEEtag/src']);
addpath(['/' base '/BEEtag/src/bradley/bradley']);

parpool('local', 20); %Open up parallel computing pool
cd(['/' base '/thermalTracking/colPos1']); %Move to parent directory containing videos
optimize = 0; %Optimize tracking parameters?
%% Load tag data

tagfile = dir('*Taglist*csv'); %Find taglist csv file
taglist = csvread(tagfile(1).name, 1,0); %Load tag data


%% Track all nest videos

filelist = dir('**/*NC.avi');


% Optimize tracking parameters on one of the videos
if optimize == 1
    threshVals = [1.5, 2, 2.5, 3, 3.5];
    filtVals = [11 12 13 14 15];
    
    nframes = 20;
    ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
    vid = VideoReader([filelist(ind).folder '/' filelist(ind).name]);
    
    [brThresh brFilt optTime] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist)
else
    % manually set values
    brThresh = 3;
    brFilt = 12;
end

% Loop across videos
for i = 1:numel(filelist)
    vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
    trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
    filelist(i).trackingData = trackingData;
    filelist(i).taglist = taglist;
    filelist(i).bradleyFilter = brFilt;
    filelist(i).bradleyThreshold = brThresh;
    nestTrackingData = filelist;
    save([filelist(i).folder '/' strrep(filelist(i).name, '.avi', '.mat')], 'trackingData', 'taglist', 'brFilt', 'brThresh');
    i
end

nestTrackingDataMaster = filelist;


%% Track all foraging chamber videos

filelist = dir('**/*FC.avi');


% Optimize tracking parameters on one of the videos
if optimize == 1
    threshVals = [0.01 0.1 0.5 1 2 3 4 5];
    filtVals = [5 8 10 12 14 16 18 20 25 30];
    
    nframes = 20;
    ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
    vid = VideoReader([filelist(ind).folder '/' filelist(ind).name]);
    
    [brThresh brFilt optTime] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist)
else
    % manually set values
    brThresh = 3;
    brFilt = 12;
end

% Loop across videos
for i = 1:numel(filelist)
    vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
    trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
    filelist(i).trackingData = trackingData;
    fileist(i).taglist = taglist;
    filelist(i).bradleyFilter = brFilt;
    filelist(i).bradleyThreshold = brThresh;
    save([filelist(i).folder '/' strrep(filelist(i).name, '.avi', '.mat')], 'trackingData', 'taglist', 'brFilt', 'brThresh');
    i
end

forageTrackingDataMaster = filelist;

%% Save output
outfile = 'trackingDataMaster.mat';
save(outfile, 'forageTrackingDataMaster', 'nestTrackingDataMaster')