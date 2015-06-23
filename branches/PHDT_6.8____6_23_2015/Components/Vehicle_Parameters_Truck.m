% Define Vehicle Parameters

% Define Load
lb2kg = 0.453592;
Sw = 0*lb2kg;
% luggage = 30*8; % 30 kg per passenger
% people = 70*8; % 70 kg per passenger
Load = 0;

% Base Vehicle
% Mass Information
MTotal = 2688.7180162729;
MChassis = 2086.524902;
MSteering = 17.9969748396;
    MPowertrain = 53.359237;
% MPowertrain = 0; % dv will take into account
MTireFL = 68.0388555;
MTireFR = 68.0388555;
MTireRL = 68.0388555;
MTireRR = 68.0388555;
MSuspFL = 43.2706024706;
MSuspFR = 43.2706024706;
MSuspF = 50.0;
MSuspRL = 38.390519246;
MSuspRR = 38.390519246;
MSuspR = 45.359237;

MASS = MTotal - MPowertrain;

Base_Vehicle = MASS;

g = 9.81;  % (m/s^2)
rho = 1.22;     % density of air [kg/m^3]
Cd = 0.7; % Drag Coefficient

rwh = 0.5480;   % Define the radius of the tire (m)
Frr = 0.015;  % Rolling Resistance
grade = 0; % Road Grade
% 6 ft 6.9in x 5 ft 8.9 in
% 78.9 in x 68.9 in =    3.5072 m^2
Af = 3.58;  % [m^2], vehicle frontal area (m^2)
nt = 1;  % Transmission Efficency

% Define Conversion Factors
mph_mps = 1/2.237;
rpm2rads = pi/30;
rads2rpm = 1/rpm2rads;
gasoline_density = 0.7197; % [kg/liter]
liter2gallon = 0.264172;

% Define Some battery stuff
MIN_SOC = 0.4;
MAX_SOC = 0.8;

Paux =  2000;
%225 kW maxpower...
gear = [2.48 1.48 1 0.75];  % [1st 2nd...]             % Gear Level

% Performance Requirements
% Test 1
test.V(1) = 68*param.mph_mps;
test.alpha(1) = 0*pi/180;
% Test 2
test.V(2) = 40*param.mph_mps;
test.alpha(2) = 4*pi/180;

% acceleration test
test.V_0_n = 0;
test.V_f_n = 38;
test.dt_2 = 10;
