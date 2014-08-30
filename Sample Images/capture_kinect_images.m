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

i=15;
while(1)
    trigger(depthVid);
    [imd, depthTimeData, depthMetaData] = getdata(depthVid);
    trigger(colorVid);
    [imc, colorTimeData, colorMetaData] = getdata(colorVid);
    
    subplot(1,2,1)
    imshow(imd,[]);
    
    subplot(1,2,2)
    imshow(imc,[]);
    if toc(t0) > 10.0
        
        t0 = tic;
        imwrite(imc,['color' num2str(i) '.jpg']);
        save(['depth' num2str(i)],'imd');
        i = i+1;
    end
end

stop(depthVid);
stop(colorVid);