function celsius = takeOneWireTempReading(sensor, addr)
    
    %%
reset(sensor);
write(sensor, addr, hex2dec('44'), true);

% Make sure temperature conversion is done. This is necessary if all commands run continuosly in a script.
pause(1);

reset(sensor);
write(sensor, addr, hex2dec('BE')); % read command - 'BE'
data = read(sensor, addr, 9);
crc = data(9);
%sprintf('Data = %x %x %x %x %x %x %x %x  CRC = %x\n', ...
 %   data(1), data(2), data(3), data(4), data(5), data(6), data(7), data(8), crc)
if ~checkCRC(sensor, data(1:8), crc, 'crc8')
    error('Invalid data read.');
end

raw = bitshift(data(2),8)+data(1);

cfg = bitshift(bitand(data(5), hex2dec('60')), -5);
switch cfg
    case bin2dec('00')  % 9-bit resolution, 93.75 ms conversion time
        raw = bitand(raw, hex2dec('fff8'));
    case bin2dec('01')  % 10-bit resolution, 187.5 ms conversion time
        raw = bitand(raw, hex2dec('fffC'));
    case bin2dec('10')  % 11-bit resolution, 375 ms conversion time
        raw = bitand(raw, hex2dec('fffE'));
    case bin2dec('11')  % 12-bit resolution, 750 ms conversion time
    otherwise
        error('Invalid resolution configuration');
end
% Convert temperature reading from unsigned 16-bit value to signed 16-bit.
raw = typecast(uint16(raw), 'int16');

celsius = double(raw) / 16.0;
fahrenheit = celsius * 1.8 + 32.0;
%sprintf('Temperature = %.4f Celsius, %.4f Fahrenheit', celsius, fahrenheit)