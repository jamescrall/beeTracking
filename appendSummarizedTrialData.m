function masterData = appendSummarizedTrialData(masterData)
varNames = {'porTimeMoving', 'porTimeOnNest', 'medMovingSpeed','framesTracked', 'porTimeInactive'};
%%
for i = 1:numel(masterData) %Loop across colonies
    %%
    % i = colony index
% j = day index
% k = trial index
    colDat = masterData(i).colonyData;
    taglist = colDat(1).trackingData(1).taglist;
    nbees = numel(taglist);
    
    for j = 1:numel(colDat) %loop across days
        
        trialDat = colDat(j).trackingData;
        
        for k = 1:numel(trialDat)
            %%
            
            data = masterData(i).colonyData(j).trackingData(k);
            tmp = nan(1,nbees, numel(varNames));
            tmp(:,:,1) = nanmean(data.movingIndex); %Calculate portion of time moving
            tmp(:,:,2) = nanmean(data.onNestIndex); %Calculate portion of time on nest
            speeds = data.speeds; %Extract speed vals
            speeds(data.movingIndex == 0) = NaN; %Remove values when bees aren't moving
            tmp(:,:,3) = nanmedian(speeds); %median speeds when moving
            tmp(:,:,4) = data.frameCounts;
            
            if ~exist('sumDat') %If "sumDat" doesn't exist or has been cleared, make it
                sumDat = tmp;
                trialTimes = data.trialTime;
            else
                sumDat = cat(1, sumDat, tmp);
                trialTimes = [trialTimes data.trialTime];
            end
            
        end
        
        
    end
    

    %% Write summary data back into masterData object
    masterData(i).summaryData = sumDat;
    masterData(i).summaryDataVariableNames = varNames;
    masterData(i).summaryDataTrialTimes = trialTimes;
    clear sumDat
    clear trialTimes
end