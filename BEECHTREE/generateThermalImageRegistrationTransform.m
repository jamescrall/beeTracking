
%Point to thermal video
[filename pathname] = uigetfile('*');
cd(pathname);


%% Load in data set from single experiment

thermVid = VideoReader(filename);

visFile = strrep(filename, 'TC.mj2', 'NC.avi');
visVid = VideoReader(visFile);

playThermAndVisVids(thermVid, visVid);
close all
%%
%% Collect registration points
%Set color map
m = 255;
clrMp = inferno(m);


i = 20;
visIm = read(visVid,i);
visIm = imadjust(rgb2gray(visIm));
thermIm = read(thermVid,i);

out = imagesc(thermIm);

colormap(clrMp);
thermImRGB = ind2rgb(im2uint8(mat2gray(thermIm)), clrMp);
thermImRGB = uint8(round(thermImRGB.*255));
cpselect(thermImRGB, visIm)

%% Check registration points

subplot(2,1,1)
imshow(thermImRGB)
hold on
plot(movingPoints1(:,1), movingPoints1(:,2), 'go')
hold off;


subplot(2,1,2)
imshow(visIm)
hold on
plot(fixedPoints1(:,1), fixedPoints1(:,2), 'go')
hold off;
% %%
% clear xv yv xtt ytt xt yt
% npts = 30;
% 
% figure(1);
% imshow(imadjust(rgb2gray(visIm)));
% xv = nan(npts,1);
% yv = xv;
% hold on
% for j = 1:npts
%     [xtt ytt] = ginput(1);
%     xv(j) = xtt;
%     yv(j) = ytt;
%     plot(xv,yv, 'ro');
%     
%     text(xv(j)+30, yv(j)-30, num2str(j), 'Color', 'r');
%     
% end
% hold off
%%
% figure(1);
% imshow(imadjust(rgb2gray(visIm)));
% hold on
% 
% plot(xv,yv, 'ro');
% for j = 1:npts
%     text(xv(j)+30, yv(j)-30, num2str(j), 'Color', 'r', 'FontSize', 20);
% end

%%

%figure(2);

% %%
% imagesc(read(thermVid,i));
% colormap hot
% colorbar

%%
xt = nan(size(xv));
yt = nan(size(yv));

hold on
%
for j = 1:numel(xv)
    [xtt ytt] = ginput(1);
    xt(j) = xtt;
    yt(j) = ytt;
    
    plot(xtt,ytt, 'ro')
    text(xt(j)+10, yt(j)-10, num2str(j), 'Color', 'k', 'FontSize', 20);
end

%% Fit transformation
%tform = fitgeotrans([xt yt], [x y], 'affine');
ind = [1:27 30];
tform = cp2tform([xv(ind) yv(ind)], [xt(ind) yt(ind)], 'projective');
out = tformfwd(tform,[xv(ind) yv(ind)]);

%%
tform = cp2tform(fixedPoints, movingPoints, 'projective');
out = tformfwd(tform,fixedPoints);
imagesc(thermImRGB);
hold on;
plot(movingPoints(:,1), movingPoints(:,2), 'go');
plot(out(:,1), out(:,2), 'ro');
hold off

%% Check transformation output
figure(1);
imagesc(thermIm);
colormap jet
hold on
plot(xt(ind), yt(ind), 'ko');
for j = ind
    text(xt(j)+10, yt(j)-10, num2str(j), 'Color', 'k');
    
end
plot(out(:,1), out(:,2), 'ro');
%% Check transformation option #2
while 1
    figure(1);
    imshow(visIm);
    hold on
    [x y] = ginput(1);
    plot(x,y, 'ro');
    hold off
    
    figure(2);
    imagesc(thermIm);
    hold on
    out = tformfwd(tform, [x y]);
    plot(out(:,1), out(:,2), 'ro');
    hold off
end

%%
outDir = uigetdir();
filePrefix = inputdlg('filename prefix:');
filePrefix = filePrefix{1}; %Remove character from cell
save(strcat(outDir, '/', filePrefix, 'tform.mat'), 'tform');
save(strcat(outDir, '/', filePrefix, '_tform_metadata.mat'), 'tform', 'movingPoints', 'fixedPoints', 'filename', 'visFile', 'thermImRGB', 'visIm', 'movingPoints', 'fixedPoints');