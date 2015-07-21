function [ FAIL, MPG, emission, delta_SOC, sim ] = find_weights( a1,a2,a3,shift,eng,clutch,RUN_TYPE)
clc
tic 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------------------Load All Data--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data_universal;
cd('Components');
%                              ~~ Engine ~~
% Engine_30_kW;
Engine_41_kW_manip;
% Engine_41_kW_smooth;
% Engine_50_kW;
% Engine_73_kW;
% Engine_95_kW;
% Engine_102_kW;
% Engine_186_kW;
% Engine_224_kW;

%                              ~~ Motor ~~
% Motor_int;
% Motor_75_kW;
% Motor_30_kW;
% Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
% Motor_16_kW;
Motor_25_kW;

%                             ~~ Battery ~~
% Battery_int;  % No variation with the number of modules in this battery!!
Battery_ADVISOR;

%                              ~~ Vehicle ~~
% Vehicle_Parameters_4_HI_AV;
% Vehicle_Parameters_4_HI;
Vehicle_Parameters_small_car_plus;
% Vehicle_Parameters_8_HI_AV;
% Vehicle_Parameters_8_HI;

% Low Speed
% Vehicle_Parameters_4_low_AV;
% Vehicle_Parameters_4_low;
% Vehicle_Parameters_1_low_AV;
% Vehicle_Parameters_1_low;

cd ..

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-------------------Put all the data into structures----------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Design Variables-------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dvar.FD = 5.65;
dvar.G = 1.1;
dvar.fc_trq_scale = 1.065;
dvar.mc_trq_scale = 0.9;
dvar.module_number = 15;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Data-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Manipulate_Data_Structure;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Select Drive Cycle----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                              ~~ Standard ~~

% cyc_name = 'HWFET';
% cyc_name = 'UDDS';
% cyc_name = 'US06';
cyc_name = 'SHORT_CYC_HWFET';
% cyc_name = 'RAMP';
% cyc_name = 'LA92';
% cyc_name = 'CONST_65';
% cyc_name = 'CONST_45';
% cyc_name = 'COMMUTER';

% City
% cyc_name = 'INDIA_URBAN';
% cyc_name = 'MANHATTAN';
% cyc_name = 'Nuremberg';
% cyc_name = 'NYCC';
% cyc_name = 'AA_final';
%                              ~~ AV~~

% cyc_name = 'US06_AV';
% cyc_name = 'HWFET_AV';
% cyc_name = 'AA_final_AV';

[cyc_data] = Drive_Cycle(param, vinf, cyc_name );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Weighing Parameters for DP------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Weighing Parameters for DP------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
weight.fuel = 1;  
if RUN_TYPE.emiss_data == 1     % whether or not the engine maps have emissions data
    if RUN_TYPE.emiss_on == 0
        weight.NOx = 0;
        weight.CO = 0;
        weight.HC = 0;
        RUN_TYPE.folder_name = 'main - no emiss';
    else
        weight.NOx = a1*vinf.ave_fuel/vinf.ave_NOx;
        weight.CO = a2*vinf.ave_fuel/vinf.ave_CO;
        weight.HC = a3*vinf.ave_fuel/vinf.ave_HC;
        RUN_TYPE.folder_name = 'main - emiss';
    end
else
    RUN_TYPE.folder_name = 'main - no emiss data';
end

weight.shift = shift;
weight.engine_event = eng*vinf.fc_max_pwr_initial_kW/41;  % also scaled by dvar.fc_trq, can do inside DP or at each evaluation...
weight.clutch_event = clutch;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------Simulate-------------------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[FAIL, MPG, emission, delta_SOC, sim] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight);
return

