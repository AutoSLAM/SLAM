% Set this to 1 to reconnect to Arduino, Kinect, etc. %
cleanMode = 0;
withArduino = false;
close all;

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
    DEPTH_THRESHHOLD = 1200;
    withArduino = false
    if withArduino
        % Connect to the arduino board %
        a=arduino('COM19');
        
        % Specify digital pins' mode %
        a.pinMode(LEFT_DIR,'output')
        a.pinMode(RIGHT_DIR,'output')
    end
    
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
    
    % constant, obtained by calibration
    c = -0.004175;
end

t0 = tic;

% start the video input %
start(depthVid);
start(colorVid);

division = zeros(480,2);
division(:,1) = 640/3;
division(:,2) = 1:480;

division2 = zeros(480,2);
division2(:,1) = 2*640/3;
division2(:,2) = 1:480;

origin = [0 0 pi/2];
origin=plot_robot(0,0,origin);

trigger(depthVid);
[imd2, ~, ~] = getdata(depthVid);
trigger(colorVid);
[imc2, ~, ~] = getdata(colorVid);

% http://www.mathworks.in/help/vision/examples/sparse-3-d-reconstruction-from-two-views.html?prodcode=VP&language=en
% Use SURF to detect feature points
imPts2 = detectSURFFeatures(rgb2gray(imc2));

% Extract feature descriptors
[features2, valid2] = extractFeatures(rgb2gray(imc2), imPts2);

is_obj_plotted = false;

x=tic;
timer1 = tic;
timer2 = tic;

