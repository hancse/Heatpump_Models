
%Model 1 Parameter


Ewp = 1000; % (electricity) [W]
mc = 0.05;  % (mass flow condensor) [kg/s]
Tc_in = 273.15 + 28; % (temperature Condensor in) [oC]
me = 0.05;  %(mass flow evaporator)[kg/s]
% input
%   Ewp; [W], electricity in
Te_in = 273.15 +7;  %oC, temperature evaporator in
% modelparameters
 cair=1000; %[J/kgK], heat capacity air
 cw=4200; %[J/kgK], heat capacity water
 C=100000; %[J/K], Capacity
%   Ce=C;
%   Cc=C;
%%
%%Model 2

%Notation Description
%   Tcin Temp. of refrig. into Condenser (?C)
%   Tcout Temp. of refrig. out of Condenser (?C)
%   Tein Temp. of refrig. into Evaporator (?C)
%   Teout Temp. of refrig. out of Evaporator (?C)
%   Qin Heat transferred into the HP cycle (J)
%   Qout Heat transferred out of the HP cycle (J)
%   Qeva Heat transferred into the Evaporator (J)
%   Qw Heat transferred out of the Condenser (J)
%   W Work done to the HP cycle (Nm)
%   K Efficiency of the Compressor
%   Ce Heat capacity of the Evaporator (J/kg · K)
%   Cc Heat capacity of the Condenser (J/kg · K)
%   Cf Heat capacity of the refrigerant (J/kg · K)
%   m? w1 Massflow rate of refrigerant in evaporator (kg/s)
%   m? w2 Massflow rate of refrigerant in condenser (kg/s)
%   me Mass of evaporator (kg)
%   mc Mass of condenser (kg