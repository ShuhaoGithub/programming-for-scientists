% PolygonScreen takes polygon coordinates, organelle track data, pixel as
% input and returns screened data which meets the input demand.
function [newInput] = PolygonScreen(h,organelleInput,pixel,in)

inPoly = organelleInput;
inPoly(:,5) = inpolygon(organelleInput(:,3),organelleInput(:,4),h.Position(:,1)*pixel,h.Position(:,2)*pixel);

organelleStructure = cell(inPoly(end,1)+1,1);
for i = 0:inPoly(end,1)
    organelleStructure{i+1,1} = inPoly(inPoly(:,1)==i,:);
end
switch in
    % if want data in polygon
    case 1
        for i = 1:size(organelleStructure,1)
            if sum(organelleStructure{i,1}(:,5))~=size(organelleStructure{i,1},1)
                organelleStructure{i,1} = [];
            end
        end
    % if want data outside polygon
    case 0
        for i = 1:size(organelleStructure,1)
            if sum(organelleStructure{i,1}(:,5))~=0
                organelleStructure{i,1} = [];
            end
        end
end
% save the screened data into newInput
newInput = [];
for i = 1:size(organelleStructure,1)
    newInput = [newInput;organelleStructure{i,1}];
end
end