function playThermAndVisVidsWithTrackingData(thermVid, visVid, nestTracks)
    %
    %Simple playback function for thermal video
    % -NB currently set to only play a few frames to check video integrity
    %
    %   Inputs:
    %       visVid and thermVid - tracking and thermal camera VideoReader objects
    %
    %       nestTracks - tracked nest data, after running through
    %       "appendThermalCamCoordinates"
    
    cm = inferno(200);
    %for i = 1:vid.NumberOfFrames
    for i = 1:40
        %%
        subplot(1,2,1);
        im = read(thermVid,i);
        im = convertThermalImage(im);
        imagesc(im);
        colormap(cm)
        hold on
        plot(nestTracks(i,:,5), nestTracks(i,:,6), 'go');
        hold off
        
        subplot(1,2,2);
        im = rgb2gray(read(visVid,i));
        imshow(imadjust(im));
        hold on
        plot(nestTracks(i,:,1), nestTracks(i,:,2), 'go');
        hold off
        drawnow
        pause(0.2);
    end
    