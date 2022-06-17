function [thermalProbePolygon1 thermalProbePolygon2] = outlineTwoThermalProbes(im)

%%
term = 0;
    m = magma(200);

while term == 0
imagesc(im);
colormap(m);

uiwait(msgbox('outline location of thermal probe 1'));
thermalProbePolygon1 = roipoly;

uiwait(msgbox('outline location of thermal probe 2'));
thermalProbePolygon2 = roipoly;

green = cat(3,zeros(size(im)), ones(size(im)), zeros(size(im)));
imagesc(im);
colormap(m);
hold on
h = imshow(green);
set(h, 'AlphaData', (thermalProbePolygon1+thermalProbePolygon2).*0.6);

choice = questdlg('Thermal probe locations look good?', 'Save data?', 'save','edit', 'edit')
    
    switch choice
        case 'save'
            term = 1;
        case 'edit'
            continue
    end
end