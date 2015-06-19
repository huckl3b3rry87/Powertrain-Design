function [Sim_Grade, F_max_6, V_max_6, RR ] = Engine_Power_Sizer_hi( param, vinf, dvar, test )
 
% -------------------- Road Load-------------------------------
RR = length(test.V);
for r = 1:1:RR
    % Pbase(r) = Engine_Base_Power(V_test(r),alpha_test(r), param, vinf);
    % P_req(r,:) = Engine_Base_Power(V,alpha_test(r), param, vinf);
    F_RL(:,r) = Road_Load( test.Vsim, test.alpha(r), param, vinf ); 
end

% ---------------- Actual Engine Performance -----------------------------

[Sim_Grade, Force_PM] = Max_Force_Calculator( vinf, dvar, test.Vsim, test);

% for all gears
[F_max_t, V_max_t ] = Max_Speed( Force_PM, F_RL(:,test.req), test.Vsim);

w = length(vinf.gear);
[ F_max_6, V_max_6] = Max_Speed(Sim_Grade.Eng_Tractive_Effort(:,w), F_RL(:,test.req), test.Vsim);

% put into structured data-set
Sim_Grade.F_RL = F_RL;
Sim_Grade.V_max_t = V_max_t;
Sim_Grade.F_max_t = F_max_t;
end

