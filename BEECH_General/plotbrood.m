function plotbrood(brood)


br = brood(brood(:,3) == '3',:); %separate out pots
eg = brood(brood(:,3) == '1',:);    % eggs
la = brood(brood(:,3) == '2',:);    %larvae
fp = brood(brood(:,3) == '5',:);    %full pots
ep = brood(brood(:,3) == '4',:);    %empty pots
pp = brood(brood(:,3) == '6',:);    %pollen pots
bc = brood(brood(:,3) == '7',:);    %wax cover
qc = brood(brood(:,3) == '8',:);    %queen cells

ms = 12;
plot(br(:,1),br(:,2), 'yo', 'MarkerSize', ms);
plot(fp(:,1),fp(:,2), 'mo', 'MarkerSize', ms);
plot(ep(:,1), ep(:,2), 'go', 'MarkerSize', ms);
plot(la(:,1),la(:,2), 'ro', 'MarkerSize', ms);
plot(eg(:,1), eg(:,2), 'bo','MarkerSize', ms);
plot(pp(:,1), pp(:,2), 'o', 'Color', [1 0.5 0], 'MarkerSize', ms);
plot(bc(:,1), bc(:,2), 'o', 'Color', [0 0.8 1], 'MarkerSize', ms);
plot(qc(:,1), qc(:,2), 'o', 'Color', [1 0.7 0.6], 'MarkerSize', ms*2);