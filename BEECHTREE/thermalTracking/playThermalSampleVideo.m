
thermVidRd = VideoReader(strcat(filenamebase, 'Thermal.mj2'));
%%
nframes = thermVidRd.NumberOfFrames;
meanTemps = [];
for i = 1:20:nframes
    xl = [32 48];
    tIm = read(thermVidRd,i);
    tIm = convertThermalImage(tIm);
    figure(1);
    imagesc(tIm, xl);
    colormap jet
    colorbar
    drawnow
    figure(2);
    meanTemps = [meanTemps mean(mean(tIm(200:400, 200:400)))];
    plot(meanTemps);
    ylim(xl);
    drawnow
    %if mod(i,100) == 0
        disp(i);
    %end
    
end