function [ speeds ] = DutyCycles( trip_distance, roadheight,  length)
%Assume roadheight is given in the form of elevation versus time. 

%DEFINE CONSTANTS 

%%changed inc
inc =trip_distance/length; %set the distance increment to be used. 
DutyCycleParameters 
timestep = 0.017; %set the time step to be used. 


if isempty(roadheight) %if the road height is not specified (i.e. no information available) 
    roadheight = zeros(1, trip_distance/inc); %set the road grade to be flat for the entire length of the trip.
    %Distance vector is split into tenths of a mile. 
end

% figure(1)
% subplot(1,2,1)
% plot(distance_vec, roadgrades)
% title('Road Grade vs. Distance Travelled') 
% xlabel('Distance (miles)') 
% ylabel('Road Grade')
% 
% subplot(1,2,2)
% plot(distance_vec, roadheight) 
% title('Road Height vs. Distance Travelled') 
% xlabel('Distance (miles)') 
% ylabel('Road Height')

%All percentages are percentages of time, NOT distance. 
if trip_distance < 0.1
    trip_type = 'near_dock'; 
    percent_creep = 0.85; %Divide the trip by the percentage in each mode of operation. 
    percent_lstransient = 0.15; %Note that percentages should sum to 1.0. 
    percent_short_hstransient = 0.0; 
    percent_long_hstransient = 0.0; 
    percent_hscruise = 0.0; 
elseif (trip_distance > 0.1) && (trip_distance) <= 2
    trip_type = 'short_local'; 
    percent_creep = 0.04; %Divide the trip by the percentage in each mode of operation. 
    percent_lstransient = 0.93; %Note that percentages should sum to 1.0. 
    percent_short_hstransient = 0.03; 
    percent_long_hstransient = 0.0; 
    percent_hscruise = 0.0; 
elseif (trip_distance > 2) && (trip_distance < 6)
    trip_type = 'local'; 
    percent_creep = 0.00; %Divide the trip by the percentage in each mode of operation. 
    percent_lstransient = 0.15; %Note that percentages should sum to 1.0. 
    percent_short_hstransient = 0.85; 
    percent_long_hstransient = 0.0; 
    percent_hscruise = 0.0; 
elseif (trip_distance > 6) && (trip_distance < 20)
    trip_type = 'long_local'; 
    percent_creep = 0.00; %Divide the trip by the percentage in each mode of operation. 
    percent_lstransient = 0.00; %Note that percentages should sum to 1.0. 
    percent_short_hstransient = 0.0; 
    percent_long_hstransient = 0.96; 
    percent_hscruise = 0.04; 
elseif trip_distance >= 20 
    trip_type = 'long_distance'; 
    percent_creep = 0.00; %Divide the trip by the percentage in each mode of operation. 
    percent_lstransient = 0.00; %Note that percentages should sum to 1.0. 
    percent_short_hstransient = 0.00; 
    percent_long_hstransient = 0.02; 
    percent_hscruise = 0.98;  
end
distance_sum = creep_avgspeed*percent_creep + ls_transient_avgspeed*percent_lstransient + shs_transient_avgspeed*percent_short_hstransient + lhs_transient_avgspeed*percent_long_hstransient + hs_cruise_avgspeed*percent_hscruise;

trip_time = trip_distance/distance_sum; %time of the trip (in hours). 
    
total_distance = 0; %set the distance traveled so far to 0. 
current_time = 0; %initialize the time to 0. 
currentspeeds = [0]; %initialize the known speeds to a list with v(0) = 0. 
weight = [percent_creep, percent_lstransient, percent_short_hstransient, percent_long_hstransient, percent_hscruise]; 
modes = [1,2,3,4,5]; %create a vecotr of numerical values representing modes of operation. 

