function beeCounts = plotBeeCounts_Wy(beeCounts)
% Plot brood, but with specified marker size and alpha values
% 
% Example
%  %brood = nx3 matrix
%  size = 300;
%  alpha = 0.5
% plotbroodTrans(brood, size, alpha)
% 
% 
size = 6;
queens = beeCounts(beeCounts(:,3) == '1',:); %separate out pots
workers = beeCounts(beeCounts(:,3) == '2',:);




 plot(queens(:,1),queens(:,2), 'yo', 'MarkerSize', size*2);
 plot(workers(:,1), workers(:,2), 'go', 'MarkerSize', size);