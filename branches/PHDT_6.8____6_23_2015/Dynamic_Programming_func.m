% Dynamic Programming - written by Huckleberry Febbo - 07/20/2014

function [FAIL, MPG, emission, delta_SOC, sim] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Create New Tables-----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%
tables = [cyc_data.cyc_name, RUN_TYPE.folder_name, ' tables'];
%%
check_exist = exist(fullfile(cd,tables),'dir');
if check_exist == 7
    rmdir(tables,'s')                 % Delete any left over info
end
mkdir(tables)
cd(tables);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Simulate all Possible Dynamics----------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%% define state grids
x1_grid = (0.4:RUN_TYPE.soc_size:0.8)';  % SOC
x1_length = length(x1_grid);

x2_grid = [1 2 3];                        % engine off (1) & engine on (2) & engine idling (3)
x2_length = length(x2_grid);

x3_grid = vinf.gear;                     % gear level - [1st 2nd...]
x3_length = length(x3_grid);

% define control grids
u1_grid = vinf.eng_control_trq';         % engine torque [N-m]
u1_length = length(u1_grid);

u2_grid = [-1 0 1];                      % shift down, nothing, up
u2_length = length(u2_grid);

u3_grid = [1 2 3];                       % move to: engine off (1) & engine on (2) & engine idling (3)
u3_length = length(u3_grid);

% define speed converter properties for moving Off - see automotive transmission fundamentals pg #80
vinf.W_gb_is_min = 1000*(pi/30);                               % [rad/s]- minimum speed of gearbox input shaft in first gear where it can be directly connected to the engine
vinf.W_eng_opt = 3000*pi/30;                                   % [rad/s]- heuristic, engine can run at this speed even when vehicle is stopped, also engine starts at this speed when moving off and then reduces linearly to vinf.Wgb_is_min
vinf.W_eng_mo = linspace(vinf.W_eng_opt,vinf.W_gb_is_min,20);  % [rad/s]- moving off engine speed vector
vinf.W_gb_mo = linspace(0,vinf.W_gb_is_min,20);                % [rad/s]- moving off gearbox input shaft speed vector
vinf.We_fail = 550*param.rpm2rads;

%% define SOC soft cnstraints
SOC_penalty = linspace(0.1,10,20);
NEAR_SOC_min = param.MIN_SOC + fliplr(linspace(RUN_TYPE.soc_size,0.02,20));
NEAR_SOC_max = param.MAX_SOC - fliplr(linspace(RUN_TYPE.soc_size,0.02,20));

if RUN_TYPE.sim == 0
    tic
end

