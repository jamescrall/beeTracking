%% Generate "masterData" object with "compileAndAnalyzeMaster.m"

vars = {'interactionRate', 'netDensity','day' ,'colony' ,'treatment', 'time'};

%%
for i = 1:numel(masterData)
    
    %%
    colDat = masterData(i).colonyData;
    treatment = masterData(i).treatment;
    if strmatch(treatment, '6ppb') == 1
        trt = 1;
    else trt = 0;
    end
    firstDay = masterData(i).firstDay
    %% loop across days
    for j = 1:numel(colDat)
        %%
        trackDat = colDat(j).trackingData;
        taglist = trackDat(1).taglist;
        nbees = numel(taglist);
        refMat = zeros(nbees, nbees);
        for k = 1:numel(trackDat)
            %%
            try
                time = trackDat(k).trialTime - firstDay + 1;
                intMatAv = trackDat(k).intMatAv;
                
                ey = eye(size(intMatAv,1));
                intMatAv(logical(ey)) = NaN; %Remove diagonal of matrix
                intMat = double(intMatAv > 0);
                intMat(isnan(intMatAv)) = NaN;
                
                intRate = nanmean(nanmean(intMatAv));
                netDensity = nanmean(nanmean(intMat));
                
                
                netSum = [intRate netDensity j i trt time];
            catch
                disp('Error here');
                return
            end
            
            
            if ~exist('netData');
                netData = netSum;
            else
                netData = [netData; netSum];
            end
            
        end
        %%
        %         %%
        %         for k = 1:numel(trackDat)
        %             %%
        %             intMat = trackDat(k).intMatAv > 0;
        %             refMat = refMat + intMat;
        %         end
        %
        %         intMat = double(refMat > 0);
        %         for l = 1:nbees
        %             intMat(l,l) = NaN;
        %         end
        %
        %         masterData(i).colonyData(j).intMat = intMat;
        %
        %         netDensity = nanmean(nanmean(intMat));
        
        %Append data on number of valid  trials
        
        
        %Write to table
        
        
        
    end
    
    
    
end

%%
netData = array2table(netData);
netData.Properties.VariableNames = vars;
writetable(netData,'/Users/james/Documents/chronicBeeImidacloprid/networkSummaryDataOct2.csv');
