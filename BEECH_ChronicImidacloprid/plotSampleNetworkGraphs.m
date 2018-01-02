
%%
    for i = [1 2]
   j = 4; %Which day?
    colDat = masterData(i).colonyData;
    treatment = masterData(i).treatment;
    if strmatch(treatment, '6ppb') == 1
        trt = 1;
    else trt = 0;
    end
        %%
        trackDat = colDat(j).trackingData;
        taglist = trackDat(1).taglist;
        nbees = numel(taglist);
        refMat = zeros(nbees, nbees, numel(trackDat));
        for k = 1:numel(trackDat)
            %%
                time = trackDat(k).trialTime;
                intMatAv = trackDat(k).intMatAv;
                
                ey = eye(size(intMatAv,1));
                intMatAv(logical(ey)) = NaN; %Remove diagonal of matrix
                intMat = double(intMatAv > 0);
                intMat(isnan(intMatAv)) = NaN;
                
                intRate = nanmean(nanmean(intMatAv));
                netDensity = nanmean(nanmean(intMat));
                
                
                netSum = [intRate netDensity j i trt time];

             refMat(:,:,k) = intMat;
            
        end
    
        ind = ~isnan(nanmean(nanmean(refMat,3)));
    refMat = refMat(ind,ind,:)
    refMat = nanmean(refMat,3);
    refMat(isnan(refMat)) = 0 ;
subplot(2,1,i);
circularGraph(double(refMat> 0));
    end
