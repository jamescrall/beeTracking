%Get user inputs for folder
%[filename pathname] = uigetfile('*.avi', 'select first movie');
%[tagfile tagpathname] = uigetfile('*.csv', 'select taglist file');

masDir = uigetdir(pwd, 'Choose parent directory');
subDirs = dir(masDir);
subDirs = subDirs(3:end); %Ignore first two elements in directory

%%
%Loop over folders to first manually input nest outlines for all colonies
for aa = 1:numel(subDirs)
    curDir = [masDir '\' subDirs(aa).name];
    if isdir(curDir)
        %% Create list of movie pairs
        cd(curDir);
        list = dir('*NC.avi');
        
        %Read in taglist
        taglist = dir('*taglist.csv');
        taglist = csvread(taglist.name);
        %% generate manual inputs of nest outlines
        backgroundImages = struct();
        
        
        for zz = 1:numel(list)
            %%
            vid = VideoReader(list(zz).name);
            bIm = medianImage(vid,20);
            % calculate background for both nest and
            imshow(imadjust(bIm));
            if zz == 1
                title('New nest!: outline nest structure...');
                
                [nestOutline xi yi] = roipoly();
            else
                title('Modifications?');
                
                h = impoly(gca, [xi yi]);
                addNewPositionCallback(h(1),@(p) assignin('base','xy',p));
                wait(h);
                xi = xy(:,1);
                yi = xy(:,2);
                nestOutline = roipoly(bIm, xy(:,1), xy(:,2));
                
            end
            backgroundImages(zz).bIm = bIm;
            backgroundImages(zz).filename = list(zz).name;
            backgroundImages(zz).path = pathname;
            backgroundImages(zz).nestOutline = nestOutline;
            
            clear bIm
            clear nestOutline
        end
        %
        filename = list(1).name;
        save(strrep(filename, 'NC.avi', 'backgroundImages.mat'), 'backgroundImages');
    else
        continue
    end
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