function [] = diagnosticTrackingPlot(nestTrackingData, statBeeNestData, forageTrackingData, statBeeForageData, backIm, forBackIm, title)

%%
subplot(2,2,1);
imshow(backIm);
hold on;
plot(nestTrackingData.trackingData(:,:,1), nestTrackingData.trackingData(:,:,2));
hold off;

subplot(2,2,2);
imshow(backIm);
hold on;
plot(statBeeNestData.trackingData(:,:,1), statBeeNestData.trackingData(:,:,2), 'o');
hold off;

subplot(2,2,3);
imshow(forBackIm);
hold on;
plot(forageTrackingData(:,:,1), forageTrackingData(:,:,2));
hold off;

subplot(2,2,4);
imshow(forBackIm);
hold on;
plot(statBeeForageData.trackingData(:,:,1), statBeeForageData.trackingData(:,:,2), 'o');
hold off;
suptitle(title);