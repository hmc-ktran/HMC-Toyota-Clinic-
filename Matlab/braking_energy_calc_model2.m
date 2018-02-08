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
Cd = 0.58;
A_truckface = 113.4 * 0.09290304; %m^2
rho = 1.225; %kg/m^3
C_rr = 0.006; % dimensionless
n_tires = 18; %18-wheeler
%velocity_mph(1) =
%65;
%for i = 2:(length(distance)) %Allows us to make a faux velocity vector that changes in this loop
 %  velocity_mph(i) = velocity_mph(i-1) - 65/length(distance); 
%end
 
%velocity_mps = 0.44704*velocity_mph*ones(length(distance), 1);  %Allows us to make our own constant velocity

%note this is in KPH
velocity_mph = velSimulation(distance);
velocity_mps = 0.44704*velocity_mph; %Convert from MPH to m/s
potential_E_inst = zeros(length(distance), 1); %Instantaneous potential energy in MJ
potential_E_sum = zeros(length(distance), 1);  %Cumulative potential energy in MJ
grade = elevation2grade( elevation, distance ); %Calculates the percent grade using our function elevation2grade
theta = atan(grade);

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
velocitydiff = zeros(length(distance), 1);
veldiff = zeros(length(distance), 1);
velcnt = 0;
VC = zeros(length(distance), 1);
for i = 1:(length(distance)-1)   %Loop to calculate kinetic energy
    if velocity_mps(i) > velocity_mps(i+1)   %If slowing down, calculate the energy lost to slowing down
        if i ==1
            velocitydiff(i) = velocity_mps(i)-velocity_mps(i+1);
        else
            velocitydiff(i) = velocitydiff(i-1) + velocity_mps(i)-velocity_mps(i+1);
        end
        veldiff(i) =  velocity_mps(i)-velocity_mps(i+1);
        velcnt = velcnt + 1;
                                %kinetic_E_inst(i) = 0.5*mass_kg*(velocity_mps(i)^2-velocity_mps(i+1)^2)/(10^6);
    else       %If not slowing down, recoverable kinetic energy is 0.
       if i >1 
        if velocitydiff(i-1) >= 8.33  %if velocity difference is greater than 8.333mps, can adjust this number
         kinetic_E_inst(i) = 0.5*mass_kg*(velocity_mps(i-velcnt)^2-velocity_mps(i)^2)/(10^6);
        end
       end
      VC(i) = velcnt;
      % kinetic_E_inst(i) = 0;
      velocitydiff(i) = 0;
      velcnt = 0;
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
        delta_x = distance(i+1)-distance(i);
        friction_E_inst(i) = C_rr* mass_kg*gravity*abs(grade(i))*abs(cos(theta(i)))*n_tires*(delta_x)/(10^6);
        drag_E_inst(i) = 0.5* Cd* rho* velocity_mps(i).^2 * A_truckface * (distance(i+1)-distance(i))/(10^6);
   elseif velocity_mps(i)>velocity_mps(i+1)	
       friction_E_inst(i) = C_rr* mass_kg*gravity*abs(grade(i))*abs(cos(theta(i)))*n_tires*(delta_x)/(10^6);
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
%% also calculate time
E_braking_sum = zeros(length(distance), 1);
E_braking_inst = zeros(length(distance), 1);
Route_Time_inst = zeros(length(distance), 1);
Route_Time_sum = zeros(length(distance), 1);
for i = 1:(length(distance)-1)
       if velocity_mps(i) > 0
         Route_Time_inst(i) = abs(distance(i)-distance(i+1))/(velocity_mps(i)/1000);
       end
       if drag_E_inst(i) + friction_E_inst(i) <= kinetic_E_inst(i) + potential_E_inst(i)
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
       if i == 1                     %Sum kinetic energies to get cumulative energy
        Route_Time_sum(i) = Route_Time_inst(i);
       else
        Route_Time_sum(i) = Route_Time_sum(i-1) + Route_Time_inst(i);
       end
end
E_braking_sum(length(distance)) = E_braking_sum(length(distance)-1);
sample3seconds = E_braking_inst(292)+E_braking_inst(293)+E_braking_inst(295)+E_braking_inst(294);
Energy_Per_Second = zeros(length(distance), 1);
for i = 1:(length(distance)-1)
       if Route_Time_inst(i) > 0;
         Energy_Per_Second(i) = E_braking_inst(i)/Route_Time_inst(i);
       end
end

Energy_30_seconds = [0];
Energy_30_seconds_temp = 0;
Energy_counter = 0;
Time_counter = 0;
for i=1:(length(distance)-1)
        Time_counter = Time_counter + Route_Time_inst(i);
        Energy_30_seconds_temp = Energy_30_seconds_temp + E_braking_inst(i);
        if Time_counter >= 30
             Time_counter = 0;
             Energy_counter = Energy_counter + 1;
             Energy_30_seconds(Energy_counter) = 30*Energy_30_seconds_temp/Time_counter;
             Energy_30_seconds_temp = 0;
        end
