video_input = videoinput('gige'); %connect to the first gige camera
source = video_input.Source; %get the source object

%To get temperature linear data, the following GenICam registers needs
%to be set
source.SensorGainMode = 'HighGainMode';
source.TemperatureLinearMode = 'On';
source.TemperatureLinearResolution = 'High';


%start the video acquisition
start(video_input);

%MATLAB will receive data in uint16 format, the camera streams in 14bit
%therefor we have to remove the two most significant bits (2^14 and 2^15)
temp_linear = double(getdata(video_input, 1, 'uint16'));
temp_linear_stripped = temp_linear -(2^15) - (2^14); %removing the 2 MSB

%the temperature is linear in this format: T = Signal * 0.04
temp_data_kelvin = temp_linear_stripped * 0.04;
%we get the data in Kelvin, so it needs to be converted
temp_data_celcius = temp_data_kelvin - 273.15;

%displaying the temperature in pixel(100,100)
disp(temp_data_celcius(100,100));

%to display the image, we can use imagesc
imagesc(temp_data_celcius);

stop(video_input);
imaqreset;