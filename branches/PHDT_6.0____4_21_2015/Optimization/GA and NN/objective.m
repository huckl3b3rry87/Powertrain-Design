function obj = objective(x,varargin)

weight = cell2struct(varargin{2},varargin{1},1);

% Load all data
load('NOx_net.mat');
load('MPG_net.mat');
load('HC_net.mat');
load('CO_net.mat');


MPG = MPG_net(x');
NOx = NOx_net(x');
HC = HC_net(x');
CO = CO_net(x');

obj = -MPG + weight.NOx*NOx + weight.CO*CO + weight.HC*HC;

end
