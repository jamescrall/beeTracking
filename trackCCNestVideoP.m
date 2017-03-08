function trackingData = trackCCNestVideoP(vid, brFilt, brThresh, bIm, nestOutline, taglist, nframes)
    
    % Set up dummy variables
    %nframes = vid.NumberOfFrames;
    
    tags = taglist(:,1);
    xcent = nan(nframes, numel(tags));
    ycent = nan(nframes, numel(tags));
    frontx = nan(nframes, numel(tags));
    fronty = nan(nframes, numel(tags));
    occupiedNestPixels = nan(nframes);
    occupiedNonNestPixels = nan(nframes);
    nBeeChunks = nan(nframes);
    ntags = numel(tags);
    
    
    hbar = parfor_progressbar(nframes,'Tracking tags for nest video...')
    tic
    %%
    parfor i = 1:nframes
        %%
        try
            thr = 10;
            im = rgb2gray(read(vid,i));
            imd = abs(int8(bIm) - int8(im));
            imd = imd > thr;
            
            %Segment into individual bees
            se = strel('disk',6);
            ime = imerode(imd,se);
            
            %More permissive dilation to capture tags
            se = strel('disk',30);
            
            impd = imdilate(imd,se); %im permissive dilation
            
            imf = im.*uint8(impd);
            F = locateCodes(imf,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', brFilt, 'bradleyThreshold', brThresh, 'vis', 0);
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
        catch
            disp(strcat('Error in frame ', num2str(i), ', skipping...'));
        end
        
        %%
        se = strel('disk', 12);
        ims = imdilate(imd,se);
        occMap = regionprops(ims);
        
        sizeTh = 12000;
        occMap = occMap([occMap.Area] > sizeTh);
        occupiedNestPixels(i) = sum(sum(ims(nestOutline))); %nestPixelsOccupied
        occupiedNonNestPixels = sum(sum(ims(~nestOutline))); %nonNestPixelsOccupied
        nBeeChunks(i) = numel(occMap);
        
        %Report progress
        hbar.iterate(1);
    end
    
    toc
    trackingData = nan(nframes, ntags, 4);
    trackingData(:,:,1) = xcent;
    trackingData(:,:,2) = ycent;
    trackingData(:,:,3) = frontx;
    trackingData(:,:,4) = fronty;
    close(hbar);