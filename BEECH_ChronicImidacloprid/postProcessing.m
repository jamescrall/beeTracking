parDir = uigetdir(pwd, 'Choose parent directory');
cd(parDir)
dirList = dir('*colPos*');

%%
masterData = struct();
for bb = 1:numel(dirList) %Loop across colony positions
    %% Data from colony position-level directory
    masDir = [parDir '\' dirList(bb).name];
    
    %Read in taglist data
    cd(masDir)
    taglist = dir('*taglist.cs v');
    colony = taglist.name(4:5);
    taglist = csvread(taglist.name,1,0);
    queenInd = taglist(:,2);
    callowInd = taglist(:,3);
    taglist = taglist(:,1);
    
    %Generate list of subdirectories (i.e. days)
    subDirs = dir(masDir);
    subDirs = subDirs(3:end); %Ignore first two elements in directory
    subDirs = subDirs([subDirs.isdir]); %Look only for directories
    colonyData = struct();
    for aa = 1:numel(subDirs)
        %%
        colonyData(aa).day = subDirs(aa).name;
        colonyData(aa).path = [masDir '\' subDirs(aa).name];
        [trackData nestBackIm forBackIm nestOutline] = postprocessColonyFolder([masDir '\' subDirs(aa).name], taglist);
        colonyData(aa).trackingData = trackData;
        colonyData(aa).nestBackIm = nestBackIm;
        colonyData(aa).forBackIm = forBackIm;
        colonyData(aa).nestOutline = nestOutline;
    end
    
    masterData(bb).colony = colony;
    masterData(bb).colonyData = colonyData;
    masterData(bb).path = masDir;
end
%%
save(strcat(parDir, '\masterData'), 'masterData', '-v7.3'); %Write data to file