% Run for 60 seconds %
while toc(timer1)<60
    % Either an Arduino is present, or 3 seconds have elapsed from the last
    % time
    if withArduino || toc(timer2) > 3
        timer2 = tic;
        % Acquire images from kinect %
        imd1=imd2;
        imc1=imc2;
        
        trigger(depthVid);
        [imd2, depthTimeData, depthMetaData] = getdata(depthVid);
        trigger(colorVid);
        [imc2, colorTimeData, colorMetaData] = getdata(colorVid);
        
        %     % Show colour image, divided into 3 parts %
        %     subplot(2,2,1)
        %     imshow(imc2,[]);
        %     hold on;
        %     plot(division(:,1), division(:,2), 'r.');
        %     plot(division2(:,1), division2(:,2), 'r.');
        %     hold off
        %
        %     % Show depth image, divided into 3 parts %
        %     subplot(2,2,2)
        %     imshow(imd2,[]);
        %     hold on;
        %     plot(division(:,1), division(:,2), 'r.');
        %     plot(division2(:,1), division2(:,2), 'r.');
        %     hold off
        
        % http://www.mathworks.in/help/vision/examples/sparse-3-d-reconstruction-from-two-views.html?prodcode=VP&language=en
        % Use SURF to detect feature points
        imPts1 = imPts2;
        imPts2 = detectSURFFeatures(rgb2gray(imc2));
        
        % Extract feature descriptors
        features1 = features2;
        valid1 = valid2;
        [features2, valid2] = extractFeatures(rgb2gray(imc2), imPts2);
        
        % Extract index pairs corresponding to matching features
        indexPairs = matchFeatures(features1, features2);
        
        % Extract matching features
        matchedPoints1 = valid1(indexPairs(:, 1));
        %matchedPoints1 = matchedPoints1(Ida(matchedPoints1) > 0);
        matchedPoints2 = valid2(indexPairs(:, 2));
        
        
        % Threshold the image, so that all objects at a ditance > THRESHHOLD
        % away are ignored %
        thresh = logical(imd2~=0 & imd2<DEPTH_THRESHHOLD);
        % Remove noise, ie.e, components with total connected area less than
        % the specified value %
        thresh2 = bwareaopen(thresh,1600);
        % Get the connected components of the de-noised, threshholded image %
        cc = bwconncomp(thresh2);
        % Get the centroids of the connected components %
        centroid_struct = regionprops(cc,'Centroid');
        c1 = cat(1, centroid_struct.Centroid);
        % Label the connected components
        lb = bwlabel(thresh2);
        
        % No. of connected components
        cc_num = max(max(lb));
        
        surf_count = zeros(cc_num,1);
        
        figure(2)
        imshow(thresh2,[])
        hold on
        for i=1:size(matchedPoints1.Location,1)
            % for each matched point whose depth data is not zero
            if lb(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0
                surf_count(lb(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))) = surf_count(lb(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))) + 1;
                plot(uint16(matchedPoints1.Location(i,1)),uint16(matchedPoints1.Location(i,2)),'r*')
            end
        end
        hold off
        figure(1)
        
        %     % Show the colour image of the region that the bot detects
        %     % as an obstacle, and plot the centroids on this image %
        %     subplot(2,2,3)
        %     imc2(:,:,1) = imc2(:,:,1).*uint8(thresh2);
        %     imc2(:,:,2) = imc2(:,:,2).*uint8(thresh2);
        %     imc2(:,:,3) = imc2(:,:,3).*uint8(thresh2);
        %     imshow(imc2,[]);
        %     hold on;
        %     plot(division(:,1), division(:,2), 'r.');
        %     plot(division2(:,1), division2(:,2), 'r.');
        %     if isempty(c1) ~= 1
        %         plot(c1(:,1), c1(:,2), 'r*');
        %     end
        %     hold off;
        %
        %     % Show a black and white image of the region that the bot detects
        %     % as an obstacle, and plot the centroids on this image %
        %     subplot(2,2,4)
        %     imshow(thresh2,[]);
        %     hold on;
        %     plot(division(:,1), division(:,2), 'r.');
        %     plot(division2(:,1), division2(:,2), 'r.');
        %     if isempty(c1) ~= 1
        %         plot(c1(:,1), c1(:,2), 'r*');
        %     end
        %     hold off;
        
        % Centroids in left part of screen (i.e., on bot's right side, due to
        % lateral inversion %
        left = sum(logical(c1<640/3));
        left = left(1,1);
        
        % Centroids in center of screen %
        mid = sum(logical(c1>640/3 & c1<2*640/3));
        mid = mid(1,1);
        
        % Centroids in right part of screen (i.e., on bot's left side, due to
        % lateral inversion %
        right = sum(logical(c1>2*640/3));
        right = right(1,1);
        
        % Speed at which bot must move/turn %
        SPEED_TURN = 32;
        SPEED_FWD = 17;
        
        % Duration for which bot must move/turn %
        TIME_FWD = 0.1;
        TIME_TURN = 0.005;
        
        
        if withArduino
            if mid<=right && mid<=left
                %go straight
                move_fwd(TIME_FWD, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);
                disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
                % if there is no rotation, then calculate translation amount
                deltax = do_translation(imc1,imc2,imd1,imd2);
                % plot translation
                origin = plot_robot(double(deltax),0,origin);
            elseif right<=mid && right<=left
                %Ironically, if the right side of the image has the least
                %number of points, turn left. This is due to lateral
                %inversion.
                move_left(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
                disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
                % calculate amount of rotation
                deltheta = do_rotation(imc1,imc2,imd1,imd2,matchedPoints1,matchedPoints2,valid2)
                deltheta=deltheta*pi/180;
                % plot translation
                origin = plot_robot(0,double(deltheta),origin);
            else
                %turn right
                move_right(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_TURN);
                disp(['left:' num2str(left) ' mid:' num2str(mid) ' right:' num2str(right)]);
                % calculate amount of rotation
                deltheta = do_rotation(imc1,imc2,imd1,imd2,matchedPoints1,matchedPoints2,valid2)
                deltheta=deltheta*pi/180;
                % plot translation
                origin = plot_robot(0,double(deltheta),origin);
            end
        else
            deltheta = do_rotation(imc1,imc2,imd1,imd2,matchedPoints1,matchedPoints2,valid2)
            deltheta=deltheta*pi/180;
            
            if(deltheta<=5.0)
                % if there is no rotation, then calculate translation amount
                deltax = do_translation(imc1,imc2,imd1,imd2);
                % plot translation
                origin = plot_robot(double(deltax),0,origin);
            else
                deltax=0;
                %plot rotation
                origin = plot_robot(0,double(deltheta),origin);
                
                % flush out for 0.2- keep triggering images and ignore them
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
        end
        
        %For each labelled component if the number of surf points on it is
        %greater than 5 then calculate the angle of the object wrt the bot and
        %plot it on the map
        for i=1:cc_num
            %get the depth of the feature
            d=imd2(uint16(c1(i,2)),uint16(c1(i,1)));
            if surf_count(i,1)>=5 && d ~= 0
                %find pixel distance from central line of image
                l=320-uint16(c1(i,1));
                %calculate its angle from the bot
                angle=l*pi/(c*d*180);
                %plot the object on the map if it isn't already plotted
                if ~is_obj_plotted
                    [plotted_points_x, plotted_points_y] = plot_object(double(d),double(angle),origin,[]);
                    plotted_points = [plotted_points_x, plotted_points_y];
                    is_obj_plotted = true;
                else
                    [new_points_x, new_points_y] = plot_object(double(d),double(angle),origin,plotted_points);
                    if new_points_x ~= -1 && new_points_y ~= -1
                        plotted_points = [plotted_points;[new_points_x, new_points_y]];
                    end
                end
            end
        end
    end
end
% Stop the video input when done %
stop(depthVid);
stop(colorVid);

% Stop the bot %
SPEED_FWD = 0;
if withArduino
    move_fwd(TIME_TURN, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED_FWD);
end