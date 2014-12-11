function [obj_x, obj_y] = plot_object(x,theta,location_bot, plotted_points)

% The scale of the graph is 100 : 1 i.e 100 mm displacement corresponds to 1 unit on the graph
x2 = x/100;

% Computation of the new position of the bot based on the earlier location
obj_theta = location_bot(3) - theta;
obj_x = location_bot(1) + (x2*cos(obj_theta));
obj_y = location_bot(2) + (x2*sin(obj_theta));

%if the distance of the new feature point is greater than 7 units from any
%of the existing feature points then plot it on the map
if sum(size(plotted_points)) == 0 || pdist([plotted_points(dsearchn(plotted_points,[obj_x, obj_y]),:);[obj_x, obj_y]],'euclidean') > 7
    figure(1);
    subplot(1,2,2);
    hold on;
    plot(obj_x,obj_y,'r*');
    disp(['obj_x = ' num2str(obj_x) '  obj_y = ' num2str(obj_y)]);
else
    obj_x = -1;
    obj_y = -1;
end
end
