function obj = objective(x,varargin)

S = size(varargin);
if S(2) == 6 % not normalized
    normalized = cell2struct(varargin{6},varargin{5},1);
else
    normalized = cell2struct(varargin{10},varargin{9},1);
end

if normalized.on == 1
    weight = cell2struct(varargin{2},varargin{1},1);
    mean = cell2struct(varargin{4},varargin{3},1);
    std = cell2struct(varargin{6},varargin{5},1);
    net = cell2struct(varargin{8},varargin{7},1);
    MPG = std.MPG.std_MPG*net.MPG.MPG_net(x') + mean.MPG.mean_MPG;
    NOx = std.NOx.std_NOx*net.NOx.NOx_net(x') + mean.NOx.mean_NOx;
    HC = std.HC.std_HC*net.HC.HC_net(x') + mean.HC.mean_HC;
    CO = std.CO.std_CO*net.CO.CO_net(x') + mean.CO.mean_CO;
else
    weight = cell2struct(varargin{2},varargin{1},1);
    net = cell2struct(varargin{4},varargin{3},1);

    MPG = net.MPG.MPG_net(x');
    NOx = net.NOx.NOx_net(x');
    HC = net.HC.HC_net(x');
    CO = net.CO.CO_net(x');
end

obj = -MPG + (weight.NOx*NOx + weight.CO*CO + weight.HC*HC)/1000;  %output of emissions was in mg

end
