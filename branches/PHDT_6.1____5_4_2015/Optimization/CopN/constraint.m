function [gineq,geq] = constraint(x)
net.constraint = load('constraint_net');

% net = cell2struct(varargin{2},varargin{1},1);
gineq = net.constraint.constraint_net(x');  % should be neg one if it passes  <= 0
geq = [];
return;

