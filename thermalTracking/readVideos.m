[filename pathname] = uigetfile('*');
vid = VideoReader([pathname filename]);

%%
for i = 1:vid.NumberOfFrames
im = read(vid,i);
im = convertThermalImage(im);
imagesc(im, [30 42]);
colormap jet
drawnow
end

%% for 
means = [];
stds = [];
for i = 1:vid.NumberOfFrames
   means = [means mean(mean(convertThermalImage(read(vid,i))))]; 
   stds = [stds std(std(convertThermalImage(read(vid,i))))]; 
i
end