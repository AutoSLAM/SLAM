% Set this to 1 to reconnect to Arduino, Kinect, etc. %
cleanMode = 0;

if cleanMode || ~exist('a','var') || ~exist('depthVid','var')
    clear all;
    close all;
        
    % Variables to set the pins to which the motor driver is connected
    % conveniently %
    LEFT_DIR = 46;
    RIGHT_DIR = 47;
    RIGHT_EN = 3;
    LEFT_EN = 4;
    RIGHT_BR = 36;
    LEFT_BR = 38;
    
    % Maximum Distance beyond which objects are ignored %
    THRESHHOLD = 1000;
    
    % Connect to the arduino board %
    a=arduino('COM15');
    
    % Specify digital pins' mode %
    a.pinMode(LEFT_DIR,'output')
    a.pinMode(RIGHT_DIR,'output')
    
    % Add path
    utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
        'html', 'KinectForWindows');
    addpath(utilpath);
    
    imaqreset;
    
    % hwInfo = imaqhwinfo('kinect');
    
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
end

t0 = tic;

% start the video input %
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

% Run for 30 seconds %
while toc(timer1)<30
    
    % Acquire images from kinect %
    trigger(depthVid);
    [imd, depthTimeData, depthMetaData] = getdata(depthVid);
    trigger(colorVid);
    [imc, colorTimeData, colorMetaData] = getdata(colorVid);
    
    % Show colour image, divided into 3 parts %
    subplot(2,2,1)
    imshow(imc,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    hold off

    % Show depth image, divided into 3 parts %
    subplot(2,2,2)
    imshow(imd,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    hold off
    
    % Threshold the image, so that all objects at a ditance > THRESHHOLD
    % away are ignored %
    thresh = logical(imd~=0 & imd<THRESHHOLD);
    % Remove noise, ie.e, components with total connected area less than
    % the specified value %
    thresh2 = bwareaopen(thresh,1600);
    % Get the connected components of the de-noised, threshholded image %
    cc = bwconncomp(thresh2);
    % Get the centroids of the connected components %
    centroid_struct = regionprops(cc,'Centroid');
    c = cat(1, centroid_struct.Centroid);
    
    % Show the colour image of the region that the bot detects 
    % as an obstacle, and plot the centroids on this image %
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
    
    % Show a black and white image of the region that the bot detects 
    % as an obstacle, and plot the centroids on this image %
    subplot(2,2,4)
    imshow(thresh2,[]);
    hold on;
    plot(division(:,1), division(:,2), 'r.');
    plot(division2(:,1), division2(:,2), 'r.');
    if isempty(c) ~= 1
        plot(c(:,1), c(:,2), 'r*');
    end
    hold off;
    
    % Centroids in left part of screen (i.e., on bot's right side, due to
    % lateral inversion %
    left = sum(logical(c<640/3));
    left = left(1,1);
    
    % Centroids in center of screen %
    mid = sum(logical(c>640/3 & c<2*640/3));
    mid = mid(1,1);
    
    % Centroids in right part of screen (i.e., on bot's left side, due to
    % lateral inversion %
    right = sum(logical(c>2*640/3));
    right = right(1,1);
    
    % Speed at which bot must move/turn %
    SPEED_TURN = 35;
    SPEED_FWD = 35;
    
    % Duration for which bot must move/turn %
    TIME_FWD = 0.1;
    TIME_TURN = 0.075;
    
    if mid<=right && mid<=left
        %go straight
        move_fwd(TIME_FWD, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);
        disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
    elseif right<=mid && right<=left
        %Ironically, if the right side of the image has the least
        %number of points, turn left. This is due to lateral
        %inversion.
        move_left(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
        disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
    else
        %turn right
        move_right(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
        disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
    end
    
end

% Stop the video input when done %
stop(depthVid);
stop(colorVid);

% Stop the bot %
SPEED_FWD = 0;
move_fwd(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);