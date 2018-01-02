
[filename pathname] 
= uigetfile('*');
cd(pathname);
%% Load in data set from single experiment

thermVid = VideoReader(filename);

visFile = strrep(filename, 'TC.mj2', 'NC.avi');
visVid = VideoReader(visFile);

playThermAndVisVids(thermVid, visVid);
close all
%%
%% Collect registration points
clear xv yv xtt ytt xt yt
npts = 30;
i = 20;
visIm = read(visVid,i);
thermIm = read(thermVid,i);
figure(1);
imshow(imadjust(rgb2gray(visIm)));
xv = nan(npts,1);
yv = xv;
hold on
for j = 1:npts
    [xtt ytt] = ginput(1);
    xv(j) = xtt;
    yv(j) = ytt;
    plot(xv,yv, 'ro');
    
    text(xv(j)+30, yv(j)-30, num2str(j), 'Color', 'r');
    
end
hold off
%%
figure(1);
imshow(imadjust(rgb2gray(visIm)));
hold on

plot(xv,yv, 'ro');
for j = 1:npts
    text(xv(j)+30, yv(j)-30, num2str(j), 'Color', 'r', 'FontSize', 20);
end

%%

figure(2);

%%
imagesc(read(thermVid,i));
colormap hot
colorbar

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
save([outDir '/BEECHthermCamtform.mat'], 'tform');