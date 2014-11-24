% Function to obtain constant c used when measuring the angle rotated by
% the bot between an initial and final image
function c = calibrate_odometry(Ia, Ib, Ida, ~, theta)

% http://www.mathworks.in/help/vision/examples/sparse-3-d-reconstruction-from-two-views.html?prodcode=VP&language=en
% Use SURF to detect feature points
imPts1 = detectSURFFeatures(rgb2gray(Ia));
imPts2 = detectSURFFeatures(rgb2gray(Ib));

% Extract feature descriptors
[features1, valid1] = extractFeatures(rgb2gray(Ia), imPts1);
[features2, valid2] = extractFeatures(rgb2gray(Ib), imPts2);

% Extract index pairs corresponding to matching features
indexPairs = matchFeatures(features1, features2);

% Extract matching features
matchedPoints1 = valid1(indexPairs(:, 1));
matchedPoints2 = valid2(indexPairs(:, 2));

% To store number of matching feature points
n = 0;
% To store the sum of the translation of matching feature points along the horizontal axis
l_by_r = 0;

for i=1:size(matchedPoints1,1)
    % for each matched point whose depth data is not zero
    if (Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0)
        % add the quantity del(y)/depth to l_by_r
        l_by_r = l_by_r + ((matchedPoints2.Location(i,1)- matchedPoints1.Location(i,1)))/double((Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))));
        %increment n
        n = n + 1;
    end
end

% get average of l_by_r, and then divide by theta to get c, by l=c*theta*r
c = l_by_r/(theta*n);

end