% This program is designed by Shuhao Zhang in 2020/10.
% A distribution plot of nearest neighbor distance and to nucleus distance
% will be completed by running this program and following the command.

clearvars; close all;
% Define two pixels as the maximum distance of interaction 
pairDis = 2;
% 0.11um/pixel
pixel = 0.11;
% Define an interactio event lasting at least five seconds
successiveThresh = 5;
% Interval between frames is 2 seconds
interval = 2;
% Plot the trajectory in red
trajectoryColor = 'r';
% Generate the video in one frame per second
FPS = 1;
frameNum = 15;

disp('Please select your endo image file(.tif)');
[endoImageFile, endoImagePath] = uigetfile('*.tif');
disp('Please select the endosome tracking file(.csv)');
[endoFile, endoPath] = uigetfile('*.csv');

endoImage = GenerateImageCell(endoImagePath,endoImageFile);
% parse the tracking file into desired input format
endoInput = ReadIn(strcat(endoPath,endoFile));
% create a new format of data sorted into cells according to frame number
endosome = SplitFrame(endoInput,frameNum);

% nucleus position
figure;
imshow(endoImage{1,1});
[x,y] = getpts; % get nucleus coordinates
figure;
for i = 1:size(endosome,1)
    for j = 1:size(endosome{i,1},1)
        % calculate distance
        endosome{i,1}(j,5) = sqrt(power(endosome{i,1}(j,3)-x,2)+power(endosome{i,1}(j,4)-y,2));
    end
    f = ksdensity(endosome{i,1}(:,5),0:5:500);
    h = plot(0:5:500,f);
    drawnow
    hold on
end
title('To Nucleus Distance Distribution')
saveas(gcf,strcat(endoPath,'\','TNDist'),'fig')


figure;
dStat = [];
for i = 1:size(endosome,1)
    for j = 1:size(endosome{i,1},1)
        intermediate = endosome{i,1};
        intermediate(j,:) = [];
        [IDX,d] = knnsearch(endosome{i,1}(j,3:4),intermediate(:,3:4));
        dStat = [dStat;d];
    end
    f = ksdensity(dStat,0:4:500);
    h = plot(0:4:500,f);
    drawnow
    hold on
end
title('Nearest Neighbor Distance Distribution')
saveas(gcf,strcat(endoPath,'\','NNDist'),'fig')