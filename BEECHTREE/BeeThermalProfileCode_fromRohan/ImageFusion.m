%This file contains all the code to set up the cameras an the
%transformation

% Load the Atlats SDK
atPath = getenv('FLIR_Atlas_MATLAB');
atLive = strcat(atPath,'Flir.Atlas.Live.dll');
asmInfo = NET.addAssembly(atLive);

%Connect to the HD camera
HDCam = videoinput('tisimaq_r2013', 1, 'RGB24 (3872x2764)');
triggerconfig(HDCam, 'manual');
src = getselectedsource(HDCam);
set(src, 'ExposureAuto', 'off');
% You can run the following line with a different value to get the right
% exposure
set(src, 'Exposure', .01);

%Scan for FLIR Thermal Camera
scan = Flir.Atlas.Live.Discovery.Discovery;
StScan = scan.Start(10);
%Connect to Thermal Camera
ImStream = Flir.Atlas.Live.Device.ThermalCamera(true);
% The following line will change depending on your camera. Look at each
% St.Scan dot item from 0 to the last to see the camera you want.
ImStream.Connect(StScan.Item(3)); 
% Turns the image from black and white to iron pallete
pal = ImStream.ThermalImage.PaletteManager;
ImStream.ThermalImage.Palette = pal.Iron;

%Take a snapshot with the thermal and HD Camera
HDImage = getsnapshot(HDCam);
ThermalImage = ImStream.GetImage;

%Get Pixels
img = ThermalImage.ImageProcessing.GetPixelsArray;
im = double(img);
imView = uint8(img); %This is the img to use when setting up transformation

%----Enter the following code to set up transformation----

% Type "cpselect(image to be transformed, other image) to register control
% points which will be saved as movingPoints and fixed points

% This will create a transformation
tform = fitgeotrans(movingPoints, fixedPoints,'affine');

% Use ShowPics.m to take two simultaneous pics. Then use the thermal
% signatures and the thermal image to try to match bees to thermal
% profiles. You should do this for as many bees as possible. Then run
% GetSnaps.m for one iteration. Lastly, run CentroidMatcher.m. It will mark
% the centroids of each bee on the thermal and HDimage. If the marks are
% inaccurate then you will have to pick another set of control points.





