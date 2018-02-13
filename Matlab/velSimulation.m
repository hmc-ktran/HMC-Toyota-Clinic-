function [ velocity ] = velSimulation( distance )
%velSimulation generates a simulated velocity profile
%   It uses a distance vector as an input and outputs a velocity vector

velocity = ones(length(distance),1);
stopInterval = 100;
distanceInterval = 3;

%Average vehicle speeds in each nextMode: 
creep_avgspeed = 2.7; %All units in mph 
creep_avgspeed_sd = 1.0; %also note the standard deviation of that param for later. 
ls_transient_avgspeed = 7.6; %low speed transient 
ls_transient_avgspeed_sd = 2.5; 
shs_transient_avgspeed = 17.1; %short high speed transient
shs_transient_avgspeed_sd = 3.8; 
lhs_transient_avgspeed = 18.7; %long high speed transient 
lhs_transient_avgspeed_sd = 3.7; 
hs_cruise_avgspeed = 37.9; %high speed cruise 
hs_cruise_avgspeed_sd = 5.1; 

%maximum speed 
creep_maxspeed = 4.8; %All units in mph 
ls_transient_maxspeed = 16.5; %low speed transient 
shs_transient_maxspeed = 41.3; %short high speed transient
lhs_transient_maxspeed = 47.7; %long high speed transient 
hs_cruise_maxspeed = 58.6; %high speed cruise 

percent_creep = 0.00; %Divide the trip by the percentage in each nextMode of operation. 
percent_lstransient = 0.01; %Note that percentages should sum to 1.0. 
percent_short_hstransient = 0.02; 
percent_long_hstransient = 0.02; 
percent_hscruise = 0.95;
percent_stop = 0;
weight = [percent_creep, percent_lstransient, percent_short_hstransient, percent_long_hstransient, percent_hscruise, percent_stop]; 
modes = [1,2,3,4,5,6];
counter = 0;
nextMode = 5;
nextSpeed = hs_cruise_avgspeed;
for i = 1:distanceInterval:length(distance)
    currentMode = nextMode;
    currentSpeed = nextSpeed;
    counter=counter + 1;
    if (counter == stopInterval)
        nextMode = 6;
        nextSpeed = 0;
    else 
        nextMode = datasample(modes, 1, 'weights', weight, 'Replace', false); %randomly select a nextMode of operation based on the time spent in that nextMode. 
        if nextMode == 1 
            avg_speed = creep_avgspeed;
            speed_sd = creep_avgspeed_sd;   
        elseif nextMode == 2
            avg_speed = ls_transient_avgspeed;
            speed_sd = ls_transient_avgspeed_sd;  
        elseif nextMode == 3 
            avg_speed = shs_transient_avgspeed;
            speed_sd = shs_transient_avgspeed_sd;   
        elseif nextMode == 4 
            avg_speed = lhs_transient_avgspeed;
            speed_sd = lhs_transient_avgspeed_sd;
        elseif nextMode == 5 
            avg_speed = hs_cruise_avgspeed;
            speed_sd = hs_cruise_avgspeed_sd;
        end
    nextSpeed = normrnd(avg_speed, speed_sd);
    end
    velocity(i) = currentSpeed;
    if(length(distance) - 1 - i > 0)
        velocity(i+1) = 2*(currentSpeed)/3 + nextSpeed/3;
    end
    if (length(distance)- 2 - i > 0)
        velocity(i+2) = 2*(nextSpeed)/3 + currentSpeed/3;
    end
end
end