for t = 1:cyc_data.time_cyc
    Tm_max = single(zeros(x3_length,u1_length,u2_length));               % [x3]x[u1]x[u2]
    Tm_min = single(zeros(x3_length,u1_length,u2_length));               % [x3]x[u1]x[u2]
    Tm_save = single(zeros(x3_length,u1_length,u2_length));              % [x3]x[u1]x[u2]
    Wm_save = single(zeros(x3_length,u1_length,u2_length));              % [x3]x[u1]x[u2]
    We_save = single(zeros(x3_length,u1_length,u2_length));              % [x3]x[u1]x[u2]
    table_x1 = single(zeros(x1_length,x3_length,u1_length,u2_length));   % [x1]x[x3]x[u1]x[u2]
    inst_fuel = single(zeros(x3_length,u1_length,u2_length));            % [x3]x[u1]x[u2]
    inst_fuel_off = single(zeros(x3_length,1,u2_length));                % [x3]x[1]x[u2]
    inst_fuel_idle = single(zeros(x3_length,1,u2_length));
    infeasible_Te = single(zeros(x3_length,u1_length,u2_length));        % [x1]x[x3]x[u1]x[u2]
    infeasible_Pbatt = single(zeros(x1_length,x3_length,u1_length,u2_length));
    
    for x3 = 1:x3_length           % go through all of the gears
        x3_c = x3_grid(x3);
        
        for u2 = 1:u2_length       % shift down, don't shift, and shift up
            u2_c = u2_grid(u2);
            
            if (x3_c == x3_grid(1) && u2_c == u2_grid(1)) || (x3_c == x3_grid(x3_length) && u2_c == u2_grid(u2_length))
                u2_c = 0;          % cannot shift
            end
            
            if u2 == 1 || u2 == 3  % shift penalty
                Shift_Penalty = weight.shift;
            else
                Shift_Penalty = 0;
            end
            
            % update x3 and define new gear ID
            New_Gear_Index = x3 + u2_c;
            x3_n = x3_grid(New_Gear_Index);
            
            % speed of input shaft to gearbox
            Wis_gb = cyc_data.Ww(t)*dvar.FD*x3_n;                   % [rad/s] 

            % engine
            if  New_Gear_Index == 1 && Wis_gb < vinf.W_gb_is_min    % use moving off strategy
                We_c = interp1(vinf.W_gb_mo,vinf.W_eng_mo,Wis_gb);  % [rad/s]
            else
                We_c = Wis_gb;                                      % [rad/s]
            end
            Te_c =  u1_grid;                                                                 % engine control, [u1]x[1]
            Te_drive = Te_c;                                                                 % subtract auxiliary power (torque) here     
            
            % check engine
             We_save(x3,:,u2) =  We_c*ones(size(u1_grid));      %  speed of the engine depends on the gear and engine state
              
            % saturate engine speed - for max torque lookup & fuel lookup
            if We_c < vinf.W_eng_min,   We_c = vinf.W_eng_min; end
            if We_c > vinf.W_eng_max,   We_c = vinf.W_eng_max; end
            
            Te_max =  interp1(vinf.eng_consum_spd_old,vinf.eng_max_trq,We_c)*ones(size(Te_c));
            if cyc_data.Ww(t)~=0
                infeasible_Te(x3,:,u2) = (Te_max < Te_c);                       % [u1]x[1]
            else           % if the vehicle is stopped, the engine cannot charge the motor
                infeasible_Te(x3,:,u2) = (0 < Te_c);                            % [u1]x[1]
            end
            
            % saturate for lookup tables
            Te_min = vinf.Te_min*ones(size(Te_c));
            Te_c(Te_c > Te_max) = Te_max(Te_c > Te_max);
            Te_c(Te_c < Te_min) = Te_min(Te_c < Te_min);
            
            fuel = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,Te_c,We_c,'linear')*cyc_data.dt)';
            if RUN_TYPE.emiss_data == 1
                NOx = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_nox_map,Te_c,We_c,'linear')*cyc_data.dt)';
                CO = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_co_map,Te_c,We_c,'linear')*cyc_data.dt)';
                HC = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_hc_map,Te_c,We_c,'linear')*cyc_data.dt)';
                inst_fuel(x3,:,u2) = weight.fuel*fuel + weight.NOx*NOx + weight.CO*CO + weight.HC*HC + Shift_Penalty*ones(size(fuel));
                
                % for idling - should be the same each time, could remove
                % from loop
                fuel_idle = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,vinf.Te_min, vinf.W_gb_is_min,'linear')*cyc_data.dt)';
                NOx_idle = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_nox_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
                CO_idle =  (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_co_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
                HC_idle =(interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_hc_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
                inst_fuel_idle(x3,1,u2) = weight.fuel*fuel_idle + weight.NOx*NOx_idle + weight.CO*CO_idle + weight.HC*HC_idle + Shift_Penalty;
            else
                inst_fuel(x3,:,u2) = weight.fuel*fuel + Shift_Penalty*ones(size(fuel));
                
                % for idling
                fuel_idle = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,vinf.Te_min, vinf.W_gb_is_min,'linear')*cyc_data.dt)';
                inst_fuel_idle(x3,1,u2) = weight.fuel*fuel_idle + Shift_Penalty;
            end
            % save for the grid points where no torque is applied and the engine is off
            inst_fuel_off(x3,1,u2) = Shift_Penalty;  % [x3]x[1]x[u2]  - (gear x zero torque x gear control) - now this just penalizes shifting events
            
             % motor
            Wm_c = cyc_data.Ww(t)*dvar.FD*dvar.G;                                            % [rad/sec]
            Tm_c = cyc_data.Tw(t)/(dvar.FD*dvar.G)*ones(size(Te_c)) - Te_drive*x3_n/dvar.G;  % [u1]x[1]
            
            % check motor
            Tm_max_current = interp1(vinf.m_map_spd,vinf.m_max_trq,Wm_c)*ones(size(u1_grid));
            Tm_max(x3,:,u2) =  Tm_max_current;                                            % [x2]x[x3]x[u1]x[u2]x[u3]
            Tm_min_current = interp1(vinf.m_map_spd,vinf.m_max_gen_trq,Wm_c)*ones(size(u1_grid));
            Tm_min(x3,:,u2) =  Tm_min_current;                                            % [x2]x[x3]x[u1]x[u2]x[u3]
            Tm_save(x3,:,u2) = Tm_c;                                                      % [x2]x[x3]x[u1]x[u2]x[u3]
            Wm_save(x3,:,u2) = Wm_c*ones(size(u1_grid));                                  % [u1]x[1]  -  check for each gear
            
            % saturate the motor for the efficiency lookup table
            Tm_eff = Tm_c;
            Tm_eff(Tm_c > Tm_max_current) = Tm_max_current(Tm_c > Tm_max_current);
            Tm_eff(Tm_c < Tm_min_current) =  Tm_min_current(Tm_c < Tm_min_current);
            Wm_eff = Wm_c;
            Wm_eff(Wm_c > vinf.Wm_max) = vinf.Wm_max;
            Wm_eff(Wm_c < vinf.Wm_min) = vinf.Wm_min;
            eff_m = interp2(vinf.m_map_trq, vinf.m_map_spd, vinf.m_eff_map, Tm_eff, abs(Wm_eff))';
            eff_m(isnan(eff_m)) = 0.2;
           
            % update x1
            Pbat_charge = (Wm_eff*Tm_eff).*(eff_m*vinf.ess_coulombic_eff);    % Tm_c < 0
            Pbat_discharge = (Wm_eff*Tm_eff)./(eff_m*vinf.ess_coulombic_eff); % battery needs to supply more power!!
            
            Pbat = Pbat_discharge;
            Pbat(Tm_c < 0) = Pbat_charge(Tm_c < 0);
            
            Pbat = repmat(Pbat,[1, x1_length]);
            Pbat = permute(Pbat, [2 1]);
            
            % discharge
            Pbatt_max = repmat(interp1(vinf.ess_soc, vinf.ess_max_pwr_dis, x1_grid),[1,u1_length]);
            rint_discharge = repmat(interp1(vinf.ess_soc,vinf.ess_r_dis,x1_grid),[1,u1_length]);
            
            % charge
            Pbatt_min = -repmat(interp1(vinf.ess_soc, vinf.ess_max_pwr_chg, x1_grid),[1,u1_length]);
            rint_charge = repmat(interp1(vinf.ess_soc,vinf.ess_r_chg,x1_grid),[1,u1_length]);
            
            % check battery infeasibility
            infeasible_Pbatt(:,x3,:,u2) = (Pbatt_max < Pbat); % do not penlize it for operating too low; can brake
            
            % saturate nattery
            Pbat(Pbatt_max < Pbat) = Pbatt_max(Pbatt_max < Pbat);
            Pbat(Pbat < Pbatt_min) = Pbatt_min(Pbat < Pbatt_min);
            
            % charge & discharge resistances
            rint_c = rint_charge;
            rint_c(Pbat > 0) = rint_discharge(Pbat > 0);
            
            % SOC calculation
            Voc_c = repmat(interp1(vinf.ess_soc,vinf.ess_voc,x1_grid), [1, u1_length]);
            SOC_c_matrix = repmat(x1_grid,[1, u1_length]);
            SOC_n =  SOC_c_matrix -(Voc_c -(Voc_c.^2 -4*Pbat.*rint_c).^(1/2))./(2*rint_c*vinf.ess_cap_ah*3600)*cyc_data.dt;
            table_x1(:,x3,:,u2) = SOC_n;
        end           % end of u2 (gear control)
    end               % end of x3 (sear state)
    % check all motor torques from previous loops
    infeasible_Tm = (Tm_save > Tm_max);      % can brake to make the rest up
    
    % check all engine speeds from previous loops
    infeasible_We = (We_save < vinf.We_fail) | (We_save > vinf.W_eng_max);
    
    % add in extra dimensions for engine state & engine control
    infeasible_Pbatt = repmat(infeasible_Pbatt,[1,1,1,1,x2_length,u3_length]);
    infeasible_Pbatt = permute(infeasible_Pbatt,[1 5 2 3 4 6]);
    
    % motor
    infeasible_Tm = repmat(infeasible_Tm,[1,1,1,x2_length,x1_length,u3_length]);
    infeasible_Tm = permute(infeasible_Tm,[5 4 1 2 3 6]);
    infeasible_Wm = (Wm_save > vinf.Wm_max) | (Wm_save < vinf.Wm_min);
    infeasible_Wm = repmat(infeasible_Wm,[1,1,1,x2_length,x1_length,u3_length]);
    infeasible_Wm = permute(infeasible_Wm,[5 4 1 2 3 6]);
    
    % engine
    infeasible_We = repmat(infeasible_We,[1,1,1,x2_length,x1_length,u3_length]);
    infeasible_We = permute(infeasible_We,[5 4 1 2 3 6]);
    infeasible_Te = repmat(infeasible_Te,[1,1,1,x2_length,x1_length,u3_length]);
    infeasible_Te = permute(infeasible_Te,[5 4 1 2 3 6]);
    
    % add in the extra dimension for engine state | note: SOC tables are not
    % affected by what it was, they will be affected by the engine torque
    % control appled at that time step though
    table_x1 = repmat(table_x1,[1,1,1,1,x2_length]);
    table_x1 = permute(table_x1,[1 5 2 3 4]);
    
    % check SOC
    infeasible_SOC = (table_x1 < param.MIN_SOC) | (table_x1 > param.MAX_SOC);   
    infeasible_SOC = repmat(infeasible_SOC,[1,1,1,1,1,u3_length]);
    table_x1(table_x1 > param.MAX_SOC) = param.MAX_SOC;
    table_x1(table_x1 < param.MIN_SOC) = param.MIN_SOC;
    
    % lower SOC penalties
    SOC_soft = SOC_penalty(1)*((NEAR_SOC_min(2) < table_x1)  & (table_x1 < NEAR_SOC_min(1)));
    SOC_soft = SOC_soft + SOC_penalty(2)*(NEAR_SOC_min(3) < table_x1  & table_x1 < NEAR_SOC_min(2));
    SOC_soft = SOC_soft + SOC_penalty(3)*(NEAR_SOC_min(4) < table_x1  & table_x1 < NEAR_SOC_min(3));
    SOC_soft = SOC_soft + SOC_penalty(4)*(NEAR_SOC_min(5) < table_x1  & table_x1 < NEAR_SOC_min(4));
    SOC_soft = SOC_soft + SOC_penalty(5)*(NEAR_SOC_min(6) < table_x1  & table_x1 < NEAR_SOC_min(5));
    SOC_soft = SOC_soft + SOC_penalty(6)*(NEAR_SOC_min(7) < table_x1  & table_x1 < NEAR_SOC_min(6));
    SOC_soft = SOC_soft + SOC_penalty(7)*(NEAR_SOC_min(8) < table_x1  & table_x1 < NEAR_SOC_min(7));
    SOC_soft = SOC_soft + SOC_penalty(8)*(NEAR_SOC_min(9) < table_x1  & table_x1 < NEAR_SOC_min(8));
    SOC_soft = SOC_soft + SOC_penalty(9)*(NEAR_SOC_min(10)< table_x1  & table_x1 < NEAR_SOC_min(9));
    SOC_soft = SOC_soft + SOC_penalty(10)*(NEAR_SOC_min(11)< table_x1 & table_x1 < NEAR_SOC_min(10));
    SOC_soft = SOC_soft + SOC_penalty(11)*(NEAR_SOC_min(12)< table_x1 & table_x1 < NEAR_SOC_min(11));
    SOC_soft = SOC_soft + SOC_penalty(12)*(NEAR_SOC_min(13)< table_x1 & table_x1 < NEAR_SOC_min(12));
    SOC_soft = SOC_soft + SOC_penalty(13)*(NEAR_SOC_min(14)< table_x1 & table_x1 < NEAR_SOC_min(13));
    SOC_soft = SOC_soft + SOC_penalty(14)*(NEAR_SOC_min(15)< table_x1 & table_x1 < NEAR_SOC_min(14));
    SOC_soft = SOC_soft + SOC_penalty(15)*(NEAR_SOC_min(16)< table_x1 & table_x1 < NEAR_SOC_min(15));
    SOC_soft = SOC_soft + SOC_penalty(16)*(NEAR_SOC_min(17)< table_x1 & table_x1 < NEAR_SOC_min(16));
    SOC_soft = SOC_soft + SOC_penalty(17)*(NEAR_SOC_min(18)< table_x1 & table_x1 < NEAR_SOC_min(17));
    SOC_soft = SOC_soft + SOC_penalty(18)*(NEAR_SOC_min(19)< table_x1 & table_x1 < NEAR_SOC_min(18));
    SOC_soft = SOC_soft + SOC_penalty(19)*(NEAR_SOC_min(20)< table_x1 & table_x1 < NEAR_SOC_min(19));
    SOC_soft = SOC_soft + SOC_penalty(20)*((param.MIN_SOC < table_x1) & (table_x1 < NEAR_SOC_min(20)));
    
    % upper SOC penalties
    SOC_soft = SOC_soft + SOC_penalty(1)*(NEAR_SOC_max(2)  > table_x1 & table_x1 > NEAR_SOC_max(1));
    SOC_soft = SOC_soft + SOC_penalty(2)*(NEAR_SOC_max(3)  > table_x1 & table_x1 > NEAR_SOC_max(2));
    SOC_soft = SOC_soft + SOC_penalty(3)*(NEAR_SOC_max(4)  > table_x1 & table_x1 > NEAR_SOC_max(3));
    SOC_soft = SOC_soft + SOC_penalty(4)*(NEAR_SOC_max(5)  > table_x1 & table_x1 > NEAR_SOC_max(4));
    SOC_soft = SOC_soft + SOC_penalty(5)*(NEAR_SOC_max(6)  > table_x1 & table_x1 > NEAR_SOC_max(5));
    SOC_soft = SOC_soft + SOC_penalty(6)*(NEAR_SOC_max(7)  > table_x1 & table_x1 > NEAR_SOC_max(6));
    SOC_soft = SOC_soft + SOC_penalty(7)*(NEAR_SOC_max(8)  > table_x1 & table_x1 > NEAR_SOC_max(7));
    SOC_soft = SOC_soft + SOC_penalty(8)*(NEAR_SOC_max(9)  > table_x1 & table_x1 > NEAR_SOC_max(8));
    SOC_soft = SOC_soft + SOC_penalty(9)*(NEAR_SOC_max(10) > table_x1 & table_x1 > NEAR_SOC_max(9));
    SOC_soft = SOC_soft + SOC_penalty(10)*(NEAR_SOC_max(11)> table_x1 & table_x1 > NEAR_SOC_max(10));
    SOC_soft = SOC_soft + SOC_penalty(11)*(NEAR_SOC_max(12)> table_x1 & table_x1 > NEAR_SOC_max(11));
    SOC_soft = SOC_soft + SOC_penalty(12)*(NEAR_SOC_max(13)> table_x1 & table_x1 > NEAR_SOC_max(12));
    SOC_soft = SOC_soft + SOC_penalty(13)*(NEAR_SOC_max(14)> table_x1 & table_x1 > NEAR_SOC_max(13));
    SOC_soft = SOC_soft + SOC_penalty(14)*(NEAR_SOC_max(15)> table_x1 & table_x1 > NEAR_SOC_max(14));
    SOC_soft = SOC_soft + SOC_penalty(15)*(NEAR_SOC_max(16)> table_x1 & table_x1 > NEAR_SOC_max(15));
    SOC_soft = SOC_soft + SOC_penalty(16)*(NEAR_SOC_max(17)> table_x1 & table_x1 > NEAR_SOC_max(16));
    SOC_soft = SOC_soft + SOC_penalty(17)*(NEAR_SOC_max(18)> table_x1 & table_x1 > NEAR_SOC_max(17));
    SOC_soft = SOC_soft + SOC_penalty(18)*(NEAR_SOC_max(19)> table_x1 & table_x1 > NEAR_SOC_max(18));
    SOC_soft = SOC_soft + SOC_penalty(19)*(NEAR_SOC_max(20)> table_x1 & table_x1 > NEAR_SOC_max(19));
    SOC_soft = SOC_soft + SOC_penalty(20)*(table_x1 > NEAR_SOC_max(20));
    
    % add in dimension for engine control
    SOC_soft = repmat(SOC_soft,[1,1,1,1,1,u3_length]);
    
    % add in extra dimensions for SOC & engine state & engine control | note: inst_fuel was [x3]x[u1]x[u2]
    inst_fuel = repmat(inst_fuel,[1,1,1,x2_length,x1_length,u3_length]);
    inst_fuel = permute(inst_fuel,[5 4 1 2 3 6]);
    
    % add in results for engine off  | note: inst_fuel_off was [x3]x[1]x[u2]
    inst_fuel_off = repmat(inst_fuel_off,[1,1,1,x1_length,1,1]);   % [x3{1}] x [1-for u1{2}] x [u2{3}] x [x1{4}] x [1-for x2{5}] x [1-for u3{6}]
    inst_fuel_off = permute(inst_fuel_off,[4 5 1 2 3 6]);
    inst_fuel(:,1,:,1,:,1) =  inst_fuel_off;      % still has shifting penalties
    inst_fuel(:,2,:,1,:,1) =  inst_fuel_off; 
    inst_fuel(:,3,:,1,:,1) =  inst_fuel_off;
    
    % add in engine idling results 
    inst_fuel_idle = repmat(inst_fuel_idle,[1,1,1,x1_length,1,1]);  % [x3{1}] x [1-for u1{2}] x [u2{3}] x [x1{4}] x [1-for x2{5}] x [1-for u3{6}]
    inst_fuel_idle = permute(inst_fuel_idle,[4 5 1 2 3 6]);
    inst_fuel(:,1,:,1,:,3) =  inst_fuel_idle;
    inst_fuel(:,2,:,1,:,3) =  inst_fuel_idle;
    inst_fuel(:,3,:,1,:,3) =  inst_fuel_idle;
    
    % penalize for using engine torque when engine is off
    inst_fuel(:,1,:,(2:end),:,1) = weight.infeasible*ones(size(inst_fuel(:,1,:,(2:end),:,1)))+ inst_fuel(:,1,:,(2:end),:,1);
    inst_fuel(:,2,:,(2:end),:,1) = weight.infeasible*ones(size(inst_fuel(:,2,:,(2:end),:,1)))+ inst_fuel(:,2,:,(2:end),:,1);
    inst_fuel(:,3,:,(2:end),:,1) = weight.infeasible*ones(size(inst_fuel(:,3,:,(2:end),:,1)))+ inst_fuel(:,3,:,(2:end),:,1);
    
    % penalize for using engine torque when engine is idling
    inst_fuel(:,1,:,(2:end),:,3) = weight.infeasible*ones(size(inst_fuel(:,1,:,(2:end),:,3)))+ inst_fuel(:,1,:,(2:end),:,3);
    inst_fuel(:,2,:,(2:end),:,3) = weight.infeasible*ones(size(inst_fuel(:,2,:,(2:end),:,3)))+ inst_fuel(:,2,:,(2:end),:,3);
    inst_fuel(:,3,:,(2:end),:,3) = weight.infeasible*ones(size(inst_fuel(:,3,:,(2:end),:,3)))+ inst_fuel(:,3,:,(2:end),:,3);
    
    % penalize for turning engine on
    inst_fuel(:,1,:,:,:,2) = weight.engine_event*ones(size(inst_fuel(:,1,:,:,:,2))) + inst_fuel(:,1,:,:,:,2);
    inst_fuel(:,1,:,:,:,3) = weight.engine_event*ones(size(inst_fuel(:,1,:,:,:,3))) + inst_fuel(:,1,:,:,:,3);
    
    % penalize for using clutch
    inst_fuel(:,1,:,:,:,3) = weight.clutch_event*ones(size(inst_fuel(:,1,:,:,:,3))) + inst_fuel(:,1,:,:,:,3);
    inst_fuel(:,2,:,:,:,3) = weight.clutch_event*ones(size(inst_fuel(:,2,:,:,:,3))) + inst_fuel(:,2,:,:,:,3);
    
    % do not penalize engine when it is off
    infeasible_We(:,1,:,:,:,1) = zeros(size(infeasible_We(:,1,:,:,:,1)));
    infeasible_We(:,2,:,:,:,1) = zeros(size(infeasible_We(:,2,:,:,:,1)));
    infeasible_We(:,3,:,:,:,1) = zeros(size(infeasible_We(:,3,:,:,:,1)));
    
    infeasible_Te(:,1,:,:,:,1) = zeros(size(infeasible_Te(:,1,:,:,:,1)));
    infeasible_Te(:,2,:,:,:,1) = zeros(size(infeasible_Te(:,2,:,:,:,1)));
    infeasible_Te(:,3,:,:,:,1) = zeros(size(infeasible_Te(:,3,:,:,:,1)));
    
    % opperational cost
    table_L = inst_fuel + SOC_soft + weight.infeasible*(infeasible_SOC + infeasible_We + infeasible_Tm + infeasible_Wm + infeasible_Te + infeasible_Pbatt);   %[x2]x[u1]x[u2]x[u3]
    
    savename = ['Transitional Cost = ',num2str(t),' Table.mat'];
    save(savename,'table_x1','table_L');
    
    if RUN_TYPE.sim == 0  % for DP only runs
        complete = 100-(cyc_data.time_cyc-t)/(cyc_data.time_cyc)*100;
        clc
        fprintf('__________________________________________________\n\n')
        fprintf('Percent Complete of Dynamic Simulation = ')
        fprintf(num2str(complete))
        fprintf('\n')
        fprintf('__________________________________________________\n\n')
    end
