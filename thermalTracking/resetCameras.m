function [vid video_input] = resetCameras()
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
%% Load pointgrey cam (Point Grey Blackfly 2448x2048 monochrome
vid = videoinput('pointgrey', 1, 'F7_Mono8_2448x2048_Mode0');
triggerconfig(vid, 'Manual');
vid.FramesPerTrigger = 1;
src1 = getselectedsource(vid);
vid.FramesPerTrigger = 1;
vid.FramesPerTrigger = inf;
triggerconfig(vid,'manual');

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
%src.FrameRate = 30;