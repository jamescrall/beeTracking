function [offset thermIm] = calculateThermImOffset(thermIm, thermImIndex, videoTimes, refTemps, tempTimes, refPol)
    %Inputs
    %
    %
    %
    
    time = videoTimes(thermImIndex); %get frame time
    timeDf = abs(tempTimes - time); %Calculate differences between time vectors
    ind = find(timeDf == min(timeDf)); %Find index of closest value from temp data
    refTemp = refTemps(ind); %Extract reference temperature
    measuredRefTemp = median(thermIm(refPol));
    offset = refTemp - measuredRefTemp;
    thermIm = thermIm + offset;