end
cd ..  % come out of the folder
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-------------------------Dynamic Programming-----------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% define parameters
BETA = weight.CS;
Desired_SOC = 0.55; % extract solutions from the middle

J_STAR = repmat(BETA*(x1_grid - Desired_SOC).^2, [1, x2_length,x3_length]); % terminal state penalty, [x1]x[x2]
J_STAR(J_STAR~=0) = J_STAR(J_STAR~=0) + weight.SOC_final;

cd(tables);         % go into tables
for t = cyc_data.time_cyc:-1:1
    loadfile_name = ['Transitional Cost = ',num2str(t),' Table.mat'];
    load(loadfile_name);
    table_x1 = repmat(table_x1,[1,1,1,1,1,u3_length]); % add in extra dimension for engine control
    SOC_State_Penalty = single(zeros(x1_length,x2_length,x3_length,u1_length,u2_length,u3_length));
    for x2 = 1:x2_length                  % eng state
        for x3 = 1:x3_length              % gear state
            for u1 = 1:u1_length          % torque control  - should be able to eliminate this for loop
                for u2 = 1:u2_length      % gear control
                    for u3 = 1:u3_length  % eng control
                        
                        % next gear state
                        if (u2 == 1 && x3 == 1) || (u2 == 3 && x3 == x3_length)
                            u2_c = 0; % cannot shift; will move off of state grid
                            Infeasible_Shift = weight.infeasible*single(ones(x1_length,1,1,1,1,1));
                        else
                            u2_c = u2_grid(u2);
                            Infeasible_Shift = single(zeros(x1_length,1,1,1,1,1));
                        end
                        x3_n = x3 + u2_c;
                        
                        % next engine state
                        if  u3 == 1     % eng is off
                            x2_n = 1;
                        elseif u3 == 2  % eng is on
                            x2_n = 2;
                        else            % eng is idling
                            x2_n = 3;
                        end
                        
                        % penalizing where they land - just penalizing the SOC
                        F  = griddedInterpolant(x1_grid,J_STAR(:,x2_n,x3_n),'linear');
                        SOC_State_Penalty(:,x2,x3,u1,u2,u3) = F(table_x1(:,x2,x3,u1,u2,u3)) + Infeasible_Shift; % only u2 and u3 change the state
                    end
                end
            end
        end
    end
    J_temp = table_L + SOC_State_Penalty;
    
    for x1 = 1:x1_length
        for x2 = 1:x2_length
            for x3 = 1:x3_length
                S = squeeze(J_temp(x1,x2,x3,:,:,:));
                [~,idx] = min(S(:));
                [u1_id,u2_id,u3_id] = ind2sub(size(S),idx);
                opt_trq(x1,x2,x3) = u1_grid(u1_id);
                opt_id_u2(x1,x2,x3) = u2_id;
                opt_eng_ctr(x1,x2,x3) = u3_grid(u3_id);
                
                % define the new optimum value
                opt_value(x1,x2,x3) = J_temp(x1,x2,x3,u1_id,u2_id,u3_id);  % using optimium control sequence [u1opt,u2opt,u3opt]
            end
        end
    end
    J_STAR = opt_value;   % next terminal cost!
    
    savename=['Cost & Control = ',num2str(t),' TABLE.mat'];
    save(savename,'J_STAR','opt_trq','opt_id_u2','opt_eng_ctr');
    
    if RUN_TYPE.sim == 0
        complete =(cyc_data.time_cyc-t)/(cyc_data.time_cyc)*100;
        clc
        fprintf('__________________________________________________\n\n')
        fprintf('Percent Complete of Dynamic Programming = ')
        fprintf(num2str(complete))
        fprintf('\n')
        fprintf('__________________________________________________\n\n')
    end
