function [] = makeDiagnosticTrackingPlots(masterData)
outPath = uigetdir()
% i = colony index
% j = day index
% k = trial index
for i = 1:numel(masterData) %Loop across colonies
    
    
    colDat = masterData(i).colonyData;
    
    for j = 1:numel(colDat) %loop across days

        trialDat = colDat(j).trackingData;
        backIm = colDat(j).backIm;
        for k = 1:numel(trialDat)

            subplot(3,4,k)
            
            data = masterData(i).colonyData(j).trackingData(k);
            imshow(backIm);
            hold on
            plot(data.nestCoordinates(:,:,1), data.nestCoordinates(:,:,2), '.');
            hold off
            title(datestr(data.trialTime));
            axis equal
            
        end
        mainTitle = strcat({'Colony '}, masterData(i).colony, {','}, colDat(j).day);
        suptitle(mainTitle);
        
        saveas(1, strcat(masterData(i).colony, num2str(j)), 'png');
        
    end
end


