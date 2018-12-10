function  measuredTemps = readTempsFromThermalVideos(thermVid, thermCoordinates)
%
%Inputs
%
%   thermVid - thermal camera video
%
%   thermCoordinates - nframes x N x 2 matrix, where N = number of points
%   to measures, and 3rd dimensions represents x and y coordinates,
%   respectively
%
%Output
%
%   measuredTemps - nframes x N matrix, of framewise temperature
%   measurements
nThermFrames = thermVid.NumberOfFrames;
measuredTemps = nan(size(thermCoordinates,1), size(thermCoordinates,2));

for j = 1:nThermFrames
    %%
    % figure(1)
    % visIm = read(visVid,i);
    thermIm = read(thermVid,j); %Read in thermal video frame
    thermIm = convertThermalImage(thermIm); %Convert raw data to deg C
    
    %%
    for k = 1:size(thermCoordinates,2)
        x = thermCoordinates(j,k,1);
        y = thermCoordinates(j,k,2);
        if ~isnan(x)
            temp = takeTempReadingFromThermalImage(thermIm, x, y);
            measuredTemps(j,k) = temp;
        end
    end
    
end