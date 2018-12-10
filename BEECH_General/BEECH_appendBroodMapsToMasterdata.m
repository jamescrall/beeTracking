function masterData = BEECH_appendBroodMapsToMasterdata(masterData)
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
    
    for j = 1:numel(uniqueDays)
        %%
        dayIndex = find(days == uniqueDays(j));
        
        %Define file prefix
        filePrefix = ['colPos', num2str(colony), '_', datestr(uniqueDays(j)),  ...
            '_expRound', num2str(expRound)];
        
        %Check if file already exists
        outfilename = strcat(filePrefix, '_brood.mat');
        broodFilelist = dir(['**/*' outfilename]);
        
        if ~isempty(broodFilelist)
            load([broodFilelist.folder '/' broodFilelist.name], 'brood');
            choice = questdlg(['Brood file "' outfilename '" already exists on disk - loading. Skip analysis?'], 'Load Brood Data', 'Yes', 'No', 'No');
            
            switch choice
                case 'Yes'
                    %Write to masterData
                    for k = 1:numel(dayIndex)
                        trackingData(dayIndex(k)).brood = brood;
                        trackingData(dayIndex(k)).broodFileIndex = outfilename;
                    end
                    
                    continue
                    
                case 'No'
                    msgbox('loading brood data for editing...');
            end
        else
            choice = questdlg('Do you want to load existing brood data?', 'Load Brood Data', 'Yes - from file', 'Yes - from last', 'No', 'No')
            
            switch choice
                case 'Yes - from file' %Load from file?
                    
                    uiopen('load');
                    
                case 'Yes - from last'
                    
                    brood = lastBrood; %Use memory
                    
                case 'No'
                    
                    disp('No brood data loaded')
                    
                    if exist('brood', 'var')
                        clear brood %Make sure there's no brood in memory
                    end
            end
            
        end
        %% visualize individual movement
        
        %Create empty brood if it doesn't exist yet
        if ~exist('brood')
            brood = [];
        end
        
        
        
        %Run GUI to map nest structure
        [brood backImage sampleImageStack] = BEECH_locateBroodAndPots_output(trackingData(dayIndex), brood, filePrefix);
        
        %Save current brood to memory temporarily
        lastBrood = brood;
        
        
        
        %Write to masterData
        for k = 1:numel(dayIndex)
            trackingData(dayIndex(k)).brood = brood;
            trackingData(dayIndex(k)).broodFileIndex = outfilename;
        end
        
        %Clear current brood iteration
        clear brood;
        
    end
    
    masterData(i).trackingData = trackingData; %Append modify trackingData object back into master
end