function [gineq, geq] = constraint(x,varargin)

net = cell2struct(varargin{2},varargin{1},1);
gineq_temp = net.constraint.constraint_net(x(1:end-1)'); % should be neg one if it passes  <= 0

if gineq_temp < -0.95
    gineq = -1;
else
    gineq = 1;
end
geq = [];

return;

