%% Load metadata

%  Manually specify master data file
masterData = struct();
uiwait(msgbox('Choose .mat file with tracking data'));
[file path] = uigetfile('*trackingData*.mat');
load([path file]); %Loads objects "nestTrackingDataMaster" and "forageTrackingDataMaster"
nestData = nestTrackingDataMaster;
forageData = forageTrackingDataMaster;
clear nestTrackingDataMaster forageTrackingDataMaster

%  Manually specify tform object
uiwait(msgbox('Choose .mat file with correct tform image registration object'));
[file path] = uigetfile('*tform.mat');
load([path file]); %Loads "tform" object
masterData.tform = tform;
%
%msgbox('Navigate to parent folder with video data');
% Files that need to be present in the master directory with video files:
% *brood.mat: manually specified coordinates of brood and waxpot locations
% (from BEECH_locateBroodAndPots)
%
% *temperatures*.mat file, with 12 temperature readings and times, temp1,
% temp2, etc.

cd(uigetdir(pwd, 'Choose folder with brood location data, separately for differnet days'));
broodList = dir('*brood.mat');
broodNames = {broodList.name};

for i = 1:numel(nestData)
    day = nestData(i).name(1:6);
    ind = contains(broodNames, day);
    load(broodList(ind).name);
    nestData(i).brood = brood;
end
%
%load temperature data
uiwait(msgbox('Choose .mat file with temperature data'));
[file path] = uigetfile('*temperatures.mat');
load([path file]); %Loads "tform" object

tempTimes = times;
calTemps = temps;

