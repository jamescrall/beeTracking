function trackingData = trackCCForageVideoP(forVid, brFilt, brThresh, bIm, taglist)
    nframes = forVid.NumberOfFrames;
    
    %Need to add sections for tag-agnostic tracking of bee blobs on nectar and
    %pollen feeder
    hbar = parfor_progressbar(nframes,'Tracking tags from foraging video...')
    tic
    tags = taglist(:,1);
    ntags = numel(tags);
    xcent = nan(nframes, numel(tags));
    ycent = nan(nframes, numel(tags));
    frontx = nan(nframes, numel(tags));
    fronty = nan(nframes, numel(tags));
    %%
    parfor i = 1:100
        %%
        try
            
            thr = 5;
            im = rgb2gray(read(forVid,i));
            imd = abs(int8(bIm) - int8(im));
            imd = imd > thr;
            
            %Segment into individual bees
            se = strel('disk',3);
            ime = imerode(imd,se);
            
            %More permissive dilation to capture tags
            se = strel('disk',20);
            
            impd = imdilate(ime,se); %im permissive dilation
            
            imf = im.*uint8(impd);
            F = locateCodes(imf,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', brFilt, 'bradleyThreshold', brThresh, 'vis', 0);
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
        
        %         %% Add this in later
        %         se = strel('disk', 12);
        %         ims = imdilate(imd,se);
        %         occMap = regionprops(ims);
        %
        %         sizeTh = 12000;
        %         occMap = occMap([occMap.Area] > sizeTh);
        %         occupiedNestPixels(i) = sum(sum(ims(nestOutline))); %nestPixelsOccupied
        %         occupiedNonNestPixels = sum(sum(ims(~nestOutline))); %nonNestPixelsOccupied
        %         nBeeChunks(i) = numel(occMap);
        
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