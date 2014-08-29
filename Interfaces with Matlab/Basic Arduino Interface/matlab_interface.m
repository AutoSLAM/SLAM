% Matlab script to control arduino board %
% Requires Matlab ArduinoIO Package to be downloaded %
% Assumes the Arduino has been loaded with the appropriate file %

% Variables to set the pins to which the motor driver is connected 
% conveniently %
LEFT_FRONT = 23;
LEFT_REAR = 43;
RIGHT_FRONT = 22;
RIGHT_REAR = 42;
RIGHT_EN = 6;
LEFT_EN = 7;

% Connect to the board %
a=arduino('COM3');

% Specify digital pins' mode %
a.pinMode(RIGHT_FRONT,'output')
a.pinMode(RIGHT_REAR,'output')
a.pinMode(LEFT_FRONT,'output')
a.pinMode(LEFT_REAR,'output')

% Make bot move forward for 3 seconds %
t0 = tic; % Start timer
display('Moving straight...')
while toc(t0) < 3 % Until 3 seconds are up, make bot go forward
    a.digitalWrite(RIGHT_FRONT,1) % Right Motor forward
    a.digitalWrite(RIGHT_REAR,0)
    a.digitalWrite(LEFT_FRONT,1) % Left Motor forward
    a.digitalWrite(LEFT_REAR,0)
    a.analogWrite(RIGHT_EN, 155) % Right Motor at 155/255th speed
    a.analogWrite(LEFT_EN, 155) % Left Motor at 155/255th speed
end

% Make bot turn right (for 0.8 seconds) %
t0 = tic; % Start timer
display('Moving right...')
while toc(t0) < 0.8 % Until 0.8 seconds are up, make bot go right
    a.digitalWrite(RIGHT_FRONT,0) % Right Motor backward
    a.digitalWrite(RIGHT_REAR,1)
    a.digitalWrite(LEFT_FRONT,1) % Left Motor forward
    a.digitalWrite(LEFT_REAR,0)
    a.analogWrite(RIGHT_EN, 155) % Right Motor at 155/255th speed
    a.analogWrite(LEFT_EN, 155) % Left Motor at 155/255th speed
end

% Make bot move forward for 3 seconds %
t0 = tic; % Start timer
display('Moving straight...')
while toc(t0) < 3 % Until 3 seconds are up, make bot go forward
    a.digitalWrite(RIGHT_FRONT,1) % Right Motor forward
    a.digitalWrite(RIGHT_REAR,0)
    a.digitalWrite(LEFT_FRONT,1) % Left Motor forward
    a.digitalWrite(LEFT_REAR,0)
    a.analogWrite(RIGHT_EN, 155) % Right Motor at 155/255th speed
    a.analogWrite(LEFT_EN, 155) % Left Motor at 155/255th speed
end

% Make bot turn left (for 0.8 seconds) %
t0 = tic; % Start timer
display('Moving left...')
while toc(t0) < 0.8 % Until 0.8 seconds are up, make bot go left
    a.digitalWrite(RIGHT_FRONT,1) % Right Motor forward
    a.digitalWrite(RIGHT_REAR,0)
    a.digitalWrite(LEFT_FRONT,0) % Left Motor backward
    a.digitalWrite(LEFT_REAR,1)
    a.analogWrite(RIGHT_EN, 155) % Right Motor at 155/255th speed
    a.analogWrite(LEFT_EN, 155) % Left Motor at 155/255th speed
end

flush(a)
