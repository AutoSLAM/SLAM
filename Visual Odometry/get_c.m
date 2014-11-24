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

%Experiment conducted to calculate the proportionality constant c
%Equation l=c*r*(theta)
%"num" is the number of iterations for which the constant c is to be calculated when the %theta value is preset
%The rotational angle is preset in each iteration and the bot is correspondingly
%moved with the same value which is used to determine the value of c
num = input('Enter number of iterations:  ');
c_tot = 0;
for i = 1:num
    theta = input('Enter theta value:  ');
    
    %   Wait until the button press and then capture first set of colour and depth image
    disp('Kinect ready. Press any key to capture first set of images...');
    waitforbuttonpress;
    trigger(depthVid);
    [imd1, ~, ~] = getdata(depthVid);
    trigger(colorVid);
    [imc1, ~, ~] = getdata(colorVid);
    
    %   Wait until the button press and then capture second set of colour and depth image
    disp('Kinect ready. Press any key to capture second set of images...');
    waitforbuttonpress;
    trigger(depthVid);
    [imd2, ~, ~] = getdata(depthVid);
    trigger(colorVid);
    [imc2, ~, ~] = getdata(colorVid);
    
    %   Add up the proportionality constants obtained after each iteration with the angle of rotation is known
    c_tot = c_tot + calibrate_odometry(imc1, imc2, imd1, imd2, theta);
end

% Averaging the proportionality constants over the number of iterations
disp(c_tot/num);

stop(depthVid);
stop(colorVid);