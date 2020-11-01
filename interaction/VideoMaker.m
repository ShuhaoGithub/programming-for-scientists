% VideoMaker takes the name of image, FPS, number of frames and RGB images
% as input and write to a new video
function [] = VideoMaker(imageName,FPS,frameNum,RGB)

videoName = strcat(char(imageName),'.tif');
aviobj = VideoWriter(videoName);
aviobj.FrameRate = FPS;
open(aviobj);
for i = 1:frameNum
    frames = RGB{i,1};
    writeVideo(aviobj,im2uint8(frames));
end
close(aviobj);
end