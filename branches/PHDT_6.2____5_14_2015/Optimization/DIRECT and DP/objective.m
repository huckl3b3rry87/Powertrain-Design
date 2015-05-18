function obj = objective(x,varargin)

param =  cell2struct(varargin{5}, varargin{4},1);
vinf =  cell2struct(varargin{7}, varargin{6},1);
cyc_name = varargin{8};
RUN_TYPE = cell2struct(varargin{10},varargin{9},1);
weight = cell2struct(varargin{12},varargin{11},1);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------Update the Design Variables------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dvar.FD = x(1);
dvar.G = x(2);
dvar.fc_trq_scale = x(3);
dvar.mc_trq_scale = x(4);  
dvar.module_number = 38;  % Fixed (for now) - should be passing this..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------Manipulate Data Based of Scaling Factors----------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Manipulate_Data_Structure; % Need to recalcualte the Tw for the ne vehicle mass

[cyc_data] = Drive_Cycle(param, vinf, cyc_name );

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Run DP with new Data--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%    

[FAIL, MPG, emission, delta_SOC, ~] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight);

if ~FAIL.final && ~isempty(MPG) && ~isempty(emission.NOx) && ~isempty(emission.CO) && ~isempty(emission.HC)
    obj = -MPG + weight.NOx*emission.NOx + weight.CO*emission.CO + weight.HC*emission.HC; 
else
    obj = 10^10;    % doing something like this may not be appropriate
    FAIL.final = 1; % Make Sure it Fails
end

if ( isnan(emission.NOx) || isnan(emission.CO) || isnan(emission.HC))
    emission.NOx = -1;
    emission.CO = -1;
    emission.HC = -1;  % Will fail it for sure and make sure that the constraints are not gettting passed back as NaN ( which messes DIRECT up)
end
assignin('base','con',[FAIL.final; delta_SOC; MPG; emission.NOx; emission.CO; emission.HC]);

return
