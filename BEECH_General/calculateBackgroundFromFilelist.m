function [backIm backStack] = calculateBackgroundFromFilelist_par(filelist, nvid, qntl, frameNumber)
    
    % Inputs
    %   filelist - list of video files to calculate a collective background
    %   image for
    %
    %   nvid - how many videos to sample
    %
    %  frameNumber - what frame number to choose from vid?
    %
    %
    % Output
    %
    %   backIm - background image
    
    
    ind = floor(linspace(1,numel(filelist),nvid)); %Skip the first few videos
    
    
    for i = 1:nvid
        %%
        filename = [filelist(ind(i)).folder '/' filelist(ind(i)).name];
        try
            mov = VideoReader(filename);
            im = rgb2gray(read(mov,frameNumber));
            
            if ~exist('backStack') %If we're on the first rep, create empty matrix for all frames
                backStack = nan(size(im,1), size(im,2), nvid);
            end
            
            backStack(:,:,i) = im;
        catch
            continue
        end
    end
    
    
    %% Calculate median image
    backIm =  quantile(backStack,qntl, 3);
