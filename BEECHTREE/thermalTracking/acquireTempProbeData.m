%% Initialize arduino and DS18B20 sensors
<<<<<<< Updated upstream
a = arduino('COM4', 'Uno', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D2');
=======
a = arduino('/dev/tty.usbmodem1411', 'Mega2560', 'Libraries', 'PaulStoffregen/OneWire');
sensor = addon(a, 'PaulStoffregen/OneWire', 'D3');
>>>>>>> Stashed changes
therm1 = sensor.AvailableAddresses{1};
therm2 = sensor.AvailableAddresses{2};
therm3 = sensor.AvailableAddresses{3};
therm4 = sensor.AvailableAddresses{4};
<<<<<<< Updated upstream

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
=======
therm5 = sensor.AvailableAddresses{5};
therm6 = sensor.AvailableAddresses{6};
therm7 = sensor.AvailableAddresses{7};
therm8 = sensor.AvailableAddresses{8};
therm9 = sensor.AvailableAddresses{9};
therm10 = sensor.AvailableAddresses{10};
therm11 = sensor.AvailableAddresses{11};
therm12 = sensor.AvailableAddresses{12};
%%
temp1 = takeOneWireTempReading(sensor, therm1);
temp2 = takeOneWireTempReading(sensor, therm2);
temp3 = takeOneWireTempReading(sensor, therm3);
temp4 = takeOneWireTempReading(sensor, therm4);
temp5 = takeOneWireTempReading(sensor, therm5);
temp6 = takeOneWireTempReading(sensor, therm6);
temp7 = takeOneWireTempReading(sensor, therm7);
temp8 = takeOneWireTempReading(sensor, therm8);
temp9 = takeOneWireTempReading(sensor, therm9);
temp10 = takeOneWireTempReading(sensor, therm10);
temp11 = takeOneWireTempReading(sensor, therm11);
temp12 = takeOneWireTempReading(sensor, therm12);



expTime = 125; %Length of experiment in minutes
buf = 1; % buffer time in minutes
times = [];
temps = [];
expPref = 'cthermalTrackingExpts';
filenamebase = strcat(expPref,datestr(now, '_dd-mmm-yyyy_HH-MM-SS'));

tic
while toc < expTime*60 %Start timer
    temp1 = [temp1 takeOneWireTempReading(sensor, therm1)];
    temp2 = [temp2 takeOneWireTempReading(sensor, therm2)];
    temp3 = [temp3 takeOneWireTempReading(sensor, therm3)];
    temp4 = [temp4 takeOneWireTempReading(sensor, therm4)];
    temp5 = [temp5 takeOneWireTempReading(sensor, therm5)];
    temp6 = [temp6 takeOneWireTempReading(sensor, therm6)];
    temp7 = [temp7 takeOneWireTempReading(sensor, therm7)];
    temp8 = [temp8 takeOneWireTempReading(sensor, therm8)];
    temp9 = [temp9 takeOneWireTempReading(sensor, therm9)];
    temp10 = [temp10 takeOneWireTempReading(sensor, therm10)];
    temp11 = [temp11 takeOneWireTempReading(sensor, therm11)];
    temp12 = [temp12 takeOneWireTempReading(sensor, therm12)];
>>>>>>> Stashed changes
    
    times = [times now];
    plot([temp1' temp2' temp3' temp4' temp5' temp6' temp7' temp8' temp9' temp10' temp11' temp12']);
end

<<<<<<< Updated upstream
save(strcat(filenamebase, 'temperatures.mat'), 'times', 'temps1', 'temps2', 'temps3', 'temps4');
=======
save(strcat(filenamebase, 'temperatures.mat'), 'times', 'temp1', 'temp2', 'temp3', 'temp4', 'temp5', 'temp6', 'temp7', 'temp8', 'temp9', 'temp10', 'temp11', 'temp12', 'therm1', 'therm2', 'therm3', 'therm4', 'therm5', 'therm6', 'therm7', 'therm8', 'therm9', 'therm10', 'therm11', 'therm12');
>>>>>>> Stashed changes
