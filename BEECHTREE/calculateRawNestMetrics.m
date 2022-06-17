function [nestTracks nestBehMetrics outputMetrics] = calculateRawNestMetrics(nestTracks, broodPos, wpPos, bodyLength)
%
%
%Inputs:
%
% nestTracks
%
%   An n x m x 7 matrix, where n = # of frames for a single trial, m = num bees
%
%   Sheets 1-2 are x and y coordinates of tag centroid
%   Sheets 3-4 are x and y coordinates of tag front
%   Sheets 5-6 are transformed bee coordinates (tag centroid) into the
%       thermal camera
%   Sheet 7 contains bee thoracic temperature data
%
% broodPos: N x 2 matrix, x-y coordinates of brood
%
% wpPos: N x 2 materix, x-y coordinates of waxpots
%
% bodyLength: length of average body size, to estimate occupancy and
% interactions
%
% Outputs:
%   n x m x Z matrix, where n = # of frame,s m = num bees, and Z is the
%   number of estimated metrics (detailed below)
%
%   speed
%   abs rotational vel
%
%   distance to nearest brood
%   orientation to nearest brood

%   distance to nearest full pot
%   angle to nearest full pot
%% Heal missing data
for i = 1:size(nestTracks,3)
    %for i = 1:6
    nestTracks(:,:,i) = fixShortNanGaps(nestTracks(:,:,i), 5);
end

%%
vis = 0; %Visualize example data?
if vis == 1
    for i = 1:size(nestTracks,1)
        %%
        plot(1,1)
        hold on
        
        BEECH_plotBrood(brood, 200, 0.5);
        plot(nestTracks(i,:,1), nestTracks(i,:,2), 'bo');
        
        xlim([400 3800]);
        ylim([200 3000]);
        for j = 1:size(nestTracks,2)
            plot(squeeze(nestTracks(i,j,[1 3])), squeeze(nestTracks(i,j,[2 4])), 'r-', 'LineWidth', 5);
        end
        drawnow
        hold off
        
    end
end



%% Hard coded foraging exit location
% foragingExitLocation = [3500 1475];

% %% Distance to physical nest structure

% broodPos = brood(char(brood(:,3)) == '1', 1:2);
% wpPos = brood(char(brood(:,3)) == '2', 1:2);
%% distance To nest structures
if ~isempty(broodPos)
    broodAn = 1;
else
    broodAn = 0;
end

if ~isempty(wpPos)
    wpAn = 1;
else
    wpAn = 0;
end

vis = 0;
%Create empty vectors for output metrics
minBroodDists = nan(size(nestTracks(:,:,1)));
minBroodDistAngles = minBroodDists;
minWpDists = minBroodDists;
minWpDistAngles = minBroodDists;

%h = waitbar(0, 'calculating metrics across frames');

for i = 1:size(nestTracks,1)
    %%
    if broodAn
        broodDists = pdist2(permute(nestTracks(i,:,1:2), [2 3 1]), broodPos(:,1:2));
    end
    
    if wpAn
        wpDists = pdist2(permute(nestTracks(i,:,1:2), [2 3 1]), wpPos(:,1:2));
        
    end
    
%    waitbar(i/size(nestTracks,1), h);
    
    for j = 1:size(nestTracks,2)
        %%
        if ~isnan(nestTracks(i,j,1)) %Does data exist for this individual on this frame?
            if broodAn
                minBroodDist = nanmin(broodDists(j,:)); %minimum distance to a brood object
                minBroodDistInd = find(broodDists(j,:) == minBroodDist); %Index for this brood
                v1 = [diff(nestTracks(i,j,[1 3])), diff(nestTracks(i,j,[2 4]))]; %orientation vector
                v2 = [diff([nestTracks(i,j,1) broodPos(minBroodDistInd,1)]), diff([nestTracks(i,j,2) broodPos(minBroodDistInd,2)])]; %Vector to nearest brood
                minBroodDistAngle = atan2(abs(det([v1;v2])),dot(v1,v2)); %Angle between these vectors
                %Write to memory
                minBroodDists(i,j) = minBroodDist;
                minBroodDistAngles(i,j) = minBroodDistAngle;
            end
            
            if wpAn
                minWpDist = nanmin(wpDists(j,:));
                minWpDistInd = find(wpDists(j,:) == minWpDist);
                v1 = [diff(nestTracks(i,j,[1 3])), diff(nestTracks(i,j,[2 4]))]; %orientation vector
                v2 = [diff([nestTracks(i,j,1) wpPos(minWpDistInd,1)]), diff([nestTracks(i,j,2) wpPos(minWpDistInd,2)])]; %Vector to nearest brood
                minWpDistAngle = atan2(abs(det([v1;v2])),dot(v1,v2)); %Angle between these vectors
                %Write to memory
                minWpDists(i,j) = minWpDist;
                minWpDistAngles(i,j) = minWpDistAngle;
            end
            
            
            
            
            if vis == 1 %Visualize check that closet nest elements are being correctly identified. Currently set not to show
                %%
                plot(nestTracks(i,:,1), nestTracks(i,:,2), 'ko');
                hold on
                BEECH_plotBrood(brood, 200, 0.5);
                plot(nestTracks(i,j,1), nestTracks(i,j,2), 'ro');
                plot(broodPos(minBroodDistInd,1), broodPos(minBroodDistInd,2), 'go');
                plot(wpPos(minWpDistInd,1), wpPos(minWpDistInd,2), 'mo')
                
                hold off
                axis equal
                drawnow
                pause(1);
            end
        end
        
    end
