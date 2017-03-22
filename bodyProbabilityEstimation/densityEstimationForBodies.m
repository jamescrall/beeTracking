%Manually load distriProbaMats


%Get rid of empty frames
sums = nansum(nansum(allBWFora));
stack = allBWFora(:,:,sums > 0);

%% Looks like the tag location jumps around in the frame (i.e. these don't seem to be centered n the tag...

for i = 1:size(stack,3)
    %%
    imagesc(stack(:,:,i));
    title(i);
    pause(0.1);
    
end

%% Use more centered subset
stackS = stack(1:300,1:300,40:end);

%Calculate mean image stack
meanStack = nanmean(stackS,3);

%% Plot scaled mean image
subplot(2,1,1);
imagesc(meanStack)
axis equal
title('Raw mean image stack');

%Local averaging - requires "smooth2a" dependency
subplot(2,1,2);
meanStackSmooth = smooth2a(meanStack, 10, 10); %Smooth the 2d data, second two numbers set the smooth width in rows and columns, respectively
imagesc(meanStackSmooth);
axis equal
title('Smooth by local averaging');


