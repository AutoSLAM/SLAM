% Make bot turn right for secs seconds %
function move_right(secs, a, RIGHT_DIR, LEFT_DIR, RIGHT_EN, LEFT_EN, SPEED)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
t0 = tic; % Start timer
display('Moving right...')
while toc(t0) < secs % Until secs seconds are up, turn bot right
    a.digitalWrite(RIGHT_DIR,0) % Right Motor backward
    a.digitalWrite(LEFT_DIR,0) % Left Motor forward
    a.analogWrite(RIGHT_EN, SPEED) % Right Motor at SPEED/255th speed
    a.analogWrite(LEFT_EN, SPEED) % Left Motor at SPEED/255th speed
end
end
