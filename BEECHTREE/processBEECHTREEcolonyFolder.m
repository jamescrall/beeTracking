%%  Choose
[file path] = uigetfile('*trackingData*.mat');
load([path file]); %Loads objects "nestTrackingDataMaster" and "forageTrackingDataMaster"
nestData = nestTrackingDataMaster;
forageData = forageTrackingDataMaster;
clear nestTrackingDataMaster forageTrackingDataMaster
[file path] = uigetfile('*tform.mat');
load([path file]); %Loads "tform" object

disp('Navigate to parent folder with video data');
cd(uigetdir());
%%
vis = 0;

for i = 1:numel(nestData)
    %%
    nestFile = nestData(i).name;
    list = dir(['**/*' nestFile]);
    
    if numel(list) == 1
        
        nestFile = [list(1).folder '/' list(1).name];
        thermFile = strrep(nestFile, 'NC.avi', 'TC.mj2');
        
    else
        
        disp('Multiple files with same name, check for redundancy');
        return
        
    end
    
    nestVid = VideoReader(nestFile);
    thermVid = VideoReader(thermFile);
    
    %Add snapshot to master data for reference;
    nestData(i).thermSampleIm = read(thermVid,1);
    nestData(i).nestSampleIm = read(nestVid,1);
    
    nestTracks = nestData(i).trackingData;
    
    %Calculate transformed coordinates from tracked camera to thermal camera
    nestTracks = appendThermalCamCoordinates(nestTracks, tform);
    
    if vis == 1
        playThermAndVisVidsWithTrackingData(thermVid, nestVid, nestTracks);
    end
    
    
    nestData(i).trackingData = nestTracks; %write modifided data back into master data object
    
    %Add in timestamp as a datenum 
        date = nestData(i).name;
    date = strsplit(date, '_colPos');
    date = date{1};
    date = datenum(date, 'dd-mmm-yyyy_HHMMSS');
    nestData(i).trialTime = date;
    i
end

%%
n = 8;
for i = 1:numel(nestData)
    %%
    subplot(6, 5, i)
    im = nestData(i).thermSampleIm;
    imagesc(im);
    colormap hot;
    hold on
    nestTracks= nestData(i).trackingData;
    plot(nestTracks(:,:,5), nestTracks(:,:,6),'.','MarkerSize', 5, 'Color', 'g');
    hold off
title(datestr(nestData(i).trialTime));
end