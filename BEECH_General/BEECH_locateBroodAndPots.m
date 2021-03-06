cd(uigetdir(pwd, 'Pick an input directory for hive videos'));
filelist = dir('**/*NC.avi');

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
% end


%% Get median background image of each hive
nvid = 15; %How many videos to sample?
ind = floor(linspace(1,numel(filelist),nvid));

%Load images into memory

for i = 1:nvid
    %%
    filename = [filelist(ind(i)).folder '/' filelist(ind(i)).name];
    try
        mov = VideoReader(filename);
        im = rgb2gray(read(mov,1));
        if i ==1 %If we're on the first rep, create empty matrix for all frames
            allFrames = nan(size(im,1), size(im,2), nvid);
        end
        
        allFrames(:,:,i) = im;
    catch
        continue
    end
end

%% Calculate median image
backImage = median(allFrames,3);
imshow(backImage)
allFrames = cat(3, backImage, allFrames);

%%
imInd = 1;
imc = allFrames(:,:,imInd);
imshow(imadjust(uint8(imc)));
hold on;

term = 0;

while term == 0
    
    %Display any available data
    if exist('brood')
        plotbrood(brood)
    end
    
    [x y button] = ginput(1); %Get one set of points from current interface
    msgbox({"Labels:""1: eggs", "2: larvae", "3: pupae", "4:});
    
    if char(button) == '1' | char(button) == '2' | char(button) == '3' | char(button) == '4' | char(button) == '5' | char(button) == '6' | char(button) == '7'
        if ~exist('brood')
            brood = [x y button];
        else
            brood = [brood; [x y button]];
        end
        plotbrood(brood)
        
        
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
            plotbrood(brood)
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
%%
cd(uigetdir);
filePrefix = inputdlg('output filename prefix:');
filePrefix = filePrefix{1}; %Remove character from cell

name = strcat(filePrefix, '_brood.mat');

%cd(uigetdir(pwd, 'Pick a directory to save to'));
save(name, 'brood', 'backImage', 'filelist');
