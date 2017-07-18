% This program shows images taken from the thermal and HD camera
% simultaneously

HDImage = getsnapshot(HDCam);
ThermalImage = ImStream.GetImage;
%DigImage = DigStream.GetImage;

%Get Pixels
img = ThermalImage.ImageArray;
im = double(img);
imView = uint8(img);

figure(1)
imshow(HDImage);
figure(2)
imshow(imView);