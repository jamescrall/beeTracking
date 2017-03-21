function out = trackCCVideoStationaryBeesP(vid,brFilt, brThresh, taglist, nframes)

% Set up dummy variables
%nframes = vid.NumberOfFrames;

%%
totframes = vid.NumberOfFrames; %How many total frames in the video?

sampFrameIndex = floor(linspace(1, totframes, nframes)); %Generate list of frames to sample for stationary bees
sampFrames = uint8(zeros(vid.Height, vid.Width, nframes));

%Read sample frames into memory
disp(['loading frames into memory...']);
for i = 1:nframes
    
    z = sampFrameIndex(i);
    im = rgb2gray(read(vid,z));
    sampFrames(:,:,i) = im;
end
%disp(['done loading frames into memory, proceeding to tracking']);
%%
disp('tracking stationary tag data');

%Set up dummy variables
tags = taglist(:,1);
ntags = numel(tags);
xcent = nan(nframes, ntags);
ycent = nan(nframes, ntags);
frontx = nan(nframes, ntags);
fronty = nan(nframes, ntags);


hbar = parfor_progressbar(nframes,'Tracking full frames for stationary bees...')
tic
%%
parfor i = 1:nframes
    %%
    try
        
        F = locateCodes(sampFrames(:,:,i),'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', brFilt, 'bradleyThreshold', brThresh, 'vis', 1);
        if ~isempty(F)
            rtags = [F.number];
            for j = 1:ntags
                
                rt = F(rtags == tags(j));
                
                if numel(rt) == 1
                    xcent(i,j) = rt.Centroid(1);
                    ycent(i,j) = rt.Centroid(2);
                    frontx(i,j) = rt.frontX;
                    fronty(i,j) = rt.frontY;
                end
            end
        end
    catch
        disp(strcat('Error in frame ', num2str(i), ', skipping...'));
    end
    
    %         %%
    %         se = strel('disk', 12);
    %         ims = imdilate(imd,se);
    %         occMap = regionprops(ims);
    %
    %         sizeTh = 12000;
    %         occMap = occMap([occMap.Area] > sizeTh);
    %         occupiedNestPixels(i) = sum(sum(ims(nestOutline))); %nestPixelsOccupied
    %         occupiedNonNestPixels = sum(sum(ims(~nestOutline))); %nonNestPixelsOccupied
    %         nBeeChunks(i) = numel(occMap);
    %
    %         %Report progress
    hbar.iterate(1);
end

toc
trackingData = nan(nframes, ntags, 4);
trackingData(:,:,1) = xcent;
trackingData(:,:,2) = ycent;
trackingData(:,:,3) = frontx;
trackingData(:,:,4) = fronty;
out = struct();
out.trackingData = trackingData;
out.sampleFrames = sampFrames;
out.sampleFramesIndex = sampFrameIndex;
close(hbar);