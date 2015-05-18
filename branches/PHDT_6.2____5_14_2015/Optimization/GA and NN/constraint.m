function [gineq, geq] = constraint(x,varargin)

net = cell2struct(varargin{2},varargin{1},1);
gineq_temp = net.constraint.constraint_net(x'); % should be neg one if it passes  <= 0

if gineq_temp < -0.3 % May be too strict if the constraint model is poor !
    gineq = -1;
else
    gineq = 1;
end
geq = [];

return;

