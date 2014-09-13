utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);

imaqreset;
hwInfo = imaqhwinfo('kinect');

depthVid = videoinput('kinect',2);

triggerconfig(depthVid,'manual');
set(depthVid, 'FramesPerTrigger', 1);
set(depthVid,'TriggerRepeat', Inf);

colorVid = videoinput('kinect',1);

triggerconfig(colorVid,'manual');
set(colorVid, 'FramesPerTrigger', 1);
set(colorVid,'TriggerRepeat', Inf);

t0 = tic;

start(depthVid);
start(colorVid);

while(1)
    trigger(depthVid);
    [imd, depthTimeData, depthMetaData] = getdata(depthVid);
    trigger(colorVid);
    [imc, colorTimeData, colorMetaData] = getdata(colorVid);
    
    subplot(2,2,1)
    imshow(imc,[]);
    
    subplot(2,2,2)
    imshow(imd,[]);
    
    thresh = logical(imd~=0 & imd<1000);
    thresh2 = bwareaopen(thresh,600);
    cc = bwconncomp(thresh2);
    centroid_struct = regionprops(cc,'Centroid');
    c = cat(1, centroid_struct.Centroid);
    
    subplot(2,2,3)
    imc(:,:,1) = imc(:,:,1).*uint8(thresh2);
    imc(:,:,2) = imc(:,:,2).*uint8(thresh2);
    imc(:,:,3) = imc(:,:,3).*uint8(thresh2);
    imshow(imc,[]);
    if isempty(c) ~= 1
        hold on;
        plot(c(:,1), c(:,2), 'r*');
        hold off
    end
    
    subplot(2,2,4)
    imshow(thresh2,[]);
    if isempty(c) ~= 1
        hold on;
        plot(c(:,1), c(:,2), 'r*');
        hold off
    end
    
end

stop(depthVid);
stop(colorVid);