 function [thermRegData] = updateRegistrationPointsColonyFolder(wd)
cd(wd);

%Load metadata
metadatafile = dir('*metadata*');
load(metadatafile(1).name);

% Load image registration data
imregfile = dir('*imageRegistration*');
load(imregfile(1).name);

%% Generate thermal background pic;
filelist = dir('**/*TC.mj2');

nvid = 50;
quantiles = 0.2:0.05:0.75;
[backIms thermBackStack usable] = calculateBackgroundFromFilelist_thermal(filelist, nvid, quantiles, 20);

for i = 1:numel(quantiles)
    
    %%
    backIm = backIms(:,:,i);
    thermImRGB = filterThermIm(backIm);
    %thermImRGB = histeq(thermImRGB);
    subplot(3,4,i);  imshow(thermImRGB); title(i); pause(0.2);
    
end


i = inputdlg('Choose threshold #:');
i = str2num(i{1});
thermImRGB = filterThermIm(backIms(:,:,i));
thermImRGB = imrotate(thermImRGB, 180);
clf;

%% Background for tracking camera
filelist = dir('**/*NC.avi');
nvid = 20;
[backIm visBackStack usable] = calculateBackgroundFromFilelist(filelist, nvid, 0.3, 10);
visIm = uint8(backIm);


%% Record control points
%Rotate registration pts
thermPts_out(:,1) = size(thermImRGB,2) - thermPts_out(:,1);
thermPts_out(:,2) = size(thermImRGB,1) - thermPts_out(:,2);

[thermPts visPts] = cpselect(thermImRGB, visIm, thermPts_out, visPts_out, 'Wait', true);

%% do spline transformation
tform_dat = generate_nonrigid_transform(thermImRGB, visPts, thermPts);


%% Write to thermReg object
thermRegData = struct();
thermRegData.thermPts = thermPts;
thermRegData.visPts = visPts;
thermRegData.thermImRGB = thermImRGB;
thermRegData.visIm = visIm;
thermRegData.thermBackStack = thermBackStack;
thermRegData.visBackStack = thermBackStack;
thermRegData.tform_dat = tform_dat;

%thermRegData


