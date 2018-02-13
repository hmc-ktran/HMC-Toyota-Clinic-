% This script calculates the braking energy for a given route, using the
% instantaneous distance, velocity, time, and elevation for that route.
%% Load in csv:
clear all;
[FileName,PathName,FilterIndex] = uigetfile({'*.VBO';'*.csv'}, 'Pick the data file of interest'); %Choose file with GUI
full_path = strcat(PathName, FileName); %make full file path from path + filename
[fp,n, ext] = fileparts(full_path);

if (strcmpi(ext,'.VBO'))
   data = importdata(full_path, " ", 70);
   data = data.data;
   lat = data(:,3)/60;
   goodindices = lat > 0;
   data = data(goodindices,:);
   lat = data(:,3)/60;
   lon = -data(:,4)/60;
   velocity_kph = data(:,5);
   elevation = data(:,7);
   distance = pathdist(lat,lon, 'kilometers');
elseif (strcmpi(ext,'.csv'))
    data = importdata(full_path); %Get file into Matlab
else
    if (isstruct(data)) %If the data has any non-data (like text), only take the numerical part and ignore the rest
        data = data.data;
    end
    distance = data(:,6);  %km
    elevation = data(:,1); %meters
    velocity_mph = data(:,2);  %mph
end


%% Potential Energy Calculation
%For now, we assume data is columnated in the format:
%[Lat, Long, Elevation (m), Distance (km), Grade (%)]
%We will still calculation grade in case future datasets don't have this.
Cd = 0.58;
A_truckface = 113.4 * 0.09290304; %m^2
rho = 1.225; %kg/m^3
C_rr = 0.006; % dimensionless
n_tires = 18; %18-wheeler
%velocity_mph(1) = 65;
%for i = 2:(length(distance)) %Allows us to make a faux velocity vector that changes in this loop
 %  velocity_mph(i) = velocity_mph(i-1) - 65/length(distance); 
%end
 
%velocity_mps = 0.44704*velocity_mph*ones(length(distance), 1);  %Allows us to make our own constant velocity

%note this is in KPH
%velocity_mph = velSimulation(distance);
velocity_mps = 0.2778*velocity_kph; %Convert from MPH to m/s
potential_E_inst = zeros(length(distance), 1); %Instantaneous potential energy in MJ
potential_E_sum = zeros(length(distance), 1);  %Cumulative potential energy in MJ
grade = elevation2grade( elevation, distance ); %Calculates the percent grade using our function elevation2grade
theta = atan(grade);

for i = 1:(length(distance)-1)
   velNow = velocity_mps(i);
   if i > 20 && velNow > 31.2
       velocity_mps(i) = mean(velocity_mps(i-20:i));
   elseif i < 20 && velNow > 31.2
           velocity_mps(i) = mean(velocity_mps(1:i));
   end
end



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
for i = 1:(length(velocity_mps)-1)   %Loop to calculate kinetic energy
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
%% Energy Loss Calculations
friction_E_inst = zeros(length(distance), 1);
friction_E_sum = zeros(length(distance), 1);
drag_E_inst = zeros(length(distance), 1);
drag_E_sum = zeros(length(distance), 1);
for i = 1:(length(distance)-1)   %Loop to calculate kinetic energy
   if elevation(i)>elevation(i+1)  %If going downhill, calculate the energy from the drop
        friction_E_inst(i) = C_rr* mass_kg*gravity*abs(grade(i))*abs(cos(theta(i)))*n_tires*(distance(i+1)-distance(i))/(10^6);
        drag_E_inst(i) = 0.5* Cd* rho* velocity_mps(i).^2 * A_truckface * (distance(i+1)-distance(i))/(10^6);
   elseif velocity_mps(i)>velocity_mps(i+1)	
       friction_E_inst(i) = C_rr* mass_kg*gravity*abs(grade(i))*abs(cos(theta(i)))*n_tires*(distance(i+1)-distance(i))/(10^6);
       drag_E_inst(i) = 0.5* Cd* rho* velocity_mps(i).^2 * A_truckface * (distance(i+1)-distance(i))/(10^6);
   else
       friction_E_inst(i) = 0 ;
       drag_E_inst(i) = 0;
    end
    if i == 1                     %Sum kinetic energies to get cumulative energy
       friction_E_sum(i) = friction_E_inst(i) ;
       drag_E_sum(i) = drag_E_inst(i);
    else
      drag_E_sum(i) = drag_E_sum(i-1) + drag_E_inst(i);
      friction_E_sum(i) = friction_E_sum(i-1) + friction_E_inst(i);
    end
