% This program:
% 1. takes images from both cameras
% 2. finds the locations of viewable tags in the HDImage
% 3. Transforms these to coordinates in the thermal image
% 4. Finds temperatures at these coordinates in the thermal image
% It will do this a specified number of times

numTags = 40; % Set this at beginning. This is the largest tag number. 
% Experiments should Ideally be set up with tags 1 to numTags. If not, there will be many blank cells.
numMeasurements = 80; % Number of measurements to take(use 1 if you only want to do 1 iteration)
TempCollection = cell(numTags, numMeasurements); %array of temperatures organized by bee
SnapNum = 1; % Variable to store the trial number
interval = 2; %How long in seconds between each snapshot (optional)
start(HDCam); % Starts image aquisition
    
for n = (1:numMeasurements)
    %Take a snapshot with the thermal and HD Camera

    HDImage = getsnapshot(HDCam);
    ThermalImage = ImStream.GetImage;

    %Get Pixels
    img = ThermalImage.ImageArray;
    im = double(img);
    imView = uint8(img); %This is a viewable version of the thermal image

    % Locate all the codes in the HDImage
    Codes = locateCodes(HDImage, 'colMode', 1, 'threshmode', .3, 'tagList', TagList);
    
    % Go to next iteration of loop if no measurements are made
    if (numel(Codes) == 0)
        continue;
    end
    
    numCodes = numel(Codes);

    % Create array of centroids
    
    [ Centroids{1,1:numCodes} ] = Codes.Centroid;
    [ Centroids{2,1:numCodes} ] = Codes.number;
    
    % Create array of transformed centroids
    TransformedCentroids = cell(2, numCodes);
    for i = 1:numCodes
        TransformedCentroids{1,i} = int16(transformPointsForward(tform, Centroids{1,i}));
        TransformedCentroids{2,i} = Centroids{2,i};
    end

    % Create array of temperature values
    Temps = cell(2, numCodes);
    % I exclude measuremnts from a semi-circular area in the photo since it
    % contains the HDCamera
    for i = 1:numCodes
        xCoord = TransformedCentroids{1,i}(1);
        yCoord = TransformedCentroids{1,i}(2);
        if ((yCoord - 60)^2 + (xCoord - 43)^2 > 121)
            pt = System.Drawing.Point(TransformedCentroids{1,i}(1),TransformedCentroids{1,i}(2));
            Temps{1,i} = ThermalImage.GetValueAt(pt);
            Temps{2,i} = TransformedCentroids{2,i};
        end
    end
    
    % Fill the appropriate columns with temperature measurements
    for i = 1:numCodes
        BeeID = Temps{2,i};
        if not(isempty(Temps{1,i}))
            TempCollection{BeeID, SnapNum} = Temps{1,i};
        end
    end
    
    if (n ~= numMeasurements)
        clearvars Centroids TransformedCentroids Temps;
    end
    
    SnapNum = SnapNum + 1;
    disp('done with iteration')
    % pause(interval); Use this if you want to wait longer between each
    % iteration
end

%stop image aquisition
stop(HDCam);