function [] = generateBackgroundImagesForSubfolders(subDirs, masDir)
%Inputs:
%subDirs - list of subdirectories to cycle over
%masDir - parent directory

%%
for aa = 1:numel(subDirs)
    
    curDir = [masDir '\' subDirs(aa).name];
    
    if isdir(curDir)
        %% Create list of movie pairs
        cd(curDir);
        list = dir('*NC.avi');
        outfile = strrep(list(1).name, 'NC.avi','backgroundImages.mat');
        if exist(outfile) == 2
            load(strcat(pwd, '\', outfile))
            figure(1);
            backIm =backgroundImages.backIm;
            imshow(backIm);
            hold on;
            h = imshow(cat(3,ones(size(backIm)), zeros(size(backIm)), zeros(size(backIm))));
            set(h, 'AlphaData', backgroundImages.nestOutline.*0.5);
            opt = questdlg(strcat({'Background images for "'}, curDir, {'" already exists - overwrite?'}), 'Yes', 'No');
            
            switch opt
                case 'Yes'
                    disp('Overwriting file...');
                case 'No'
                    disp(strcat({'File already exists, skipping file '}, outfile));
                    continue
                    %                    load(outfile);
            end
        end
        
        backIm = backImFromFilelist(list,3,1,12); %Calculate background images across these videos and plot diagnostic results
        pause(1);
        %% generate manual inputs of nest outlines
        backgroundImages = struct();
        
        figure(1);
        
        imshow(backIm);
        
        if ~exist('xi')
            
            title('New nest!: outline nest structure...');
            
            [nestOutline xi yi] = roipoly();
            
        else
            title('Modifications?');
            
            h = impoly(gca, [xi yi]);
            addNewPositionCallback(h(1),@(p) assignin('base','xy',p));
            wait(h);
            xy = evalin('base','xy');
            xi = xy(:,1);
            yi = xy(:,2);
            nestOutline = roipoly(backIm, xy(:,1), xy(:,2));
            
        end
        backgroundImages.backIm = backIm;
        backgroundImages.filename = list(1).name;
        backgroundImages.path = curDir;
        backgroundImages.nestOutline = nestOutline;
        close all
        
    else
        disp(strcat('Directory "', curDir, {'" not found'}));
        continue
    end
    %
    filename = list(1).name;
    save(outfile, 'backgroundImages');
    clear backIm
    clear nestOutline
    
end