end
    drag_E_sum(length(distance)) = drag_E_sum(length(distance)-1); %in MJ
    friction_E_sum(length(distance)) = friction_E_sum(length(distance)-1);
%% Sum Energies and Plot
E_braking_sum = zeros(length(distance), 1);
E_braking_inst = zeros(length(distance), 1);
for i = 1:(length(distance)-1)
       if (drag_E_inst(i) + friction_E_inst(i) <= kinetic_E_inst(i) + potential_E_inst(i))
           E_braking_sum(i) = kinetic_E_sum(i) + potential_E_sum(i) - drag_E_sum(i) - friction_E_sum(i);
           E_braking_inst(i) = kinetic_E_inst(i) + potential_E_inst(i) - drag_E_inst(i) - friction_E_inst(i);
       else
           if i == 1   
             E_braking_sum(i) = 0;
             E_braking_inst(i) = 0;
           else
             E_braking_sum(i) = E_braking_sum(i-1);
             E_braking_inst(i) = 0;
           end
       end
end
E_braking_sum(length(distance)) = E_braking_sum(length(distance)-1);
%E_braking_sum = kinetic_E_sum + potential_E_sum - drag_E_sum - friction_E_sum;  %Recoverable energy is the sum of these two kinds of energy
%E_braking_inst = kinetic_E_inst + potential_E_inst - drag_E_inst - friction_E_inst; %Recoverable energy is the sum of these two kinds of energy
all = figure(1);          %Plot potential energy, kinetic energy, total recoverable energy and elevation against distance
plotNum = 5;
a(1) = subplot(plotNum,1,1);
plot(distance, potential_E_sum);
title(a(1), 'Maximum Recoverable Energy Breakdown');
xlabel('Distance (km)');
ylabel('Potential Energy (MJ)');
subplot(plotNum,1,2);
plot(distance, kinetic_E_sum);
xlabel('Distance (km)');
ylabel('Kinetic Energy (MJ)');
subplot(plotNum,1,3);
plot(distance, friction_E_sum);
ylabel('Friction Energy (MJ)');
xlabel('Distance (km)');
subplot(plotNum,1,4);
plot(distance, drag_E_sum);
xlabel('Distance (km)');
ylabel('Drag Energy (MJ)');
subplot(plotNum,1,5);
plot(distance, E_braking_sum);
xlabel('Distance (km)');
ylabel('Total Braking Energy (MJ)');
%subplot(6,1,4);
%plot(distance, elevation);
%xlabel('Distance (km)');
%ylabel('Elevation (m)');
%subplot(6,1,6);
%%plot(distance, drag_E_inst);
%xlabel('distance');
%ylabel('drag inst');
%subplot(6,1,6);
%plot(distance, friction_E_inst);
%ylabel('friction inst')'
figure(2);
subplot(2,1,1);
plot(distance, E_braking_sum);
title('47 Terminal Island Highway Route #1 Recoverable Energy');
%47 Terminal Island Freeway Route #1
%Gerald Desmond Bridge Route #2
%Vincent Thomas Bridge Route #3
xlabel('Distance (km)');
ylabel('Total Braking Energy (MJ)');
subplot(2,1,2);
plot(distance, elevation);
title('47 Terminal Island Highway Route #1 Elevation Profile');
xlabel('Distance (km)');
ylabel('Elevation (m)');