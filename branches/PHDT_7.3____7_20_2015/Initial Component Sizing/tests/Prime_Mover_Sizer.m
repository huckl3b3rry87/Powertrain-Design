%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%------------------------Component Sizer----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear
close all
clc
addpath('Plots')
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 0;  % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss = 1; % RUN_TYPE.emiss = 1 - has emissions  &   RUN_TYPE.emiss = 0 - NO emissions
RUN_TYPE.plot = 1;  % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.soc_size = 0.001;
RUN_TYPE.trq_size = 5;  % Nm
plot_on = 0;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%------------------Load the Component Data--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data_universal;
cd('Components');
% -----------------Engine
Engine_41_kW_manip;
% Engine_102_kW;
% Engine_73_kW;
% Engine_50_kW;

% -----------------Motor
% Motor_75_kW;
Motor_30_kW;
% Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
% Motor_25_kW;

% ----------------Battery
Battery_ADVISOR;

% ----------------Vehicle
% High Speed
Vehicle_Parameters_small_car_plus;
% Vehicle_Parameters_4_HI_AV;
% Vehicle_Parameters_4_HI;
% Vehicle_Parameters_8_HI_AV;
% Vehicle_Parameters_8_HI;
% Vehicle_Parameters_Truck;

% Low Speed
% Vehicle_Parameters_4_low_AV;
% Vehicle_Parameters_4_low;
% Vehicle_Parameters_1_low_AV;
% Vehicle_Parameters_1_low;
cd ..

data;                              %  put data into structures
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-------------------------Design Variables--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dvar.fc_trq_scale = 1.1;
dvar.mc_trq_scale = 1.05;         % manually tune until it passes the acc. test
dvar.FD = 3;
dvar.G = 1.2;
mc_max_pwr_kW =  dvar.mc_trq_scale*vinf.mc_max_pwr_kW;
dvar.module_number = ceil(4*mc_max_pwr_kW*1000*Rint_size/(Voc_size^2));
Manipulate_Data_Structure;     % update the data based off of the new variable
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Engine Power-----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% simulation settings
test.motor = 0; % (0) - Engine only  (1) Motor and Engine   (3) Motor Only
test.req = 1;
% make sure that this speed is high enough, for the G sizing; the motor
% needs to be tested past it's limit (otherwise the test will be flawed)
test.Vsim = (0:0.1:120*param.mph_mps)';
ttt = 1;
n = length(vinf.gear);

for FD = 1:0.005:14
    dvar.FD = FD;
    [Sim_Grade, F_max_6, V_max_6, RR] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
    
    if isempty(V_max_6);
        V_max_6 = NaN;
    end
    
    if isempty(Sim_Grade.V_max_t)
        Sim_Grade.V_max_t = NaN;
    end
    
    FD_sim(ttt) = FD;
    V_6(ttt) = V_max_6;
    V_act(ttt) =  Sim_Grade.V_max_t;
    ttt = ttt + 1;
end

[Max_Spd_temp, I_temp] = max(V_6);
FD_final = FD_sim(I_temp)*0.9;
[Junk, I] = min(abs(FD_final - FD_sim));
Max_Spd = V_6(I);
Final_Drive_Plot;

% update design variable
dvar.FD = FD_sim(I);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-size the engine based off meeting average power of several drive cycles-%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% optional functionality - currently not enabled
% Average_Drive_Cycle_Power;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--size the engine so that it meets the rest of the grade requirements----%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% simulation settings
test.motor = 0; % (0) - Engine only  (1) Motor and Engine   (3) Motor Only
test.req = 2;

