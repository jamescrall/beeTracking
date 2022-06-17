function [thermPtsBase visPtsBase thermImRGB visIm backIms] = updateRegistrationPointsColonyFolder(wd)
cd(wd);
metadatafile = dir('*metadata*');
load(metadatafile(1).name);

%% Generate thermal background pic;
filelist = dir('**/*TC.mj2');

nvid = 50;
quantiles = 0.2:0.05:0.75;
[backIms backStack usable] = calculateBackgroundFromFilelist_thermal(filelist, nvid, quantiles, 20);

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
%% Background for tracking camera
filelist = dir('**/*NC.avi');
nvid = 20;
[backIm backStack usable] = calculateBackgroundFromFilelist(filelist, nvid, 0.3, 10);
visIm = uint8(backIm);


%% Record control points
[thermPtsBase visPtsBase] = cpselect(thermImRGB, visIm, 'Wait', true);

function thermImRGB = filterThermIm(backIm)

thermIm = wiener2(backIm, [2 2]);
%out = imagesc(thermIm);
%
m = 255;
clrMp = inferno(m);
colormap(clrMp);
thermImRGB = ind2rgb(im2uint8(mat2gray(thermIm)), clrMp);
thermImRGB = uint8(round(thermImRGB.*255));
thermImRGB = localcontrast(thermImRGB, 0.5, 0.3);
%thermImRGB = histeq(thermImRGB);
