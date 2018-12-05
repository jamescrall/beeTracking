function [speedMat activityMat] = calculateActivityMatrix(nestData, varargin)
    % Inputs:
    %
    %   Takes matrix of the form 'nestData' as input
    %       m x n x 3
    %   m: number of frames
    %   n: number of bees
    %
    %
    % Optional:
    % 2nd input can be threshold on speed to define active/inactive
    %   NB: this is required if you want in include the 3rd input
    %
    % 3rd input:  time reference for calculating speed. Can either be a single
    %   value, which is the interpreted as frame per second (i.e., Hz), or a
    %   vector of length m, which is then interpreted as timestamps for each
    %   frame.
    %
    %
    %
    % Outputs
    %    speedMat - m x n matrix of speed for each frame
    %
    %   activityMat - m x n matrix of binary activity (active/inactive) states
    %   based on threshold
    %
    %
    %
    
    %%
    
    if ~isempty(varargin) %Are there are optional inputs supplied?
        
        thresh = varargin{1}; %if so, extract the first as an activity threshold
        
        
        if length(varargin) > 1
            
            tms = varargin{2}; %Extract 2nd optional input
            
            if numel(tms) == 1 %Is that input a single value? If so, calculate as a constant frame rate
                preVels = calculateSpeedConstantRate(nestData, tms);
                
            elseif numel(tms) > 1 %Otherwise,
                if size(nestData,1) == numel(tms)
                    preVels = calculateSpeedVariableRate(nestData, tms);
                else
                    disp('Supplied timestamps dont match number of frames in the supplied data, aborting...');
                    return
                end
            end
            
        else
            fps = 2;
            preVels = calculateSpeedConstantRate(nestData, fps);
            
        end
        
    else
        
        thresh = 10^-3.9; %If not supplied, use standard activity threshold
        fps = 2;
        preVels = calculateSpeedConstantRate(nestData, fps);
    end
    
    
    activityMat = preVels > thresh;
    activityMat = double(activityMat);
    activityMat(isnan(preVels)) = NaN;
    speedMat = preVels;
    
    blankRow = nan(1,size(nestData,2)); %Resize both matrices to fit original size of nestData
    speedMat = [blankRow ; speedMat];
    activityMat = [blankRow ; activityMat];
    
    
    
function preVels = calculateSpeedConstantRate(nestData, fps)
    preDiffVel = abs(diff(nestData(:,:,1:2)));
    preVels = sqrt(preDiffVel(:,:,1).^2 + preDiffVel(:,:,2).^2);
    preVels = preVels*fps; %Correct for frame rate
    
function preVels = calculateSpeedVariableRate(nestData, tms)
    preDiffVel = abs(diff(nestData(:,:,1:2))); %Get framewise distances
    preVels = nan(size(preDiffVel,1), size(preDiffVel,2));
    preVels = sqrt(preDiffVel(:,:,1).^2 + preDiffVel(:,:,2).^2);
    timediffs = diff(tms);
    preVels = bsxfun(@divide, preVels, timediffs'); %Correct for frame rate
    
