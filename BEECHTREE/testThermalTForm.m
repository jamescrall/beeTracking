function [] = testThermalTForm(tform)
%
% Input
%
% tform: ouput of fitgeotrans, fit with a polynomial
%



%% Select video and load data
flip = 1;
m = 500;
clrMp = inferno(m);

uiwait(msgbox('Choose thermal video to test tform on'));

[filename pathname] = uigetfile('*');


% Load in data set from single experiment

thermVid = VideoReader(fullfile(pathname, filename));

visFile = strrep(filename, 'TC.mj2', 'NC.avi');
visVid = VideoReader(fullfile(pathname, visFile));

thermIm = read(thermVid, 1);
visIm = read(visVid, 1);

%Selec out image
i = 20;
visIm = read(visVid,i);
visIm = imadjust(rgb2gray(visIm));
thermIm = convertThermalImage(read(thermVid,i));

if flip
    thermIm = imrotate(thermIm, 180);
end

%Filter out some noise
thermIm = wiener2(thermIm, [2 2]);
%out = imagesc(thermIm);

colormap(clrMp);
thermImRGB = ind2rgb(im2uint8(mat2gray(thermIm)), clrMp);
thermImRGB = uint8(round(thermImRGB.*255));
thermImRGB = localcontrast(thermImRGB);

while 1
    subplot(1,2,1);
    imshow(visIm);
    title('press any button while on image to stopproceed')
    
    hold on
    [x y button] = ginput(1);
    plot(x,y, 'ro');
    hold off
    
    subplot(1,2,2);
    imagesc(thermImRGB);
    hold on
    out = transformPointsInverse(tform,[x y]);
    plot(out(:,1), out(:,2), 'ro');
    hold off
    drawnow
    if char(button) ~= ''
        close(gcf)
        break
    end
end

inp = questdlg('Save tform object?', 'Yes', 'No');
if inp == 'Yes'
    outDir = uigetdir();
    filePrefix = inputdlg('filename prefix:');
    filePrefix = filePrefix{1}; %Remove character from cell
    save(fullfile(outDir, [filePrefix '_tform.mat']), 'tform');
end