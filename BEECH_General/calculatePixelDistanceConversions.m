%% Calculate pixel to meters conversions


%Need "masterData" loaded
nestBackIm = masterData(1).colonyData(1).nestBackIm;

forBackIm = masterData(1).colonyData(1).forBackIm;

%% calculate conversion factors for nest images
%Conversions are expressed in mm/pixels
%Nest image reference distances:
%width of nest rectangle: 6.05 inches = 153.67 mm
%horizontal inter-screw distance: 5 inches = 137 mm
%Vertical inter-screw distance: 5.5 inches = 139.7 mm

imshow(nestBackIm);
title('get edges of nest rectangle');
d = calculateDistanceBetweenUserPoints;
conv1 = 153.67/d;

% title('get horizontal distance between black screws');
% d = calculateDistanceBetweenUserPoints;
% conv2 = 137/d;

title('get vertical distance between black screws');
d = calculateDistanceBetweenUserPoints;
conv3 = 139.7/d;

nestConv = mean([conv1 conv3]);

%% calculate conversion for foraging images
%foraging image reference distances:
%Left to right outermost edges of rounded rectangles: 4.125 inches =
%104.775 mm

imshow(forBackIm);

title('click on outermost edges of left and right rounded rectangles');
d = calculateDistanceBetweenUserPoints;
forConv = 104.775/d;