total_idle = 0; %initialize an idle counter to 0.
total_time = 0; %initialize a time counter to 0.
while total_distance < trip_distance %Until you have completed the trip... 
    mode = datasample(modes, 1, 'weights', weight, 'Replace', false); %randomly select a mode of operation based on the time spent in that mode. 
    if mode == 1 
        avg_speed = creep_avgspeed;
        speed_sd = creep_avgspeed_sd;
        avg_time = creep_time/3600; %change units to hours from seconds. 
        time_sd = creep_time_sd/3600;
        num_stops = creep_stops; 
        num_stops_sd = creep_stops_sd; 
        stop_length = creep_stopdist; 
        stop_length_sd = creep_stopdist_sd; 
        idle_time = creep_idletime; 
        idle_time_sd = creep_idletime_sd; 
    elseif mode == 2
        avg_speed = ls_transient_avgspeed;
        speed_sd = ls_transient_avgspeed_sd;
        avg_time = ls_transient_time/3600; 
        time_sd = ls_transient_time_sd/3600; 
        num_stops = ls_transient_stops; 
        num_stops_sd = ls_transient_stops_sd; 
        stop_length = ls_transient_stopdist; 
        stop_length_sd = ls_transient_stopdist_sd; 
        idle_time = ls_transient_idletime; 
        idle_time_sd = ls_transient_idletime_sd; 
    elseif mode == 3 
        avg_speed = shs_transient_avgspeed;
        speed_sd = shs_transient_avgspeed_sd; 
        avg_time = shs_transient_time/3600;
        time_sd = shs_transient_time_sd/3600;
        num_stops = shs_transient_stops; 
        num_stops_sd = shs_transient_stops_sd; 
        stop_length = shs_transient_stopdist; 
        stop_length_sd = shs_transient_stopdist_sd; 
        idle_time = shs_transient_idletime;
        idle_time_sd = shs_transient_idletime_sd; 
    elseif mode == 4 
        avg_speed = lhs_transient_avgspeed;
        speed_sd = lhs_transient_avgspeed_sd;
        avg_time = lhs_transient_time/3600;
        time_sd = lhs_transient_time_sd/3600;
        num_stops = lhs_transient_stops; 
        num_stops_sd = lhs_transient_stops_sd; 
        stop_length = lhs_transient_stopdist; 
        stop_length_sd = lhs_transient_stopdist_sd; 
        idle_time = lhs_transient_idletime; 
        idle_time_sd = lhs_transient_idletime_sd; 
    elseif mode == 5 
        avg_speed = hs_cruise_avgspeed;
        speed_sd = hs_cruise_avgspeed_sd;
        avg_time = hs_cruise_time/3600;
        time_sd = hs_cruise_time_sd/3600; 
        num_stops = hs_cruise_stops; 
        num_stops_sd = hs_cruise_stops_sd; 
        stop_length = hs_cruise_stopdist; 
        stop_length_sd = hs_cruise_stopdist_sd; 
        idle_time = hs_cruise_idletime;
        idle_time_sd = hs_cruise_idletime_sd; 
    end
    
    %Randomly select a total time to be in this mode. 
    mode_time = normrnd(avg_time, time_sd);
    if mode_time < 0
        mode_time = 0; %time should always be greater or equal to 0. 
    end
    total_time = total_time + mode_time; %track how much time you are taking. 
    
    %randomly select a total number of stops 
    num_stops = floor(normrnd(num_stops, num_stops_sd));
    
    %select a total amount of time to be spent idling in this mode - to be
    %appended at the end of the duty cycle. 
    mode_idle_time = normrnd(idle_time, idle_time_sd)*mode_time; %idle times are in percentages - multiply by total time. 
    if mode_idle_time <0 
        mode_idle_time =0; %make sure there is no negative idle time... 
    end
    mode_time = mode_time - mode_idle_time; %update the actual time spent running. 
    total_idle = total_idle + mode_idle_time; %add to the idle counter. 
    %For each stop, select a distance to stop over.
    stop_lengths = zeros(num_stops, 1); 
    stop_speeds = zeros(num_stops, 1);
    for i=1:num_stops 
        stop_lengths(i) = normrnd(stop_length, stop_length_sd); %choose a distance to stop over
        if stop_lengths(i) < 0 
            stop_lengths(i) = stop_length;
        end
        stop_speeds(i) = normrnd(avg_speed, speed_sd); %choose a speed at which the stop begins. 
        if stop_speeds(i) < 0
            stop_speeds(i) = avg_speed; 
        end
        
    end
    diground = @(x,d) round(x*10^d)/10^d;
    stop_times = diground(stop_lengths./stop_speeds, 2);
  %  total_stoptime = sum(stop_times); %how much time is spent stopping? 
  if num_stops <= 0 
      time_travel = mode_time; %you never make any stops. 
  else
    time_travel = mode_time - stop_times(1); %time spent travelling if you do 1 stop.
  end
  
  stop_pos = zeros(1,num_stops); %create a vector to store stop positions. 
    
    %idle_stop = idle_time/num_stops; 
    
    time_limit = [0:timestep:(time_travel - timestep)]; %if not enough time left... 
    if isempty(time_limit) %set the number of stops to 0 if there isn't enough time to do any of them. 
        num_stops = 0;
        stop_pos = []; %no stop positions. 
    elseif num_stops <= 0
        stop_pos = [];
    else
        stop_pos(1) = datasample([0:(time_travel - timestep)], 1); %otherwise get a stop position. 
        for i=2:num_stops %pick a time for each stop to begin. 
            start_limit = stop_pos(i-1) + stop_times(i-1);
            stop_limit = mode_time - stop_times(i);
            time_limit = [start_limit:timestep:stop_limit];
            if isempty(time_limit)
              num_stops = i-1; 
            else
                stop_pos(i) = datasample(time_limit, 1);
            end
        end
    end
    

 
    current_stop = 1; %start a counter for stops. 
    while (current_time< mode_time) && (total_distance < trip_distance) %go over all time steps in the mode unless you go over the distance. 
        if ismember(current_time, stop_pos) %if we are at a time stop. 
            start_speed = stop_speeds(current_stop); %speed the start initiates at
            stop_time = stop_times(current_stop); %how long the stop should take. 
            speeds = [start_speed:-(start_speed*timestep/stop_time):0]; %speeds at each point. 
            newspeeds = [currentspeeds, speeds]; %concatenate the 2 lists. 
            current_time = current_time + stop_times(current_stop); %update the time. 
            distance = stop_lengths(current_stop);
            total_distance = total_distance + distance; %add to the distance count. 
        else
            speed = normrnd(avg_speed, speed_sd); %randomly select a new speed. 
            newspeeds = [currentspeeds, speed] ;%add it to the list. 
            current_time = current_time + timestep; %increment the time by one time step. 
            distance = speed*timestep; 
            total_distance = total_distance + distance; 
        end
        currentspeeds = newspeeds; %update the speed tracker. 
    end
