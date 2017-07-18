video_input = videoinput('gige', 1, 'Mono16'); %connect to the first gige camera
source = video_input.Source; %get the source object

%To get temperature linear data, the following GenICam registers needs
%to be set
source.SensorGainMode = 'LowGainMode';
source.TemperatureLinearMode = 'On';
source.TemperatureLinearResolution = 'High';
%start the video acquisition

%% Load pointgrey cam
vid = videoinput('pointgrey', 1, 'F7_Mono8_2448x2048_Mode0');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;
%% allocate memory
nframes = 100;
thermIm = getThermalImage(video_input);
visIm = getsnapshot(vid);

thermVid = nan(size(thermIm,1), size(thermIm,2), nframes);
visVid = uint8(nan(size(visIm,1), size(visIm,2),nframes));
%% acquire
tic
for i = 1:nframes
    thermIm = getThermalImage(video_input);
    visIm = getsnapshot(vid);
    thermVid(:,:,i) = thermIm;
    visVid(:,:,i) = visIm;
end

save('sampleThermVisPair.mat', 'thermVid', 'visVid');
%% Visualize

outVid = VideoWriter('pairedThermVisMov.avi');
open(outVid);
for i = 1:nframes
    i
    subaxis(2,1,2,'SpacingVert', 0)
    colormap(gca, 'jet')
    h = imagesc(thermVid(:,:,i) - 7, [20 35]);
    set(gca, 'XTick', [], 'YTick', [], 'Box', 'off');
    colorbar
    axis equal
    whitebg(1,'k')
    %set(gca,'Position', [0.1 0.1 0.9 0.9]);
    subaxis(2,1,1, 'SpacingVert', 0)
    imshow(uint8(visVid(:,:,i)));
    whitebg(1,'k')
    drawnow
    frame = getframe(gcf);
    
    writeVideo(outVid,frame)
    %pause(0.5);
    
end
close(outVid);
%% Clean up
stop(video_input);
imaqreset;