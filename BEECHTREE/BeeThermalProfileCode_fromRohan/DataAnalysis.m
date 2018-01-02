% This program takes the output of get snaps and outputs
% 1. An array of all the measurements for each bee without the blanks
% 2. An array of mean temperature for each bee
% 3. and array of Std. Devs for each bee

% Convert Data Entries of TempCollection into Ints
TempColAn = cell(numTags, numMeasurements);

for i = 1:numTags
    for j = 1:numMeasurements
        TempData = TempCollection{i,j};
        if not(isempty(TempData))
            TempColAn{i,j} = TempData.Value;
        end
    end
end
    
% Output temperature values for each bee without blanks
BeeRows = []; % Array with temp values for each bee
for i = 1:numTags
    Row = [];
    for j = 1:numMeasurements
        if not(isempty(TempColAn{i,j}))
            Row{end+1} = TempColAn{i,j};
        end
    end
    BeeRows{i} = Row;
end

% Find mean temperature value for each bee
Means = cell(1,numTags); % Array of mean temp values for each bee
StdDevs = cell(1,numTags); % array of std devs
for i = 1:numTags
    if not(isempty(BeeRows{i}))
        TempArr = cell2mat(BeeRows{i});
        Means{i} = mean(TempArr);
        StdDevs{i} = std(TempArr);
    end
end

