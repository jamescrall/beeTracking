function [] = colonyRecordingControl(s,sampleCols,a, speed, path, recTime, vid1, vid2, notes)
%Inputs:
%s: serial connection to smoothieboard
%sampleCols: colony positions to be sampled (in order)
%a: arduino connection
%speed: movement speed for robot arm
%
%Follow inputs are all passed down to "twoCameraAcquisition");
%path: output filepath
%trialLength: trial length (in seconds)
%vid1 and vid2: nest and foraging camera objects
%notes: trial-specific notes, passed to subfunction


%Blink warning lights for 10 seconds before moving
tic;
while toc < 10
    writeDigitalPin(a,'D10', 0);
    pause(0.2);
    writeDigitalPin(a,'D10', 1);
    pause(0.2);
end

%% Home
disp('giving time for homing...');
fprintf(s, 'G28 Y');
fprintf(s, 'G28 X');
pause(20);
xcur = 3;
ycur = 3;
%%
colCrds = csvread('C:\Users\Humblebee\Documents\Carson City\CC_ColonyCoordinates.csv');

offX = 100; %offset from corner coordinates in X
offY = 25; %offset from corner coordinates in Y

%speed = 1500; %Movement speed, in mm/min

%% Cycle through colonies
ncol = size(sampleCols,2);
for n = 1:ncol
    %% %Blink warning lights for 5 seconds before moving
tic;
while toc < 5
    writeDigitalPin(a,'D10', 0);
    pause(0.2);
    writeDigitalPin(a,'D10', 1);
    pause(0.2);
end
    %%
    i = sampleCols(n);
    colPos = i;
    writeDigitalPin(a,'D3',0)
    xc = colCrds(i,2) + offX;
    yc = colCrds(i,3) + offY;
    
    % %Comment in to switch to direct movement
    % sendToPosition(s, xc, yc, speed);
    % distanceToDestination = sqrt((xcur - xc).^2 + (ycur - yc).^2);
    
    sendToPositionSingleAxisMovement(s, xc, yc, speed);
    distanceToDestination = abs(ycur - 20) + abs(xcur - xc) + abs(yc - 20); %20 is the y-axis setpoint for moving along x-axis, set in "sendToPositionSingleAxisMovement"Function
    accBuf = 9; %Acceleration Buffer
    pause(1/speed*60*distanceToDestination)
    disp(strcat('Arriving at colony ', ' ',num2str(i),'! Turning on lights...'));
    writeDigitalPin(a,'D3',1)
    
    %Update currenty coordinats to memory
    xcur = xc;
    ycur = yc;
    %% Simulate recording - replace with actual recording loop!
    disp('Pre-recording Delay...');
    pause(5);
    disp('Starting Recording...');
    twoCameraAcquisition(path, recTime, vid1, vid2, colPos, notes);
    disp('heading to next colony');
end

%% Send to home
fprintf(s, 'G28 Y');
fprintf(s, 'G28 X');

%Turn off IR lights and warning lights
writeDigitalPin(a,'D3',0);
writeDigitalPin(a,'D10',0);

