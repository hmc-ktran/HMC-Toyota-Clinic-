% This script calculates the braking energy for a given route, using the
% instantaneous distance, velocity, time, and elevation for that route.
%% Load in csv:
[FileName,PathName,FilterIndex] = uigetfile('.csv'); %Choose file with GUI
full_path = strcat(PathName, FileName); %make full file path from path + filename
data = importdata(full_path); %Get file into Matlab
if (isstruct(data)) %If the data has any non-data (like text), only take the numerical part and ignore the rest
    data = data.data;
end
%% Potential Energy Calculation
%For now, we assume data is columnated in the format:
%[Lat, Long, Elevation (m), Distance (km), Grade (%)]
%We will still calculation grade in case future datasets don't have this.
distance = data(:,4);  %km
elevation = data(:,3); %meters
velocity_mph = 65;  %mph
%velocity_mph(1) = 65;
%for i = 2:(length(distance)) %Allows us to make a faux velocity vector that changes in this loop
 %  velocity_mph(i) = velocity_mph(i-1) - 2; 
%end
%velocity_mps = 0.44704*velocity_mph; %Convert from MPH to m/s 
velocity_mps = 0.44704*velocity_mph*ones(length(distance), 1);  %Allows us to make our own constant velocity
potential_E_inst = zeros(length(distance), 1); %Instantaneous potential energy in MJ
potential_E_sum = zeros(length(distance), 1);  %Cumulative potential energy in MJ
grade = elevation2grade( elevation, distance ); %Calculates the percent grade using our function elevation2grade
mass_lbs = 80000; %pounds
mass_kg = 0.453592*mass_lbs; %Converts from lbs to kg
gravity = 9.8; %m/s^2
for i = 1:(length(distance)-1)   %Loop to calculate potential energy
    if elevation(i)>elevation(i+1)  %If going downhill, calculate the energy from the drop
        potential_E_inst(i) = mass_kg*gravity*(elevation(i)-elevation(i+1))/(10^6);
    else                         %If not going downhill, recoverable potential energy is 0.
       potential_E_inst(i) = 0;
    end
    if i == 1                   %Sum potential energies to get cumulative energy
       potential_E_sum(i) = potential_E_inst(i);
    else
       potential_E_sum(i) = potential_E_sum(i-1) + potential_E_inst(i);
    end
end
potential_E_sum(length(distance)) = potential_E_sum(length(distance)-1);   %For last entry, mirror the cumulative energy
            
%% Dynamic Energy Calculation
kinetic_E_inst = zeros(length(distance), 1); %in MJ
kinetic_E_sum = zeros(length(distance), 1);
for i = 1:(length(distance)-1)   %Loop to calculate kinetic energy
    if velocity_mps(i) > velocity_mps(i+1)   %If slowing down, calculate the energy lost to slowing down
        kinetic_E_inst(i) = 0.5*mass_kg*(velocity_mps(i)^2-velocity_mps(i+1)^2)/(10^6);
    else						%If not slowing down, recoverable kinetic energy is 0.
       kinetic_E_inst(i) = 0;
    end
    if i == 1                     %Sum kinetic energies to get cumulative energy
       kinetic_E_sum(i) = kinetic_E_inst(i);
    else
       kinetic_E_sum(i) = kinetic_E_sum(i-1) + kinetic_E_inst(i);
    end
end
kinetic_E_sum(length(distance)) = kinetic_E_sum(length(distance)-1); %in MJ

%% Sum Energies and Plot
E_braking_sum = kinetic_E_sum + potential_E_sum;  %Recoverable energy is the sum of these two kinds of energy
E_braking_inst = kinetic_E_inst + potential_E_inst; %Recoverable energy is the sum of these two kinds of energy
all = figure(1);          %Plot potential energy, kinetic energy, total recoverable energy and elevation against distance
a(1) = subplot(4,1,1);
plot(distance, potential_E_sum);
title(a(1), 'Maximum Recoverable Energy Breakdown');
xlabel('Distance (km)');
ylabel('Potential Energy (MJ)');
subplot(4,1,2);
plot(distance, kinetic_E_sum);
xlabel('Distance (km)');
ylabel('Kinetic Energy (MJ)');
subplot(4,1,3);
plot(distance, E_braking_sum);
xlabel('Distance (km)');
ylabel('Total Braking Energy (MJ)');
subplot(4,1,4);
plot(distance, elevation);
xlabel('Distance (km)');
ylabel('Elevation (m)');
