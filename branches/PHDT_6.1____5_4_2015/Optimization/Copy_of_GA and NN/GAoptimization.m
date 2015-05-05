%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Genetic Algorithm------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear;
close all;
settings.emiss_on = 1;   % This is to turn of and on emissions
settings.normalized = 0; % If the output is normalized
settings.weights = 0;    % To use the weights as design variables
% settings.dist = 10.2567; % Cycle distance (miles) for HWFET...leave for now, but it should be calcualted on the fly
settings.dist = 8.0080; %US06
settings_name = fieldnames(settings);
settings_data = struct2cell(settings);

% Load all data
net.NOx = load('NOx_net.mat');
net.MPG = load('MPG_net.mat');
net.HC = load('HC_net.mat');
net.CO = load('CO_net.mat');
net.constraint = load('constraint_net');
net_names = fieldnames(net);
net_data = struct2cell(net);

data_universal;
univ_names = fieldnames(param);
univ_data = struct2cell(param);

if settings.normalized == 1
    mean.CO = load('mean_CO.mat');
    mean.HC = load('mean_HC.mat');
    mean.NOx = load('mean_NOx.mat');
    mean.MPG = load('mean_MPG.mat');
    std.CO = load('std_CO.mat');
    std.HC =  load('std_HC.mat');
    std.NOx = load('std_NOx.mat');
    std.MPG = load('std_MPG.mat'); 
    mean_names = fieldnames(mean);
    mean_data = struct2cell(mean);
    std_names = fieldnames(std);
    std_data = struct2cell(std);
end

if settings.weights == 0
    if settings.emiss_on == 0
        weight.NOx = 0*1.4776/0.0560;
        weight.CO = 0*1.4776/0.6835;
        weight.HC = 0*1.4776/0.0177;
    else
        weight.NOx = 2*1.4776/0.0560;
        weight.CO = 0.6*1.4776/0.6835;
        weight.HC = 4*1.4776/0.0177;
    end
    weight_names = fieldnames(weight);
    weight_data = struct2cell(weight);
    nvars = 4; % set number of design variables
    
    dvar.FD = 5.495;
    dvar.G = 1.4;
    dvar.fc_trq_scale = 0.78;
    dvar.mc_trq_scale = 1.2;
    
    x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale]';  
    x_U=[    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale]';
    
else
    %Now the weights are heuristic tunning parameters
    weight.NOx = 0*1.4776/0.0560;
    weight.CO = 0*1.4776/0.6835;
    weight.HC = 0*1.4776/0.0177;
    
    weight_names = fieldnames(weight);
    weight_data = struct2cell(weight);
    nvars = 7; % set number of design variables ( include weights)
    
         %  NOx  CO   HC
    w_L = [ 0,   0,   0];
    w_U = [0.6,  3,   2];
    dvar.FD = 5.495;
    dvar.G = 1.4;
    dvar.fc_trq_scale = 0.78;
    dvar.mc_trq_scale = 1.2;
    x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale, w_L]';
    x_U=[    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale, w_U]';
end

if settings.normalized == 1  % Currently do not have code set up for normalized and variable weights...
    vfun=@(x)objective(x, univ_names, univ_data, weight_names, weight_data, mean_names, mean_data, std_names, std_data, net_names, net_data, settings_name, settings_data);
else
    vfun=@(x)objective(x, univ_names, univ_data, weight_names, weight_data, net_names, net_data, settings_name, settings_data);
end

IntCon=[]; % Set integer variables
nonlcon=@(x)constraint(x,net_names, net_data);

% for k = 1:1
%     pop = 80 + k*1;
%     gen= 45 + k*5; %set number of generations
%     for u =1:1% if it is less than 50 (the stall gen setting) weird things happen...

pop=40; %set population size

generations= 50; %set number of generations
x0=[5.495, 1.4, 1.2, 1.2];
  ini=rand(pop,nvars);
  ini(:,1) = x_L(1) + (x_U(1) -x_L(1))*ini(:,1);
  ini(:,2) = x_L(2) + (x_U(2) -x_L(2))*ini(:,2);
   ini(:,3) = x_L(3) + (x_U(3) -x_L(3))*ini(:,3);
    ini(:,4) = x_L(4) + (x_U(4) -x_L(4))*ini(:,4);
% % Check intial point
% nonlcon=@(x)constraint(x0,net_names, net_data)
% nonlcon(x0',varargin)
% [cineq,ceq] = nonlcon(x0)
%%
time = inf; % time in (s)
% options = gaoptimset('TimeLimit', time, 'InitialPopulation',ini,'PopulationSize',pop,'Generations',gen,'PlotFcns',{@gaplotbestf, @gaplotstopping});
% options2 = gaoptimset('PlotFcns',{@gaplotbestfun, @gaplotstopping}, 'Display','iter');
%   options = saoptimset('InitialPopulation',x0,'PopulationSize',pop,'Generations',generations,'PlotFcns',@gaplotbestfun);

%% Solve problem
%         [x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon,IntCon,options2)
[x,fval,exitflag,output] = simulannealbnd(vfun,x0,x_L,x_U,nonlcon)
% [x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon)

% if exitflag ~= -2
%     result.x(k,u,:) = x;
%     result.fval(k,u) = fval;
%     result.output(k,u) = output;
% end
%         u;
%         k;
%     end
% end
% eval(['save(''','results_4_20',''',','''result'');'])
