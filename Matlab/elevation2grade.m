function [ grade ] = elevation2grade( elevation, distance )
%This function calculations the grade vector using the elevation and
%distance vectors
%  Assume elevation is in meters, and distance is in km
%  Written by Duncan Crowley & Sean Mahre, October 1, 2017

%We know that grade = (rise/run)*100 as a percent. We will use grade as a
%percent in all calculations

%A single sample is lost during this process on the front end.
for i = 2:length(distance)
    delta_d(i-1) = distance(i) - distance(i-1); %Find delta distance step
    delta_h(i-1) = elevation(i) - elevation(i-1); %Find delta elevation step
end
grade = (100 * delta_h./(1000*delta_d))';
end

