a = zeros(numCodes, 3);
b = zeros(numCodes, 3);

for i = 1:numCodes
      a(i, :) = [Centroids{1,i} 20];
end

for i = 1:numCodes
      b(i, :) = [TransformedCentroids{1,i} 1];
end

HDShapes = insertShape(HDImage, 'circle', a, 'LineWidth', 5);
ThermalShapes = insertShape(imView, 'circle', b, 'LineWidth', 1);

figure(1)
imshow(HDShapes);
figure(2)
imshow(ThermalShapes);