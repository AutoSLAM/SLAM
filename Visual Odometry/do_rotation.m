function theta = do_rotation(Ia, Ib, Ida, ~)

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
figure(1);
subplot(1,2,1);
imshow(Ib); hold on;
valid2.plot('showOrientation',true);
hold off;

n = 0;
l_by_r = 0;
c = -0.004175;

for i=1:size(matchedPoints1,1)
    if (Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0)
        l_by_r = l_by_r + ((matchedPoints2.Location(i,1)- matchedPoints1.Location(i,1)))/double((Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))));
        n = n + 1;
    end
end

theta = l_by_r/(c*n);
if(abs(theta)<7);
    theta=0;
    
end