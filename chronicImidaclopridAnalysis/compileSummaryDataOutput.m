%%
qualThresh = 30;

for i = 1:numel(masterData)
    %%
    try
        trialTimes = masterData(i).summaryDataTrialTimes;
        trialTimesA = trialTimes - masterData(i).firstDay + 1;
        sumDat = masterData(i).summaryData;
        days = unique(floor(trialTimesA));
        nightCut = 21.5/24; %9:30 pm converted to timestamp;
        mornCut = 7.5/24; %7:30 am converted to timestamp;
        tod = mod(trialTimesA, 1); %calculate time of day vector;
        
        for j = 1:numel(days)
            %%
            dayInd = floor(trialTimesA) == days(j);
            dTimes = tod(dayInd);
            dat = sumDat(dayInd,:,:);
            nightTimes = dTimes < mornCut | dTimes > nightCut;
            
            %Clean out data below quality-threshold
            dataClear = dat(:,:,3) < qualThresh;
            for k = 1:size(dat,3);
                tmp = dat(:,:,k);
                tmp(dataClear) = NaN;
                dat(:,:,k) = tmp;
            end
            
            nightDat = dat(nightTimes,:,:);
            
            dayDat = dat(~nightTimes,:,:);
            
            %Count number of valid trials for each data subset
            totTrials = sum(~isnan(dat(:,:,3)));
            nightTrials = sum(~isnan(nightDat(:,:,3)),1);
            dayTrials = sum(~isnan(dayDat(:,:,3)),1);
            
            %Generate averaged tables
            totMeans = permute(nanmean(dat,1),[2,3,1]);
            dayMeans = permute(nanmean(dayDat,1),[2,3,1]);
            nightMeans = permute(nanmean(nightDat,1),[2,3,1]);
            
            %Append data on number of valid  trials
            taglist = masterData(i).colonyData(1).trackingData(1).taglist;
            treatment = masterData(i).treatment;
            if strmatch(treatment, '6ppb') == 1
                trt = 1;
            else trt = 0;
            end
            %%
            totMeans = [taglist totMeans totTrials' repmat([0 trt j i], numel(taglist),1)];
            dayMeans = [taglist dayMeans dayTrials' repmat([1 trt j i], numel(taglist),1)];
            nightMeans = [taglist nightMeans nightTrials' repmat([2 trt j i], numel(taglist),1)];
            %%
            %Convert to tables
            variables = masterData(i).summaryDataVariableNames;
            variables = horzcat('tagNumber', variables, 'validTrials', 'timeOfDay', 'treatment', 'dayNumber', 'colonyNumber');
            %%
            totDat = array2table(totMeans);
            totDat.Properties.VariableNames = variables;
            
            dayDat = array2table(dayMeans);
            dayDat.Properties.VariableNames = variables;
            
            nightDat = array2table(nightMeans);
            nightDat.Properties.VariableNames = variables;
            %%
            if ~exist('masDat');
                masDat = totDat;
            else
                masDat = [masDat; totDat];
            end
            masDat = [masDat; dayDat; nightDat];
            
        end
    catch
        disp(strcat({'Error in colony '}, num2str(i), {', Day '}, num2str(j), {', skipping...'}));
        continue
    end
end
%%
writetable(masDat,'/Users/james/Dropbox/Work/Neonicotinoids/ChronicExposure/Data/TrackingData/summaryData.csv');
clear masDat