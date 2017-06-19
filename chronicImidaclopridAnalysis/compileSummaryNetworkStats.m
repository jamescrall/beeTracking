vars = {'netDensity' 'day' 'colony' 'treatment'};

%%
for i = 1:numel(masterData)
    
    %%
    colDat = masterData(i).colonyData;
    treatment = masterData(i).treatment;
    if strmatch(treatment, '6ppb') == 1
        trt = 1;
    else trt = 0;
    end
    %% loop across days
    for j = 1:numel(colDat)
        %%
        trackDat = colDat(j).trackingData;
        taglist = trackDat(1).taglist;
        nbees = numel(taglist);
        refMat = zeros(nbees, nbees);
        %%
        for k = 1:numel(trackDat)
            %%
            intMat = trackDat(k).intMatAv > 0;
            refMat = refMat + intMat;
        end
        
        intMat = double(refMat > 0);
        for l = 1:nbees
            intMat(l,l) = NaN;
        end
        
        masterData(i).colonyData(j).intMat = intMat;
        
        netDensity = nanmean(nanmean(intMat));
        
        %Append data on number of valid  trials
        
        
        %Write to table
        
        netSum = [netDensity j i trt];
        if ~exist('netData');
            netData = netSum;
        else
            netData = [netData; netSum];
        end
        
    end
    
    
    
end

%%
netData = array2table(netData);
netData.Properties.Variab`leNames = vars;
writetable(netData,'/Users/james/Documents/chronidBeeImidacloprid/networkSummaryData.csv');
