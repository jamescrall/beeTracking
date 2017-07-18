% Uses results from DataAnalysis.m to make an array which lists tagnumber,
% mean temp, and std dev for each bee in each cell.

means = cell(1,numTags);
stddevs = cell(1,numTags);
for i = 1:numTags
    if not(isempty(FullBeeData{i}))
        TempArr = cell2mat(FullBeeData{i});
        means{i} = mean(TempArr);
        stddevs{i} = std(TempArr);
    end
end

CompBeeData = cell(numTags,1);
for i = 1:numTags
    if not(isempty(FullBeeData{i}))
        CompBeeData{i}{1} = numel(FullBeeData{i});
        CompBeeData{i}{2} = means{i};
        CompBeeData{i}{3} = stddevs{i};
    else
        CompBeeData{i}{1} = 0;
    end
end

CompDataArr = [];
for i = 1:numTags
    CompDataArr{i} = cell2mat(CompBeeData{i});
end
    
 