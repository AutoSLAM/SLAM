function new_origin = plot_robot(delx,deltheta,origin)
delx = delx/100;
new_origin(1) = origin(1) + (delx*cos(origin(3)));
new_origin(2) = origin(2) + (delx*sin(origin(3)));
new_origin(3) = origin(3) + deltheta;

figure(1);
subplot(1,2,2);
plot_x = [origin(1) new_origin(1)];
plot_y = [origin(2) new_origin(2)];
plot(plot_x,plot_y,'LineStyle','-');
axis([-15 15 -15 15]);

grid on
hold on
end