end
cd ..

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Simulate Final Run-----------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
if RUN_TYPE.sim == 0
    clc
    min_t = toc/60;
    fprintf('__________________________________________________________________\n\n')
    fprintf('Total Time (min) for Dynamics and Dynamic Programming = ')
    fprintf(num2str(min_t))
    fprintf('\n')
    fprintf('__________________________________________________________________\n\n')
end

if RUN_TYPE.sim == 0
    fprintf('-------------------------------------------------\n');
    fprintf('Simulating Final Run! ')
    fprintf('\n')
    fprintf('-------------------------------------------------\n');
end

% pre-allocate for speed
sim.SOC_final = zeros(1,cyc_data.time_cyc);
sim.inst_fuel = zeros(1,cyc_data.time_cyc);
sim.W_mot = zeros(1,cyc_data.time_cyc);
sim.T_mot = zeros(1,cyc_data.time_cyc);
sim.W_eng = zeros(1,cyc_data.time_cyc);
sim.T_eng = zeros(1,cyc_data.time_cyc);
sim.ENG_state = zeros(1,cyc_data.time_cyc);
sim.GEAR = zeros(1,cyc_data.time_cyc);
sim.U1_sim = zeros(1,cyc_data.time_cyc);
sim.U2_sim = zeros(1,cyc_data.time_cyc);
sim.GEAR_save = zeros(1,cyc_data.time_cyc);
sim.J = zeros(1,cyc_data.time_cyc);
sim.Pbatt_sim = zeros(1,cyc_data.time_cyc);

