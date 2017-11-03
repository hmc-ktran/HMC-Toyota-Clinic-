%This script defines all duty cycle variables for each of 3 different duty
%cycles. Information comes from the Drayage Truck Duty Cycle document. 

%Define average values for trip parameters. 

%Average vehicle speeds in each mode: 
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

%time spent non-idle
creep_nonidletime = 44; %All units in seconds 
ls_transient_nonidletime = 268; %low speed transient 
shs_transient_nonidletime = 890; %short high speed transient
lhs_transient_nonidletime = 2117; %long high speed transient 
hs_cruise_nonidletime = 4767; %high speed cruise 

%time spent total 
creep_time = 363; 
creep_time_sd = 411; 
ls_transient_time = 592; 
ls_transient_time_sd = 509; 
shs_transient_time = 1385; 
shs_transient_time_sd = 687; 
lhs_transient_time = 2956; 
lhs_transient_time_sd = 2096; 
hs_cruise_time = 5577; 
hs_cruise_time_sd = 2540; 

%average time spent idling
creep_idletime = 0.66; %Percentage of time spent in idle ]
creep_idletime_sd = 0.282; 
ls_transient_idletime = 0.40; %low speed transient 
ls_transient_idletime_sd = 0.245; 
shs_transient_idletime = 0.29; %short high speed transient
shs_transient_idletime_sd = 0.154; 
lhs_transient_idletime = 0.27; %long high speed transient 
lhs_transient_idletime_sd = 0.132; 
hs_cruise_idletime = 0.13; %high speed cruise 
hs_cruise_idletime_sd = 0.081; 

%average number of stops
creep_stops = 3.2; %Number of stops
creep_stops_sd = 3.5;
ls_transient_stops = 8.5; %low speed transient 
ls_transient_stops_sd = 8.3;
shs_transient_stops = 16.2; %short high speed transient
shs_transient_stops_sd =9.6;
lhs_transient_stops = 29; %long high speed transient 
lhs_transient_stops_sd = 16.6;
hs_cruise_stops = 22.7; %high speed cruise 
hs_cruise_stops_sd = 16.9;

%average stop distance. 
creep_stopdist = 0.01; 
creep_stopdist_sd = 0.02; 
ls_transient_stopdist = 0.11; 
ls_transient_stopdist_sd = 0.13; 
shs_transient_stopdist = 0.34; 
shs_transient_stopdist_sd = 0.21; 
lhs_transient_stopdist = 0.43; 
lhs_transient_stopdist_sd = 0.30; 
hs_cruise_stopdist = 3.17; 
hs_cruise_stopdist_sd = 2.36; 

%total distance averages
creep_distance = 0.034; %All units in miles 
ls_transient_distance = 0.58; %low speed transient 
shs_transient_distance = 4.2; %short high speed transient
lhs_transient_distance = 11.3; %long high speed transient 
hs_cruise_distance = 50.6; %high speed cruise 

%average energy per mile 
creep_EPM = 8.4; %All units in Hp-hr/mile  
ls_transient_EPM = 4.8; %low speed transient 
shs_transient_EPM = 3.7; %short high speed transient
lhs_transient_EPM = 3.8; %long high speed transient 
hs_cruise_EPM = 3.9; %high speed cruise 

