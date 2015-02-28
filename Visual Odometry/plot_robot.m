% A function to plot the path traversed by the bot. The input arguments are :
% (1) delx, the forward translation in mm
% (2) deltheta, the angle of rotation in radians
% (3) origin, the previous position of the robot in the form [x y theta].
function [new_origin, bot_tri] = plot_robot(delx,deltheta,origin,old_bot_tri)

% The scale of the graph is 100 : 1 i.e 100 mm displacement corresponds to 1 unit on the graph
delx2 = delx/100;

% Computation of the new position of the bot based on the earlier location
new_origin(1) = origin(1) + (delx2*cos(origin(3)));
new_origin(2) = origin(2) + (delx2*sin(origin(3)));
new_origin(3) = origin(3) + deltheta;

% Plot the new location of the bot on the graph and join with the earlier position using a straight line.
figure(1);
subplot(1,2,2);
plot_x = [origin(1) new_origin(1)];
plot_y = [origin(2) new_origin(2)];
plot(plot_x,plot_y,'LineStyle','-');
if ~isempty(old_bot_tri)
    delete(old_bot_tri)
end
T = [6*cos(new_origin(3)) 6*sin(new_origin(3)); 6*(cos(-(2*pi/3)+new_origin(3))) 6*(sin(-(2*pi/3)+new_origin(3))); 6*(cos((2*pi/3)+new_origin(3))) 6*(sin((2*pi/3)+new_origin(3)))];
bot_tri = line([T(1:3,1);T(1,1)], [T(1:3,2);T(1,2) ]);
set(bot_tri,'Color','r');
axis([-50 50 -50 50]);
grid on
hold on
end