fail_inner_SOC = zeros(1,cyc_data.time_cyc);
fail_inner_Te = zeros(1,cyc_data.time_cyc);
fail_inner_We = zeros(1,cyc_data.time_cyc);
fail_inner_Tm = zeros(1,cyc_data.time_cyc);
fail_inner_Wm = zeros(1,cyc_data.time_cyc);
fail_inner_Pbatt = zeros(1,cyc_data.time_cyc);
fail_inner_Shift = zeros(1,cyc_data.time_cyc);
fail_inner_eng  = zeros(1,cyc_data.time_cyc);

% define initial conditions
SOC_c = 0.55;              % should be same as (Desired_SOC variable in DP)
x2 = 1;                    % engine off
x3 = 1;                    % start in first gear

cd(tables);
for t = 1:1:cyc_data.time_cyc
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %------------- Load & Determine all Control Signals --------------%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    load(['Cost & Control = ',num2str(t),' TABLE.mat']);
    
    % engine torque control
    Te_c = interp1(x1_grid,opt_trq(:,x2,x3),SOC_c,'linear');
    
    % shifting control
    id_lookup_u2 = interp1(x1_grid,opt_id_u2(:,x2,x3),SOC_c,'nearest');  % use index extraction to speed up!!
    u2_c = u2_grid(id_lookup_u2);
    if u2_c == 0; SHIFT_event = 0; else SHIFT_event = 1; end             % to quantify how many times transmission was shifted
    
    % engine control
    eng_c = interp1(x1_grid,opt_eng_ctr(:,x2,x3),SOC_c,'nearest');
    if x2 == 0 && eng_c == 2; ENG_event = 1;  else ENG_event = 0; end    % to quantify how many times engine was turned on from off
    
    % calculate cost
    sim.J(t) =  interp1(x1_grid,J_STAR(:,x2,x3),SOC_c,'linear');
    
    % update x2 (engine state) for current time step
    if eng_c == 1             % eng is off
        x2 = 1;
    elseif eng_c == 2         % eng is on
        x2 = 2;
    else                      % eng is idling
        x2 = 3;
    end
    
    % shifting control check
    if (x3 == 1 && u2_c == -1) || (x3 == x3_length && u2_c == 1)
        % put in a feasible gear so optimization can continue
        u2_c = 0;
        FAIL_Shift = 1;
    else
        FAIL_Shift = 0;
    end
    
    % update x3 (gear) for current time step
    x3 = x3 + u2_c;      % gear level
    x3_n = x3_grid(x3);  % actual gear ratio   
    
    % speed of input shaft to gearbox
    Wis_gb = cyc_data.Ww(t)*dvar.FD*x3_n;     % [rad/s]
    
    % engine
    if x2 == 1                       % eng is off - if it tries to apply torque it will get it for free, but it fails anyway
        We_c = 0;
        fuel = 0;
        clutch = 0; % clutch is dissengaged from trans
        if RUN_TYPE.emiss_data == 1  % if emissions are on
            NOx = 0;
            CO = 0;
            HC = 0;
        end
        Fail_We = 0;
        Fail_Te = 0;
        Te_drive = 0;         % subtract auxiliary power here
        
        % use a nearest interpolation scheme to mitigate numerical issues
        if Te_c ~= 0
            % engine torque control
            Te_c = interp1(x1_grid,opt_trq(:,x2,x3),SOC_c,'nearest');
        end
        
        if Te_c == 0             % no eng torque was applied
            Fail_Eng = 0;
        else                     % infeasible, cannot apply eng torque when the eng is off
            Fail_Eng = 1;
        end
    elseif x2 == 2                             % eng is on
        Fail_Eng = 0;                          % apply any torque when the engine is on
        
        if x3 == 1 &&  Wis_gb < vinf.W_gb_is_min % use moving off strategy
            We_c = interp1(vinf.W_gb_mo,vinf.W_eng_mo,Wis_gb);
            clutch = Wis_gb/vinf.W_eng_mo(end);              % clutch is partially engaged
        else
            We_c = Wis_gb;                      % [rad/s]
            clutch = 1;                         % clutch is engaged to trans
        end
        
        Te_drive = Te_c;                        % subtract auxiliary power (torque) here
        if We_c < vinf.W_eng_min
            We_fuel = vinf.W_eng_min;
            if We_c < vinf.We_fail
                Fail_We = 1;
            else
                Fail_We = 0;
            end
        elseif We_c > vinf.W_eng_max
            We_fuel = vinf.W_eng_max;
            Fail_We = 1;
        else
            We_fuel = We_c;
            Fail_We = 0;
        end
        
        Te_max = interp1(vinf.eng_consum_spd_old,vinf.eng_max_trq,We_fuel);
        if Te_c > Te_max; 
            Te_fuel = Te_max;
            Fail_Te = 1;
        elseif Te_c < vinf.Te_min;
            Te_fuel = vinf.Te_min;                           
            Fail_Te = 0;
        else
            Te_fuel = Te_c;
            Fail_Te = 0;
        end
        
        fuel = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,Te_fuel,We_fuel,'linear')*cyc_data.dt)';
        if RUN_TYPE.emiss_data == 1
            NOx = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_nox_map,Te_fuel,We_fuel,'linear')*cyc_data.dt)';
            CO = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_co_map,Te_fuel,We_fuel,'linear')*cyc_data.dt)';
            HC = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_hc_map,Te_fuel,We_fuel,'linear')*cyc_data.dt)';
        end
    else                       % eng is idling  
        % clutch is disengaged, but engine is running
        clutch = 0;  
        We_c = vinf.W_gb_is_min;
        Fail_We = 0;
        Fail_Te = 0;
        Te_drive = 0;           % subtract auxiliary power (torque) here     
                                            
        % for idling
        fuel = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
        NOx = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_nox_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
        CO = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_co_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
        HC = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_hc_map,vinf.Te_min,vinf.W_gb_is_min,'linear')*cyc_data.dt)';
        
        % use a nearest interpolation scheme to mitigate numerical issues
        if Te_c ~= 0
            % engine torque control
            Te_c = interp1(x1_grid,opt_trq(:,x2,x3),SOC_c,'nearest');
        end
        
        if Te_c == 0             % no eng torque was applied
            Fail_Eng = 0;
        else                     % infeasible, cannot apply eng torque when the eng is off
            Fail_Eng = 1;
        end
    end
    
    % motor
    Wm_c = cyc_data.Ww(t)*dvar.FD*dvar.G;                           % [rad/s]
    Tm_c = cyc_data.Tw(t)/(dvar.FD*dvar.G) - Te_drive*x3_n/dvar.G;  
    Tm_max= interp1(vinf.m_map_spd,vinf.m_max_trq,Wm_c);
    Tm_min = interp1(vinf.m_map_spd,vinf.m_max_gen_trq,Wm_c);
    if Tm_c > Tm_max;
        Fail_Tm = 1;
        Tm_eff = Tm_max;
        Tm_actual = Tm_c;
        T_b = 0;
    elseif Tm_c < Tm_min;
        Fail_Tm = 0;                                 % did not fail this in DP
        Tm_eff = Tm_min;
        Tm_actual = Tm_min;
        T_b = (Tm_c - Tm_actual)*(dvar.FD*dvar.G) ;  % make up the rest with braking torque
    else
        Fail_Tm = 0;
        Tm_eff = Tm_c;
        Tm_actual = Tm_c;
        T_b = 0;
    end
    
    if Wm_c > vinf.Wm_max
        Fail_Wm = 1;
        Wm_eff = vinf.Wm_max;
    elseif Wm_c < vinf.Wm_min
        Fail_Wm = 1;
        Wm_eff = vinf.Wm_min;
    else
        Fail_Wm = 0;
        Wm_eff = Wm_c;
    end
    
    eff_m = interp2(vinf.m_map_trq, vinf.m_map_spd, vinf.m_eff_map, Tm_eff, abs(Wm_eff))';
    if isnan(eff_m)
        eff_m = 0.2;
    end
    
    % battery
    Pbat_charge = (Wm_eff*Tm_eff).*(eff_m*vinf.ess_coulombic_eff);    % Tm_c < 0
    Pbat_discharge = (Wm_eff*Tm_eff)./(eff_m*vinf.ess_coulombic_eff); % battery needs to supply more power
    
    if Tm_c < 0;
        Pbat = Pbat_charge;
    else
        Pbat = Pbat_discharge;
    end
    
    % discharge
    Pbatt_max = interp1(vinf.ess_soc, vinf.ess_max_pwr_dis,SOC_c);
    rint_discharge = interp1(vinf.ess_soc,vinf.ess_r_dis,SOC_c);
    
    % charge
    Pbatt_min = -interp1(vinf.ess_soc, vinf.ess_max_pwr_chg,SOC_c);
    rint_charge = interp1(vinf.ess_soc,vinf.ess_r_chg,SOC_c);
    
    % saturate the battery
    if Pbat > Pbatt_max
        FAIL_Pbatt = 1;
        Pbat_eff = Pbatt_max;
    elseif Pbat < Pbatt_min
        FAIL_Pbatt = 1;
        Pbat_eff = Pbatt_min;
    else
        FAIL_Pbatt = 0;
        Pbat_eff = Pbat;
    end
    
    % charge & discharge resistances
    if Pbat > 0
        rint_c = rint_discharge;
    else
        rint_c = rint_charge;
    end
    
    Voc_c = interp1(vinf.ess_soc,vinf.ess_voc,SOC_c);
    SOC_n =  SOC_c -(Voc_c -(Voc_c.^2 -4*Pbat_eff.*rint_c).^(1/2))./(2*rint_c*vinf.ess_cap_ah*3600)*cyc_data.dt;
    
    % check new SOC
    if SOC_n > param.MAX_SOC
        SOC_n = param.MAX_SOC;
        Fail_SOC = 1;
    elseif SOC_n < param.MIN_SOC
        SOC_n = param.MIN_SOC;
        Fail_SOC = 1;
    else
        Fail_SOC = 0;
    end
    
    % update x1 (SOC) for next time step
    SOC_c = SOC_n;  
    
    % save states for simulation results
    sim.SOC_final(t) = SOC_c;
    sim.ENG_state(t) = x2;    %  on/off/idle
    sim.GEAR(t) = x3;
    
    % save simulation variables
    sim.W_eng(t)= We_c;
    sim.W_mot(t) = Wm_eff;
    sim.T_eng(t) = Te_c;
    sim.T_mot(t) = Tm_actual;   % only allow motor to opperate within it's limits
    sim.inst_fuel(t) = fuel;
    sim.SHIFT_Event(t) = SHIFT_event;
    sim.ENG_Event(t) = ENG_event;
    sim.T_brake(t) = T_b;       % the brake applies a negative torque to the system
    sim.Wis_gb(t) = Wis_gb;
    sim.eng_c(t) = eng_c;
    sim.Pbatt_sim(t) = Pbat_eff;
    sim.eff_m_sim(t) = eff_m;
    sim.clutch(t) = clutch;
    
    if RUN_TYPE.emiss_data == 1
        sim.NOx(t) = NOx;
        sim.CO(t) = CO;
        sim.HC(t) = HC;
    end
    
    % temporarilty save the opperational feasiblilty results
    fail_inner_SOC(t) = Fail_SOC;
    fail_inner_Te(t) = Fail_Te;
    fail_inner_We(t) = Fail_We;
    fail_inner_Tm(t) = Fail_Tm;
    fail_inner_Wm(t) = Fail_Wm;
    fail_inner_Pbatt(t) = FAIL_Pbatt;
    fail_inner_Shift(t) = FAIL_Shift;
    fail_inner_eng(t) = Fail_Eng;
