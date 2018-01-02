function playThermVid(vid)
    %
    %Simple playback function for thermal video
    % -NB currently set to only play a few frames to check video integrity
    %
    
    %for i = 1:vid.NumberOfFrames
    for i = 1:20
        im = read(vid,i);
        im = convertThermalImage(im);
        imagesc(im);
        colormap jet
        drawnow
        pause(0.1);
    end
   