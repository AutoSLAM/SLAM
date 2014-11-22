function c = calibrate_odometry(Ia, Ib, Ida, Idb, theta)

% Function to show how close 2 images are to each other using SURF

% Code borrowed and modified from 
% http://www.mathworks.in/help/vision/examples/sparse-3-d-reconstruction-from-two-views.html?prodcode=VP&language=en
% Use SURF to detect feature points
imPts1 = detectSURFFeatures(rgb2gray(Ia));
imPts2 = detectSURFFeatures(rgb2gray(Ib));
% Extract feature descriptors
[features1, valid1] = extractFeatures(rgb2gray(Ia), imPts1);
[features2, valid2] = extractFeatures(rgb2gray(Ib), imPts2);
indexPairs = matchFeatures(features1, features2);

matchedPoints1 = valid1(indexPairs(:, 1));
%matchedPoints1 = matchedPoints1(Ida(matchedPoints1) > 0);

matchedPoints2 = valid2(indexPairs(:, 2));
% Visualize correspondences

n = 0;
l_by_r = 0;

for i=1:size(matchedPoints1,1)
    if (Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0)
        l_by_r = l_by_r + ((matchedPoints2.Location(i,1)- matchedPoints1.Location(i,1)))/double((Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))));
        n = n + 1;
    end
end

c = l_by_r/(theta*n);

end