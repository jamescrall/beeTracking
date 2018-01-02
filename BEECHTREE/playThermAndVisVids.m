function playThermAndVisVids(thermVid, visVid)
    %
    %Simple playback function for thermal video
    % -NB currently set to only play a few frames to check video integrity
    %
    
    %for i = 1:vid.NumberOfFrames
    for i = 1:20
        %%
        subplot(1,2,1);
        im = read(thermVid,i);
        im = convertThermalImage(im);
        imagesc(im);
        colormap hot
        
        subplot(1,2,2);
        im = rgb2gray(read(visVid,i));
        imshow(imadjust(im));
        drawnow
        pause(0.2);
    end
   