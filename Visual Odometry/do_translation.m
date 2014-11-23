function translation = do_translation(imc1,imc2,imd1,imd2)
imda = imd1(:,280:360);
imdb = imd2(:,280:360);

imca = imc1(:,280:360,:);
imcb = imc2(:,280:360,:);

% imPts1 = detectSURFFeatures(rgb2gray(imca));
% imPts2 = detectSURFFeatures(rgb2gray(imcb));
% % Extract feature descriptors
% [features1, valid1] = extractFeatures(rgb2gray(imca), imPts1);
% [features2, valid2] = extractFeatures(rgb2gray(imcb), imPts2);
% indexPairs = matchFeatures(features1, features2);
% 
% matchedPoints1 = valid1(indexPairs(:, 1));
% %matchedPoints1 = matchedPoints1(Ida(matchedPoints1) > 0);
% 
% matchedPoints2 = valid2(indexPairs(:, 2));
% depth = 0;
% n=0;
% for i=1:size(matchedPoints1,1)
%     if (imda(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0 &&  imdb(uint16(matchedPoints2.Location(i,2)),uint16(matchedPoints2.Location(i,1)))~=0)
%         depth = depth + imdb(uint16(matchedPoints2.Location(i,2)),uint16(matchedPoints2.Location(i,1))) - imda(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)));
%         n = n + 1;
%     end
% end
% n
% translation = depth/n
% end
% 

correction = (imda>0);
correction = correction & (imdb>0);
correction = uint16(correction);

imda_new = imda.*correction;
imdb_new = imdb .* correction;

depth_diff = imda_new - imdb_new;

%depth_adj = im2bw(depth_diff,0);

%new_diff = uint16(bwareaopen(depth_adj,200));

sumb = sum(sum(correction,1),2);
%depth_diff = depth_diff .* new_diff;
suma = sum(sum(depth_diff,1),2);


% figure(2);
% subplot(1,3,1);
% imshow(imda_new,[]);
% subplot(1,3,2);
% imshow(imdb_new,[]);
% subplot(1,3,3);
% imshow(depth_diff,[]);
%pause(1);
% figure(1);
if sumb ~= 0
    translation = suma/sumb;
    if translation < 10.0
        translation = 0;
    end
else
    translation = 0;
end