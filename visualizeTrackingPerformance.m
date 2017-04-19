function [] = visualizeTrackingPerformance();
%%
%Currently no inputs
[filename pathname] = uigetfile('*', 'choose nest video with tracked data');
nestvid = VideoReader([pathname '\' filename]);
forvid = VideoReader([pathname '\' strrep(filename, 'NC', 'FC')]);
load([pathname '\' strrep(filename, '.avi', 'mat')]);
nestData = nestTrackingData.trackingData;
forData = forageTrackingData;
nframes = nestvid.NumberOfFrames;

for i = 1:nframes
    subplot(1,2,1);
    nestim = read(nestvid,i);
    forim = read(forvid,i);
    
    imshow(nestim);
    hold on
    plot(nestData(i,:,1), nestData(i,:,2), '.', 'MarkerSize', 10);
    if i > 10
       plot(nestData((i-10):i,:,1), nestData((i-10):i,:,2));
    end
    hold off
    subplot(1,2,2);
    imshow(forim);
    hold on
        plot(forData(i,:,1), forData(i,:,2), '.', 'MarkerSize', 10);
    if i > 10
       plot(forData((i-10):i,:,1), forData((i-10):i,:,2));
    end
    hold off
    drawnow
    
end