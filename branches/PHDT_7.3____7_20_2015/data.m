% Put all the data into a structure

% Universal Parameters
param.g = 9.81;   % m/s^2
param.rho = 1.2;  % density of air (kg/m^3)
param.mph_mps = 1/2.237;
param.rpm2rads = pi/30;
param.gasoline_density = 0.7197; % [kg/liter]
param.liter2gallon = 0.264172;
param.MIN_SOC = 0.4;
param.MAX_SOC = 0.8;
param.grade = 0;

% Vehicle information
vinf.base_mass = Base_Vehicle;
vinf.load = Load;
vinf.rwh = rwh;
vinf.Frr = Frr;
vinf.Cd = Cd;
vinf.Af = Af;
vinf.Paux = Paux;
vinf.nt = nt;

% Motor
vinf.m_map_spd = m_map_spd;
vinf.m_map_trq_orig = m_map_trq;
vinf.m_max_trq_orig = m_max_trq;
vinf.m_max_gen_trq_orig = m_max_gen_trq;
vinf.m_eff_map = m_eff_map;
vinf.Wm_min = Wm_min;
vinf.Wm_max = Wm_max;
vinf.mc_mass_orig = mc_mass;
vinf.mc_max_pwr_kW = mc_max_pwr_kW;

% Engine
vinf.W_eng_min = W_eng_min;
vinf.W_eng_max = W_eng_max;
vinf.eng_consum_spd = eng_consum_spd;
vinf.eng_consum_spd_old = eng_consum_spd_old;
vinf.eng_consum_trq_orig = eng_consum_trq';
vinf.eng_max_trq_orig = eng_max_trq;
vinf.Te_min_orig = Te_min;
vinf.fc_max_pwr_initial_kW = fc_max_pwr_initial_kW;  % changed this, I do no think it was used previously..
vinf.eng_consum_fuel_orig = eng_consum_fuel;
vinf.fc_hc_map_orig = fc_hc_map;
vinf.fc_co_map_orig = fc_co_map;
vinf.fc_nox_map_orig = fc_nox_map;
vinf.ave_fuel = ave_fuel;
vinf.ave_NOx = ave_NOx;
vinf.ave_HC = ave_HC;
vinf.ave_CO = ave_CO;
% define speed converter properties for moving Off - see automotive transmission fundamentals pg #80
vinf.W_gb_is_min = 1000*(pi/30);                               % [rad/s]- minimum speed of gearbox input shaft in first gear where it can be directly connected to the engine
vinf.W_eng_opt = 3000*pi/30;                                   % [rad/s]- heuristic, engine can run at this speed even when vehicle is stopped, also engine starts at this speed when moving off and then reduces linearly to vinf.Wgb_is_min
vinf.W_eng_mo = linspace(vinf.W_eng_opt,vinf.W_gb_is_min,20);  % [rad/s]- moving off engine speed vector
vinf.W_gb_mo = linspace(0,vinf.W_gb_is_min,20);                % [rad/s]- moving off gearbox input shaft speed vector
vinf.We_fail = 550*param.rpm2rads;
                
% Battery
vinf.ess_r_dis_orig = ess_r_dis;
vinf.ess_r_chg_orig = ess_r_chg;
vinf.ess_voc_orig = ess_voc;
vinf.ess_cap_ah = ess_cap_ah;
vinf.ess_soc = ess_soc;
vinf.ess_max_pwr_dis = ess_max_pwr_dis;
vinf.ess_max_pwr_chg = ess_max_pwr_chg;
vinf.ess_module_mass_orig = ess_module_mass;
vinf.ess_coulombic_eff = ess_coulombic_eff;

% Transmission
vinf.gear = gear;
