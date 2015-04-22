clear;
close all;
RUN_TYPE.emiss_on = 1;  % This is to turn of and on emissions

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

x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale]';
x_U=[    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale]';

IntCon=[]; % Set integer variables
vfun=@(x)objective(x,weight_names, weight_data);
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
        u
        k
    end
end
% eval(['save(''','results_4_20',''',','''result'');'])
