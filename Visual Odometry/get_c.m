utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);

imaqreset;

% create a video input object to handle the stream from the Kinect's
% depth camera, and set appropriate parameters, so that
% an image is obtained on manual trigger %
depthVid = videoinput('kinect',2);
triggerconfig(depthVid,'manual');
set(depthVid, 'FramesPerTrigger', 1);
set(depthVid,'TriggerRepeat', Inf);

% create a video input object to handle the stream from the Kinect's
% colour camera, and set appropriate parameters, so that
% an image is obtained on manual trigger %
colorVid = videoinput('kinect',1);
triggerconfig(colorVid,'manual');
set(colorVid, 'FramesPerTrigger', 1);
set(colorVid,'TriggerRepeat', Inf);

start(depthVid);
start(colorVid);

num = input('Enter number of iterations:  ');
c_tot = 0;
for i = 1:num
    theta = input('Enter theta value:  ');
    
    disp('Kinect ready. Press any key to capture first set of images...');
    waitforbuttonpress;
    trigger(depthVid);
    [imd1, ~, ~] = getdata(depthVid);
    trigger(colorVid);
    [imc1, ~, ~] = getdata(colorVid);
    
    disp('Kinect ready. Press any key to capture second set of images...');
    waitforbuttonpress;
    trigger(depthVid);
    [imd2, ~, ~] = getdata(depthVid);
    trigger(colorVid);
    [imc2, ~, ~] = getdata(colorVid);
    
    c_tot = c_tot + calibrate_odometry(imc1, imc2, imd1, imd2, theta);
end
disp(c_tot/num);

stop(depthVid);
stop(colorVid);