function [behMetrics broodLocs wpLocs] = calculateNestBehavioralMetrics(taglist, trackingData, brood, bodyLength)


%% Inputs
%
%
%
%
% bodyLength - estimate of bodyLength (~1 cm) in pixels



%%
metrics =  {'distanceToCenterStatic', ...
    'distanceToCenterInstantaneous', ...
    'porTimeMoving',...
    'movingVelocity',...
    'medianDistancetoClosestBrood', ...
    'medianDistanceToClosestWaxpot', ...
    'medianDistanceToAllBrood', ...
    'medianDistanceToAllWaxpots', ...
    'nestRangeArea50', ...
    'nestRangeArea90', ...
    'nestOccupancyDispersionIndex', ...
    'eigenvectorCentrality', ...
    'degreeCentrality', ...
    %'meanInteractionRate_perBee',...
    'meanInteractionRate',...
    'spatCorAll', ...
    'broodInfoRichness', ...
    'waxpotInfoRichness'...
    'framesTracked',...
    'meanDistanceToOtherBees',...
    'minDistanceToOtherBees', ...
    'broodOccupancyRate', ...
    'waxpotOccupancyRate',...
    'Paa', 'Pai', 'Pia', 'Pii', ...
    'porTimeOnBrood'};
behMetrics = array2table(nan(numel(taglist), numel(metrics)));
behMetrics.Properties.VariableNames = metrics;


%bodyLength = 140; %Conservation body length estimation for

%%
brId = char(brood(:,3));
broodLocs = brood(brId == '1' | brId == '2' | brId == '3',:);
wpLocs = brood(brId == '4' | brId == '5',:);

%% Pre-processing
[trackingData nestMetrics varNames] = calculateRawNestMetrics(trackingData, broodLocs, wpLocs);

speedMatrix = nestMetrics(:,:,6);

speedCutoff = 0.3;
activityMatrix = nan(size(speedMatrix,1), size(speedMatrix,2));
activityMatrix(speedMatrix > speedCutoff) = 1;
activityMatrix(speedMatrix <= speedCutoff) = 0;

%% Calculate markovian transition rates
actMatPre = activityMatrix(1:(end-1),:);
actMatPost = activityMatrix(2:end,:);

diff = abs(actMatPost - actMatPre);

behMetrics.Pii = (sum(actMatPre == 0 & diff == 0)./sum(actMatPre == 0))';
behMetrics.Pia = (sum(actMatPre == 0 & diff == 1)./sum(actMatPre == 0))';
behMetrics.Paa = (sum(actMatPre == 1 & diff == 0)./sum(actMatPre == 1))';
behMetrics.Pai = (sum(actMatPre == 1 & diff == 1)./sum(actMatPre == 1))';

%% Spatial centrality metrics
socCent = [nanmean(nanmean(trackingData(:,:,1))) nanmean(nanmean(trackingData(:,:,2)))];


%Distances from nest center
distToCentStat = sqrt(sum((socCent - [mean(trackingData(:,:,1),1,'omitnan')' mean(trackingData(:,:,2), 1, 'omitnan')']).^2,2));
distToCentInst = mean(sqrt((trackingData(:,:,1) - socCent(1)).^2 + (trackingData(:,:,2) - socCent(2)).^2), 1 , 'omitnan');

%Activity, i.e. portion of time moving
porTimeMoving = mean(activityMatrix, 1, 'omitnan')';

%Moving speed
movingVelocity = nan(numel(taglist),1);

for i = 1:numel(taglist)
    sp = speedMatrix(:,i);
    act = activityMatrix(:,i);
    movingVelocity(i) = nanmean(sp(act == 1));
end


%% Distance to nest structures
medDistCloseBrood = nan(numel(taglist),1);
medDistAllBrood = nan(numel(taglist),1);
medDistCloseWP = nan(numel(taglist),1);
medDistAllWP = nan(numel(taglist),1);
broodOcc =  nan(numel(taglist),1); %Brood occupancy rate
wpOcc =  nan(numel(taglist),1); %waxpot occupancy rate

