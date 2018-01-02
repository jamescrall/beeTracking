function  thermIm = offsetThermalImage(imIn, refPol, refTemp);
    % Function to offset FLIR A65 image with known calibration temperature
    %
    %Inputs:
    %imIn: thermal Image (converted to deg C)
    %refPol: reference polygon with location of temperature probe
    %refTemp: measured reference temperature for that frame
    
    %%

    