
colInd = ['g' 'r' 'g' 'r' 'g'  'r'];
treatInd = colInd == 'r';

for i = 1:numel(masterData)
    %%
    figure(3);
    subplot(3,2,i);
    sumDat = masterData(i).summaryData;
    %Quality  threshold;
    th = 10; %How many frames as a minimum?
    ind = sumDat(:,:,4) < th;
    
    %Extract and quality threshold
    porActive = sumDat(:,:,1);
    porActive(ind) = NaN;
    porNursing = sumDat(:,:,2);
    porNursing(ind) = NaN;
    movSpeed = sumDat(:,:,3);
    movSpeed(ind) = NaN;
    
    var = porNursing; %Which variable to look at?
     
    times = masterData(i).summaryDataTrialTimes;
    nbees = size(var,2);
    for j = 1:nbees
        plot(times, var(:,j), 'b');
    end
    title(masterData(i).colony);
    
    if i == 1
        medians = nan(size(var,1), 6);
    end
    figure(4);
    subplot(3,1,3)
    plot(times, nanmedian(var,2), colInd(i), 'LineWidth', 1);
    medians(:,i) = nanmedian(var,2);
    hold on
    datetick
    %timesRep = repmat(times, 1 nbees);
    %Plot for each bee
    
end

plot(times, mean(medians(:,treatInd),2), 'r', 'LineWidth', 3);
plot(times, mean(medians(:,~treatInd),2), 'g', 'LineWidth', 3);
hold off