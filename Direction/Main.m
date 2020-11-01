% This program is designed by Shuhao Zhang in 2020/10.
% Illustrate the direction of movement in WT and KO cell.
% To run this program, simply fill the imageName with 'WT.jpg' or 'KO.jpg'.

close all; clearvars;

pixel = 0.11;
imageName = 'WT.jpg';

disp('Please select the tracking file(.csv)');
[file, path] = uigetfile('*.csv');
fileName = strcat(path,file);
spots = csvread(file,1,1);
data = spots(:,[2 8 4 5]);

% if see nucleus as a single point, use the following code
% firstframe = data(data(:,2)==0,:);
% prompt = 'Please indicate your nucleus x coordinates:(um)';
% nucleusx = input(prompt);
% prompt = 'Please indicate your nucleus y coordinates:(um)';
% nucleusy = input(prompt);
% distance = [];
% distance(:,1) = firstframe(:,3) - nucleusx;
% distance(:,2) = firstframe(:,4) - nucleusy;
% distance(:,3) = sqrt(power(distance(:,1),2)+power(distance(:,2),2));
% distanceNorm = distance(:,3)/max(distance(:,3));

figure;
imshow(imageName);
disp('Please draw nucleus');
h = drawfreehand;
nucleus = h.Position;

tracks = cell(data(end,1)+1,1);
displacement = -ones(length(tracks),2);
for i = 1:data(end,1)+1
    if size(data(data(:,1)==i-1,:),1)>5
        tracks{i,1} = data(data(:,1)==i-1,:);
    end
end

for i = 1:length(tracks)
    if ~isempty(tracks{i,1})
        medi = tracks{i,1};
        xv = pixel*nucleus(:,1);
        yv = pixel*nucleus(:,2);
        xq = medi(:,3);
        yq = medi(:,4);
        in = inpolygon(xq,yq,xv,yv);
        if ~ismember(1,in)
            dis = 0;
            for disi = 1:size(tracks{i,1},1)-1
                dis = dis + sqrt(power(medi(disi+1,3)-medi(disi,3),2)+power(medi(disi+1,4)-medi(disi,4),2));
            end
            displacement(i,1) = i-1;
            displacement(i,2) = dis;% displacement
            [dist,nucleusCoordinate] = Distance2Freehand(pixel*nucleus,medi(end,3:4));% to nucleus distance
            displacement(i,3) = dist;
            displacement(i,4:5) = nucleusCoordinate;
            displacement(i,6) = Angle([xq(1),yq(1)],[xq(end),yq(end)],nucleusCoordinate);%1 if outwards,-1 if inwards, 0 if periphery
        else
            tracks{i,1} = [];
        end
    end
end
distanceNorm = displacement(:,2)/max(displacement(:,2));

figure
imshow(imageName);
hold on
angleSet = [];
for ploti = 1:length(tracks)
    if ~isempty(tracks{ploti})%&displacement(ploti,2)>30
    particleTrack = tracks{ploti};
    x = particleTrack(:,3)/pixel;
    y = particleTrack(:,4)/pixel;
        if sqrt(power(x(1)-x(end),2)+power(y(1)-y(end),2)) > 100
            plot(x,y,'y')
            plot([x(1),x(end)],[y(1),y(end)],'b');
            plot(x(1),y(1),'w+');
            text(x(1),y(1),num2str(displacement(ploti,6)),'color','w','FontSize',5)
            angleSet = [angleSet;displacement(ploti,6)];
            hold on
        end
    end
end
title('Direction of movement in cell')
saveas(gcf,strcat(path,'\','DirectionOfMovementCell'),'fig')

f = ksdensity(angleSet,0:5:180);
figure;
h = plot(0:5:180,f);

title('Direction of movement')
saveas(gcf,strcat(path,'\','DirectionOfMovement'),'fig')