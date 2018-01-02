qualThresh = 30;

% Need to run 'compileAndAnalyzeMaster' first 

for i = 1:numel(masterData)
    %%
    sumDat = masterData(i).summaryData;
    trialTimes = masterData(i).summaryDataTrialTimes;
    trialTimesA = trialTimes - masterData(i).firstDay + 1;
    tod = mod(trialTimesA, 1); %calculate time of day vector;
    hours = floor(tod*24);
    hoursCont = floor(trialTimesA*24);
    day = floor(trialTimesA);
    tags = masterData(i).colonyData(1).trackingData(1).taglist;
    variables = masterData(i).summaryDataVariableNames;
    variables = ['tagNumber' variables 'time' 'hour' 'hoursCont' 'day' 'treatment' 'colony'];
    treatment = masterData(i).treatment;
    if strmatch(treatment, '6ppb') == 1
        trt = 1;
        
    else trt = 0;
        
    end
    
    %Loop across timesteps and reshape data
    for j = 1:numel(trialTimesA)
        %%
        tmp = permute(sumDat(j,:,:), [2 3 1]); %reshape summaryData
        tmp = [tags tmp repmat([trialTimesA(j) hours(j) hoursCont(j) day(j) trt i],numel(tags),1)];
        tmp = array2table(tmp);
        tmp.Properties.VariableNames = variables;
        %Append data to master
        
        if ~exist('hourlyData')
            hourlyData = tmp;
        else
            hourlyData = [hourlyData;tmp];
        end
    end
    
    
end
%%
writetable(hourlyData,'/Users/james/Documents/chronicBeeImidacloprid/summaryDataHourlyDec82017.csv');
clear hourlyData