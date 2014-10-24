% VL_DEMO_SIFT_MATCH  Demo: SIFT: basic matching
% with a few modifications to accept inout from kinect

% modify to appropriate vl_setup path
run('C:\Users\Joel\Documents\Code\LoP\vlfeat-0.9.19\toolbox\vl_setup')
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

timer1 = tic;
start(depthVid);
start(colorVid);

pfx = fullfile(vl_root,'figures','demo') ;
randn('state',0) ;
rand('state',0) ;
figure(1) ; clf ;

% --------------------------------------------------------------------
%                                                    Create image pair
% --------------------------------------------------------------------
while toc(timer1)<60
    trigger(colorVid);
    [Ia, ~, ~] = getdata(colorVid);
    
    trigger(colorVid);
    [Ib, ~, ~] = getdata(colorVid);
    
    % --------------------------------------------------------------------
    %                                           Extract features and match
    % --------------------------------------------------------------------
    
    [fa,da] = vl_sift(im2single(rgb2gray(Ia))) ;
    [fb,db] = vl_sift(im2single(rgb2gray(Ib))) ;
    
    [matches, scores] = vl_ubcmatch(da,db) ;
    
    [drop, perm] = sort(scores, 'descend') ;
    matches = matches(:, perm) ;
    scores  = scores(perm);
    
    figure(1) ; clf ;
    imagesc(cat(2, Ia, Ib)) ;
    axis image off ;
    vl_demo_print('sift_match_1', 1) ;
    
    figure(2) ; clf ;
    imagesc(cat(2, Ia, Ib)) ;
    
    xa = fa(1,matches(1,:)) ;
    xb = fb(1,matches(2,:)) + size(Ia,2) ;
    ya = fa(2,matches(1,:)) ;
    yb = fb(2,matches(2,:)) ;
    
    hold on ;
    h = line([xa ; xb], [ya ; yb]) ;
    set(h,'linewidth', 1, 'color', 'b') ;
    
    vl_plotframe(fa(:,matches(1,:))) ;
    fb(1,:) = fb(1,:) + size(Ia,2) ;
    vl_plotframe(fb(:,matches(2,:))) ;
    axis image off ;
    
    vl_demo_print('sift_match_2', 1) ;
end