%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Genetic Algorithm------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear;
close all;
settings.emiss_on = 1;   % This is to turn of and on emissions
settings.normalized = 0; % If the output is normalized
settings.weights = 0;    % To use the weights as design variables
settings.dist = 10.2567; % Cycle distance (miles) for HWFET...leave for now, but it should be calcualted on the fly
% settings.dist = 8.0080; %US06, actually does not mattter, it gets multiplied by entire obj func
% settings.dist = 8.45; % UDDS
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
    nvars = 5; % set number of design variables
    
dvar.FD = 5.665;
dvar.G = 1.1;
dvar.fc_trq_scale = 1.095;
dvar.mc_trq_scale = 1.4;
dvar.module_number = 23;
x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale,floor(0.5*dvar.module_number)]';
x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale,floor(1.5*dvar.module_number)]';

    IntCon=5; % Set integer variables
else
    %Now the weights are heuristic tunning parameters
    weight.NOx = 0*1.4776/0.0560;
    weight.CO = 0*1.4776/0.6835;
    weight.HC = 0*1.4776/0.0177;
    
    weight_names = fieldnames(weight);
    weight_data = struct2cell(weight);
    nvars = 8; % set number of design variables ( include weights)
    
    %  NOx  CO   HC
    w_L = [ 0,   0,   0];
    w_U = [0.6,  3,   2];
    dvar.FD = 5.495;
    dvar.G = 1.4;
    dvar.fc_trq_scale = 0.78;
    dvar.mc_trq_scale = 1.2;
    x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale, w_L,0]';
    x_U=[    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale, w_U,1]';
    
    IntCon=8; % Set integer variables
end

if settings.normalized == 1  % Currently do not have code set up for normalized and variable weights...
    vfun=@(x)objective(x, univ_names, univ_data, weight_names, weight_data, mean_names, mean_data, std_names, std_data, net_names, net_data, settings_name, settings_data);
else
    vfun=@(x)objective(x, univ_names, univ_data, weight_names, weight_data, net_names, net_data, settings_name, settings_data);
end

nonlcon=@(x)constraint(x,net_names, net_data);

% for k = 1:1
%     pop = 80 + k*1;
%     gen= 45 + k*5; %set number of generations
%     for u =1:1% if it is less than 50 (the stall gen setting) weird things happen...

pop=60; %set population size

generations=50; %set number of generations

ini=rand(pop,nvars);
ini(:,1) = x_L(1) + (x_U(1) -x_L(1))*ini(:,1);  % Probably not the best way to find the initial population
ini(:,2) = x_L(2) + (x_U(2) -x_L(2))*ini(:,2);
ini(:,3) = x_L(3) + (x_U(3) -x_L(3))*ini(:,3);
ini(:,4) = x_L(4) + (x_U(4) -x_L(4))*ini(:,4);
ini(:,5) = floor(x_L(5) + (x_U(5) -x_L(5))*ini(:,5));

if settings.weights == 1  % do not have variable weights and batteryu modules as a DV
    ini(:,5) = x_L(5) + (x_U(5) -x_L(5))*ini(:,5);
    ini(:,6) = x_L(6) + (x_U(6) -x_L(6))*ini(:,6);
    ini(:,7) = x_L(7) + (x_U(7) -x_L(7))*ini(:,7);
end

time = inf; % time in (s)
% options = gaoptimset('TimeLimit', time, 'InitialPopulation',ini,'PopulationSize',pop,'Generations',gen,'PlotFcns',{@gaplotbestf, @gaplotstopping});
% options2 = gaoptimset('PlotFcns',{@gaplotbestfun, @gaplotstopping}, 'Display','iter');
  options = gaoptimset('InitialPopulation',ini,'PopulationSize',pop,'Generations',generations,'PlotFcns',@gaplotbestfun,'Display','iter');
%     options = gaoptimset('InitialPopulation',ini,'PopulationSize',pop,'Generations',generations,'PlotFcns',@gaplotbestfun,...
%     'CreationFcn',{@gacreationnonlinearfeasible,...
%     'UseParallel',true,'NumStartPts',20});
%% Solve problem
%         [x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon,IntCon,options2)
[x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon,IntCon,options)
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
