% Distance2Freehand takes the freehand object coordinates and a point as
% input and returns the distance and nucleus coordinates.
function [dist,nuCoord] = Distance2Freehand(free,point)

free(:,3:4) = [free(:,1)-point(1),free(:,2)-point(2)];
free(:,5) = sqrt(power(free(:,3),2)+power(free(:,4),2));
[dist,index] = min(free(:,5));
nuCoord = free(index,1:2);
end
