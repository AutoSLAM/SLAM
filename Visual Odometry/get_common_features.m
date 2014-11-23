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

disp('Kinect ready. Press any key or click on figure window to capture first image...');
waitforbuttonpress;
trigger(depthVid);
[imd1, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc1, ~, ~] = getdata(colorVid);

disp('Kinect ready. Press any key or clikc on figure window to capture second image...');
waitforbuttonpress;
trigger(depthVid);
[imd2, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc2, ~, ~] = getdata(colorVid);

stop(depthVid);
stop(colorVid);

SURFMatch(imc1, imc2);