[file path] = uigetfile('*.avi', 'pick movie file');
%filelist = dir('**/*NC.avi');
vid = VideoReader([path file]);

thermFile = strrep(file, 'NC.avi', 'TC.mj2');

%Check to see if data already exists
outName = strsplit(file, '.av');
outName = outName{1};
outFile = strcat(path, outName, '_metadata.mat');

if exist(outFile, 'file')
    choice = questdlg('Metadata file already exists - overwrite?', 'Overwrite brood file?', 'Yes', 'No', 'No')
    
    switch choice
        case 'Yes'
            disp('Overwriting file...');
            
        case 'No'
            disp('Exiting...')
            return
    end
end
nframes = vid.NumberOfFrames;
%%
choice = questdlg('Do you want to load existing brood data?', 'Load Brood Data', 'Yes', 'No', 'No')

switch choice
    case 'Yes'
        uiopen('load');
        
    case 'No'
        disp('No brood data loaded')
        if exist('brood', 'var')
            clear brood
        end
end
% %% visualize individual movement
% times = unique([hiveData.time]);
% ids = unique(hiveData.id);
%
% for i = 1:numel(times)
%
% end.


%% Get median background image of each hive
nsamples = 5; %How many video frames to sample?
ind = floor(linspace(1,nframes,nsamples));%Load images into memory

for i = 1:nsamples
    %%
    j = ind(i);
    im = rgb2gray(read(vid,j));
    if i ==1 %If we're on the first rep, create empty matrix for all frames
        allFrames = nan(size(im,1), size(im,2), nsamples);
    end
    
    allFrames(:,:,i) = im;
    
end

%% Calculate median image
backImage = median(allFrames,3);
imshow(uint8(backImage));
allFrames = cat(3, backImage, allFrames);

%%
uiwait(msgbox('locate nest structural elements (brood, pots, etc.)'));
imInd = 1;
imc = allFrames(:,:,imInd);
imshow(imadjust(uint8(imc)));
hold on;

term = 0;
msgbox({'brood labels','1: egg (green)', '2: larvae (red)', '3: pupae (yellow)',...
    '4: empty waxpot (purple)', '5: full honeypot (dark blue)', '6: pollen pot (orange)', ...
    '7: wax covering (light blue)', '8: pollen food source (orange, solid)', '9: nectar food source (dark blue, solid)', '', 'commands:','d: delete nearest point', ...
    'f: move forward 1 frame', 'b: move back 1 frame',...
    '=: zoom in', '-: zoom out', 'c: clear all brood data','q: finish and exit'});
while term == 0
    
    %Display any available data
    if exist('brood')
        plotBrood_Wy(brood)
    end
    
    [x y button] = ginput(1); %Get one set of points from current interface
    %"1" for brood, "2" for honeypots, "3" for wax cover
    
    if char(button) == '1' | char(button) == '2' | char(button) == '3' | char(button) == '4' | char(button) == '5' | char(button) == '6' | char(button) == '7' | char(button) == '8' | char(button) == '9' 
        if ~exist('brood')
            brood = [x y button];
        else
            brood = [brood; [x y button]];
        end
        plotBrood_Wy(brood)
        
        
        %Remove last point
        
        %Zoom in
    elseif char(button) == '='
        range = 800;
        xlim([(x - range) (x + range)]);
        ylim([(y - range) (y+range)]);
        
        %Zoom out
    elseif char(button) == '-'
        xlim([0 3664]);
        ylim([0 2748]);
        
        
        %Delete point nearest click
    elseif char(button) == 'd'
        dm = sqrt((brood(:,1) - x).^2 + (brood(:,2) - y).^2);
        brood(find(dm == min(dm)),:) = [];
        hold off;
        imshow(imadjust(uint8(imc)));
        hold on;
        if ~isempty(brood)
            plotBrood_Wy(brood)
        end
        
        %Loop for clearing all data
    elseif char(button) == 'c'
        choice = questdlg('Do you want to clear all brood data?', 'Clear Brood Data', 'Yes', 'No', 'No')
        
        switch choice
            case 'Yes'
                clear brood;
                hold off;
                imshow(imadjust(uint8(imc)));
                hold on;
            case 'No'
                disp('Brood data retained - continuing loop')
        end
        
    elseif char(button) == 'q' %Terminate while loop
        
        term = 1;
        
    elseif char(button) == 'f'
        
        if imInd < size(allFrames, 3)
            imInd = imInd+1; %Index which image were looking att
            imc = allFrames(:,:,imInd);
            imshow(imadjust(uint8(imc)));
            
        end
        
    elseif char(button) == 'b'
        
        if imInd > 1
            imInd = imInd-1; %Index which image were looking att
            imc = allFrames(:,:,imInd);
            imshow(imadjust(uint8(imc)));
            
        end
    end
end
%% add locations of thermal probes
uiwait(msgbox('locate the two thermal probes'));
close all
%m = magma(200);
thermVid = VideoReader([path thermFile]);

nframes = thermVid.NumberOfFrames;
thermIm = read(thermVid, nframes);
%imagesc(thermIm);
%colormap(m);

[thermPoly1 thermPoly2] = outlineTwoThermalProbes(thermIm);


%% get worker and queen locations/counts

%%Comment in to count queens and workers
%uiwait(msgbox('locate queens and workers'));
%imc = allFrames(:,:,end);
%beeCountRefImage = imadjust(uint8(imc));
%beeCounts = getBeeCounts(beeCountRefImage);

%%
%cd(uigetdir(pwd, 'Pick a directory to save to'));

%save(outFile, 'brood', 'backImage', 'file', 'path', 'thermPoly1', 'thermPoly2', 'beeCounts', 'beeCountRefImage');
save(outFile, 'brood', 'backImage', 'file', 'path', 'thermPoly1', 'thermPoly2');
