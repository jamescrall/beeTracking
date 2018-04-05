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
br = brood(brood(:,3) == '1',:); %separate out pots
pots = brood(brood(:,3) == '2',:);
bc = brood(brood(:,3) == '3',:);

broodCol = [1 0.6 0.4];
waxpotCol = [0.8 0.7 0.5];

scatter(br(:,1),br(:,2), size, 'filled', 'MarkerFaceAlpha',alpha, 'MarkerFaceColor', broodCol);
scatter(pots(:,1),pots(:,2), size,'MarkerEdgeColor', waxpotCol, 'MarkerEdgeAlpha',alpha);
scatter(bc(:,1),bc(:,2), size/2, 'filled', 'MarkerFaceAlpha',alpha, 'MarkerFaceColor', waxpotCol);



% plot(fp(:,1),fp(:,2), 'mo');
% plot(ep(:,1), ep(:,2), 'go');
% plot(la(:,1),la(:,2), 'ro');
% plot(eg(:,1), eg(:,2), 'bo');
% plot(pp(:,1), pp(:,2), 'o', 'Color', [1 0.5 0]);
% plot(bc(:,1), bc(:,2), 'o', 'Color', [0 0.8 1]);