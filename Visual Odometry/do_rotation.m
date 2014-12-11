% Function to obtain the angle rotated by the bot 
% between an initial and final image
function theta = do_rotation(~, Ib, Ida, ~, matchedPoints1, matchedPoints2, valid2)

% Show most recent image, and plot the feature points on it
% figure(1);
% subplot(1,2,1);
% imshow(Ib); hold on;
% valid2.plot('showOrientation',true);
% hold off;

% To store number of matching feature points
n = 0;
% To store the sum of the translation of matching feature points along the horizontal axis
l_by_r = 0;

% constant, obtained by calibration
c = -0.004175;

for i=1:size(matchedPoints1,1)
    % for each matched point whose depth data is not zero
    if (Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1))) ~= 0)
        % add the quantity del(y)/depth to l_by_r
        l_by_r = l_by_r + ((matchedPoints2.Location(i,1)- matchedPoints1.Location(i,1)))/double((Ida(uint16(matchedPoints1.Location(i,2)),uint16(matchedPoints1.Location(i,1)))));
        %increment n
        n = n + 1;
    end
end

% obtain theta using theta = l/c*r
theta = l_by_r/(c*n);

% % ignore theta < 7 (since this is likely noise)
% if(abs(theta)<7);
%     theta=0;
% end