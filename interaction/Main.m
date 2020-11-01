% This program is designed by Shuhao Zhang in 2020/10.
% This program is designed for detecting interactions between endosomes and
% lysosomes, or in general any pairs of organelles, using KNN search.

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

% Use user interface to select the target image file and tracking file
disp('Please select your endo image file(.tif)');
[endoImageFile, endoImagePath] = uigetfile('*.tif');
disp('Please select your lyso image file(.tif)');
[lysoImageFile, lysoImagePath] = uigetfile('*.tif');
disp('Please select the endosome tracking file(.csv)');
[endoFile, endoPath] = uigetfile('*.csv');
disp('Please select the lysosome tracking file(.csv)');
[lysoFile, lysoPath] = uigetfile('*.csv');

% Save each frame of endosome movie into variable endoImage cell
endoImage = GenerateImageCell(endoImagePath,endoImageFile);

% Save each frame of endosome movie into variable endoImage cell
lysoImage = GenerateImageCell(lysoImagePath,lysoImageFile);

% parse the tracking file into desired input format
endoInput = ReadIn(strcat(endoPath,endoFile));
lysoInput = ReadIn(strcat(lysoPath,lysoFile));

% decide a target range for valid data
figure;
imshow(lysoImage{1,1});
h = drawpolygon;
prompt = 'Do you want inside or outside? 1 for inside and 0 for outside';
in = input(prompt);
endoInput = PolygonScreen(h,endoInput,pixel,in);
lysoInput = PolygonScreen(h,lysoInput,pixel,in);

% create a new format of data sorted into cells according to frame number
endosome = SplitFrame(endoInput,frameNum);
lysosome = SplitFrame(lysoInput,frameNum);


%Generate NearestNeighbor ID pair using KNN search
IDX = cell(frameNum,1);
d = cell(frameNum,1); % distance
pair = cell(frameNum,1);
pairID = cell(frameNum,1);
for frame = 1:frameNum
    [IDX{frame,1},d{frame,1}] = knnsearch(endosome{frame,1}(:,3:4),lysosome{frame,1}(:,3:4)); % Idx = knnsearch(X,Y) finds the nearest neighbor in X for each query point in Y and returns the indices of the nearest neighbors in Idx, a column vector. Idx has the same number of rows as Y.
    pair{frame,1} = zeros(length(IDX{frame,1}),2);
    for pairi = 1:length(IDX{frame,1})
        pair{frame,1}(pairi,:) = [IDX{frame,1}(pairi) pairi];
    end
    if ~isnan(pair{frame,1})
        pairID{frame,1}(:,1) = endosome{frame,1}(pair{frame,1}(:,1),1);
        pairID{frame,1}(:,2) = lysosome{frame,1}(pair{frame,1}(:,2),1);
        %pairID{frame,1}(D{frame,1}>(pairDis/pixel),:) = [];
        pairID{frame,1}(d{frame,1}>(pairDis),:) = [];
    end
end

%if pairID is empty
m = 0;
for i = 1:length(pairID)
    if isempty(pairID{i,1})
        m = m+1;
    end
end
if m == i
    error('No interaction')
end


for pairIDi = 1:size(pairID,1)
    pairID{pairIDi,1}(:,3) = pairIDi-1;
end

%[endoID lysoID frame]
pairIdSorted = [];
for pairIDsortedi = 1:size(pairID,1)
    pairIdSorted = [pairIdSorted;pairID{pairIDsortedi,1}];
end
pairIdSorted = sortrows(pairIdSorted);

% save generated data into cells
pairIdInCell = {};
pairIdInCell{1,1}(1,:) = pairIdSorted(1,1:3);
m = 1;
n = 1;
for i = 2:size(pairIdSorted,1)
    if pairIdSorted(i,1) == pairIdSorted(i-1,1) && pairIdSorted(i,2) == pairIdSorted(i-1,2)
       pairIdInCell{n,1}(m+1,:) = pairIdSorted(i,1:3);
       m = m+1;
   else
       n = n+1;
       m = 1;
       pairIdInCell{n,1}(m,:) = pairIdSorted(i,1:3);
   end
end

idxDiff = cell(length(pairIdInCell),1);
for i = 1:length(pairIdInCell)
    if length(pairIdInCell{i,1})>3
        idxDiff{i,1} = diff(pairIdInCell{i,1});
    end
end

% final data representation
pairFinalCell = {};
pairFinal = [];
n = 1;
for i = 1:length(pairIdInCell)
    m = 0;
    for j = 1:size(idxDiff{i,1},1)
        if idxDiff{i,1}(j,3) == 1
            m = m+1;
        else
            if m > successiveThresh/interval
                pairFinal = [pairFinal;pairIdInCell{i,1}(j-m:j,:)];
                pairFinalCell{n,1} = pairIdInCell{i,1}(j-m:j,:);
                n = n+1;
            end
            m = 0;
        end
        if m == size(idxDiff{i,1},1) && m~=0
            pairFinal = [pairFinal;pairIdInCell{i,1}];
            pairFinalCell{n,1} = pairIdInCell{i,1};
            n = n+1;
        end
    end
end   

