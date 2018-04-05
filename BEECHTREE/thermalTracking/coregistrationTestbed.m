% All relevant files need to be loaded into a single, separate folder (no data from other experiments)
[filename pathname] = uigetfile('*');
cd(pathname);
%% Load in data set from single experiment

thermVid = VideoReader(filename);
visFile = strrep(filename, 'Thermal.mj2', 'Visual.avi');
visVid = VideoReader(visFile);

timeFile = strrep(filename, 'Thermal.mj2', 'timestamps.mat');
load(timeFile);
videoTimes = times;
%% Load in temperature readings file
%[filename pathname] = uigetfile('*', 'select temp file');
list = dir('*temperatures.mat');
load(list(1).name);
tempTimes = times;
figure(1);

i = temps1;
plot(tempTimes, i);
temps1M = movmean(temps1,50); %Smooth temperature trace
temps2M = movmean(temps2,50); %Smooth temperature trace
temps3M = movmean(temps3,50); %Smooth temperature trace
temps4M = movmean(temps4,50); %Smooth temperature trace

tempsM = mean([temps1M' temps2M' temps3M' temps4M'],2);
plot(i, 'r');
hold on
plot(tempsM, 'b');


figure(2);
plot(tempTimes, temps1M, 'r', 'LineWidth', 2);
hold on
plot(tempTimes, temps2M, 'g', 'LineWidth', 2);
plot(tempTimes, temps3M, 'b', 'LineWidth', 2);
plot(tempTimes, temps4M, 'k', 'LineWidth', 2);
datetick
ylim([20 35]);


%% Check videos

for i = 1:50:thermVid.NumberOfFrames
    subplot(2,1,1);
    im = read(thermVid,i);
    im = convertThermalImage(im);
    imagesc(im, [24 45]);
    colormap jet
    
    subplot(2,1,2);
    im = rgb2gray(read(visVid,i));
    imshow(im);
    
    drawnow
