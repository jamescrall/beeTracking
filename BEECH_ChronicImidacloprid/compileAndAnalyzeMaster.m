
%% Choose directory with tracked data in it
cd(uigetdir());

list = dir('*masterData.mat');

%% load and compile
load(list(1).name); %load cohort B
masterData1 = masterData;

load(list(2).name); %load cohort C
masterData2 = masterData;

load(list(3).name); %load cohort D
masterData3 = masterData;

masterData = [masterData1 masterData2 masterData3]; %create master

clear masterData1
clear masterData2
clear masterData3
%%
masterData = appendSummarizedTrialData(masterData)

%% Load in treatment data and do some clean up

treatmentData = readtable('treatmentData.xlsx');

for i = 1:numel(masterData)
    
    %% Read in and add data on treatment and start date info
    col = masterData(i).colony;
    ind = strcmp(col, treatmentData.colony);
    tmp = treatmentData.treatment(ind);
    masterData(i).treatment = tmp{1};
    masterData(i).position = treatmentData.location(ind);
    masterData(i).firstDay = datenum(treatmentData.firstDay{ind}, 'dd-mmm')
    
    % Rearrange data in order of trial times
    times = masterData(i).summaryDataTrialTimes;
    [s ind] = sort(times);
    masterData(i).summaryDataTrialTimes = s;
    summaryData = masterData(i).summaryData;
    summaryData = summaryData(ind,:,:);
    masterData(i).summaryData = summaryData;
    
end


%% Generate list of tracked bees

inactivityThresh = 0.95; %Portion of time moving to be considered "active"
qualThresh = 150; %How many frames tracked to be considered alive?


for i = 1:numel(masterData)
    %%
    taglist = masterData(i).colonyData(1).trackingData.taglist;
    goodQuality = masterData(i).summaryData(:,:,3) > qualThresh;
    
    masterData(i).summaryDataQualCheck = goodQuality;
    
    moving = masterData(i).summaryData(:,:,4) < inactivityThresh;
    
    aliveAndTrackable = qualThresh & moving;
    masterData(i).summaryDataAliveAndTrackable = aliveAndTrackable;
    
    days = floor(masterData(i).summaryDataTrialTimes);
    uDays = unique(days);
    
    lastDayAAT = aliveAndTrackable(days == uDays(end),:); %last day alive and trackable binary
    
    goodTaglist = taglist(sum(lastDayAAT) > 0);
    
    masterData(i).goodTaglist = goodTaglist;
    
    outfile = strcat(masterData(i).colony, 'goodTaglist.csv');
    csvwrite(outfile, goodTaglist);
end

