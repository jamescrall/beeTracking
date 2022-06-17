function thermImRGB = filterThermIm(backIm)

thermIm = wiener2(backIm, [2 2]);
%out = imagesc(thermIm);
%
m = 255;
clrMp = inferno(m);
colormap(clrMp);
thermImRGB = ind2rgb(im2uint8(mat2gray(thermIm)), clrMp);
thermImRGB = uint8(round(thermImRGB.*255));
thermImRGB = localcontrast(thermImRGB, 0.5, 0.3);
%thermImRGB = histeq(thermImRGB);