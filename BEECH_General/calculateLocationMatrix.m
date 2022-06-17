function posMatrix = calculateLocationMatrix(nestData, brood, cutoff)
    %
    % Inputs:
    %
    %   nestData:  m x n x 2(+) matrix, where m = nframes, n = nbees, and
    %   dimensions 1,2 are x and y coordinates, respectively
    %
    %   brood: n x 3 matrix, where 'n' = the # of annotated brood elements,
    %   columns 1 and 2 are x and y positions, and the third column
    %   represents the brood type '1' for brood', '2' for waxpots
    %
    %   cutoff: distance (same dimensions as nestData and brood)
    %
    %
    % Output:
    %
    %   posMatrix: m x n matrix, where m = nframes and n = nbees,with 0,1, and
    %   2 indicating instantaneous location off nest, on brood, and on waxpots
    
    %%
%     broodPos = brood(brood(:,3) == '1',1:2);
%     wpPos = brood(brood(:,3) == '2',1:2);
    posMatrix = nan(size(nestData,1), size(nestData,2));
    
    for i = 1:size(nestData,1)
        %%
        for j = 1:size(nestData,2)
            %%
            if ~isnan(nestData(i,j,1))
                
                x = nestData(i,j,1);
                y = nestData(i,j,2);
                
                dists = sqrt((x- brood(:,1)).^2 + (y- brood(:,2)).^2);
                
                if min(dists) > cutoff
                    
                   posMatrix(i,j) = 0;
                   
                elseif min(dists) < cutoff
                    
                    ind = find(dists == min(dists));
                    
                    if brood(ind,3) == '1'
                        posMatrix(i,j) = 1;
                    elseif brood(ind,3) == '2'
                        posMatrix(i,j) = 2;
                    end
                end
            end
        end
    end