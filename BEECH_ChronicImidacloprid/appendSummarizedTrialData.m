function masterData = appendSummarizedTrialData(masterData)
    %Set up waitbar
    h = waitbar(0, 'looping across colonies and appending data');
    
    %Manually set mm/pixel conversion conversions
    nConv = 0.0897;
    fConv = 0.1034;
    
    %% Set variable names
    varNames = {'porTimeMoving', 'medMovingSpeed','framesTracked', 'porTimeInactive', 'porTimeNursing', 'porTimePatrolling', 'porTimeForaging', 'porTimeExploring', 'distanceFromSocialCenter', 'porTimeInactiveForaging'};
    
    %Load in preset ROIs for foraging chamber
    load('/Users/james/Dropbox/Work/Neonicotinoids/ChronicExposure/Data/TrackingData/foragingROIs.mat');
    
    %%
    for i = 1:numel(masterData) %Loop across colonies
        %%
        % i = colony index
        % j = day index
        % k = trial index
        colDat = masterData(i).colonyData;
        taglist = colDat(1).trackingData(1).taglist;
        nbees = numel(taglist);
        
        for j = 1:numel(colDat) %loop across days
            
            
            for k = 1:numel(colDat(j).trackingData)
                %%
                %nest data
                data = masterData(i).colonyData(j).trackingData(k);
                
                %Extract movement index
                nestMovingIndex = data.nestMovingIndex;
                forageMovingIndex = data.forageMovingIndex;
                
                %extract moving speeds for nest data
                speedsN = data.nestSpeeds; %Extract speed vals
                speedsN(nestMovingIndex == 0) = NaN; %Remove values when bees aren't moving
                
                %Repeat for foraging chamber
                speedsF = data.forageSpeeds;
                speedsF(forageMovingIndex == 0) = NaN;
                
                %Bring in nest coordinates
                nestCoords = data.nestCoordinates;
                trackedNest = ~isnan(nestCoords(:,:,1));
                
                %Foraging data
                forDat = data.forageCoordinates;
                trackedForaging = ~isnan(forDat(:,:,1));
                
                onNectar = inpolygon(forDat(:,:,1), forDat(:,:,2), nectarX, nectarY);
                onPollen = inpolygon(forDat(:,:,1), forDat(:,:,2), pollenX, pollenY);
                
                %% Recalculate this
                %Erosion
                nestOutline = colDat(j).nestOutline;
                dilationFactor = 5; %How much to dilate nest outline to catch close tags? in mm
                dilationFactor = round(dilationFactor/nConv);
                se = strel('disk', dilationFactor);
                nestOutlineDil = imdilate(nestOutline, se);
                onNest = maskCoordinatesIndex(nestCoords(:,:,1:2), nestOutlineDil);
                
                
                %                 figure(2);
                %  x = nestCoords(:,:,1);
                %y = nestCoords(:,:,2);
                %                 imshow(colDat(j).nestBackIm);
                %                 hold on
                %                 plot(x(onNestIndex == 1), y(onNestIndex == 1), 'ro');
                %                 plot(x(onNestIndex == 0), y(onNestIndex == 0), 'go');
                %                 hold off
                
                %% Social interactions
                nframes = size(onNectar,1);
                %generate empty matrix of pairwise interactions
                distMat = nan(nbees, nbees, nframes);
                for zz = 1:nframes
                    %%
                    x = nestCoords(zz,:,1);
                    y = nestCoords(zz,:,2);
                    distMat(:,:,zz) = squareform(pdist([x' y']));
                end
                %Set distance at 10 mm, convert to pixels
                distThresh = 15/nConv; %
                intMat = distMat;
                intMat(distMat < distThresh) = 1;
                intMat(distMat >= distThresh) = 0;
                
                %Generate average matrics
                intMatAv = nanmean(intMat, 3);
                distMatAv = nanmean(distMat, 3);
                cooccurrenceFrames = sum(~isnan(distMat),3); %How many frames did bee pairs co-occur in?
                %% Distance from nest center
                %Calculate "social center"
                xm = nanmean(nanmean(nestCoords(:,:,1)));
                ym = nanmean(nanmean(nestCoords(:,:,2)));
                
                xd = nestCoords(:,:,1) - xm;
                yd = nestCoords(:,:,2) - ym;
                totd = sqrt(xd.^2 + yd.^2);
                
                distanceFromCenter = nanmean(totd);
                %%
                %Generate behavior state list
                behState = zeros(size(nestMovingIndex));
                
                %Create individual indices for different behaviors
                nursingIndex = onNest(1:(end-1),:) == 1; %Index for nursing
                patrollingIndex = onNest(1:(end-1),:) == 0 & trackedNest(1:(end-1),:) == 1 & nestMovingIndex == 1; %Index for patrolling
                nectarForagingIndex = onNectar(1:(end-1),:);
                pollenForagingIndex = onPollen(1:(end-1),:);
                exploringIndex = trackedForaging(1:(end-1),:) == 1 & ~nectarForagingIndex & ~pollenForagingIndex & forageMovingIndex == 1;
                inactiveForagingIndex = trackedForaging(1:(end-1),:) == 1 & ~nectarForagingIndex & ~pollenForagingIndex & forageMovingIndex == 0;
                inactiveNestIndex = nestMovingIndex == 0 & trackedNest(1:(end-1),:) == 1 & onNest(1:(end-1),:) == 0;
                
                
                
                
                %Check for any co-classified points
                conflictIndex = find(nursingIndex + patrollingIndex + nectarForagingIndex + pollenForagingIndex + exploringIndex + inactiveForagingIndex + inactiveNestIndex > 1);
                
                %Write to single matrix
                behState(nursingIndex) = 1;
                behState(patrollingIndex) = 2;
                behState(nectarForagingIndex) = 3;
                behState(pollenForagingIndex) = 4;
                behState(exploringIndex) = 5;
                behState(inactiveForagingIndex) = 6;
                behState(inactiveNestIndex) = 7;
                
                if ~isempty(conflictIndex)
                    behState(conflictIndex) = 0; %Remove any conflicting data
                    disp(strcat({'removing '}, num2str(numel(conflictIndex)), {' conflicting behavioral state frames'}));
                end
                
                
                %Calculated total frames where bee could be tracked
                trackableFrames = sum(behState > 0);
                
                %% Write to summary data
                tmp = nan(1,nbees, numel(varNames));
                tmp(:,:,1) = nanmean(nestMovingIndex); %Calculate portion of time moving
                tmp(:,:,2) = nanmedian(speedsN); %median speeds when moving
                tmp(:,:,3) = sum(trackedNest) + sum(trackedForaging); %total number of tracked frames
                tmp(:,:,4) = sum(inactiveNestIndex + inactiveForagingIndex)./trackableFrames; %portion of time inactive total
                tmp(:,:,5) = sum(nursingIndex)./trackableFrames; %portion of time nursing
                tmp(:,:,6) = sum(patrollingIndex)./trackableFrames;
                tmp(:,:,7) = sum(nectarForagingIndex + pollenForagingIndex)./trackableFrames;
                tmp(:,:,8) = sum(exploringIndex)./trackableFrames;
                tmp(:,:,9) = distanceFromCenter;
                tmp(:,:,10) = sum(inactiveForagingIndex)./trackableFrames; %portion of time inactive total
                
                if ~exist('sumDat') %If "sumDat" doesn't exist or has been cleared, make it
                    sumDat = tmp;
                    trialTimes = data.trialTime;
                else
                    sumDat = cat(1, sumDat, tmp);
                    trialTimes = [trialTimes data.trialTime];
                end
                
                %Write trial-level data back to masterData
                %behavioral state data
                masterData(i).colonyData(j).trackingData(k).behavioralState = behState;
                masterData(i).colonyData(j).trackingData(k).intMatAv = intMatAv; %interaction matrix (rate)
                masterData(i).colonyData(j).trackingData(k).distMatAv = distMatAv; %distance matrix
                masterData(i).colonyData(j).trackingData(k).coccurrenceFrames = cooccurrenceFrames; %Number of frames for cooccurrence
                
            end
            
            %Write day-level data back to masterData
            masterData(i).colonyData(j).nestOutlineDil = nestOutlineDil;
            
        end
        
        
        %% Write summary data back into masterData object
        masterData(i).summaryData = sumDat;
        masterData(i).summaryDataVariableNames = varNames;
        masterData(i).summaryDataTrialTimes = trialTimes;
        
        clear sumDat
        clear trialTimes
        
        waitbar(i/numel(masterData));
    end
    close(h);