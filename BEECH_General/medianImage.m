function medianImage = medianImage(vid, n)
    %% Calculates a median background image for vid, using n frames
    
    frames = uint8(nan(vid.Height, vid.Width, n));
    
    smp = floor(linspace(1,vid.NumberOfFrames, n));
    h = waitbar(0,'Loading background frames');
    for i = 1:numel(smp)
        
        %%
       z = smp(i);
       im = rgb2gray(read(vid,z));
       frames(:,:,i) = im;
       waitbar(i/numel(smp));
    end
    close(h);
    
    disp('calculating background...');
    medianImage = median(frames,3);