end

Energy_3_seconds = [0];
Energy_3_seconds_temp = 0;
Energy_counter_3 = 0;
Time_counter_3 = 0;
for i=1:(length(distance)-1)
        Time_counter_3 = Time_counter_3 + Route_Time_inst(i);
        Energy_3_seconds_temp = Energy_3_seconds_temp + E_braking_inst(i);
        if Time_counter_3 >= 3
             Time_counter_3 = 0;
             Energy_counter_3 = Energy_counter_3 + 1;
             Energy_3_seconds(Energy_counter_3) = 3*Energy_3_seconds_temp/Time_counter_3;
             Energy_3_seconds_temp = 0;
        end
end

Energy_180_seconds = [0];
Energy_180_seconds_temp = 0;
Energy_counter_180 = 0;
Time_counter_180 = 0;
for i=1:(length(distance)-1)
        Time_counter_180 = Time_counter_180 + Route_Time_inst(i);
        Energy_180_seconds_temp = Energy_180_seconds_temp + E_braking_inst(i);
        if Time_counter_180 >= 180
             Time_counter_180 = 0;
             Energy_counter_180 = Energy_counter_180 + 1;
             Energy_180_seconds(Energy_counter_180) = 180*Energy_180_seconds_temp/Time_counter_180;
             Energy_180_seconds_temp = 0;
        end
end

Energy_1800_seconds = [0];
Energy_1800_seconds_temp = 0;
Energy_counter_1800 = 0;
Time_counter_1800 = 0;
for i=1:(length(distance)-1)
        Time_counter_1800 = Time_counter_1800 + Route_Time_inst(i);
        Energy_1800_seconds_temp = Energy_1800_seconds_temp + E_braking_inst(i);
        if Time_counter_1800 >= 1800
             Time_counter_1800 = 0;
             Energy_counter_1800 = Energy_counter_1800 + 1;
             Energy_1800_seconds(Energy_counter_1800) = 1800*Energy_1800_seconds_temp/Time_counter_1800;
             Energy_1800_seconds_temp = 0;
        end
end

Energy_dot3_seconds = [0];
Energy_dot3_seconds_temp = 0;
Energy_counter_dot3 = 0;
Time_counter_dot3 = 0;
for i=1:(length(distance)-1)
        Time_counter_dot3 = Time_counter_dot3 + Route_Time_inst(i);
        Energy_dot3_seconds_temp = Energy_dot3_seconds_temp + E_braking_inst(i);
        if Time_counter_dot3 >= .3
            
             Energy_counter_dot3 = Energy_counter_dot3 + 1;
             Energy_dot3_seconds(Energy_counter_dot3) = .3*Energy_dot3_seconds_temp/Time_counter_dot3;
             Energy_dot3_seconds_temp = 0;
             Time_counter_dot3 = 0;
        end
end
dot3_max = max(Energy_dot3_seconds);
max1800 = max(Energy_1800_seconds);
max180 = max(Energy_180_seconds);
max30 = max(Energy_30_seconds);
max3 = max(Energy_3_seconds);

dot3_avg = mean(Energy_dot3_seconds);
avg1800 = mean(Energy_1800_seconds);
avg180 = mean(Energy_180_seconds);
avg30 = mean(Energy_30_seconds);
avg3 = mean(Energy_3_seconds);

dot3_avgP = mean(Energy_dot3_seconds)/3;
avg1800P = mean(Energy_1800_seconds)/1800;
avg180P = mean(Energy_180_seconds)/180;
avg30P = mean(Energy_30_seconds)/30;
avg3P = mean(Energy_3_seconds)/3;


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
title('Vincent Thomas Bridge Route #3 Recoverable Energy');
%47 Terminal Island Freeway Route #1
%Gerald Desmond Bridge Route #2
%Vincent Thomas Bridge Route #3
xlabel('Distance (km)');
ylabel('Total Braking Energy (MJ)');
subplot(2,1,2);
plot(distance, elevation);
title('Vincent Thomas Bridge Route #3 Elevation Profile');
xlabel('Distance (km)');
ylabel('Elevation (m)');

figure(3);
subplot(2,1,1);
plot(Route_Time_sum, E_braking_sum);
xlabel('Total Time')

figure(4);
plot(distance,E_braking_inst);
title('Instaneous Energy vs Distance')
xlabel('Distance (km)');
ylabel('Instantaneous Energy (MJ)')

figure(5);
subplot(2,1,1);
plot(distance,velocity_mps);
title('velocity vs Distance')
xlabel('Distance (km)');
ylabel('Instantaneous Energy (MJ)')
subplot(2,1,2);
plot( distance, kinetic_E_inst);
title('kinetic Energy vs Distance')
xlabel('Distance (km)');
ylabel('Instantaneous Energy (MJ)')