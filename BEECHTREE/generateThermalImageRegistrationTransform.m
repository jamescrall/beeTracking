
%% Point to thermal video
uiwait(msgbox('Choose thermal video'));

[filename pathname] = uigetfile('*');
cd(pathname);


% Load in data set from single experiment

thermVid = VideoReader(filename);

visFile = strrep(filename, 'TC.mj2', 'NC.avi');
visVid = VideoReader(visFile);

thermIm = read(thermVid, 1);
visIm = read(visVid, 1);

m = 255;
clrMp = inferno(m);
subplot(1,2,1);
imshow(visIm);
subplot(1,2,2);
thermIm = convertThermalImage(thermIm);
imagesc(thermIm);
colormap(clrMp);

toFlip = questdlg('Flip thermal image?');
if strmatch(toFlip, 'Yes')
    flip = 1;
    subplot(1,2,1);
    imshow(visIm);
    subplot(1,2,2);
    thermIm = imrotate(thermIm, 180);
    imagesc(thermIm);
    colormap(clrMp);
else
    flip = 0;
end
%playThermAndVisVids(thermVid, visVid);
%close all
%% Collect registration points
%Set color map



i = 20;
visIm = read(visVid,i);
visIm = imadjust(rgb2gray(visIm));
thermIm = convertThermalImage(read(thermVid,i));

if flip
    thermIm = imrotate(thermIm, 180);
end

%Filter out some noise
thermIm = wiener2(thermIm, [2 2]);
out = imagesc(thermIm);

colormap(clrMp);
thermImRGB = ind2rgb(im2uint8(mat2gray(thermIm)), clrMp);
thermImRGB = uint8(round(thermImRGB.*255));
thermImRGB = localcontrast(thermImRGB);
cpselect(thermImRGB, visIm)

%% Check registration points
%
% subplot(1,2,1)
% imshow(thermImRGB)
% hold on
% plot(movingPoints(:,1), movingPoints(:,2), 'go')
% hold off;
%
%
% subplot(1,2,2)
% imshow(visIm)
% hold on
% plot(fixedPoints(:,1), fixedPoints(:,2), 'go')
% hold off;
%
% cpselect(thermImRGB, visIm, movingPoints, fixedPoints)


% %%
% xt = nan(size(xv));
% yt = nan(size(yv));
%
% hold on
% %
% for j = 1:numel(xv)
%     [xtt ytt] = ginput(1);
%     xt(j) = xtt;
%     yt(j) = ytt;
%
%     plot(xtt,ytt, 'ro')
%     text(xt(j)+10, yt(j)-10, num2str(j), 'Color', 'k', 'FontSize', 20);
% end
%
% %% Fit transformation
% %tform = fitgeotrans([xt yt], [x y], 'affine');
%
% tform = cp2tform([xv(ind) yv(ind)], [xt(ind) yt(ind)], 'projective');
% out = tformfwd(tform,[xv(ind) yv(ind)]);

%%
%tform = fitgeotrans(movingPoints, fixedPoints, 'lwm',2);
tform = fitgeotrans(movingPoints, fixedPoints, 'pwl');
out = transformPointsInverse(tform,fixedPoints);
imagesc(thermImRGB);
hold on;
plot(movingPoints(:,1), movingPoints(:,2), 'go');
plot(out(:,1), out(:,2), 'ro');
hold off

% %% Check transformation output
% figure(1);
% imagesc(thermIm);
% colormap jet
% hold on
% plot(xt(ind), yt(ind), 'ko');
% for j = ind
%     text(xt(j)+10, yt(j)-10, num2str(j), 'Color', 'k');
%
% end
% plot(out(:,1), out(:,2), 'ro');
%% Check transformation option #2
while 1
    figure(1);
    subplot(1,2,1);
    imshow(visIm);
    hold on
    [x y] = ginput(1);
    plot(x,y, 'ro');
    hold off
    
   subplot(1,2,2);
    imshow(thermImRGB);
    hold on
    out = transformPointsInverse(tform,[x y]);
    plot(out(:,1), out(:,2), 'ro');
    hold off
    drawnow
end

%%
outDir = uigetdir();
filePrefix = inputdlg('filename prefix:');
filePrefix = filePrefix{1}; %Remove character from cell
save(strcat(outDir, '/', filePrefix, '_tform.mat'), 'tform');
save(strcat(outDir, '/', filePrefix, '_tform_metadata.mat'), 'tform', 'movingPoints', 'fixedPoints', 'filename', 'visFile', 'thermImRGB', 'visIm', 'movingPoints', 'fixedPoints');