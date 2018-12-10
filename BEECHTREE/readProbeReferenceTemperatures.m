function probeTemps = readProbeReferenceTemperatures(thermVid,refPoly1, refPoly2)
%
% Inputs:
%   thermVid - VideoReader object for thermal video
%
%   refPoly1 and refPoly2 - first and second polygons defining upper and
%   lower thermal probes
%
% Output:
%   probeTemps - nframes x 2 matrix, with median temps for upper (column 1) and
%   lower (column 2) probes for each frame
%
nframes = thermVid.NumberOfFrames;

probeTemps = nan(nframes,2);

for i = 1:nframes
    %%
    thermIm = read(thermVid,i);
    thermIm = convertThermalImage(thermIm);
    
    probeTemps(i,1) = nanmedian(thermIm(refPoly1));
    probeTemps(i,2) = nanmedian(thermIm(refPoly2));
end