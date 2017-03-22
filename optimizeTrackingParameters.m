function [brThresh brFilt] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist)
    
    %Inputs:
    %vid: VideoReader object
    %threshVals - range of bradley threshold values to test
    %filtVals - range of bradley threshold values to test
    %nframes - how many frames to sample over?
    
    %% Track across frames
    frameIndex = round(linspace(1,vid.NumberOfFrames, nframes));
    outData = nan(numel(threshVals), numel(filtVals), nframes,2);
    for i = 1:nframes
        %%
        %i
        im = rgb2gray(read(vid,frameIndex(i)));
        imshow(im);
        for j = 1:numel(threshVals)
            %j
            for k = 1:numel(filtVals)
                %k
                tic
                F = locateCodes(im,'threshMode', 1,'sizeThresh', [300 1500], 'bradleyFilterSize', [filtVals(k) filtVals(k)], 'bradleyThreshold', threshVals(j), 'vis', 1);
                timeS = toc;
                if ~isempty(F)
                    outData(j,k,i,1) = sum(ismember([F.number], taglist));
                    
                end
                outData(j,k,i,2) = timeS;
            end
        end
    end
    
    %% Normalize and plot
    outData(isnan(outData)) = 0; %Replace nans with zeros;
    
    outDataNorm = sum(outData,3);
    outDataNorm = outDataNorm./max(max(outDataNorm));
    %Visualize performance surface
    imagesc(outDataNorm);
    set(gca, 'XTick', 1:size(outDataNorm,2), 'XTickLabels', filtVals, 'YTick', 1:numel(threshVals), 'YTickLabels', threshVals);
    
    %% Identify maxima
    [r,c] = find(outDataNorm == 1);
    brThresh = threshVals(r);
    brFilt = filtVals(c);
    hold on
    plot(c,r, 'go', 'MarkerSize', 30);
    text(c,r,strcat('Optima: thresh = ', num2str(brThresh), ',filter size = ', num2str(brFilt)));
    hold off
