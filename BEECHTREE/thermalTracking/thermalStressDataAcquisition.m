%Load cameras from function
[vid video_input] = resetCameras;

%% Load thermal probes (DS18B20 via Arduino)
a = arduino('COM8', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};

%% Test loop
colName = inputdlg('colony name:');
colName = colName{1};
cd(uigetdir());

filenamebase = strcat(colName, datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

thermVid = VideoWriter(strcat(filenamebase, 'Thermal'), 'Archival');
visVid = VideoWriter(strcat(filenamebase, 'Visual.avi'));

open(thermVid);
open(visVid);

%empty vectors for data output
t1 = [];
t2 = [];
times = [];
error = [];

trialLength = 15; %trial time in minutes

tic %start timer

while toc < trialLength*60
   %% 
  %  try
        % get data from all sources into memory
         start(video_input); %Connect to FLIR
        start(vid); %Connect to PG
       
        %Trigger both videos
        trigger(video_input);
        trigger(vid);
        
        
        thermIm = getdata(video_input,1);
        visIm = getdata(vid,1);
        
        flushdata(video_input);
        flushdata(vid);
        
        stop(video_input);
        stop(vid);
        
        temp1 = takeOneWireTempReading(sensor, therm1);
        temp2 = takeOneWireTempReading(sensor, therm2);
        curTime = now;
        
        %Save data
        t1 = [t1 temp1];
        t2 = [t2 temp2];
        times = [times curTime];
        error = [error 0];
        %     subplot(3,1,1);
        %     plot(times,t1, 'r');
        %     hold on
        %     plot(times,t2, 'b');
        %     datetick
        %     hold off
        %
        %     subplot(3,1,2);
        %     colormap(gca, 'jet');
        %     imagesc(thermIm);
        %     colorbar;
        %
        %     subplot(3,1,3);
        %     imshow(visIm);
    catch
        %Save data
        disp('error - loading blank frames, saving thermal data and resetting cameras...');
        
        temp1 = takeOneWireTempReading(sensor, therm1);
        temp2 = takeOneWireTempReading(sensor, therm2);
        curTime = now;
        t1 = [t1 temp1];
        t2 = [t2 temp2];
        times = [times curTime];
        error = [error 1];
        visIm = uint8(zeros(size(visIm)));
        thermIm = uint16(zeros(size(thermIm)));
        
        [vid video_input] = resetCameras;
        continue

    end
    
    writeVideo(thermVid, thermIm);
    writeVideo(visVid, visIm);
    
    plot(times, t1, 'g');
    hold on
    text(times(1), t1(1), 'green - t1, blue - t2');
    plot(times, t2, 'b');
    errorTimes = times(error == 1);
    plot(errorTimes, repmat(mean(t1), numel(errorTimes),1), 'ro');
    datetick
    hold off
end

close(thermVid);
close(visVid);
save(strcat(filenamebase, 'TempAndTimeData'), 't1', 't2', 'times');