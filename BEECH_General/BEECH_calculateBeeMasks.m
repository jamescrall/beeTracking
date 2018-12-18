function masterData = BEECH_calculateBeeMasks(masterData)
    % Input
    %   masterData - standard format for processBEECHTREEcolonyFolder
    %
    %
    % Output
    %   masterData - wtih appended metadata files for bee masks
    
    %%
    for i = 1:numel(masterData) %loop across colonies
        
        trackingData = masterData(i).trackingData
        dailyBackgrounds = masterData(i).dailyBackgrounds;
        %%
        for j = 1:numel(trackingData)
            %%
            vid = VideoReader([trackingData(j).folder '/' trackingData(j).name]);
            nframes = vid.NumberOfFrames;
            
            backInd = find([dailyBackgrounds.day] == trackingData(j).day);
            backImage = uint8(dailyBackgrounds(backInd).backImage);;
            
            for zz = 1:nframes
                
                %%
                
                im = rgb2gray(read(vid,zz));
                sgm = 2;
                
                imGF = imgaussfilt(im, sgm);
                backImGF= imgaussfilt(backImage,sgm);
                % subplot(2,1,1);
                %imshow(imGF)
                
                %subplot(2,1,2);
                %imshow(backImGF);
                %
                imd = double(imGF) - double(backImGF);
                
                imagesc(imd);
                %
                imshow(imadjust(im));
                %
                alphamask(imd < -5, [1 0 0], 0.5);
            end
            
        end
        
        masterData(i).trackingData = trackingData; %Write tracking data back into masterData object
    end