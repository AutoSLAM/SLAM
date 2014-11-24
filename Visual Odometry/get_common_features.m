%Configuring the Kinect device with Matlab to get the Device ID
utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);

imaqreset;%Image aquisition adapters reset

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

%   Wait until the button press and then capture first set of colour and depth image
disp('Kinect ready. Press any key or click on figure window to capture first image...');
waitforbuttonpress;
trigger(depthVid);
[imd1, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc1, ~, ~] = getdata(colorVid);

%   Wait until the button press and then capture second set of colour and depth image
disp('Kinect ready. Press any key or clikc on figure window to capture second image...');
waitforbuttonpress;
trigger(depthVid);
[imd2, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc2, ~, ~] = getdata(colorVid);

stop(depthVid);
stop(colorVid);

% Call SURFMatch function, where the image matching and corresponding
% display of matched features takes place
SURFMatch(imc1, imc2);