% Variables to set the pins to which the motor driver is connected 
% conveniently %
LEFT_FRONT = 23;
LEFT_REAR = 43;
RIGHT_FRONT = 22;
RIGHT_REAR = 42;
RIGHT_PWM = 6;
LEFT_PWM = 7;

% Connect to the board %
a=arduino('COM3');

% Specify digital pins' mode %
a.pinMode(RIGHT_FRONT,'output')
a.pinMode(RIGHT_REAR,'output')
a.pinMode(LEFT_FRONT,'output')
a.pinMode(LEFT_REAR,'output')

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

while(1)
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
    thresh2 = bwareaopen(thresh,60);
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
    
    if right>mid
        if right>left
            %turn right
            SPEED = 155;
            x = 0.1;
            move_right( x, a, RIGHT_FRONT, RIGHT_REAR, LEFT_FRONT, LEFT_REAR, RIGHT_EN, LEFT_EN, SPEED );
        else
            %turn left
            SPEED = 155;
            x = 0.1;
            move_left( x, a, RIGHT_FRONT, RIGHT_REAR, LEFT_FRONT, LEFT_REAR, RIGHT_EN, LEFT_EN, SPEED );
        end
    else
        if mid>left
            %go straight
            SPEED = 155;
            x = 0.1;
            move_fwd( x, a, RIGHT_FRONT, RIGHT_REAR, LEFT_FRONT, LEFT_REAR, RIGHT_EN, LEFT_EN, SPEED );
        else
            %turn left
            SPEED = 155;
            x = 0.1;
            move_left( x, a, RIGHT_FRONT, RIGHT_REAR, LEFT_FRONT, LEFT_REAR, RIGHT_EN, LEFT_EN, SPEED );
        end
    end
end

% stop(depthVid);
% stop(colorVid);