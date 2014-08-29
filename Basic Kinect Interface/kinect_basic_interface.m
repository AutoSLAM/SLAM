utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
'html', 'KinectForWindows');
addpath(utilpath);
hwInfo = imaqhwinfo('kinect');
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);

% triggerconfig([colorVid depthVid],'manual');
% set([colorVid depthVid], 'FramesPerTrigger', 100);
% start([colorVid depthVid]);
% trigger([colorVid depthVid]);
% [colorFrameData colorTimeData colorMetaData] = getdata(colorVid);
% [depthFrameData depthTimeData depthMetaData] = getdata(depthVid);
% stop([colorVid depthVid]);

preview(depthVid);
preview(colorVid);

im = getsnapshot(depthVid);
flush(colorVid);