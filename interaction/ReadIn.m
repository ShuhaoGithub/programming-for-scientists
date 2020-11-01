% ReadIn takes file as input and parses data into desired input format
% saved into coords
function coords = ReadIn(file)
spots = xlsread(file);
% clear trash data
spots(isnan(spots(:,2)),:) = [];
spots = sortrows(spots,2);
coords = spots(:,[2 8 4 5]);
end