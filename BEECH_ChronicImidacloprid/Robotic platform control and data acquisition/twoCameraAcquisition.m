function [outVid1, outVid2, TSFile] = twoCameraAcquisition(path, recTime, vid1, vid2, colPos, notes)
%Inputs:
%
%path - output filepath
%trialLength - trial length (in seconds)
%vid1 and vid2: nest and foraging camera objects
%colPos: position of current colony within tracking Arena (positions 1-12)
%t: Overall Trial Time Start
%notes: prompted user input appended to trial log
%%
masterLogFile = 'C:\Users\Humblebee\Documents\Carson City\CC_TrialMasterLog.csv';
nframes = recTime*6; %high estimate of how many frames
t = now;
dateVid = datestr(t, 'dd-mmm-yyyy');
hourVid = datestr(t, 'HH');
minsVid = datestr(t, 'MM');
secsVid = datestr(t, 'SS');
timeVid = strcat('_',hourVid, minsVid, secsVid);
path = [path '\colPos' num2str(colPos) '\' dateVid '\'];

%If the folder doesn't exist, make it
if ~isdir(path)
    mkdir(path)
end

outVid1 = VideoWriter(strcat(path, '\', dateVid,timeVid,'_colPos', num2str(colPos), '_NC.avi'));
outVid2 = VideoWriter(strcat(path, '\', dateVid,timeVid,'_colPos', num2str(colPos), '_FC.avi'));

timeStamps = nan(nframes,2);

open(outVid1);
open(outVid2);

i = 1;

tic
%for i = 1:nframes
while toc < recTime
    im1 = peekdata(vid1,1);
    clock1 = rem(now,1);
    im2 = peekdata(vid2,1);
    clock2 = rem(now,1);
    %subplot(1,2,1)
    %imshow(im1);
    %subplot(1,2,2)
    %imshow(im2);
    %drawnow
    
    writeVideo(outVid1, im1);
    writeVideo(outVid2, im2);
    flushdata(vid1);
    flushdata(vid2);
    
    timeStamps(i,1) = clock1;
    timeStamps(i,2) = clock2;
    
    i = i + 1;
end
%toc

close(outVid1); % NB: for some reason, windows can't read the output file but Matlab & VLC can (see below)...
% Other video can be read in Windows Media Player... ???
close(outVid2);

TSFile = strcat(path, '\', dateVid,timeVid,'_timestamps.csv');
timeStamps = timeStamps(~any(isnan(timeStamps),2),:);
csvwrite(TSFile, timeStamps);
%% Append trial data to master log
try
    arch = readtable(masterLogFile);
    logTable = cell2table({datestr(t) num2str(colPos) outVid1.Filename outVid2.Filename TSFile notes});
    logTable.Properties.VariableNames = {'time', 'colonyPosition', 'video1Filename', 'video2Filename', 'timestampFilename', 'notes'};
    logTable.colonyPosition = cell2mat(logTable.colonyPosition);
    writetable([arch; logTable], masterLogFile);
catch
    warning('Error in writing collection data to "CC_TrialMasterLog.csv, skipping..."');
end