for i = 1:numel(taglist)
    %%
    if ~isempty(broodLocs)
        broodDists = sqrt(pdist2(trackingData(:,i,1), broodLocs(:,1)).^2 + ...
            pdist2(trackingData(:,i,2), broodLocs(:,2)).^2);
        minBroodDists = min(broodDists,[],2);
        medDistCloseBrood(i) = nanmedian(minBroodDists);
        medDistAllBrood(i) = nanmedian(nanmedian(broodDists));
        minBrDstNN = minBroodDists(~isnan(minBroodDists)); %Remove nans from min brood
        broodInts = double(minBrDstNN < bodyLength); %%logical by which are close to brood
        broodOcc(i) = mean(broodInts, 'omitnan'); %average
    end
    
    if ~isempty(wpLocs)
        wpDists = sqrt(pdist2(trackingData(:,i,1), wpLocs(:,1)).^2 + ...
            pdist2(trackingData(:,i,2), wpLocs(:,2)).^2);
        minWpDists = min(wpDists,[],2);
        medDistCloseWP(i) = nanmedian(minWpDists);
        medDistAllWP(i) = nanmedian(nanmedian(wpDists));
        minWpDstNN = minWpDists(~isnan(minWpDists)); %Remove nans from min brood
        WpInts = double(minWpDstNN < bodyLength); %%logical by which are close to brood
        wpOcc(i) = mean(WpInts, 'omitnan'); %average
    end
end


%% Spatial dispersion metrics
na50 = nan(numel(taglist),1);
na90 = nan(numel(taglist),1);
iod = nan(numel(taglist),1);

for i = 1:numel(taglist)
    %%
    xy = permute(trackingData(:,i,1:2), [1 3 2]);
    [areaSmall areaLarge iodC] = calculateSpatialDispersionMetrics(xy);
    na50(i) = areaSmall;
    na90(i) = areaLarge;
    iod(i) = iodC;
end


%% Add spatial data

[spatCorMat pointCounts] = createSpatialCorrelationMatrix(trackingData);
spatCorMat(spatCorMat == 1) = NaN;
spatCorAll = mean(spatCorMat, 1, 'omitnan');
%instead of 2d bin counts:


%%% Mostly good up to here
%[jsDivMat beeLocs pointCounts2] = createJSDivergenceMatrix(intTags, curDayHive);
%spatialEvennessIndex = calculateSpatialEvennessIndex(intTags, curDayHive);



broodInfoRichness = calculateSpatialNestInformation(trackingData, broodLocs);
waxpotInfoRichness = calculateSpatialNestInformation(trackingData, wpLocs);

%% Interaction metrics
distMat = calculatePairwiseDistanceMatrix(trackingData);
distMat(distMat == 0) = NaN;
intMat = distMat;
meanDistanceToOtherBees = mean(permute(nanmedian(distMat,2), [3,1,2]), 1, 'omitnan');
minDistanceToOtherBees = nanmedian(permute(nanmin(distMat, [], 2), [3,1,2]));

intMat(distMat <= bodyLength) = 1;
intMat(distMat > bodyLength) = 0;
intMat = mean(intMat,3, 'omitnan');
meanInteractionRate = mean(intMat, 1, 'omitnan');

binMat = intMat;
binMat(intMat > 0) = 1;
binMat(intMat == 0) = 0;

degCent = nansum(binMat);
intMat(isnan(intMat)) = 0;
eigCent = eigenCentrality(intMat);

framesTracked = sum(~isnan(trackingData(:,:,1)));

%% Write variable to output table
behMetrics.distanceToCenterStatic = distToCentStat;
behMetrics.distanceToCenterInstantaneous = distToCentInst';
behMetrics.porTimeMoving = porTimeMoving;
behMetrics.movingVelocity = movingVelocity;
behMetrics.medianDistanceToAllBrood = medDistAllBrood;
behMetrics.medianDistanceToAllWaxpots = medDistAllWP;
behMetrics.medianDistancetoClosestBrood = medDistCloseBrood;
behMetrics.medianDistanceToClosestWaxpot = medDistCloseWP;
behMetrics.nestRangeArea50 = na50;
behMetrics.nestRangeArea90 = na90;
behMetrics.nestOccupancyDispersionIndex = iod;
behMetrics.eigenvectorCentrality = eigCent;
behMetrics.degreeCentrality = degCent';
behMetrics.meanInteractionRate = meanInteractionRate';
behMetrics.spatCorAll = spatCorAll';
behMetrics.broodInfoRichness = broodInfoRichness;
behMetrics.waxpotInfoRichness = waxpotInfoRichness;
behMetrics.framesTracked = framesTracked';
behMetrics.meanDistanceToOtherBees = meanDistanceToOtherBees';
behMetrics.minDistanceToOtherBees = minDistanceToOtherBees';
behMetrics.broodOccupancyRate = broodOcc;
behMetrics.waxpotOccupancyRate = wpOcc;