end

%close(h);

%% Social distance

distMat = calculatePairwiseDistanceMatrix(nestTracks(:,:,1:2));
distMat(distMat == 0) = NaN;
meanDistanceToOtherBees = permute(nanmedian(distMat,2), [3,1,2]);
minDistanceToOtherBees = permute(nanmin(distMat, [], 2), [3,1,2]);


%% distance metrics
%nestCenter = [nanmean(nanmean(nestTracks(:,:,1))) nanmean(nanmean(nestTracks(:,:,2)))];
brood = [broodPos ; wpPos];
nestCenter = mean(brood(:,1:2),1, 'omitnan');
distToNestCenter = sqrt((nestTracks(:,:,1) - nestCenter(1)).^2 + (nestTracks(:,:,2) - nestCenter(2)).^2); %Calculate distance to nest center

%distToForagingExit = sqrt((nestTracks(:,:,1) - foragingExitLocation(1)).^2 + (nestTracks(:,:,2) - foragingExitLocation(2)).^2); %Calculate distance to nest center

%distToQueen = sqrt((bsxfun(@minus, nestTracks(:,:,1), nestTracks(:,1,1))).^2 + (bsxfun(@minus, nestTracks(:,:,2), nestTracks(:,1,2))).^2); %Calculate distance to nest center
%Removing dist to queen, becuase you have no idea when the queen's not
%there

%% Dynamic metrics
speed = sqrt(diff(nestTracks(:,:,1)).^2 + diff(nestTracks(:,:,2)).^2); %Calculate speed
speed = [speed ; nan(size(speed,2),1)']; %pad last row with nans
speed = log10(speed); %log transformat

LPspeed = nan(size(speed)); %lowpass speed
for zz = 1:size(LPspeed,2)
    LPspeed(:,zz) = movmean(speed(:,zz), 20);
end
%LPspeed = log10(LPspeed); %log transformat

MPspeed = nan(size(speed)); %med-pass speed
for zz = 1:size(MPspeed,2)
    MPspeed(:,zz) = movmean(speed(:,zz), 4);
end
%MPspeed = log10(MPspeed); %log transformat

xor = diff(nestTracks(:,:,[1 3]), 1,3);
yor = diff(nestTracks(:,:,[2 4]), 1,3); %orientation vector

%orVec = cat(3, xor, yor);
orVec = atan2(yor,xor);
angSpeed = diff(orVec);

%Correct discontinuities
ind = angSpeed < -pi;
angSpeed(ind) = angSpeed(ind) + 2*pi;
ind = angSpeed > pi;
angSpeed(ind) = angSpeed(ind) - 2*pi;

%Make absolute
angSpeed = log10(abs(angSpeed));
%hist(reshape(abs(angSpeed), numel(angSpeed), 1), 200);

%Pad with nans
angSpeed = [angSpeed; nan(size(angSpeed,2), 1)'];

%brood approach speed
broodApproachSpeed = diff(minBroodDists);
broodApproachSpeed = [broodApproachSpeed; nan(size(broodApproachSpeed,2), 1)'];

%Waxpot approach speed
waxpotApproachSpeed = diff(minWpDists);
waxpotApproachSpeed = [waxpotApproachSpeed; nan(size(waxpotApproachSpeed,2), 1)'];

%%% Got rig of logs on speed throughout this section, didn't know why there
%%% were there and were making complex number outputs

%% output
outputMetrics = {'distanceToNearestBrood', 'angleToNearestBrood', 'distanceToNearestWaxpot', ...
    'angleToNearestWaxpot', 'distanceFromNestCenter', 'speed', ...
    'angularSpeed',  'meanDistToNestmates', 'minDistToNestmate', 'broodApproachSpeed', ...
    'wpApproachSpeed', 'LPSpeed','MPspeed'};

nestBehMetrics = cat(3,minBroodDists, minBroodDistAngles, minWpDists, minWpDistAngles, distToNestCenter, ...
    speed, angSpeed, meanDistanceToOtherBees, minDistanceToOtherBees, ...
    broodApproachSpeed, waxpotApproachSpeed, LPspeed, MPspeed);

%To add:
%Thoracic temp
%Distance to queen?
%Deviation of speed/angular speed?

