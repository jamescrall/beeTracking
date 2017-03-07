function medianImage = medianImage(vid, n)
    %% Calculates a median background image for vid, using n frames
    
    frames = uint8(nan(vid.Height, vid.Width, n));
    
    smp = floor(linspace(1,vid.NumberOfFrames, n));
    for i = 1:numel(smp)
        
        %%
       z = smp(i);
       im = read(vid,z);
       frames(:,:,i) = rgb2gray(im);
    end
    
    medianImage = median(frames,3);