end

delta_SOC = sim.SOC_final(end) - sim.SOC_final(1);
total_fuel_gram = sum(sim.inst_fuel);                  % dt is 1 
sim.EE = sum(sim.ENG_Event);
sim.SE = sum(sim.SHIFT_Event);

total_distance_mile = sum(cyc_data.cyc_spd)/3600;
if RUN_TYPE.emiss_data == 1
    emission.NOx = sum(sim.NOx)/total_distance_mile;   % dt is 1 
    emission.HC = sum(sim.HC)/total_distance_mile;     % g/mile
    emission.CO = sum(sim.CO)/total_distance_mile;
else
    emission = NaN;
end
MPG = total_distance_mile/(total_fuel_gram/1000/param.gasoline_density*param.liter2gallon);

if isinf(MPG)
    MPG = 0;
end
cd ..    % come out of folder

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------------check outer feasibility---------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% SOC
if any(any(fail_inner_SOC))
    FAIL.fail_outer_SOC = 1;
else
    FAIL.fail_outer_SOC = 0;
end
if abs(delta_SOC) > RUN_TYPE.soc_size
    FAIL.fail_dSOC = 1;
else
    FAIL.fail_dSOC = 0;
end
% We
if any(any(fail_inner_We))
    FAIL.fail_outer_We = 1;
