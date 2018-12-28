function [] = sendToPosition(s,x,y, speed)

%sends Carson City Robot to coordinates xy over serial connection s
%Inputs: 
% x and y: destination coordinates
% s: open serial connection to Smoothieboard

%Set global maxima and minima
xmax = 1180;
ymax = 450;
xmin = 20;
ymin = 10;

if x > xmax | y > ymax | x < xmin | y < ymin
    error('Destination coordinates out of bounds');
end

gmsg = strcat('G0 X',num2str(x), ' Y', num2str(y), ' F', num2str(speed)); 
fprintf(s, gmsg);

    