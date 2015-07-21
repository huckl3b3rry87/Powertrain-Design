function f = Differential_EQ(~, x, param, vinf, dvar, ni, g)

v = x(1); % instantaneous vehicle speed

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
dx_dt = v;                        % differential equation for distance  = dx_dt

f=[acc
    dx_dt];