else
    FAIL.fail_outer_We = 0;
end
% Te
if any(any(fail_inner_Te))
    FAIL.fail_outer_Te = 1;
else
    FAIL.fail_outer_Te = 0;
end
% Wm
if any(any(fail_inner_Wm))
    FAIL.fail_outer_Wm = 1;
else
    FAIL.fail_outer_Wm = 0;
end
% Tm
if any(any(fail_inner_Tm))
    FAIL.fail_outer_Tm = 1;
else
    FAIL.fail_outer_Tm = 0;
end
% Pbatt
if any(any(fail_inner_Pbatt))
    FAIL.fail_outer_Pbatt = 1;
else
    FAIL.fail_outer_Pbatt = 0;
end
% Shift
if any(any(fail_inner_Shift))
    FAIL.fail_outer_Shift = 1;
else
    FAIL.fail_outer_Shift = 0;
end
% eng
if any(any(fail_inner_eng))
    FAIL.fail_outer_eng = 1;
else
    FAIL.fail_outer_eng = 0;
end

FAIL.final = ((FAIL.fail_outer_Tm + FAIL.fail_outer_Wm + FAIL.fail_outer_Te + FAIL.fail_outer_We + FAIL.fail_outer_SOC + FAIL.fail_dSOC + FAIL.fail_outer_Pbatt + FAIL.fail_outer_Shift + FAIL.fail_outer_eng) ~= 0);
end
