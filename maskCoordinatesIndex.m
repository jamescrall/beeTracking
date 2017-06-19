function onNestInd = maskCoordinatesIndex(coords, mask)
    
    %% use matrix of pixel coordiantes to extract
    x = coords(:,:,1);
    y = coords(:,:,2);
    
    %Convert to matrix
    xind = reshape(x,numel(x),1);
    yind = reshape(y,numel(y),1);
    
    xind = round(xind);
    yind = round(yind);
    
    nind = ~isnan(xind);
    
    onNestInd = nan(size(xind));
    t1 = xind(nind);
    t2 = yind(nind);
    onNestInd(nind) = mask(sub2ind(size(mask),yind(nind)', xind(nind)'));
    onNestInd = reshape(onNestInd, size(x,1), size(x,2));