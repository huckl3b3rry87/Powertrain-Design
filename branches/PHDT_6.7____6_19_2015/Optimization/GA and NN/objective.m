function obj = objective(x,varargin)

% Load Universal Parameters
param = cell2struct(varargin{2},varargin{1},1);

S = size(varargin);
if S(2) == 8 % not normalized
    settings = cell2struct(varargin{8},varargin{7},1);
else
    settings = cell2struct(varargin{12},varargin{11},1);
end

if settings.normalized == 1
    weight = cell2struct(varargin{4},varargin{3},1);
    mean = cell2struct(varargin{6},varargin{5},1);
    std = cell2struct(varargin{8},varargin{7},1);
    net = cell2struct(varargin{10},varargin{9},1);
    MPG = std.MPG.std_MPG*net.MPG.MPG_net(x') + mean.MPG.mean_MPG;
    NOx = std.NOx.std_NOx*net.NOx.NOx_net(x') + mean.NOx.mean_NOx;
    HC = std.HC.std_HC*net.HC.HC_net(x') + mean.HC.mean_HC;
    CO = std.CO.std_CO*net.CO.CO_net(x') + mean.CO.mean_CO;
else
    weight = cell2struct(varargin{4},varargin{3},1);
    net = cell2struct(varargin{6},varargin{5},1);

    MPG = net.MPG.MPG_net(x');
    NOx = net.NOx.NOx_net(x');
    HC = net.HC.HC_net(x');
    CO = net.CO.CO_net(x');
end

obj = (1000*param.gasoline_density/(param.liter2gallon*MPG) + weight.NOx*NOx + weight.CO*CO + weight.HC*HC)*settings.dist;  %output of emissions was in g/mile, DP did g oprimization

end
