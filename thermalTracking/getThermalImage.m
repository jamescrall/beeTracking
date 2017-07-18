function thermIm = getThermalImage(video_input)

%Reads from A65 FLIR camera and returns an image of pixel-level temperature
%values
%start(video_input);
temp_linear = double(getsnapshot(video_input));
temp_linear_stripped = temp_linear -(2^15) - (2^14); %removing the 2 MSB

%the temperature is linear in this format: T = Signal * 0.04
temp_data_kelvin = temp_linear_stripped * 0.04;

%we get the data in Kelvin, so it needs to be converted
thermIm = temp_data_kelvin - 273.15;
%stop(video_input);