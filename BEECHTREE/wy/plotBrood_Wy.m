function BEECH_plotBrood(brood, size, alpha)
% Plot brood, but with specified marker size and alpha values
% 
% Example
%  %brood = nx3 matrix
%  size = 300;
%  alpha = 0.5
% plotbroodTrans(brood, size, alpha)
% 
% 
eggs = brood(brood(:,3) == '1',:); %separate out pots
larvae = brood(brood(:,3) == '2',:);
pupae = brood(brood(:,3) == '3',:);
emptyPots = brood(brood(:,3) == '4',:);
fullPots = brood(brood(:,3) == '5',:);
pollenPots = brood(brood(:,3) == '6',:);
waxCovering = brood(brood(:,3) == '7',:);
pollenFoodSource = brood(brood(:,3) == '8',:);
nectarFoodSource = brood(brood(:,3) == '9',:);



 plot(pupae(:,1),pupae(:,2), 'yo');
 plot(eggs(:,1), eggs(:,2), 'go');
 plot(larvae(:,1),larvae(:,2), 'ro');
 plot(emptyPots(:,1), emptyPots(:,2), 'mo');
 plot(fullPots(:,1), fullPots(:,2), 'bo');
 plot(pollenPots(:,1), pollenPots(:,2), 'o', 'Color', [1 0.5 0]);
 plot(waxCovering(:,1), waxCovering(:,2), 'o', 'Color', [0 0.8 1]);
 plot(pollenFoodSource(:,1), pollenFoodSource(:,2), '.', 'Color', [1 0.5 0],'MarkerSize', 10);
 plot(nectarFoodSource(:,1), nectarFoodSource(:,2), '.', 'Color', [0 0.2 1], 'MarkerSize', 10);