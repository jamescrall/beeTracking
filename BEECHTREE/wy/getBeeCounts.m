function beeCounts = getBeeCounts(im)

%%

term = 0;
msgbox({'worker labels','1: queen (yellow)', '2: worker (red)', '', 'commands:','d: delete nearest point', ...
    'f: move forward 1 frame', 'b: move back 1 frame',...
    '=: zoom in', '-: zoom out', 'c: clear all worker location data','q: finish and exit'});
imshow(im);
hold on

while term == 0
    
    %Display any available data
    if exist('beeCounts', 'var')
        plotBeeCounts_Wy(beeCounts)
    end
    
    [x y button] = ginput(1); %Get one set of points from current interface
    %"1" for queens, "2" for workers, "3" for wax cover
    
    if char(button) == '1' | char(button) == '2'
        if ~exist('beeCounts')
            beeCounts = [x y button];
        else
            beeCounts = [beeCounts; [x y button]];
        end
        plotBeeCounts_Wy(beeCounts)
        
        
        %Remove last point
        
        %Zoom in
    elseif char(button) == '='
        range = 800;
        xlim([(x - range) (x + range)]);
        ylim([(y - range) (y+range)]);
        
        %Zoom out
    elseif char(button) == '-'
        xlim([0 3664]);
        ylim([0 2748]);
        
        
        %Delete point nearest click
    elseif char(button) == 'd'
        dm = sqrt((beeCounts(:,1) - x).^2 + (beeCounts(:,2) - y).^2);
        beeCounts(find(dm == min(dm)),:) = [];
        hold off;
        imshow(im);
        hold on;
        if ~isempty(beeCounts)
            plotBeeCounts_Wy(beeCounts)
        end
        
        %Loop for clearing all data
    elseif char(button) == 'c'
        choice = questdlg('Do you want to clear all bee data?', 'Clear Data', 'Yes', 'No', 'No')
        
        switch choice
            case 'Yes'
                clear beeCounts;
                hold off;
                imshow(im);
                hold on;
            case 'No'
                disp('Bee location data retained - continuing loop')
        end
        
    elseif char(button) == 'q' %Terminate while loop
        
        term = 1;
        
        
    end
end