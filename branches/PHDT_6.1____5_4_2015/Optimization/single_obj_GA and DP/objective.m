function obj = objective(~,varargin)

weight = cell2struct(varargin{9},varargin{8},1);

emission.NOx = evalin('base','NOx');
emission.CO  = evalin('base','CO');
emission.HC = evalin('base','HC');
MPG = -evalin('base','MPG'); % Negative for objective function

if  ~isempty(MPG) && ~isempty(emission.NOx) && ~isempty(emission.CO) && ~isempty(emission.HC)
    obj = -MPG + weight.NOx*emission.NOx + weight.CO*emission.CO + weight.HC*emission.HC;
else
    obj = 10^15;    % doing something like this may not be appropriate
end
return
