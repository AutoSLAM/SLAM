function translation = do_translation(imc1,imc2,imd1,imd2)
%imda holds the depth values of the image imd1 with 40 pixels taken from both sides of %the centre pixel
%imdb holds the depth values of the image imd2 with 40 pixels taken from both sides of %the centre pixel
imda = imd1(:,280:360);
imdb = imd2(:,280:360);

%imca holds the color rgb values of the image imc1 with 40 pixels taken from both sides of %the centre pixel
%imcb holds the color rgb values of the image imc2 with 40 pixels taken from both sides of %the centre pixel
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


%correction holds the binary values 0 and 1 corresponding to each pixel. If pixel depth %is >0 then the binary value is 1 otherwise it is 0
correction = (imda>0);

%correction holds the binary values 0 and 1 corresponding to each pixel in both the %images imda and imdb. If pixel depth is >0 in both the images then the binary value is 1
%otherwise 0
correction = correction & (imdb>0);

%type conversion from logical array to integer array
correction = uint16(correction);

%imda_new and imdb_new hold the actual depth value of only those pixels whose depth in %both the images imd1 and imd2 is >0. The binary value is 1 iff the corresponding entry %in the correction matrix is also 1
imda_new = imda.*correction;
imdb_new = imdb .* correction;

%subtract the depth value to get the distance traversed by the bot in the forward %direction
depth_diff = imda_new - imdb_new;

%depth_adj = im2bw(depth_diff,0);

%new_diff = uint16(bwareaopen(depth_adj,200));

%finding the number of entries in the correction matrix which has value 1
sumb = sum(sum(correction,1),2);

%depth_diff = depth_diff .* new_diff;

%adding up all the depth differences of those pixels which had depth >0 in both the %images
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
    translation = suma/sumb; %averaging the depth difference i.e. the distance traversed %by the bot
    if translation < 10.0 %if the translation value is <10 then ignore it as the movement %of the bot is not significant i.e. 10mm which is mostly due to noise data given by the %Kinect
        translation = 0;
    end
else
    translation = 0;
end