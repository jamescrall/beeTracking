function [filelist] = trackAllVideosInDirectoryPar(direc, optimize, brFilt, brThresh, textFilter, textTag)
% Inputs:
%   direc - directory containing videos to track.
%       NB: Looks for separate set of foraging and nest videos, and
%       separately optimizes them. Master directory must also contain a
%       .csv file where the first column (with a header) contains a list of
%       valid tags for this specific colony
%
%   optimize - option of whether to optimize (and save) tracking
%       parameters. '0' uses default values (3 and 15 for threshold and filter,
%       see below. '1' will perform an optimization by searching a pre-defined
%       parameter space and use these values
%
%   brFilt - default bradley filter value (currently need to supply defaults even if
%       optimizing
%
%   brThresh - default bradley threshold value (again, current need to
%       supply even if optimizing
%
%   textFilter - search term to look for a subset of videos. E.g., '.avi'
%       to look for avi videos, or "NC.avi" if
%
%   textTag - output text to attach to saved files
%
% Outputs:
%   filelist - matlab structure with tracking data attached to each video
%   file


%% Load tag data

tagfile = dir(fullfile(direc, '*aglist*csv')); %Find taglist csv file
%taglist = csvread(fullfile(direc, tagfile(1).name), 1,0); %Load tag data
%taglist = taglist(:,1);

taglist = readtable(fullfile(direc, tagfile(1).name)); %Load tag data
taglist = taglist.tagNumber;

%% Track all nest videos

filelist = dir(fullfile(direc, '**', ['*' textFilter '*']));


% Optimize tracking parameters on one of the videos
if optimize == 1
    try
        threshVals = [0.05 0.1 0.5 0.8 1 1.5 2 2.5 3 4 5];
        filtVals = [12 13 14 15 16 18 20 25 30];
        
        %threshVals = [0.1 0.5 1];
        %filtVals = [10 12];
        nframes = 15;
        
        ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
        vid = VideoReader(fullfile(filelist(ind).folder, filelist(ind).name));
        
        [brThresh brFilt outData] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist);
        save(fullfile(direc, [textTag '_trackingOptimization.mat']), 'brThresh', 'brFilt', 'outData');
    catch
        disp('Error running optimization, using default settings...');
        brThresh = 3;
        brFilt = 15;
    end
    
else
    % manually set values
    brThresh = 3;
    brFilt = 15;
end

% Loop across videos
for i = 1:numel(filelist)
    try
        vid = VideoReader(fullfile(filelist(i).folder, filelist(i).name));
        trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist(:,1));
        filelist(i).trackingData = trackingData;
        filelist(i).taglist = taglist;
        i
        filelist(i).valid = 1;
    catch
        disp(['Error reading and tracking file ' filelist(i).name ', skipping']);
        continue
    end
    %% Save output
    outfile = fullfile(direc, [textTag '_trackingDataMaster.mat']);
    save(outfile, 'filelist')
end


