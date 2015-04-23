% clear;
close all;
RUN_TYPE.emiss_on = 1;  % This is to turn of and on emissions
normalized.on = 0; % if the output is normalized
normalized_name = fieldnames(normalized);
normalized_data = struct2cell(normalized);

% Load all data
net.NOx = load('NOx_net.mat');
net.MPG = load('MPG_net.mat');
net.HC = load('HC_net.mat');
net.CO = load('CO_net.mat');
net_names = fieldnames(net);
net_data = struct2cell(net);

if normalized.on == 1   
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


if RUN_TYPE.emiss_on == 0
    weight.NOx = 0*1.4776/0.0560;
    weight.CO = 0*1.4776/0.6835;
    weight.HC = 0*1.4776/0.0177;
    %     RUN_TYPE.folder_name = 'NN - no emiss';
else
    weight.NOx = 2*1.4776/0.0560;
    weight.CO = 0.6*1.4776/0.6835;
    weight.HC = 4*1.4776/0.0177;
    %     RUN_TYPE.folder_name = 'NN - emiss';
end

weight_names = fieldnames(weight);
weight_data = struct2cell(weight);
nvars=4; % set number of design variables

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Design Variables-------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~d%
dvar.FD = 5.495;
dvar.G = 1.4;
dvar.fc_trq_scale = 0.78;
dvar.mc_trq_scale = 1.2;

x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale]';  % canged from 0.5
x_U=[    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale]';

IntCon=[]; % Set integer variables
if normalized.on == 1
    vfun=@(x)objective(x,weight_names, weight_data, mean_names, mean_data, std_names, std_data, net_names, net_datanormalized_name, normalized_data);
else
    vfun=@(x)objective(x,weight_names, weight_data, net_names, net_data, normalized_name, normalized_data);
end
nonlcon=[];

for k = 1:1
    pop = 80 + k*1;
    generations= 40 + k*5; %set number of generations
    for u =1:1
        ini=rand(pop,nvars);
        populations=pop; %set population size
        options = gaoptimset('InitialPopulation',ini,'PopulationSize',populations,'Generations',generations,'PlotFcns',{@gaplotbestfun, @gaplotstopping});
        
        %% Solve problem
        [x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon,IntCon,options)
        
        if exitflag ~= -2
            result.x(k,u,:) = x;
            result.fval(k,u) = fval;
            result.output(k,u) = output;
        end
        u;
        k;
    end
end
% eval(['save(''','results_4_20',''',','''result'');'])
