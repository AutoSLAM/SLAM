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
    
    THRESHHOLD = 1000;
    % Connect to the board, if it hasn't already been %
    %if ~exist('a','var')
    a=arduino('COM15');
    %end
    
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
end

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

while toc(timer1)<30
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
    
    thresh = logical(imd~=0 & imd<THRESHHOLD);
    thresh2 = bwareaopen(thresh,1600);
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
    
    SPEED_TURN = 35;
    SPEED_FWD = 35;
    
    TIME_FWD = 0.1;
    TIME_TURN = 0.075;
    
    %     if right>mid
    %         if right>left
    %             %turn right
    %             move_right(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
    %         else
    %             %turn left
    %             move_left(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
    %         end
    %     else
    %         if mid>=left
    %             %go straight
    %             move_fwd(TIME_FWD, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);
    %         else
    %             %turn left
    %             move_left(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
    %         end
    %     end
    %
    %     if left>mid && left>right
    %         %turn left
    %         move_left(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
    %     elseif right>mid && right>left
    %         %turn right
    %         move_right(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
    %     else
    %         %go straight
    %         move_fwd(TIME_FWD, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);
    %     end
    
    % TODO: Account for size of object, distance of object, divide screen
    % into more parts
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

stop(depthVid);
stop(colorVid);
SPEED_FWD = 0;
move_fwd(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);