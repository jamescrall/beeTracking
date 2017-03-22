%Get user inputs for folder
%[filename pathname] = uigetfile('*.avi', 'select first movie');
%[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');


parDir = uigetdir(pwd, 'Choose parent directory');
cd(parDir)
dirList = dir('*colPos*');

%for i = 1:numel(dirList)
for i = 1:2
    %%
    masDir = [parDir '/' dirList(i).name];
    subDirs = dir(masDir);
    subDirs = subDirs(3:end); %Ignore first two elements in directory
    
    generateBackgroundImagesForSubfolders(subDirs, masDir)
    clear xi
    clear yi
end

%% Find optimal tracking parameters?
choice = questdlg('Optimize tracking parameters?', 'Yes', 'No');
switch choice
    case 'Yes'
        %threshVals = [0.001 0.005 0.01 0.05 0.08 0.1 0.12 0.15 0.2 0.3 0.5 1 1.5 2 3 4 5];
        %filtVals = [8 10 12 14 16 18 20];
        %parpool(4);
        threshVals = [0.5 1 2 4];
        filtVals = [10 15 20];
        nframes = 10;
        [forvidfilename forvidpathname] = uigetfile({'*avi', 'Choose foraging movie to optimize'});
        forvid = VideoReader([forvidpathname forvidfilename]);
        [nestvidfilename nestvidpathname] = uigetfile({'*avi', 'Choose foraging movie to optimize'});
        nestvid = VideoReader([nestvidpathname nestvidfilename]);
        [tagfilename tagpathname] = uigetfile({'*csv', 'Choose tag data file'});
        taglist = readtable([tagpathname tagfilename], 'readVariableNames', 0);
        taglist = table2array(taglist(:,1));
        figure(1)
        [forThresh forFilt] = optimizeTrackingParameters(forvid,threshVals,filtVals,nframes,taglist)
        %Set threshold ranges
        figure(2)
        [nestThresh nestFilt] = optimizeTrackingParameters(nestvid,threshVals,filtVals,nframes,taglist);
    case 'No'
        return
end




%% Track!
%Gear up parallel pool
parpool(4);
brFiltNest = [10 10];
brThreshNest = 0.1;
brFiltFor = [9 9];
brThreshFor = 0.1;

for aa = 1:numel(subDirs)
    curDir = [masDir '\' subDirs(aa).name];
    if isdir(curDir)
        %% Create list of movie pairs
        cd(curDir);
        list = dir('*NC.avi');
        
        %Load in background images file
        filename = list(1).name;
        backgroundImages = load(strrep(filename, 'NC.avi', 'backgroundImages.mat'));
        backgroundImages = backgroundImages.backgroundImages;
        %Read in taglist
        taglist = dir('*taglist.csv');
        taglist = csvread(taglist.name);
        
        %Loop across videos
        for zz = 1:numel(list)
            zz
            filename = list(zz).name
            %Create VideoReader object
            vid = VideoReader([curDir '/' filename]);
            
            nframes = vid.NumberOfFrames;
            
            %% Track nest video
            
            % Set tracking parameters
            brFiltNest = [10 10];
            brThreshNest = 0.1;
            
            %run tracking
            nestTrackingData = trackCCNestVideoP(vid,brFiltNest, brThreshNest, backgroundImages(zz).bIm, backgroundImages(zz).nestOutline, taglist, vid.NumberOfFrames);
            
            %% Track a handful (40) of frames to look for bees not caught by background segmentation
            statBeeNestData = trackCCVideoStationaryBeesP(vid,brFiltNest, brThreshNest, taglist, 40);
            %% Track foraging chamber video
            forFilename = strrep(filename, 'NC', 'FC');
            forVid = VideoReader([curDir '/' forFilename]);
            forBackIm = medianImage(forVid, 30);
            forageTrackingData = trackCCForageVideoP(forVid, brFiltFor, brThreshFor, forBackIm, taglist, forVid.NumberOfFrames);
            
            %% Again, track a handful of foraging chamber frames to look for bees not caught by background segmentation
            
            statBeeForageData = trackCCVideoStationaryBeesP(forVid,brFiltFor, brThreshFor, taglist, 40);
            
            %     %% Interpolate
            %     for j = 1:4
            %         nestTrackingData(:,:,j) = fixShortNanGaps(nestTrackingData(:,:,j),10);
            %         forageTrackingData(:,:,j) = fixShortNanGaps(forageTrackingData(:,:,j),10);
            %     end
            
            %% Save data
            bIm = backgroundImages(zz).bIm;
            nestOutline = backgroundImages(zz).nestOutline;
            save(strrep(vid.Name, '.avi', 'mat'), 'nestTrackingData', 'forageTrackingData', 'statBeeNestData', 'statBeeForageData', 'bIm', 'nestOutline');
            
            
        end
    else
        continue
    end
end