clear all;
close all;

% Variables to set the pins to which the motor driver is connected 
% conveniently %
LEFT_DIR = 48;
RIGHT_DIR = 47;
RIGHT_EN = 3;
LEFT_EN = 4;
RIGHT_BR = 36;
LEFT_BR = 38;

% Connect to the board %
a=arduino('COM15');

% Specify digital pins' mode %
a.pinMode(LEFT_DIR,'output')
a.pinMode(RIGHT_DIR,'output')

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

trigger(colorVid);
[imc, colorTimeData, colorMetaData] = getdata(colorVid);

division = zeros(480,2);
division(:,1) = 640/3;
division(:,2) = 1:480;

division2 = zeros(480,2);
division2(:,1) = 2*640/3;
division2(:,2) = 1:480;

timer1 = tic;

while toc(timer1)<7
    trigger(depthVid);
    [imd, depthTimeData, depthMetaData] = getdata(depthVid);
    trigger(colorVid);
    [imc, colorTimeData, colorMetaData] = getdata(colorVid);
    
    subplot(2,2,1)
    imshow(imc,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    hold off
    
    subplot(2,2,2)
    imshow(imd,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    hold off
    
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
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    if isempty(c) ~= 1
        plot(c(:,1), c(:,2), 'r*');
    end
    hold off;
    
    subplot(2,2,4)
    imshow(thresh2,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    if isempty(c) ~= 1
        plot(c(:,1), c(:,2), 'r*');
    end
    hold off;
    
    left = sum(logical(c<640/3));
    left = left(1,1);
    
    mid = sum(logical(c>640/3 & c<2*640/3));
    mid = mid(1,1);
    
    right = sum(logical(c>2*640/3));
    right = right(1,1);
    
    SPEED = 130;
    
    if right>mid
        if right>left
            %turn right
            x = 0.4;
            move_right(x, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED);
        else
            %turn left
            x = 0.4;
            move_left(x, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED);
        end
    else
        if mid>left
            %go straight
            x = 0.1;
            move_fwd(x, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED);
        else
            %turn left
            x = 0.4;
            move_left(x, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED);
        end
    end
end

 stop(depthVid);
 stop(colorVid);
 SPEED = 0;
 move_fwd(x, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED);