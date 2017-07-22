%% Initialize arduino and DS18B20 sensors
a = arduino('COM8', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
%therm2 = sensor.AvailableAddresses{2};

%%
temp1 = takeOneWireTempReading(sensor,therm1)

expTime = 30; %Length of experiment in minutes
buf = 1; % buffer time in minutes
times = [];
temps = [];
expPref = 'exp2';
filenamebase = strcat(expPref,datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

tic
while toc < (expTime*60 + buf*60) %Start timer
    temps = [temps takeOneWireTempReading(sensor, therm1)];
    times = [times now];
    
end

save(strcat(filenamebase, 'temperatures.mat'), 'times', 'temps');