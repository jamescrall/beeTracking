%Get user inputs for folder
%[filename pathname] = uigetfile('*.avi', 'select first movie');
%[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');


parDir = uigetdir(pwd, 'Choose parent directory');
cd(parDir)
dirList = dir('*colPos*');
close all
for i = 1:numel(dirList)
    %for i = 1:2
    %%
    masDir = [parDir '\' dirList(i).name];
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
        threshVals = [0.005 0.01 0.05 0.08 0.1 0.12 0.15 0.2 0.3 0.5 1 1.5 2 3 4 5 6 7];
        filtVals = [4 6 8 10 12 14 16];
        %parpool(4);
        %threshVals = [0.5 1 2 4];
        %filtVals = [10 15 20];
        nframes = 20;
        [forvidfilename forvidpathname] = uigetfile({'*avi', 'Choose foraging movie to optimize'});
        forvid = VideoReader([forvidpathname forvidfilename]);
        
        [nestvidfilename nestvidpathname nestPerfData] = uigetfile({'*avi', 'Choose foraging movie to optimize'});
        nestvid = VideoReader([nestvidpathname nestvidfilename]);
        
        [tagfilename tagpathname] = uigetfile({'*csv', 'Choose tag data file'});
        %taglist = readtable([tagpathname tagfilename], 'readVariableNames', 0);
        taglist = csvread([tagpathname tagfilename],1,0);
        taglist = taglist(:,1);
        
        
        choice2 = questdlg('optimize for threshold and filter size?', 'Yes', 'No');
        
        switch choice2
            case 'Yes'
                %Run optimization outine
                figure(1)
                [brThreshFor brFiltFor forTimePerFrame] = optimizeTrackingParameters(forvid,threshVals,filtVals,nframes,taglist)
                disp(strcat({'forage optima: th - '}, num2str(brThreshFor), {', filt - '}, num2str(brFiltFor), {', time - '}, num2str(forTimePerFrame)));
                %Set threshold ranges
                saveas(1,strcat(parDir,'\', datestr(now, 'dd-mm-yyyy'),'forageOptimization.png'))
                figure(2)
                [brThreshNest brFiltNest nestTimePerFrame] = optimizeTrackingParameters(nestvid,threshVals,filtVals,nframes,taglist);
                disp(strcat({'nest optima: th - '}, num2str(brThreshNest), {', filt - '}, num2str(brFiltNest), {', time - '}, num2str(forTimePerFrame)));
                saveas(2,strcat(parDir,'\', datestr(now, 'dd-mm-yyyy'),'nestOptimization.png'))
            case 'No'
                disp('Hard coding tracking parameters and skipping...');
                brFiltNest = 10;
                brThreshNest = 4;
                brFiltFor = 8;
                brThreshFor = 3;
                
        end
        
        choice3 = questdlg('Optimizing background thresholding values?')
        
        switch choice3
            case 'Yes'
                disp('Oops! Option not implemented yet - hardcoding and moving on...');
                nestBackThresh = 15;
                forBackThresh = 8;
            case 'No'
                disp('Hard coding tracking background threshold and skipping...');
                nestBackThresh = 15;
                forBackThresh = 8;
        end
        
    case 'No'
        brFiltNest = 10;
        brThreshNest = 4;
        brFiltFor = 8;
        brThreshFor = 3;
        nestBackThresh = 15;
        forBackThresh = 8;
end




%% Track!
%Gear up parallel pool
parpool(4);
%%
if numel(brFiltNest) == 1
    brFiltNest = [brFiltNest brFiltNest];
    brFiltFor = [brFiltFor brFiltFor];
end

for bb = 1:numel(dirList) %Loop across colony positions
    %% Data from colony position-level directory
    masDir = [parDir '\' dirList(bb).name];
    
    %Read in taglist data
    cd(masDir)
    taglist = dir('*taglist.csv');
    taglist = csvread(taglist.name,1,0);
    queenInd = taglist(:,2);
    callowInd = taglist(:,3);
    taglist = taglist(:,1);
    
    %Generate list of subdirectories (i.e. days)
    subDirs = dir(masDir);
    subDirs = subDirs(3:end); %Ignore first two elements in directory
    
    %% Loop across days
    for aa = 1:numel(subDirs)
        curDir = [masDir '\' subDirs(aa).name];
        if isdir(curDir)
            %% Create list of movie pairs
            cd(curDir);
            list = dir('*NC.avi');
            
            %Load in background images file
            filename = dir('*backgroundImages*');
            backgroundImages = load(filename.name);
            backgroundImages = backgroundImages.backgroundImages;
            backIm = backgroundImages.backIm;
            nestOutline = backgroundImages.nestOutline;
            
            %Calculate foraging background video
            forlist = dir('*FC.avi');
            forBackIm = backImFromFilelist(forlist, 5, 1,10);
            
            %Loop across videos within the day's folder
            for zz = 1:numel(list)
                %zz
                filename = list(zz).name
                
                %Create VideoReader object
                vid = VideoReader([curDir '/' filename]);
                
                nframes = vid.NumberOfFrames;
                outfile = strrep(vid.Name, '.avi', 'mat');
                filecheck = strcat(outfile, '.mat');
                if exist(filecheck) ~= 2 %If the output data doesn't exist already, proceed to tracking - otherwise skip
                    %% Track nest video
                    % Set tracking parameters
                    %brFiltNest = [10 10];
                    %brThreshNest = 0.1;
                    
                    %run tracking
                    nestTrackingData = trackCCNestVideoP(vid,brFiltNest, brThreshNest, backgroundImages.backIm, backgroundImages.nestOutline, taglist, vid.NumberOfFrames, nestBackThresh);
                    
                    %% Track a handful (40) of frames to look for bees not caught by background segmentation
                    statBeeNestData = trackCCVideoStationaryBeesP(vid,brFiltNest, brThreshNest, taglist, 30);
                    
                    %% Track foraging chamber video
                    forFilename = strrep(filename, 'NC', 'FC');
                    forVid = VideoReader([curDir '/' forFilename]);
                    %forBackIm = medianImage(forVid, 30);
                    forageTrackingData = trackCCForageVideoP(forVid, brFiltFor, brThreshFor, forBackIm, taglist, forVid.NumberOfFrames, forBackThresh);
                    
                    %% Again, track a handful of foraging chamber frames to look for bees not caught by background segmentation
                    statBeeForageData = trackCCVideoStationaryBeesP(forVid,brFiltFor, brThreshFor, taglist, 30);
                    
                    %% Save data
                    save(outfile, 'nestTrackingData', 'forageTrackingData', 'statBeeNestData', 'statBeeForageData', 'backIm','forBackIm', 'nestOutline', 'taglist', 'callowInd','queenInd');
                    
                    %% Diagnostic plot
                    diagnosticTrackingPlot(nestTrackingData, statBeeNestData, forageTrackingData, statBeeForageData, backIm, forBackIm, {outfile})
                    
                else
                    
                    disp(strcat('"',outfile, {'" already exists, skipping...'}));
                    continue
                    
                end
                
            end
            
        else
            continue
        end
    end
end