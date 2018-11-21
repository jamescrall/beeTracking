function d = calculateDistanceBetweenUserPoints()
    %%
    [x y] = ginput(2);
    hold on
    plot(x,y, 'r-o', 'LineWidth', 3);
    d = sqrt(diff(x)^2 + diff(y)^2);
    h = text(mean(x), mean(y)-50, num2str(round(d)), 'Color', 'r', 'FontSize', 20); 
    hold off