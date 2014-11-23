close all;
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

origin = [0 0 pi/2];
origin=plot_robot(0,0,origin);

x=tic;
trigger(depthVid);
[imd2, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc2, ~, ~] = getdata(colorVid);

while(true)
    if toc(x)>1
        trigger(depthVid);
        imd1=imd2;
        imc1=imc2;
        trigger(depthVid);
        [imd2, ~, ~] = getdata(depthVid);
        trigger(colorVid);
        [imc2, ~, ~] = getdata(colorVid);
        deltheta = do_rotation(imc1,imc2,imd1,imd2)
        deltheta=deltheta*pi/180;
        if(deltheta==0)
            deltax = do_translation(imc1,imc2,imd1,imd2);
            origin = plot_robot(double(deltax),0,origin);
        else
            deltax=0;
            origin = plot_robot(0,double(deltheta),origin);
            y = tic;
            while toc(y) < 0.2
                imd1 = imd2;
                imc1 = imc2;
                trigger(depthVid);
                [imd2, ~, ~] = getdata(depthVid);
                trigger(colorVid);
                [imc2, ~, ~] = getdata(colorVid);
            end
        end
        deltax
        x=tic;
    end
end