end

speeds = [currentspeeds, zeros(1,int8(total_idle/timestep))]; 
time_vec = [0:timestep:(length(speeds)-1)*timestep];


%Create a profile of distance traveled and road grade over time. 
distances = zeros(1,length(speeds)); %initialize a distance vector. 
height_steps = [0:total_distance/length(roadheight):total_distance - total_distance/length(roadheight)];
for i=2:length(speeds) 
    newdistance = speeds(i)*timestep; %find out how far the vehicle travels in one step. 
    distances(i) = distances(i-1) + newdistance; %find a cumulative distance traveled. 
end

F = griddedInterpolant(height_steps, roadheight); 
height_time = F(distances);

roadgrade = zeros(1, length(height_time));
for i=2:length(height_time)
    roadgrade(i) = (height_time(i) - height_time(i-1)) /(distances(i) - distances(i-1));
    if isnan(roadgrade(i)) 
        roadgrade(i) = 0; 
    end
%heights_times = interp1(height_steps, roadheight, distances);
end
mph_to_kph = 1.60934; 
speeds = speeds*mph_to_kph;
distances = distances*mph_to_kph; 

figure(1)
subplot(3,1,1)
plot(time_vec, roadgrade)
xlabel('Time (h)')
ylabel('Road Grade (%)')
subplot(3,1,2)
plot(time_vec, distances)
xlabel('Time (h)')
ylabel('Distance (km)')
subplot(3,1,3)
plot(time_vec, speeds)
xlabel('Time (h)')
ylabel('Speed (kph)')

figure(7) 
plot(time_vec, speeds)
xlabel('Time (hours)') 
ylabel('Speed (kph)') 
title('Vehicle Velocity vs. Time')
% size(roadgrade)
% size(distances)
% time_vec

