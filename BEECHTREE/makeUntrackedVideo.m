% All relevant files need to be loaded into a single, separate folder (no data from other experiments)
[filename pathname] = uigetfile('*');
cd(pathname);

%% Load in data set from single experiment

thermVid = VideoReader(filename);
visFile = strrep(filename, 'TC.mj2', 'NC.avi');
visVid = VideoReader(visFile);



%%
outVid = VideoWriter(strrep(filename, 'TC.mj2', 'summaryVid.avi'));
open(outVid);
%for i = 1:thermVid.NumberOfFrames
nframes = 100;
h = waitbar(0, 'Video progress');
for i = 1:nframes
    %%
    subplot(1,2,1);
    im = read(thermVid,i);
    im = convertThermalImage(im);
    
    
    
    if i == 1
        imagesc(im);
        colormap hot
        refPol = roipoly;
    end
    
    refTemp = 23;
    
    mTemp = median(im(refPol));
    diff = refTemp - mTemp;
    im = im+diff;
    imagesc(im, [21.5 32]);
    colormap jet
    colorbar
    %%
    subplot(1,2,2);
    im = rgb2gray(read(visVid,i));
    imshow(imadjust(im));
    drawnow
    pause(0.2);
    
    frame = getframe(gcf);
    writeVideo(outVid,frame);
    waitbar(i/nframes, h);
end

close(outVid);