% Output ID pairs with frame annotation
finalOutputInCell = pairFinalCell;
for i = 1:size(pairFinalCell,1)
    finalOutputInCell{i,1}(:,[4 7]) = pairFinalCell{i,1}(:,[2 3]);
    for j = 1:size(finalOutputInCell{i,1},1)
        endomediate = endoInput(endoInput(:,1)==pairFinalCell{i,1}(j,1),:);
        finalOutputInCell{i,1}(j,[2 3]) = endomediate(endomediate(:,2)==pairFinalCell{i,1}(j,3),[3 4]);
        lysomediate = lysoInput(lysoInput(:,1)==pairFinalCell{i,1}(j,2),:);
        finalOutputInCell{i,1}(j,[5 6]) = lysomediate(lysomediate(:,2)==pairFinalCell{i,1}(j,3),[3 4]);
    end
end

finalOutputInArray = [];
for i = 1:size(finalOutputInCell,1)
    finalOutputInArray = [finalOutputInArray;finalOutputInCell{i,1}];
end

% make new folder for saving results
newFolder = endoFile(1:end-4);
mkdir(newFolder);

% save the statistics of duration of interaction events
duration = tabulate(finalOutputInArray(:,[3 4]));
pairNum = size(duration,1);
duration(duration(:,2)==0,:) = [];
figure;
histogram(duration(:,2)*interval);
title('duration/s');
saveas(gcf,strcat(newFolder,'\',endoFile(1:end-4),'duration'),'fig')

% save the percentage of interaction time over the whole life span
lysoSum = tabulate(lysoInput(:,1));
lysoSum(lysoSum(:,2)==0,:) = [];
ratio = zeros(size(duration,1),1);
for stati = 1:size(duration)
    ratio(stati,1) = duration(stati,2)/lysoSum(lysoSum(:,1)==duration(stati,1),2);
end
figure;
histogram(ratio);
title('ratio')
saveas(gcf,strcat(newFolder,'\',endoFile(1:end-4),'interaction time / life span'),'fig')

% plot interaction trajectory
figure;
RGBx = endoImage{1,1};
imshow(RGBx);
hold on
dislyso = [];
for ploti = 1:size(finalOutputInCell,1)
    plot(finalOutputInCell{ploti,1}(:,5)/pixel,finalOutputInCell{ploti,1}(:,6)/pixel,trajectoryColor,'LineWidth',2);
%    text(x(1,1),y(1,1),num2str(plottracksi),'color','w');
    hold on
end
title('interaction trajectory')
saveas(gcf,strcat(newFolder,'\',endoFile(1:end-4),'interactiontrajectory'),'fig')


% write video
RGB = cell(length(endoImage),1);
for i = 1:length(endoImage)
    RGB{i,1}(:,:,2) = endoImage{i,1};
    RGB{i,1}(:,:,1) = lysoimage{i,1};
    RGB{i,1}(:,:,3) = 0;
end
video_endolyso = sortrows(finalOutputInArray,7);
for framei = 1:length(RGB)
    mediate = finalOutputInArray(finalOutputInArray(:,7) == framei-1,:);
    for framej = 1:size(mediate,1)
        %endoimage{framei,1} = insertMarker(endoimage{framei,1},mediate(framej,[2 3]),'o','color','white','size',10);
        %lysoimage{framei,1} = insertMarker(lysoimage{framei,1},mediate(framej,[5 6]),'s','color','magenta','size',10);
        RGB{framei,1} = insertMarker(RGB{framei,1},mediate(framej,[2 3])/pixel,'o','color','white','size',5);
        RGB{framei,1} = insertMarker(RGB{framei,1},mediate(framej,[5 6])/pixel,'s','color','magenta','size',5);
    end
end

VideoMaker(strcat(newFolder,'\',lysoFile(1:end-4)),FPS,frameNum,RGB);
m = 1;
finalOutputInArray(1,8) = m;
for i = 2:size(finalOutputInArray,1)
    if finalOutputInArray(i,1)==finalOutputInArray(i-1,1)&&finalOutputInArray(i,4)==finalOutputInArray(i-1,4)
        finalOutputInArray(i,8) = m;
    else
        m = m+1;
        finalOutputInArray(i,8) = m;
    end
end
save(strcat(newFolder,'\',lysoFile(1:end-4),'PairStatistics.mat'),'finalOutputInArray')

% save all the results into file
x = tabulate(finalOutputInArray(:,8));
y = finalOutputInArray(1,[1 4 7 8]);
for i = 2:size(finalOutputInArray,1)
    if finalOutputInArray(i,8) ~= finalOutputInArray(i-1,8)
    y = [y;finalOutputInArray(i,[1 4 7 8])];
    end
end
x(:,3) = y(y(:,4)==x(:,1),1);
x(:,4) = y(y(:,4)==x(:,1),2);
x(:,5) = y(y(:,4)==x(:,1),3);
for stati = 1:size(x)
    x(stati,6) = lysoSum(lysoSum(:,1)==x(stati,4),2);
end

xlsname = strcat(newFolder,'\',lysoFile(1:end-4),'ratioStatistics.xls');
xlswrite(xlsname,x,strcat('A2:F',num2str(size(x,1))))
title = {'interaction frame number','endoID','lysoID','interaction initial frame','total frame number of lyso'};
xlswrite(xlsname,title,'B1:F1');