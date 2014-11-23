function SURFMatch(Ia, Ib)
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
matchedPoints2 = valid2(indexPairs(:, 2));

% Visualize correspondences
figure(1);clf;
showMatchedFeatures(Ia, Ib, matchedPoints1, matchedPoints2);

figure(2);clf;
showMatchedFeatures(Ia, Ib, matchedPoints1, matchedPoints2, 'montage');


% imshow(Ia);
% hold on;
% plot(matchedPoints1(:,1),matchedPoints1(:,2),'Marker','x','Color','red','MarkerSize',10);
% hold off;
% 
% matchedPoints1 = imPts1(indexPairs(:, 1));
% matchedPoints2 = imPts2(indexPairs(:, 2));
% 
% figure(3);clf;
% showMatchedFeatures(Ia, Ib, matchedPoints1, matchedPoints2, 'montage');
% 
% end