%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%------------------------Component Sizer----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear all
close all
clc
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 0;  % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss = 1; % RUN_TYPE.emiss = 1 - has emissions  &   RUN_TYPE.emiss = 0 - NO emissions
RUN_TYPE.plot = 1;  % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.soc_size = 0.001;
RUN_TYPE.trq_size = 5;  % Nm
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
% Motor_30_kW;
% Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
Motor_25_kW;

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
dvar.fc_trq_scale = 1;
dvar.mc_trq_scale = 0.9;         % manually tune until it passes the acc. test
dvar.FD = 2;
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

% resimualte with selected gear ratio
dvar.FD = FD_sim(I);

Manipulate_Data_Structure;
[Sim_Grade, F_max_6, V_max_6, RR] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
Grade_Plot_1;

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
figure(3); clf
plot(fc_trq_sim,V_diff/param.mph_mps)
xlabel('fc trq scale')
ylabel('V diff')
[Min, I] = min(V_diff);
fprintf('The best fc_trq_scale is: ')
fc_trq_sim(I)  % If the fc_trq scale goes up then it will not lower the final speed

% resimulate with selected trq scale
dvar.fc_trq_scale = fc_trq_sim(I);
Manipulate_Data_Structure; 
[Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
Grade_Plot_1;

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
figure(5);clf
plot( G_sim,V_diff_mot/param.mph_mps)
xlabel('Motor Gear Ratio')
ylabel('Velocity Difference')

[Min, I] = min(V_diff_mot);
fprintf('The best G ratio is: ')
G_sim(I)

dvar.G = G_sim(I);
[Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test );
Grade_Plot_1;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------------Motor Size  ----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% determine acc. req. based off drive cycles
clear V_0 V_f
S = 20;                    % number of points to calcualte acc. at
dt_2 = 0.0002;
graph = 1;
% % [ V_0, V_f, Acc_Final ] = Accel_Req_City( S, dt_2, graph );  % V_Final is in MPH
[ V_0, V_f, Acc_Final ] = Accel_Req_High( S, dt_2, graph );  % Exclude US06!!

% chop off end of vector
V_0 = V_0(1:end-3);
V_f = V_f(1:end-3);
Acc_Final = Acc_Final(1:end-3);

cd('Initial Component Sizing')
save('V_0','V_0')
save('V_f','V_f')
save('Acc_Final','Acc_Final')
cd ..

% set up simultion variables
V_sim_full = [];
We_sim_full = [];
Wm_sim_full = [];
x_sim_full = [];
acc_sim_full = [];
Teng_sim_full = [];
Tm_sim_full = [];
time_sim_full = [];

EE = 1;
index(1) = [1];
for i = 1:(length(V_0-2)+1)
    if i == (length(V_0)+1)     % last one
        TYPE = 1;               % velocity req.
        Acc_Final_temp = 100;   % does not matter
        [ PASS, Sim_Variables, time_sixty, Acc_Test ] = Acceleration_Test(test.V_0_n,test.V_f_n, Acc_Final_temp, test.dt_2, param, vinf, dvar, TYPE);
    else
        TYPE = 0;               % acceleration req.
        [ PASS, Sim_Variables, time_sixty, Acc_Test ] = Acceleration_Test(V_0(i),V_f(i), Acc_Final(i), dt_2, param, vinf, dvar, TYPE);    
    end
    Pass_Total(i) = PASS;
    if ~isempty(Sim_Variables)
        index(EE+1) = [index(EE) + length(Sim_Variables(2:end,1))];
        EE = EE + 1;
        
        % save variables
        x_sim_full = [ x_sim_full;Sim_Variables(:,1)];
        V_sim_full = [V_sim_full; Sim_Variables(:,2)];       % mph
        acc_sim_full = [ acc_sim_full; Sim_Variables(:,3)];
        Teng_sim_full = [Teng_sim_full; Sim_Variables(:,4)];
        Tm_sim_full = [Tm_sim_full; Sim_Variables(:,5)];
        We_sim_full = [We_sim_full; Sim_Variables(:,6)];    % rpm
        Wm_sim_full = [ Wm_sim_full; Sim_Variables(:,7)];   % rpm
        time_sim_full = [time_sim_full; Sim_Variables(:,8)];
        time_sixty_save{i} = time_sixty;
        Acc_Test_save{i} = Acc_Test;
    end
end

fprintf('Did the vehicle pass??? \n\n')
I = [];
if any(Pass_Total == 0)
    fprintf('Nope!! \n')
    I = find(Pass_Total == 0)
    fprintf('\n\n')
else
    fprintf('Yep!! \n\n')
end

if ~isempty(I)
    e = I(1);    % plot what failed
else
    e = (EE-1);  % plot zero to whatever
end

start = index(e)+ e;
stop = index(e+1);

x_sim = x_sim_full(start:stop);
V_sim =  V_sim_full(start:stop);
acc_sim = acc_sim_full(start:stop);
Teng_sim =  Teng_sim_full(start:stop);
Tm_sim = Tm_sim_full(start:stop);
We_sim = We_sim_full(start:stop);
Wm_sim =  Wm_sim_full(start:stop);
time_sim = time_sim_full(start:stop);

% Plot the results
Kinematics_Plot;
Kinetics_Plot;

dvar
Grade_Plot_1;



