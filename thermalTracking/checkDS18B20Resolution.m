a = arduino('COM8', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');

%%
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};
%%
t1 = [];
t2 = [];
while 1
t1 = [t1 takeOneWireTempReading(sensor, therm1)];
t2 = [t2 takeOneWireTempReading(sensor, therm2)];

t1
t2
end