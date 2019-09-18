function masterData = BEECH_appendBackgroundImagesToMasterdata(masterData)
    %% append broodData to masterData file
    
    for i = 1:numel(masterData) %Loop across colonies
        %%
        disp(['Beginning colony ' num2str(i) ' of ' num2str(numel(masterData))]);
        colony = masterData(i).colPos; %identify colony position
        expRound = masterData(i).expRound; %identify experimental round
        trackingData = masterData(i).trackingData; %Extract trackng data
        
        times = [trackingData.datenum];
        days = datenum(datestr(times, 'yyyymmdd'), 'yyyymmdd');
        
        uniqueDays = unique(days);
        dailyBackgrounds = struct();
        
        for j = 1:numel(uniqueDays)
            %%
            dayIndex = find(days == uniqueDays(j));
            
            [backImage backStack] = calculateBackgroundFromFilelist(trackingData(dayIndex), 40, 0.8);
            
            dailyBackgrounds(j).day = uniqueDays(j);
            dailyBackgrounds(j).backImage = uint8(backImage);
            dailyBackgrounds(j).backStack = backStack;
            %Write to masterData
            for k = 1:numel(dayIndex)
                trackingData(dayIndex(k)).day = uniqueDays(j);
            end
            
            
        end
        
        masterData(i).dailyBackgrounds = dailyBackgrounds; %Append background images to masterData
        masterData(i).trackingData = trackingData; %Append modify trackingData object back into master
        
    end