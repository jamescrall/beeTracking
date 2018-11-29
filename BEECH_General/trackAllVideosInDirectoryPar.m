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
    
    tagfile = dir([direc '/*aglist*csv']); %Find taglist csv file
    taglist = csvread([direc '/' tagfile(1).name], 1,0); %Load tag data
    taglist = taglist(:,1);
    
    %% Track all nest videos
    
    filelist = dir([direc '/**/*' textFilter '*']);
    
    
    % Optimize tracking parameters on one of the videos
    if optimize == 1
        
        threshVals = [0.05 0.1 0.5 0.8 1 1.5 2 2.5 3 4 5];
        filtVals = [5 8 10 11 12 13 14 15 16 18 20 25 30];
        
        %threshVals = [0.1 0.5 1];
        %filtVals = [10 12];
        nframes = 15;
        
        ind = floor(numel(filelist)/2); %Which video to use? take one from the middle
        vid = VideoReader([filelist(ind).folder '/' filelist(ind).name]);
        
        metadata = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist);
        save([direc '/' textTag 'trackingOptimization.mat'], 'metadata');
        brThresh = metadata.brThreshOpt;
        brFilt = metadata.brFiltOpt;
        
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
        i;
        %% Save output
        outfile = [direc '/' textTag 'trackingDataMaster.mat'];
        save(outfile, 'filelist')
    end
    
    