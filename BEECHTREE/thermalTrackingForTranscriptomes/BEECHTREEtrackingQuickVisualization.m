% Quick visualization of tracking output for colony

%Manually specify file
[file path] = uigetfile();
load([path '/' file]);

ncols = numel(nestTrackingDataMaster);
%% Plot nest data

for i = 1:ncols
   %%
   data = nestTrackingDataMaster(i).trackingData;
   plot(data(:,:,1), data(:,:,2), '-o');
   title(datestr(nestTrackingDataMaster(i).datenum));
   drawnow
   pause(0.2);
   
end

%% Plot foraging data

for i = 1:ncols
   %%
   data = forageTrackingDataMaster(i).trackingData;
   plot(data(:,:,1), data(:,:,2), '-o');
   xlim([0 2000]);
   ylim([0 2000]);
   title(datestr(forageTrackingDataMaster(i).datenum));
   drawnow
   pause(0.2);
   
end