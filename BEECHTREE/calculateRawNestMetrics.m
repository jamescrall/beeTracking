function [nestBehMetrics] = calculateRawNestMetrics(nestTracks, brood)
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
    %
    % Outputs:
    %
    %
    
    %% Heal missing data
    for i = 1:size(nestTracks,3)
        nestTracks(:,:,i) = fixShortNanGaps(nestTracks(:,:,i), 5);
    end
    
    %%
    vis = 1
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
    
    
    %%
    outputMetrics = {'distanceToNearestBrood', 'angleToNearestBrood', 'distanceToNearestWaxpots', ...
        'angleToNearestWaxpot', 'distanceFromNestCenter', 'distanceToForagingExit', 'speed'};
    
    
    %%
    
    broodPos = brood(char(brood(:,3)) == '1', 1:2);
    wpPos = brood(char(brood(:,3)) == '2', 1:2);
        %% distance To nest structures
        
    broodDist = nan(size(nestTracks(:,:,1)));
    minBroodDist = broodDist;
    
    for i = 1:size(nestTracks,1)
        %%
        dists = pdist2(permute(nestTracks(i,:,1:2), [2 3 1]), broodPos(:,1:2));
        
        for j = 1:size(nestTracks,2)
            %%
            minBroodDist = nanmin(dists(j,:));
            minBroodDistInd = find(dists(j,:) == minBroodDist);
            
            
            if vis == 1
                %%
                plot(nestTracks(i,:,1), nestTracks(i,:,2), 'ko');
                hold on
                BEECH_plotBrood(brood, 200, 0.5);
                plot(nestTracks(i,j,1), nestTracks(i,j,2), 'ro');
                plot(broodPos(minBroodDistInd,1), broodPos(minBroodDistInd,2), 'go')
                hold off
                axis equal
            end
            j = j+1;
        end
        
    end
    
    