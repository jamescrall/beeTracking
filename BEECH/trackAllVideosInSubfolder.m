parpool(2); %Open up parallel computing pool
cd(uigetdir());
optimize = 0;
%% Load tag data

tagfile = dir('*taglist*csv'); %Find taglist csv file
taglist = csvread(tagfile(1).name, 1,0); %Load tag data


%% Track all nest videos

filelist = dir('**/*NC.avi');


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
    brFilt = 15;
end

% Loop across videos
for i = 1:numel(filelist)
   vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
   trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
   filelist(i).trackingData = trackingData;
   fileist(i).taglist = taglist;
   i
end

nestTrackingData = filelist;


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
    brFilt = 15;
end

% Loop across videos
for i = 1:numel(filelist)
   vid = VideoReader([filelist(i).folder '/' filelist(i).name]);
   trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
   filelist(i).trackingData = trackingData;
   fileist(i).taglist = taglist;
   i
end

forageTrackingData = filelist;

%% Save output
outfile = 'trackingDataMaster.mat';
save(outfile, 'forageTrackingData', 'nestTrackingData')