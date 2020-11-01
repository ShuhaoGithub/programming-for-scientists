% GenerateImageCell take the path and name of image file and save the image
% data into a cell
function orgImage = GenerateImageCell(path,file)
    imgName = strcat(path,file);
    frameNum = size(imfinfo(imgName),1);
    orgImage = cell(frameNum,1);
    for i = 1:frameNum
        orgImage{i,1} = imread(imgName,i);
        orgImage{i,1} = imadjust(orgImage{i,1});
    end
end