% %% Plot averages by colony
% for i = 1:numel(masterData)
%     
%     %Extract variables
%     times = masterData(i).summaryDataTrialTimes;
%     dayOne = round(min(times));
%     summaryData = masterData(i).summaryData;
%     aliveAndTrackable = masterData(i).summaryDataAliveAndTrackable;
%     qualCheck = masterData(i).summaryDataQualCheck;
%     usable = logical(zeros(size(aliveAndTrackable)));
%     treatment = masterData(i).treatment;
%     
%     %Define time regions before bees were last known to be alive (i.e. moving and well tracked)
%     
%     for j = 1:size(aliveAndTrackable,2);
%         ind = find(aliveAndTrackable(:,j));
%         maxInd = max(ind);
%         usable(1:maxInd,j) = 1;
%         
%     end
%     
%     
%     %Clean up data
%     for j = 1:size(summaryData,3)
%         tmp = summaryData(:,:,j);
%         tmp(~usable | ~qualCheck) = NaN;
%         summaryData(:,:,j) = tmp;
%     end
%     
%     %Plot
%     if strmatch(treatment,'contr')
%         col = 'g';
%     elseif strmatch(treatment,'6ppb');
%         col = 'r';
%     end
%     
%     dayOne = masterData(i).firstDay;
%     timesPlot = times - dayOne;
%     timesPlotHours = floor(timesPlot*24)/24;
%     plot(timesPlot, nanmean(summaryData(:,:,4),2), '-', 'Color', col);
%     title('inactive');
%     %plot(timesPlot, nanmean(summaryData(:,:,7)+summaryData(:,:,8),2), '-', 'Color', col);
%     
%     %plot(repmat(times', 1, size(summaryData,2)), summaryData(:,:,1),'Color', col);
%     hold on
%     %plot(repmat(times', 1, size(summaryData,2)), summaryData(:,:,1), '.','Color', col);
%     datetick('x','mmm-dd HH');
%     
% end
% hold off
% 
% %%
% %Generate master list of times
% masterTimes = [];
% for i = 1:numel(masterData)
%     %%
%     times = masterData(i).summaryDataTrialTimes;
%     dayOne = masterData(i).firstDay; %make relative to day of marking
%     timesRel = times - dayOne;
%     masterTimes = [masterTimes timesRel];
%     
% end
% 
% %Round to hoursmaster
% masterTimes = unique(datenum(datestr(masterTimes, 'dd-mmm-yyyy HH'), 'dd-mmm-yyyy HH'));
% %%
% hold off
% varNum = 5; %Which variable to extract from summary data?
% timeAlignedData = nan(numel(masterTimes), 100,numel(masterData));
% trtBin = nan(numel(masterData),1);
% for i = 1:numel(masterData)
%     %%
%     %Extract variables
%     times = masterData(i).summaryDataTrialTimes;
%     summaryData = masterData(i).summaryData;
%     aliveAndTrackable = masterData(i).summaryDataAliveAndTrackable;
%     qualCheck = masterData(i).summaryDataQualCheck;
%     usable = logical(zeros(size(aliveAndTrackable)));
%     treatment = masterData(i).treatment;
%     
%     
%     %Define time regions before bees were last known to be alive (i.e. moving and well tracked)
%     for j = 1:size(aliveAndTrackable,2);
%         %%
%         ind = find(aliveAndTrackable(:,j));
%         maxInd = max(ind);
%         usable(1:maxInd,j) = 1;
%         
%     end
%     
%     
%     %Clean up data
%     for j = 1:size(summaryData,3)
%         tmp = summaryData(:,:,j);
%         tmp(~usable | ~qualCheck) = NaN;
%         summaryData(:,:,j) = tmp;
%     end
%     
%     
%     dayOne = masterData(i).firstDay;
%     timesPlot = times - dayOne;
%     timesPlotH = datenum(datestr(timesPlot, 'dd-mmm-yyyy HH'), 'dd-mmm-yyyy HH'); %Round to collection hour
%     
%     %Extract relevant variable
%     data = summaryData(:,:,varNum);
%     
%     empty = nan(numel(masterTimes), size(data,2));
%     
%     [x ind] = ismember(timesPlotH, masterTimes);
%     
%     empty(ind,:) = data;
%     %append data
%     timeAlignedData(:,1:size(empty,2),i) = empty;
%     if strmatch(treatment,'contr')
%         trtBin(i) = 0;
%         col = 'g';
%     elseif strmatch(treatment,'6ppb');
%         trtBin(i) = 1;
%         col = 'r';
%     end
%     
%     nInd = timesPlot > 0;
%     plot(repmat(timesPlot(nInd)',1, size(data,2)), data(nInd,:), 'Color', col, 'LineWidth', 0.5);
%     hold on
%     
% end
% hold off
% 
% %% Get means and standard errors for each timestep
% clipInd = masterTimes < 100;
% times = masterTimes(clipInd);
% data = timeAlignedData(clipInd,:,:);
% treatMaster = nan(numel(times),3);
% contrMaster = nan(size(treatMaster));
% for i = 1:numel(times)
%     %% calculate statistics for treatmentData
%     try
%         dat = data(i,:,logical(trtBin));
%         
%         dat = reshape(dat,numel(dat),1);
%         dat = dat(~isnan(dat));
%         dMean = mean(dat);
%         out = bootci(1000,@mean,dat);
%         treatMaster(i,1) = dMean; %Append mean;
%         treatMaster(i,2) = out(1); %Append lower CI
%         treatMaster(i,3) = out(2); %Append upper CI
%     catch
%         disp(strcat('Error in estimating CI for timepoint', datestr(times(i)), '_skipping'));
%         continue
%     end
%     
%     %% Repeat for control
%     try
%         dat = data(i,:,~logical(trtBin));
%         
%         dat = reshape(dat,numel(dat),1);
%         dat = dat(~isnan(dat));
%         dMean = mean(dat);
%         out = bootci(1000,@mean,dat);
%         contrMaster(i,1) = dMean; %Append mean;
%         contrMaster(i,2) = out(1); %Append lower CI
%         contrMaster(i,3) = out(2); %Append upper CI
%     catch
%         disp(strcat('Error in estimating CI for timepoint', datestr(times(i)), '_skipping'));
%         continue
%     end
% end
% 
% %
% hold on;
% plot(times, contrMaster(:,1), 'g', 'LineWidth', 3);
% plot(times, contrMaster(:,2), 'g', 'LineWidth', 2);
% plot(times, contrMaster(:,3), 'g', 'LineWidth', 2);
% 
% plot(times, treatMaster(:,1), 'r', 'LineWidth', 3);
% plot(times, treatMaster(:,2), 'r', 'LineWidth', 2);
% plot(times, treatMaster(:,3), 'r', 'LineWidth', 2);
hold off