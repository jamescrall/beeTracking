cd(uigetdir);
uigetfile
mov = VideoReader();
%%
for i = 1:mov.NumberOfFrames
   imRaw = read(mov,i);
   imTh = convertThermalImage(imRaw);
   colormap jet
   imagesc(imTh);
   colorbar
   pause(0.5);
end