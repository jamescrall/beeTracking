[filename pathname] = uigetfile('*');
vid = VideoReader([pathname filename]);

%
for i = 1:vid.NumberOfFrames
im = read(vid,i);
imagesc(im);
drawnow
end