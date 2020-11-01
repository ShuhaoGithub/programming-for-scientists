% SplitFrame takes tracking data and frame number as input and returns data
% sorted according to frame number
function organelle = SplitFrame(input,frameNum)
organelle = cell(frameNum,1);
for i = 1:frameNum
organelle{i,1} = input(input(:,2)==i-1,:);
organelle{i,1}(:,2) = organelle{i,1}(:,2);
end
end