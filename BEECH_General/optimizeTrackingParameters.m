function [metaData] = optimizeTrackingParameters(vid, threshVals, filtVals, nframes, taglist)
    
    %Inputs:
    %vid: VideoReader object
    %threshVals - range of bradley threshold values to test
    %filtVals - range of bradley threshold values to test
    %nframes - how many frames to sample over?
    
    
    %Outputs:
    %brThresh - optimal threshold value
    %brFilt - optimal filter size value
    %
    %% Track across frames
    frameIndex = round(linspace(1,vid.NumberOfFrames, nframes));
    outData = nan(numel(threshVals), numel(filtVals), nframes,2);
    h = waitbar(0, 'Overall progress...');
    for i = 1:nframes
        %%
        %i
        im = rgb2gray(read(vid,frameIndex(i)));
        %imshow(im);
        for j = 1:numel(threshVals)
            %j
            h1 = waitbar(0,'progress across filter values');
            for k = 1:numel(filtVals)
                %k
                try
                    tic
                    F = locateCodes(im,'threshMode', 1,'sizeThresh', [600 1500], 'bradleyFilterSize', [filtVals(k) filtVals(k)], 'bradleyThreshold', threshVals(j), 'vis', 1);
                    timeS = toc;
                    if ~isempty(F)
                        outData(j,k,i,1) = sum(ismember([F.number], taglist));
                        
                    end
                    outData(j,k,i,2) = timeS;
                catch
                    %disp('no tags: skip');
                    continue
                end
                waitbar(k/numel(filtVals), h1);
            end
            %disp([num2str(j) ' of ' num2str(numel(threshVals)) ' threshhold values analyzed'])
            close(h1);
        end
        waitbar(i/nframes,h)
    end
    
    %% Normalize and plot
    outData(isnan(outData)) = 0; %Replace nans with zeros;
    
    nbees = sum(outData(:,:,:,1),3);
    nbeesNorm = nbees./max(max(nbees));
    %Visualize performance surface
    
    %% Identify maxima
    [r,c] = find(nbeesNorm == 1);
    brThresh = threshVals(r);
    brFilt = filtVals(c);
    
    
    %% track time spent
    timeSpent = outData(:,:,:,2);
    timeSpent = mean(timeSpent,3);
    optTime = timeSpent(find(nbeesNorm == 1));
    
    %% break ties with time performance
    if numel(brThresh) > 1 %If there's more than one optimum
        ind = find(optTime == min(optTime));
        ind = ind(1); %Tie breaker
        brThresh = brThresh(ind);
        brFilt = brFilt(ind);
        [r,c] = find(timeSpent == optTime(ind));
    end
    
    subplot(2,1,1);
    imagesc(nbees);
    colormap hot
    set(gca, 'XTick', 1:numel(filtVals), 'XTickLabels', filtVals, 'YTick', 1:numel(threshVals), 'YTickLabels', threshVals);
    colorbar
    hold on
    plot(c,r, 'go', 'MarkerSize', 30);
    text(c,r,strcat('Optimum: thresh = ', num2str(brThresh), ',filter size = ', num2str(brFilt)));
    hold off
    subplot(2,1,2);
    imagesc(timeSpent);
    colormap hot
    colorbar
    hold on
    plot(c,r, 'go', 'MarkerSize', 30);
    hold off
    
    metaData = struct();
    metaData.brThreshOpt = brThresh;
    metaData.brFiltOpt = brFilt;
    metaData.optTime = optTime;
    
    metaData.beeCounts = nbees;
    metaData.threshVals = threshVals;
    metaData.filtVals = filtVals;
