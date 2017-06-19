%Determine qualThresh and plot tracking performance
%Need to generate "masterData" first
frames = masterData(1).summaryData(:,:,3);
frames = reshape(frames, numel(frames),1);

for i = 2:numel(masterData)
    %%
    tmp =  masterData(i).summaryData(:,:,3);
    tmp = reshape(tmp, numel(tmp),1);
    frames = [frames; tmp];
end
figure(1);
hist(log10(frames), 20);
title('Frame counts across all colonies');
xlabel('Frame count (log10)');
ylabel('Count');
qualThresh = 30;

text(0.5,8000, strcat(num2str(mean(frames)), {' frames per trial (mean)'}));
text(0.5,10000, strcat(num2str(mean(frames(frames > 0))), {' frames per trial (mean, tracked bees)'}));
vline(log10(qualThresh));
text(0.5,12000, strcat(num2str(mean(frames > qualThresh)), {' portion of individual trial data  above quality threshold'}));

%
figure(2);
for i = 1:numel(masterData)
    %%
    tmp =  masterData(i).summaryData(:,:,3);
    times = masterData(i).summaryDataTrialTimes;
    times = times - masterData(i).firstDay +1;
    mn = mean(tmp,2);
    plot(times, mn);
    hold on;
    if ~exist ('mnM');
        mnM = mn;
        timesM = times';
    else
        mnM = [mnM; mn];
        timesM = [timesM; times'];
    end
end


yy = smooth(timesM, mnM, 500);
plot(timesM, yy, 'b.', 'MarkerSize', 30);
title('Tracking Performance Over Time');
xlabel('Days after exposure');
ylabel('Tracked Frames Per Bee');
hold off
clear mnM;