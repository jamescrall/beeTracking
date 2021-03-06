function backIm = backImFromFilelist(filelist,n, diagVis, thresh)
%Inputs:
%filelist - list of video files of the same dimensions
%n - number of frames to pull from each video
%diagVis - show diagnostic plots? logical
%thresh - intensity difference threshold used to generate differences of
%individual videos vs background
vid = VideoReader(filelist(1).name);
im = read(vid, 1);
zz = 1; %Set indexing variable to start

diagVis = 1; %Display diagnostic visuals?
if diagVis == 1
    xx = 1;
end

for i = 1:numel(filelist)
    vid = VideoReader(filelist(i).name);
    frameInd = round(linspace(1,vid.NumberOfFrames,n));
    
    if diagVis == 1 %If we're doing diagnostic visualization, create empty data frame
        if i == 1
            indVidData = struct();
        end
    end
    
    for j = 1:numel(frameInd)
        k = frameInd(j);
        im = rgb2gray(read(vid, k)); %Read in frame
        if i == 1 && j == 1 %If we're on the first frame, create output matrix
            frameData = uint8(nan(size(im,1), size(im,2), numel(filelist)*n));
            
        end
        frameData(:,:,zz) = im;
        %imshow(frameData(:,:,zz));
        zz = zz+1;
    end
    
    if diagVis == 1
        im = read(vid, round(vid.NumberOfFrames/2));
        indVidData(i).im = rgb2gray(im);
        xx = xx+1;
    end
    
end

backIm = median(frameData,3);

if diagVis
    figure(1);
    imshow(backIm);
    figure(2);
    nr = ceil(sqrt(numel(filelist)));
    for i = 1:numel(filelist)
        subplot(nr,nr, i);
        imd = abs(int8(indVidData(i).im) - int8(backIm)) > thresh;
        imshow(imd);
        title({filelist(i).name});
    end
end