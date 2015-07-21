% this script is a rough cost validation calculation

ENG_WEIGHT = weight.engine_event*dvar.fc_trq_scale;

fprintf('Cost From Interpolation:\n')
cost_minus_end = sim.J(1) - sim.J(end)

% disclamer: approximated cost neglects infeasibilities and SOC related costs
fprintf('Approximated Cost:\n')
cost = weight.fuel*sum(sim.inst_fuel) + weight.NOx*sum(sim.NOx) + weight.HC*sum(sim.HC) + weight.CO*sum(sim.CO) + weight.shift*sim.SE + ENG_WEIGHT*sim.EE + weight.clutch_event*sim.CE