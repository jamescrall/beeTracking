%% Initialize arduino and DS18B20 sensors
a = arduino('COM8', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};