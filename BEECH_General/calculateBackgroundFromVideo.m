function backIm = calculateBackgroundFromVideo(vid,nframes)
    %
    % Inputs:
    %   vid - VideoReader object
    %   nframes - how many frames to sample for background
    %
    %% generate background stack
    backStack = uint8(zeros(vid.Height, vid.Width, nframes));
    
    
    ind = round(linspace(1, vid.NumberOfFrames, nframes));
    
    for i = 1:nframes
        %%
       backStack(:,:,i) = rgb2gray(read(vid,ind(i))); 
        
    end
    
    backIm = median(backStack,3);
end