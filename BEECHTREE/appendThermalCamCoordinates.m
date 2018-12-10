function thermCrds = appendThermalCamCoordinates(nestTracks, tform)
    %   Function to append registered coordinates for thermal camera points,
    %   given a set of tracked points in the visual camera
    %
    % Inputs
    %%

thermCrds = nan(size(nestTracks,1), size(nestTracks,2),2); %x coordinates in therm cam

for j = 1:size(nestTracks,2)
    %%
    nind = find(~isnan(nestTracks(:,j,1)));
    crds = permute(nestTracks(nind,j,1:2), [1 3 2]);
    tfCrds = tformfwd(tform, crds);
    %nestTracks(nind,j,5:6) = permute(tfCrds, [1 3 2]);
    thermCrds(nind,j,1:2) = permute(tfCrds, [1 3 2]);
end


