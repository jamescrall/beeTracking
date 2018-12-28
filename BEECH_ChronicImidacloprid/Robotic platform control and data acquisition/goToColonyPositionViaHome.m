function [] = goToColonyPositionViaHome(s,i, speed)

%% inputs:
%s: serial connection to smoothie
%i: colonyPositioNumber
%speed: speed (mm/min)
%% Home
fprintf(s, 'G28 Y');
fprintf(s, 'G28 X');
%Now go to colony position
colCrds = csvread('C:\Users\Humblebee\Documents\Carson City\CC_ColonyCoordinates.csv');

offX = 100; %offset from corner coordinates in X
offY = 40; %offset from corner coordinates in Y

xc = colCrds(i,2) + offX;
yc = colCrds(i,3) + offY;

% %Comment in to switch to direct movement
% sendToPosition(s, xc, yc, speed);
% distanceToDestination = sqrt((xcur - xc).^2 + (ycur - yc).^2);

sendToPositionSingleAxisMovement(s, xc, yc, speed);