iii = 1;
for fc_trq_scale = 0.1:0.005:1.75
    dvar.fc_trq_scale = fc_trq_scale;
    
    % update the data based off of the new trq scale
    Manipulate_Data_Structure;
    [Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
    
    if isempty(Sim_Grade.V_max_t)
        V_diff(iii) = NaN;
    else
        V_diff(iii) = abs(Sim_Grade.V_max_t - test.V(test.req)); % Needs to be greater!! -Change this later
    end
    fc_trq_sim(iii) =  fc_trq_scale;
    iii = iii + 1;
end
if plot_on == 1
    figure(3); clf
    plot(fc_trq_sim,V_diff/param.mph_mps)
    xlabel('fc trq scale')
    ylabel('V diff')
end
[Min, I] = min(V_diff);
fprintf('The best fc_trq_scale is: ')
fc_trq_sim(I)  % If the fc_trq scale goes up then it will not lower the final speed

% update data structure with selected trq scale
dvar.fc_trq_scale = fc_trq_sim(I);
Manipulate_Data_Structure;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------------Motor Gear -----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% size motor off off maximum vehicle speed (with no motor on)

% simulation settings
test.motor = 0; % (0) - Engine only  (1) Motor and Engine   (3) Motor Only
test.req = 1;   % on flat land motor and engine speed should be close to same max
[Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );

% size motor to match the vehicle speed with the engine only, so do
% not need to update these in loop
V_max_t = Sim_Grade.V_max_t;
V_eng = V_max_t/param.mph_mps;  % mph

iii = 1;
for G = 0.3:0.1:5
    clear A
    clear I
    dvar.G = G;
    
    % resimulate to get new max speed where motor can apply torque
    [Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
    
    % figure out highest speed motor can help move vehicle
    Motor_Tractive_Effort = Sim_Grade.Motor_Tractive_Effort;
    A =  isnan(Motor_Tractive_Effort);
    I = find(A==0);
    if isempty(I) % if a never = 0, all nan..
        fprintf('ERROR: motor cannot help move vehicle with this gear value!\n');
        break;
    end
    
    % actually max vehicle speed motor can opperate at
    Max_Motor_Spd = test.Vsim(I(end));
    V_mot = Max_Motor_Spd/param.mph_mps;   % mph
    V_diff_mot(iii) = abs(V_mot-V_eng);
    G_sim(iii) = dvar.G;
    iii = iii + 1;
end

if plot_on == 1
    figure(5);clf
    plot( G_sim,V_diff_mot/param.mph_mps)
    xlabel('Motor Gear Ratio')
    ylabel('Velocity Difference')
end
[Min, I] = min(V_diff_mot);
fprintf('The best G ratio is: ')
G_sim(I)

% update design variable
dvar.G = G_sim(I);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------------Motor Size  ----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% determine acc. req. based off drive cycles
S = 35;                    % number of points to calcualte acc. at
dt_2 = 0.0002;
graph = 1;
[ V_0, V_f, Acc_Final, leg ] = Accel_Req_High( S, dt_2, graph );  % Exclude US06 and LA92 and COMMUTTER!!

% chop off end of vector
V_0 = V_0(1:end-3);
V_f = V_f(1:end-3);
Acc_Final = Acc_Final(1:end-3);

cd('Initial Component Sizing')
delete V_0.mat V_f.mat Acc_Final.mat
save('V_0','V_0')
save('V_f','V_f')
save('Acc_Final','Acc_Final')
cd ..

% run the overall acceleration test
V_0_test = 0; % could change, but currently the test starts at zero

[ Sim_Variables ] = Acceleration_Test(V_0_test, param, vinf, dvar);

if ~isempty(Sim_Variables)
    % save variables
    x_sim = Sim_Variables.x_sim;
    V_sim = Sim_Variables.V_sim;       % m/s
    acc_sim = Sim_Variables.acc_sim;
    Teng_sim = Sim_Variables.Teng_sim;
    Tm_sim = Sim_Variables.Tm_sim;
    We_sim = Sim_Variables.We_sim;    % rpm
    Wm_sim = Sim_Variables.Wm_sim;    % rpm
    time_sim = Sim_Variables.time_sim;
end

% basic acceleration test
[ PASS_1, V_actual ] = Acceleration_Time_Check( Sim_Variables, test.V_0_n,test.V_f_n, test.dt_2 );
 V_actual/param.mph_mps
% performance check for selected drive cycles
[ PASS_2,V_fail] = Max_Acceleration(V_0,V_f, Acc_Final, Sim_Variables);
% V_fail/param.mph_mps

Pass_Total = [PASS_1,PASS_2];

fprintf('Did the vehicle pass??? \n\n')
I = [];
if any(Pass_Total == 0)
    fprintf('Nope!! \n')
    I = find(Pass_Total == 0)
    fprintf('\n\n')
else
    fprintf('Yep!! \n\n')
end

% plot the results
Kinematics_Plot;
Kinetics_Plot;

dvar

% simulation settings
test.motor = 1; % (0) - Engine only  (1) Motor and Engine   (3) Motor Only
test.req = 1;   % on flat land motor and engine speed should be close to same max

Manipulate_Data_Structure;
[Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
Grade_Plot;

figure(101)
plot(Sim_Variables.V_sim/param.mph_mps,Sim_Variables.acc_sim,'b--','linewidth',6)
legend(leg, 'Actual Vehicle Performance')
