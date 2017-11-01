%% Initialize arduino and DS18B20 sensors
a = arduino('COM4', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};
therm3 = sensor.AvailableAddresses{3};
therm4 = sensor.AvailableAddresses{4};

%% ID sensors
t1 = [];
t2 = [];
t3 = [];
t4 = [];

while 1
    t1 = [t1 takeOneWireTempReading(sensor, therm1)];
    t2 = [t2 takeOneWireTempReading(sensor, therm2)];
    t3 = [t3 takeOneWireTempReading(sensor, therm3)];
    t4 = [t4 takeOneWireTempReading(sensor, therm4)];

    plot(t1, 'r');
    hold on
    plot(t2,'g');
    plot(t3,'b');    
    plot(t4,'k');

end

%%
temp1 = takeOneWireTempReading(sensor,therm1)
temp2 = takeOneWireTempReading(sensor, therm2)
expTime = 60; %Length of experiment in minutes
buf = 1; % buffer time in minutes
times = [];
temps1 = [];
temps2 = [];
temps3 = [];
temps4 = [];
expPref = 'testAug18exp2';
filenamebase = strcat(expPref,datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

tic
while toc < (expTime*60 + buf*60) %Start timer
    temps1 = [temps1 takeOneWireTempReading(sensor, therm1)];
    temps2 = [temps2 takeOneWireTempReading(sensor, therm2)];
     temps3 = [temps3 takeOneWireTempReading(sensor, therm3)];
    temps4 = [temps4 takeOneWireTempReading(sensor, therm4)];
  
    times = [times now];
    
end

save(strcat(filenamebase, 'temperatures.mat'), 'times', 'temps1', 'temps2', 'temps3', 'temps4');