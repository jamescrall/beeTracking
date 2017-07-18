imaqreset
video_input = videoinput('gige', 1, 'Mono16'); %connect to the first gige camera
vid.FramesPerTrigger = 1;
triggerconfig(video_input, 'Manual');
source = video_input.Source; %get the source object

%To get temperature linear data, the following GenICam registers needs
%to be set
source.SensorGainMode = 'HighGainMode';
source.TemperatureLinearMode = 'On';
source.TemperatureLinearResolution = 'High';
%% Acquire video
thermVid = VideoWriter(strcat('test', 'Thermal'), 'Archival');
open(thermVid);
tic
while toc < 20
    im = peekdata(video_input,1);
    %imagesc(im);
    %drawnow;
    writeVideo(thermVid,im);
end

close(thermVid);

%% read back video
vidObj = VideoReader('testThermal.mj2');
currAxes = axes;
i = 1
while hasFrame(vidObj)
    vidFrame = readFrame(vidObj);
    imagesc(vidFrame, 'Parent', currAxes);
    currAxes.Visible = 'off';
    pause(1/120);
    title(num2str(i));
    i = i+1
end

%% Preview

while 1
    im = peekdata(video_input,1);
    imagesc(im, 'Parent', currAxes);
    pause(0.1);
end