end
%% Track visual data
nframes = visVid.NumberOfFrames
%data = struct();
%nframes = 2000; %How many frames to analyze?
for i = 1:nframes
    %%
    im = rgb2gray(read(visVid,i));
    F = locateCodes(im,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', [10 10], 'bradleyThreshold', 3, 'vis', 1);
    data(i).frameData = F;
    if mod(i,50) == 0
        disp(i);
    end
end

%% Reshape tracking camera data
taglist = [];
for i = 1:numel(data)
    dat = data(i).frameData;
    if numel(dat) > 0
        taglist = [taglist [dat.number]];
    end
    
end

taglist = unique(taglist);


sumDat = nan(nframes, numel(taglist), 2);

for i = 1:numel(data)
    %%
    dat = data(i).frameData;
    if ~isempty('dat')
        for j = 1:numel(dat)
            ind = find(taglist == dat(j).number);
            sumDat(i,ind,1) = dat(j).Centroid(1);
            sumDat(i,ind,2) = dat(j).Centroid(2);
            
        end
    end
    
end
%% Subset to common tags
ind = sum(~isnan(sumDat(:,:,1))) > 20;

tagsub = taglist(ind);
sumDatS = sumDat(:,ind,:);

%% Fill in nans
sumDatS = fixShortNanGaps(sumDatS,10);

%%
vels = diff(sumDatS);

totVels = sqrt(vels(:,:,1).^2 + vels(:,:,2).^2);
%% Collect registration points
clear xv yv xtt ytt xt yt
npts = 10;
i = 10;
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
    text(xv(j)+30, yv(j)-30, num2str(j), 'Color', 'r');
end

%%

figure(2);

%%
imagesc(read(thermVid,i));
colormap jet
xt = nan(size(xv));
yt = nan(size(yv));

hold on
for j = 1:numel(xv)
    [xtt ytt] = ginput(1);
    xt(j) = xtt;
    yt(j) = ytt;
    
    plot(xtt,ytt, 'ro')
    text(xt(j)+10, yt(j)-10, num2str(j), 'Color', 'r');
end

%% Fit transformation
%tform = fitgeotrans([xt yt], [x y], 'affine');
ind = [1:10];
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




%% Calculate transformed coordinates for thermal cam
sumDatS(:,:,1) = fixShortNanGaps(sumDatS(:,:,1), 10);
sumDatS(:,:,2) = fixShortNanGaps(sumDatS(:,:,2), 10);

sumDatS(:,:,3) = nan(size(sumDatS,1), size(sumDatS,2));
sumDatS(:,:,4) = nan(size(sumDatS,1), size(sumDatS,2));

for j = 1:size(sumDatS,2)
    %%
    nind = find(~isnan(sumDatS(:,j,1)));
    crds = permute(sumDatS(nind,j,1:2), [1 3 2]);
    tfCrds = tformfwd(tform, crds);
    sumDatS(nind,j,3:4) = permute(tfCrds, [1 3 2]);
end


%% get polygons for temp correction, in order from 1-4

%Get reference location
thermIm = read(thermVid,1);
imagesc(thermIm);
colormap jet
refPol1 = roipoly;
refPol2 = roipoly;
refPol3 = roipoly;
refPol4 = roipoly;

%%
imshow((refPol1 + refPol2 + refPol3 +refPol4) > 0);

%% Calculate offsets relative to probes

offsets = nan(nframes,4);
for i = 1:nframes
    %%
    % figure(1)
    % visIm = read(visVid,i);
    thermIm = read(thermVid,i); %Read in thermal video frame
    thermIm = convertThermalImage(thermIm); %Convert raw data to deg C
    
    %%
    
    offset1 = calculateThermImOffset(thermIm, i, videoTimes,temps1M, tempTimes, refPol1);
    offset2 = calculateThermImOffset(thermIm, i, videoTimes,temps2M, tempTimes, refPol2);
    offset3 = calculateThermImOffset(thermIm, i, videoTimes,temps3M, tempTimes, refPol3);
    offset4 = calculateThermImOffset(thermIm, i, videoTimes,temps4M, tempTimes, refPol4);
    offsets(i,1) = offset1;
    offsets(i,2) = offset2;
    offsets(i,3) = offset3;
    offsets(i,4) = offset4;
end
%%
plot(offsets(:,1), 'r');
hold on
plot(offsets(:,2), 'g');
plot(offsets(:,3), 'b');
plot(offsets(:,4), 'y');

medOffset = median(offsets,2);
plot(medOffset,'k', 'LineWidth', 2);

%%
sumDatS(:,:,5) = nan(size(sumDatS,1), size(sumDatS,2));
range = 100:600;
sumDatSSub = sumDatS(range,:,:);
imagesc(~isnan(sumDatSSub(:,:,1)))

%% Add behavioral data



%% calculate behavioral data
cutoff = 100;
posMatrix = calculateLocationMatrix(sumDatS, brood, cutoff);

activityMat = calculateActivityMatrix(sumDatS);
vels = log10(activityMat(:,:,4));
velsC = reshape(vels, numel(vels),1);
hist(velsC, 100);
velCutoff = 0.75;
activity = nan(size(vels));

activity(vels < velCutoff) = 0;
activity(vels > velCutoff) = 1;
%%
vid = 1;

if vid == 1
    outVid = VideoWriter('sampleTracking');
    open(outVid);
end


%
for i = 2:500
    %%
    visIm = read(visVid,i);
    subplot(1,2,1);
    imshow(imadjust(rgb2gray(visIm)));
    hold on
    for j = 1:numel(tagsub)
        pos = posMatrix(i,j);
        act = activity(i,j);
        
        if ~isnan(pos) & ~isnan(act)
            if  pos == 1
                col = 'y';
            elseif pos == 2
                col = 'r';
            elseif pos == 0 & act == 0
                col = 'b';
            elseif pos == 0 & act == 1
                col = 'g';
            end
            if ~isnan(sumDatS(i,j,1))
                plot(sumDatS(i,j,1), sumDatS(i,j,2), '.', 'Color', col, 'MarkerSize', 30);
                text(sumDatS(i,j,1) + 10, sumDatS(i,j,2) + 10, strcat('ID: ', num2str(tagsub(j))), 'Color',col, 'FontSize', 25);
                %sumDatS(i,j,5) = temp;
            end
        end
    end
    axis equal
    hold off
    set(gca, 'Position', [0.05 -0.05 0.45 1.1], 'XTick', [], 'YTick', []);
    set(gcf, 'Color','k');
    %%
    subplot(1,2,2);
    thermIm = read(thermVid,i); %Read in thermal video frame
    thermIm = convertThermalImage(thermIm); %Convert raw data to deg C
    thermIm = thermIm + medOffset(i);
    imagesc(thermIm, [24 38]);
    colormap(cm_magma)
    colorbar('FontSize', 20, 'Color', 'w');
    hold on
    plot(sumDatS(i,:,3), sumDatS(i,:,4), 'g.', 'MarkerSize', 20);
    
    %plot(sumDatS(i,:,3), sumDatS(i,:,4),'ro');
    for j = 1:numel(tagsub)
        if ~isnan(sumDatS(i,j,1))
            if ~isnan(sumDatS(i,j,5))
                temp = sumDatS(i,j,5);
            else
                temp = takeTempReadingFromThermalImage(thermIm, sumDatS(i,j,3), sumDatS(i,j,4));
            end
            
            text(sumDatS(i,j,3) + 4, sumDatS(i,j,4) + 10, strcat(num2str(round(temp,2)), {' Deg C'}), 'Color','g', 'FontSize', 20);
            sumDatS(i,j,5) = temp;
        end
    end
    %hold off
    %drawnow
    %axis equal
    hold off
    
    set(gca, 'Position', [0.52 0.05 0.4 0.9], 'XTick', [], 'YTick', []);
    
    %%
    if vid == 1
        writeVideo(outVid, getframe(gcf));
    end
    % %
    % %     figure(2);
    % %     plot(movmean(diff(videoTimes), 20))
    % %     vline(i);
    
    i
end


if vid == 1
    close(outVid);
end


%% Single frame example

i = 8

figure(1)
visIm = read(visVid,i);
thermIm = read(thermVid,i); %Read in thermal video frame
thermIm = convertThermalImage(thermIm); %Convert raw data to deg C
time = videoTimes(i); %get frame time
timeDf = abs(tempTimes - time); %Calculate differences between time vectors
ind = find(timeDf == min(timeDf)); %Find index of closest value from temp data
refTemp = tempsM(ind); %Extract reference temperature
thermIm = offsetThermalImage(thermIm, refPol, refTemp);
subplot(3,2,[1 3 5]);
imshow(imadjust(rgb2gray(visIm)));
hold on
%plot(sumDat(1:i,:,1), sumDat(1:i,:,2), '.');
plot(sumDat(i,:,1), sumDat(i,:,2), 'ro');
offs = 20;
for j = 1:numel(tagsub)
    try
        text(sumDatS(i,j,1) + offs, sumDatS(i,j,2) + offs, num2str(tagsub(j)), 'Color', 'r');
    catch
        continue
    end
end

%%
keeperind = find(~isnan(sumDatS(i,:,1)));
offs = 5
window = 40; %Pixel window around thermal crop
indd = [1 2 4 5]
for z = 1:4
    %%
    j = indd(z)
    subplot(4,2,z*2);
    imagesc(thermIm, [23 34]);
    x = sumDatS(i,keeperind(j),3);
    y = sumDatS(i,keeperind(j),4);
    xlim([(x - window) (x+window)]-10);
    ylim([(y - window) (y+window)])
    
    colorbar
    colormap jet
    hold on
    plot(x,y,'ro');
    text(x+offs,y+offs, num2str(keeperind(j)),'Color', 'r');
end

%%
for j = 1:numel(tagsub)
    if ~isnan(sumDatS(i,j,1))
        temp = takeTempReadingFromThermalImage(thermIm, sumDatS(i,j,3), sumDatS(i,j,4));
        text(sumDatS(i,j,3) + 10, sumDatS(i,j,4) + 10, num2str(temp));
        sumDatS(i,j,5) = temp;
    end
end
hold off
drawnow



%% Make a boxplot
sdTemp = sumDatS(:,:,5);
sdTemp = sdTemp(:,sum(~isnan(sdTemp)) > 50);
sdTemp = sdTemp(1:500,:);
[a ord] = sort(nanmean(sdTemp));
sdTemp = sdTemp(:,ord);
nbees = size(sdTemp,2);
cols = distinguishable_colors(nbees)
times = (1:size(sdTemp,1))/3.75;

yl = [28 39];
subplot(1,2,1);

for i = 1:nbees
    
    plot(times,sdTemp(:,i), 'Color', cols(i,:));
    hold on
    
end
ylim(yl);

hold off
subplot(1,2,2);
boxplot(sdTemp,'BoxStyle', 'filled','Color',cols, 'Widths', 0.6, 'MedianStyle', 'target');
%boxplot(sdTemp,'BoxStyle', 'filled','Color',cols, 'OutlierSize', 0, 'Widths', 0.6, 'MedianStyle', 'target');
xlabel('Individual');
ylabel('Thoracic temperature');
ylim(yl);



%% Save data
save('trackingDataJan16.mat', 'sumDatS', 'data', 'offsets', 'brood', 'tagsub', 'medOffset');

