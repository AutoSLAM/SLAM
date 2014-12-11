%Configuring the Kinect device with Matlab to get the Device ID
close all;
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

origin = [0 0 pi/2];
origin=plot_robot(0,0,origin);

x=tic;
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

while(true)
    % trigger an image and do odometry estimation every one second
    if toc(x)>1
        imd1=imd2;
        imc1=imc2;
        trigger(depthVid);
        [imd2, ~, ~] = getdata(depthVid);
        trigger(colorVid);
        [imc2, ~, ~] = getdata(colorVid);        
        
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
        
        % calculate amount of rotation
        deltheta = do_rotation(imc1,imc2,imd1,imd2,matchedPoints1,matchedPoints2,valid2)
        deltheta=deltheta*pi/180;
        
        if(deltheta==0)
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
        
        c = -0.004175;
        THRESHHOLD = 2000;
        % Threshold the image, so that all objects at a ditance > THRESHHOLD
        % away are ignored %
        thresh = logical(imd2~=0 & imd2<THRESHHOLD);
        % Remove noise, ie.e, components with total connected area less than
        % the specified value %
        thresh2 = bwareaopen(thresh,1600);
        % Get the connected components of the de-noised, threshholded image %
        cc = bwconncomp(thresh2);
        % Get the centroids of the connected components %
        centroid_struct = regionprops(cc,'Centroid');
        % Get the centroids of the connected components %
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
        
        x=tic;
        for i=1:cc_num
            d=imd2(uint16(c1(i,2)),uint16(c1(i,1)));
            if surf_count(i,1)>=10 && d ~= 0
                l=320-uint16(c1(i,1));
                angle=l*pi/(c*d*180);
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