clear times
clear temps
% %%
% for i = 1:numel(tempList)
%     %%
%     try
%         load(tempList(i).name);
%         cdir = pwd; %get name of current directory (assume it's of form colPosN, where N %in% 1:4
%         if cdir(end) == '1'
%             curTemps = [times' temp1' temp2' temp3'];
%         elseif  cdir(end) == '2'
%             curTemps = [times' temp4' temp5' temp6'];
%         elseif cdir(end) == '3'
%             curTemps = [times' temp7' temp8' temp9'];
%         elseif cdir(end) == '4'
%             curTemps = [times' temp10' temp11' temp12'];
%         end
%
%         if ~exist('curTempsM', 'var')
%             curTempsM = curTemps;
%         else
%             keepInd = ~ismember(curTemps(:,1), curTempsM(:,1));
%             curTempsM = [curTempsM; curTemps(keepInd,:)];
%         end
%     catch
%         continue
%     end
% end
% masterTemps = curTempsM;
% clear curTempsM;
%
% %Remove missing data
% masterTemps = masterTemps(sum(masterTemps(:,2:4) == 0,2) == 0,:)
% plot(masterTemps(:,1), masterTemps(:,2), 'r.');
% datetick


out = inputdlg({'temp sensor 1 index', 'temp sensor 2 index'}, 'Define indices for temp sensors', [1 30]);
tempInd1 = str2num(out{1});
tempInd2 = str2num(out{2});
%% Manually specify ROIs
uiwait(msgbox('Navigate to parent folder containing video data'));
cd(uigetdir());
i = 17;
cmp = inferno(200)
nestFile = nestData(i).name;
list = dir(['**/*' nestFile]); %search for nest tracking data file
nestFile = [list(1).folder '/' list(1).name];
thermFile = strrep(nestFile, 'NC.avi', 'TC.mj2');
thermVid = VideoReader(thermFile);
%Specify ROIs for thermal probes
thermIm = read(thermVid,1);
imagesc(thermIm)
colormap(cmp);


refPol1 = roipoly;
refPol2 = roipoly;
imagesc(refPol1 + refPol2)


%% Analyze thermal videos
vis = 0;
uiwait(msgbox('Navigate to parent folder with video data'));
cd(uigetdir());

%NB: Add in section to generate ROIs for different thermal probes

for i = 1:numel(nestData)
    %%
    % try
    %Add in timestamp as a datenum
    date = nestData(i).name;
    date = strsplit(date, '_colPos');
    date = date{1};
    date = datenum(date, 'dd-mmm-yyyy_HHMMSS');
    nestData(i).trialTime = date;
    
    
    
    nestFile = nestData(i).name;
    list = dir(['**/*' nestFile]); %search for nest tracking data file
    
    nestData(i).nestFile = nestFile;
    nestData(i).thermFile = thermFile;
    
    if numel(list) == 1
        
        nestFile = [list(1).folder '/' list(1).name];
        thermFile = strrep(nestFile, 'NC.avi', 'TC.mj2');
        
        try
            % Load video timestamp file
            timefile = strsplit(thermFile, '_colPos');
            timefile = timefile{1};
            timefile = strcat(timefile, '_timestamps.csv');
            times = csvread(timefile);
            videoTimes = times(:,2);
            videoTimes = videoTimes+floor(date); %If timestamps are in time from beginning of day, rework
        catch
            disp('no timestamp data - likely an incomplete trial, skipping...');
            
            %If there's a "videoTimes" variable in memory, clear it
            if exist('videoTimes', 'var');
                clear videoTimes
            end
        end
        
    else
        
        disp('Multiple files with same name, check for redundancy');
        return
        
    end
    
    nestVid = VideoReader(nestFile);
    thermVid = VideoReader(thermFile);
    nThermFrames = thermVid.NumberOfFrames;
    
    %Add snapshot to master data for reference;
    nestData(i).thermSampleIm = read(thermVid,1);
    nestData(i).nestSampleIm = read(nestVid,1);
    
    
    
    %Check that the thermVid isn't filled with empty data
    thermD1 = abs(read(thermVid,1) - read(thermVid,2)); %Check first frame
    thermD2 = abs(read(thermVid,nThermFrames) - read(thermVid,nThermFrames - 1)); %Check last frame
    
    
    if mean(mean(thermD1)) > 0 & mean(mean(thermD2)) > 0 %are both first anbd last frames valid? If so, assume whole video is OK
        validThermalFrames = ones(nThermFrames,1);
        nestData(i).validThermalFrames = validThermalFrames;
        nestData(i).thermalDataQuality = 1;
    elseif mean(mean(thermD1)) == 0 & mean(mean(thermD2)) == 0 %If neither first nor last is valid, assume whole video is corrupt
        
        validThermFrames = zeros(nThermFrames,1);
        nestData(i).validThermalFrames = validThermalFrames;
        disp('thermal data is empty - skipping...');
        nestData(i).thermalDataQuality = 0;
        
        %return
        continue
        
    else %Case if only some of video is corrupted
        disp('partially valid video - checking individual frames for validity');
        validThermalFrames = zeros(nThermFrames,1);
        h = waitbar(0, 'checking for valid thermal data');
        
        for j = 1:(nThermFrames-1)
            %%
            thermImD = abs(read(thermVid,j) - read(thermVid,j+1));
            if mean(mean(thermImD > 0));
                validThermalFrames(j) = 1;
            end
            waitbar(j/nThermFrames, h);
        end
        close(h);
        nestData(i).validThermalFrames = validThermalFrames;
        nestData(i).thermalDataQuality = 1;
        
    end
    
    
    
    
    
    nestTracks = nestData(i).trackingData;
    
    %Calculate transformed coordinates from tracked camera to thermal camera
    nestTracks = appendThermalCamCoordinates(nestTracks, tform);
    
    %
    if vis == 1
        playThermAndVisVidsWithTrackingData(thermVid, nestVid, nestTracks);
    end
    
    % Calculate offsets and
    offsets = nan(nThermFrames,2);
    
    nestTracks(:,:,7) = nan(size(nestTracks,1), size(nestTracks,2));
    
    for j = 1:nThermFrames
        %%
        % figure(1)
        % visIm = read(visVid,i);
        thermIm = read(thermVid,j); %Read in thermal video frame
        thermIm = convertThermalImage(thermIm); %Convert raw data to deg C
        
        %%
        
        offset1 = calculateThermImOffset(thermIm, j, videoTimes,calTemps(:,tempInd1), tempTimes, refPol1);
        offset2 = calculateThermImOffset(thermIm, j, videoTimes,calTemps(:,tempInd2), tempTimes, refPol2);
        
        offsets(j,1) = offset1;
        offsets(j,2) = offset2;
        meanOffset = mean([offset1 offset2]);
        
        thermIm = thermIm+meanOffset;
        %%
        for k = 1:size(nestTracks,2)
            x = nestTracks(j,k,5);
            y = nestTracks(j,k,6);
            if ~isnan(x)
                temp = takeTempReadingFromThermalImage(thermIm, x, y);
                nestTracks(j,k,7) = temp;
            end
        end
        
    end
    
    nestData(i).offsets = offsets;
    nestData(i).trackingData = nestTracks; %write modifided data back into master data object
    
    i
    %   catch
    %       disp('Error reading video - check for corruption');
    %       continue
    %   end
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

%%
uisave('nestData');