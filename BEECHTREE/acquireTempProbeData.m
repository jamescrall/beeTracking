%% Initialize arduino and DS18B20 sensors
a = arduino('COM8', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};

%% Start acquiring data
expPref = 'tmp';
filenamebase = strcat(expPref,datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

expTime = 35; %Length of experiment in minutes

%Empty vectors
temp1M = [];
temp2M = [];
times = [];

tic
while toc < expTime*60
    %%
    temp1 = takeOneWireTempReading(sensor, therm1);
    temp2 = takeOneWireTempReading(sensor, therm2);
    times = [times now];
    temp1M = [temp1M temp1];
    temp2M = [temp2M temp2];
end

save(strcat(filenamebase, 'temps.mat'), 'temp1M', 'temp2M', 'times');