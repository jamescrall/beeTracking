function [brood backImage sampleFrameStack] = BEECH_locateBroodAndPots_output(filelist, brood, filePrefix)
    
    % Inputs:
    %   filelist: list of video files in format output by "dir", specifically a
    %   structure with "folder" and "name" fields for each element, specifying
    %   the
    %
    %   brood
    %
    %   filePrefix - for saving
    %
    %
    % Output:
    %
    %   brood: coordiante and identities of brood
    
    if isempty(brood)
        clear brood
    end
    
    %     %Check if
    %     outfilename = strcat(filePrefix, '_brood.mat');
    %     broodFilelist = dir(['**/*' outfilename]);
    %
    %     if ~isempty(broodFilelist)
    %         load([broodFilelist.folder '/' broodFilelist.name]);
    %         msgbox(['Brood file "' outfilename '" already exists on disk - loading...']);
    %     end
    
    %% Get median background image of each hive
    
    if numel(filelist) >=20
        nvid = 20; %How many videos to sample?
        ind = floor(linspace(5,numel(filelist),nvid)); %Skip the first few videos
    else
        nvid = numel(filelist);
        ind = 1:nvid;
    end
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
    
    sampleFrameStack = allFrames; %Save frame stack to memory for export before appending
    
    %% Calculate median image
    backImage = nanmedian(allFrames,3);
    %imshow(backImage)
    allFrames = cat(3, backImage, allFrames);
    
    %%
    imInd = 1;
    imc = allFrames(:,:,imInd);
    imshow(imadjust(uint8(imc)));
    hold on;
    
    term = 0;
    instrBox = msgbox({"LABELS:","1: eggs", "2: larvae", "3: pupae", "4: empty honey pots", "5: fully honey pots",...
        "6: pollen pots", "7: wax cover", "8: queen cell", "", "CONTROLS:", "= : zoom in", "- : zoom out", ...
        "d: delete point nearest to click", "c: clear all data", ...
        "f: toggle frame forward (first first is average, others are raw frames", "b: toggle back"});
    
    while term == 0
        
        %Display any available data
        if exist('brood')
            if ~isempty(brood)
                plotbrood(brood)
                title(filePrefix);
            end
        end
        
        [x y button] = ginput(1); %Get one set of points from current interface
        
        
        if char(button) == '1' | char(button) == '2' | char(button) == '3' | char(button) == '4' | ...
                char(button) == '5' | char(button) == '6' | char(button) == '7' | char(button) == '8'
            
            if ~exist('brood')
                brood = [x y button];
            else
                brood = [brood; [x y button]];
            end
            plotbrood(brood)
            title(filePrefix);
            
            
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
                title(filePrefix);
                
            end
            
            %Loop for clearing all data
        elseif char(button) == 'c'
            choice = questdlg('Do you want to clear all brood data?', 'Clear Brood Data', 'Yes', 'No', 'No')
            
            switch choice
                case 'Yes'
                    clear brood;
                    brood = [];
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
    
    close(gcf);
    delete(instrBox);
    %
    
    % Save file to disk
    outfilename = strcat(filePrefix, '_brood.mat');
    
    %cd(uigetdir(pwd, 'Pick a directory to save to'));
    save(outfilename, 'brood', 'backImage', 'sampleFrameStack','filelist');
