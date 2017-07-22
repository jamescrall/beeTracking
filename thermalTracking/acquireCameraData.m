imaqreset

%% Initialize FLIR A65
thermCam = videoinput('gige', 1, 'Mono16'); %connect to the first gige camera
thermCam.FramesPerTrigger = 1;
triggerconfig(thermCam, 'Manual');
source = thermCam.Source; %get the source object

%To get temperature linear data, the following GenICam registers needs
%to be set
source.SensorGainMode = 'HighGainMode';
source.TemperatureLinearMode = 'On';
source.TemperatureLinearResolution = 'High';


%% Initialize point grey (Point Grey Blackfly 2448x2048 monochrome
pgCam = videoinput('pointgrey', 1, 'F7_Mono8_2448x2048_Mode0');
triggerconfig(pgCam, 'Manual');
pgCam.FramesPerTrigger = 1;
src1 = getselectedsource(pgCam);
pgCam.FramesPerTrigger = 1;
pgCam.FramesPerTrigger = inf;
triggerconfig(pgCam,'manual');


%% Adjust settings settings
src1.ShutterMode = 'Manual';
src1.Shutter = 10;
src1.SharpnessMode = 'Manual';
sharpnessInfo1 = propinfo(src1,'Sharpness');
src1.Sharpness = 0;
src1.GammaMode = 'Manual';
src1.Gamma = 1;
src1.GainMode = 'Manual';
src1.Gain = 18;
src1.ExposureMode = 'Manual';
src1.Exposure = 2.4;
src1.Brightness = 7.4;

preview(pgCam);
%% Run experiment

expTime = 30; %Length of experiment in minutes
start(thermCam); %Start FLIR
start(pgCam); %Start point grey
expPref = 'exp2';
filenamebase = strcat(expPref,datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

thermVid = VideoWriter(strcat(filenamebase, 'Thermal'), 'Archival');
visVid = VideoWriter(strcat(filenamebase, 'Visual.avi'));

open(thermVid);
open(visVid);
times = [];
% %% Run preview?
% 
% 
% while 1 %Start timer
%     %%
%     thermIm = peekdata(thermCam,1);
%     visIm = peekdata(pgCam,1);
%     subplot(2,1,1);
%     imagesc(thermIm);
%     subplot(2,1,2);
%     imshow(visIm);
%     drawnow
%     
% end
% %% preview only FLIR
% while 1 %Start timer
%     %%
%     thermIm = peekdata(thermCam,1);
%     imagesc(thermIm);
%     drawnow
%     
% end
%%
tic
while toc < expTime*60 %Start timer
    %%
    thermIm = peekdata(thermCam,1);
    visIm = peekdata(pgCam,1);
    times = [times now];
    writeVideo(thermVid, thermIm);
    writeVideo(visVid, visIm);
    
end
%
%Close video feeds
stop(thermCam);
stop(pgCam);

%WRite timestamps to memory
save(strcat(filenamebase, 'timestamps.mat'), 'times');

close(thermVid);
close(visVid);

