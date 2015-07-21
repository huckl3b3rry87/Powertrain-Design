% standard acceleration test, both motor and engine are allowed to
% accelerate vehicle

function [ Sim_Variables ] = Acceleration_Test(V_0, param, vinf, dvar)

% Initialize Stuff
V_sim = [];
Fti_sim = [];
Frl_sim = [];
We_sim = [];
Wm_sim = [];
x_sim = [];
acc_sim = [];
Teng_sim = [];
Tm_sim = [];
time_sim =[];
in = 0;

% Gearbox and final drive ratios:
ng = vinf.gear;

x0=[V_0 0]; t0=0; tf = 0.25; % Initial conditions

% find the engine speed that maximizes torque
[~,idx]= max(vinf.eng_max_trq);
wem = vinf.eng_consum_spd(idx); % engine speed at which gear is shifted

for g=1:1:length(ng) % Loop for gears
  
    ni=ng(g)*dvar.FD; % Overall gear ratio at each gear
    we = 0;
    
    if g == length(ng) % push it to max speed
        wem = vinf.eng_consum_spd(end);
    end
    
    while max(we) < wem % Repeat statements until we=wem
        [t,x]=ode23(@(t,x) Differential_EQ(t, x, param, vinf, dvar, ni, g), [t0 tf], x0); % Don't need to manipulate data again
        v=x(:,1);  % Speed
        s=x(:,2);  % Distance
        
        Wis_gb = ni*v/vinf.rwh; % rad/sec 
        we = Wis_gb; 
        
        % moving off strategy
        if (g == 1)  % use moving off strategy
            we(Wis_gb < vinf.W_gb_is_min)  = interp1(vinf.W_gb_mo,vinf.W_eng_mo,we(Wis_gb < vinf.W_gb_is_min));
        end
        % moving off strategy
        
        zero_vector = zeros(size(we));
        
        we_saturate = we;
        
        we_saturate(we < vinf.W_eng_min) = vinf.W_eng_min;
        we_saturate(we > vinf.W_eng_max) = vinf.W_eng_max;
        
        T_eng_max = interp1(vinf.eng_consum_spd,vinf.eng_max_trq,we_saturate);
        T_eng_max(we > vinf.W_eng_max) = zero_vector(we > vinf.W_eng_max);
        
        wm = v/vinf.rwh*dvar.FD*dvar.G;
        wm_saturate = wm;
        wm_saturate(wm < vinf.Wm_min) = vinf.Wm_min;
        wm_saturate(vinf.Wm_max < wm) = vinf.Wm_max;
        
        Tm_max = interp1(vinf.m_map_spd,vinf.m_max_trq,wm_saturate);
        Tm_max(wm > vinf.Wm_max) = zero_vector(wm > vinf.Wm_max);
        
        % engine and motor
        Fti = T_eng_max*ni/vinf.rwh + Tm_max*dvar.FD*dvar.G/vinf.rwh;
        
        Frl = vinf.m*param.g*sin(param.grade) + vinf.Frr*vinf.m*param.g*cos(param.grade) + 0.5*param.rho*vinf.Cd*v.^2*vinf.Af;
        
        acc=(Fti-Frl)/vinf.m;             % differential equation for speed
        acc(Fti < Frl) = zero_vector(Fti < Frl);
        
        if mean(acc) < 0.05  % should hit the highest accelerations in the lowest gears
            break;
        end
        
        if (max(we) < wem)
            tf = tf + 0.1;
        end
        
        if tf > 150
            break;
        end
    end
    
    if any(we < wem) % Otherwise, the vehicle was traveling too fast, just shift
        % Save Variables
        V_sim = [V_sim; v(2:end)]; % m/s
        Fti_sim = [Fti_sim; Fti(2:end)];
        Frl_sim = [ Frl_sim;  Frl(2:end)];
        We_sim = [We_sim; we(2:end)*30/pi];   % RPM
        Wm_sim = [ Wm_sim; wm(2:end)*30/pi];   % RPM
        x_sim = [ x_sim; s(2:end)];
        acc_sim = [ acc_sim; acc(2:end)];
        Teng_sim = [Teng_sim; T_eng_max(2:end)];
        Tm_sim = [Tm_sim; Tm_max(2:end)];
        time_sim = [time_sim; t(2:end)];
        
        % Now gearshift is needed. Set the initial conditions for the next gear
        t0 = max(t);
        tf = tf + 1;
        x0=[v(end) s(end)];
        in = 1;
    end
end

% saturate the simulation variables to include only those when the vehicle
% is accelerating
% [~,I]  = min(abs(acc_sim));
% 
% % Sim_Variables = [x_sim,V_sim,acc_sim,Teng_sim,Tm_sim,We_sim,Wm_sim,time_sim];
% Sim_Variables.x_sim = x_sim(1:I);
% Sim_Variables.V_sim = V_sim(1:I);
% Sim_Variables.acc_sim = acc_sim(1:I);
% Sim_Variables.Teng_sim = Teng_sim(1:I);
% Sim_Variables.Tm_sim = Tm_sim(1:I);
% Sim_Variables.We_sim = We_sim(1:I);
% Sim_Variables.Wm_sim = Wm_sim(1:I);
% Sim_Variables.time_sim = time_sim(1:I);
% [~,I]  = min(abs(acc_sim));
% 
% % Sim_Variables = [x_sim,V_sim,acc_sim,Teng_sim,Tm_sim,We_sim,Wm_sim,time_sim];
Sim_Variables.x_sim = x_sim;
Sim_Variables.V_sim = V_sim;
Sim_Variables.acc_sim = acc_sim;
Sim_Variables.Teng_sim = Teng_sim;
Sim_Variables.Tm_sim = Tm_sim;
Sim_Variables.We_sim = We_sim;
Sim_Variables.Wm_sim = Wm_sim;
Sim_Variables.time_sim = time_sim;

Sim_Variables.in = in;  % a flag to see if the acceleration test got to a particular point
end





