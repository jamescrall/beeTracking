function [masterData nestBackIm forBackIm nestOutline] = postprocessColonyFolder(directory, taglist)
cd(directory);
list = dir('*NCmat.mat');
backgroundImages = dir('*backgroundImages*');
load(backgroundImages.name);
nestBackIm = backgroundImages.backIm;
nestOutline = backgroundImages.nestOutline;
%%
masterData = struct();
movThresh = 2; %
h = waitbar(0,'Looping across trials');

for i = 1:numel(list)
    %%
    disp(strcat({'loading data for trial: '}, list(i).name));
    load(list(i).name);
    nTrackingData = nestTrackingData.trackingData;
    
    %What length nan gap to fill?
    gapjump = 9;
    for j = 1:4
        nTrackingData(:,:,j) = fixShortNanGaps(nTrackingData(:,:,j), gapjump);
        forageTrackingData(:,:,j) = fixShortNanGaps(forageTrackingData(:,:,j), gapjump);
    end
    %Read in timesteps
    tmp = strsplit(list(i).name, '_colPos');
    time = tmp{1};
    timestamps = csvread(strcat(time,'_timestamps.csv'));
    dt = mean(diff(timestamps(:,1))*24*3600); %Time interval converted to seconds
    trialTime = datenum(time, 'dd-mmm-yyyy_HHMMSS');
    
    %Calculate dx and dy (in pixels);
    dx = diff(nTrackingData(:,:,1))./dt;
    dy = diff(nTrackingData(:,:,2))./dt;
    speeds = sqrt(dx.^2 + dy.^2);
    
    %Repeat for foraging chamber;
    dxf = diff(forageTrackingData(:,:,1))./dt;
    dyf = diff(forageTrackingData(:,:,2))./dt;
    speedsF = sqrt(dxf.^2 + dyf.^2);
    
    %Clean out any unrealistically fast movements
    maxSpeed = 400; %maximum allowable speeds in nest chamber
    maxSpeedF = 600; %Ditto for foraging
    cleanInd = speeds > maxSpeed;
    cleanIndF = speedsF > maxSpeedF;
    
    %Clean outliers for nest speeds
    dx(cleanInd) = NaN;
    dy(cleanInd) = NaN;
    speeds(cleanInd) = NaN;
    
    %Clean outliers for forage speeds
    dxf(cleanIndF) = NaN;
    dyf(cleanIndF) = NaN;
    speedsF(cleanIndF) = NaN;
    
    %Generate logical matrices of whether each bee is on the nest for each
    %timesteps
    %Empty matrix
    xs = nTrackingData(:,:,1); %Create x position object for simplicity
    ys = nTrackingData(:,:,2);
    onNest = nan(size(xs)); %Empty matrix for logical values of whether bees are on the nest
    xp = round(xs); %Turn into indexable value
    yp = round(ys);
    nind = ~isnan(xp); %Create general index for which coordiantes we're pulling from the trackingdata
    xp = xp(nind); %Subset the coordiantes
    yp = yp(nind);
    pixelInd = sub2ind(size(nestOutline),yp,xp); %
    pixelVals = nestOutline(pixelInd);
    onNest(nind) = pixelVals; %Index of when bees are on the nest
    movInd = speeds > movThresh; %Index of when bees are moving
    movInd = double(movInd);
    movInd(isnan(speeds)) = NaN;
    
    movIndF = speedsF > movThresh; %Index of when bees are moving
    movIndF = double(movIndF);
    movIndF(isnan(speedsF)) = NaN;
    %%
    masterData(i).filename = list(i).name;
    masterData(i).nestSpeeds = speeds;
    masterData(i).taglist = taglist;
    %masterData(i).timestamps = timestamps;
    masterData(i).onNestIndex = onNest;
    masterData(i).nestMovingIndex = movInd;
    masterData(i).forageSpeeds = speedsF;
    masterData(i).forageMovingIndex = movIndF;
    masterData(i).frameCounts = sum(~isnan(xs));
    masterData(i).trialTime = trialTime;
    masterData(i).nestCoordinates = nTrackingData;
    masterData(i).forageCoordinates = forageTrackingData;
    %masterData(i).nestOutline = backgroundImages.nestOutline;
    %masterData(i).backIm = backgroundImages.backIm;
    %     %%
    %     if vis == 1
    %         bIm = nestTrackingData.backgroundImage;
    %         col = cat(3,ones(size(bIm)), ones(size(bIm)), zeros(size(bIm)));
    %         imshow(imadjust(bIm));
    %         hold on
    %         h = imshow(col);
    %         set(h, 'AlphaData', nestTrackingData.nestOutline.*0.2);
    %         %subplot(4,4,i)
    %         plot(xs(onNest == 1), ys(onNest == 1), 'r.', 'MarkerSize', 10);
    %         plot(xs(onNest == 0), ys(onNest == 0), 'g.', 'MarkerSize', 10);
    %     end
    %     hold off
    %%
    waitbar(i/numel(list));
end
close(h)