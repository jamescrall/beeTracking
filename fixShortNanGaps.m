function intData = fixShortNanGaps(inputData, maxGapSize)
%Code to interpolated NaN gaps in a single dimension for a determined gap
%interpolates missing data (nans) along columns of "inputData" up to a
%maximum gap size of "maxGapSize"

%%
for i = 2:numel(inputData)
    %%
    if isnan(inputData(i)) & ~isnan(inputData(i-1)) %If current step is nan, and previous step isn't, try to heal
        tVec = inputData(i:end);
        nextRealNumberInd = min(find(~isnan(tVec)));
        if nextRealNumberInd <= maxGapSize + 1
            t1 = i-1;
            t2 = i + nextRealNumberInd -1;
            inputData(t1:t2) = linspace(inputData(t1), inputData(t2), nextRealNumberInd +1);
        end
        
    end
end

intData = inputData;

