%dataCollectionMaster
%Shell script for controlling acquisition from CarsonCity robot

%Initialize and open up hardware connections

%Open up smoothieboard connection
s = serial('COM6');
set(s, 'BaudRate', 115200);
fopen(s);

% Open up arduino connection
a = arduino;

%% Set up cameras - need to change!
writeDigitalPin(a,'D3',1);
pause(1);
imaqreset

frameRate = 5;

vid1 = videoinput('pointgrey', 1, 'F7_Mono8_2448x2048_Mode0');
src1 = getselectedsource(vid1);
vid1.FramesPerTrigger = 1;
vid1.FramesPerTrigger = inf;
triggerconfig(vid1,'manual');

src1.ShutterMode = 'Manual';
src1.Shutter = 15;
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
src.FrameRate = 30;

vid2 = videoinput('pointgrey', 3, 'F7_Mono8_1288x964_Mode0');
src2 = getselectedsource(vid2);
vid2.FramesPerTrigger = 1;
vid2.FramesPerTrigger = inf;
triggerconfig(vid2,'manual');

src2.ShutterMode = 'Manual';
shutterInfo2 = propinfo(src2,'Shutter');
src2.Shutter = 10;
src2.SharpnessMode = 'Manual';
sharpnessInfo2 = propinfo(src2,'Sharpness');
src2.Sharpness = 0;
src2.GammaMode = 'Manual';
src2.Gamma = 1;
src2.GainMode = 'Manual';
src2.Gain = 16;
src2.ExposureMode = 'Manual';
src2.Exposure = 2.4;
src2.Brightness = 7.4;
src.FrameRate = 7.5;

vid1Res = get(vid1, 'VideoResolution');
vid2Res = get(vid2, 'VideoResolution');

%Take and show sample pics from each camera
im1 = getsnapshot(vid1);
im2 = getsnapshot(vid2);
subplot(2,1,1);
imshow(im1);
title('Camera 1');
subplot(2,1,2);
imshow(im2);
title('Camera 2');

disp('CAMERAS READY FOR ACQUISITION: Check for correct camera recognition (Cam1 nest, Cam2 foragin chamber)')
clear('im1');
clear('im2');

%Star vids
disp('Initializing cameras for acquisition');
start(vid1);
start(vid2);

writeDigitalPin(a,'D3',0);
%preview(vid2)
%% Adjust cameras optional loop

choice = questdlg('Do you want to manually adjust camera position?','Answer the question!', 'Yes', 'Naw Im good!', []);
switch choice
    case 'Yes'
        fprintf(s, 'G28 Y');
        fprintf(s, 'G28 X');
        disp('giving time for homing...');
        writeDigitalPin(a,'D3',1)
        pause(15);
        goToColonyPosition(s,9,9000);
        disp('close preview when camera 1 is adjusted...');
        h = preview(vid1);
        waitfor(h)
        stoppreview(vid1);
        disp('switching to camera 2: close preview when adjusted...');
        h = preview(vid2);
        waitfor(h)
        stoppreview(vid2);
        disp('Cameras adjusted! moving on to experiment...');
        writeDigitalPin(a,'D3',1)
        
    case 'Naw Im good!'
        disp('Skipping camera adjustment, moving on to experiment!');
        
end
%% Recording Loop
% Define output destination for data and trial parameters
vidPath = uigetdir('F:\', 'Choose directory for imidacloprid videos'); %output directory
%ovPath = uigetdir('F:\', 'Choose directory for ovary videos'); %output directory

minutes = 5; %Trial length in minutes
recTime = 60*minutes; %Convert to seconds
%3 7 11 4 8 12
sampleCols = [1 5 9 2 6 10];



recordingTimes = datenum({'0:00', '2:00', '4:00','6:00','8:00', '10:00', '10:09','12:00', '14:00', '16:00', '18:00', '20:00', '22:00'}); %List of time to start recording
datestr(recordingTimes)
notes= inputdlg('Notes on trial:');

%% Start trial!
while 1
    %%
    t = datenum(datestr(now, 'HH:MM'));
    
    if ismember(t, recordingTimes)
        disp('Starting Trial!');
        %which colonies?
%         %RandomizeOrder? Currently not
        % sampleColsRand = sampleCols(randperm(numel(sampleCols)));

        colonyRecordingControl(s, sampleCols, a, 10000, vidPath, recTime, vid1, vid2, notes);
    end
    

end
%% close connections
fclose(s);
clear('s');