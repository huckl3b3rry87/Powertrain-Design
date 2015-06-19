clear
close all
clc
format bank
tic
RUN_TYPE.plot = 1;  % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.orig = 0;  % 1 to initialize the results

script;
alpha = 0.001; % allowable percent difference
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Simulate---------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[FAIL, MPG, emission, delta_SOC, sim] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------------Regression Test-----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%

cd('Regression Tests')
cd('Fuel Economy and Emissions')
% cd('UDDS')
cd('HWFET')
cd('test_100')
if RUN_TYPE.orig ~= 1
    load('result.mat')
    % Compare results
    per_diff.MPG = (MPG - result.MPG.orig)/result.MPG.orig*100;
    per_diff.NOx = (emission.NOx - result.NOx.orig)/result.NOx.orig*100;
    per_diff.HC = (emission.HC - result.HC.orig)/result.HC.orig*100;
    per_diff.CO = (emission.CO - result.CO.orig)/result.CO.orig*100;
    
    if abs(per_diff.MPG) > alpha
        fprintf('The MPG failed the regression test with a value of %% %.2f!', per_diff.MPG);
        fprintf('\n');
    end
    
    if abs(per_diff.NOx) > alpha
        fprintf('The NOx failed the regression test with a value of %% %.2f!', per_diff.NOx);
        fprintf('\n');
    end
    
    if abs(per_diff.CO) > alpha
        fprintf('The CO failed the regression test with a value of %% %.2f!', per_diff.CO);
        fprintf('\n');
    end
    
    if abs(per_diff.HC) > alpha
        fprintf('The HC failed the regression test with a value of %% %.2f!', per_diff.HC);
        fprintf('\n');
    end
    
    if  (abs(per_diff.MPG) > alpha) || abs((per_diff.NOx) > alpha) || abs((per_diff.CO > alpha)) || abs((per_diff.HC) > alpha)
        % Construct a questdlg with three options
        display = 'Would you like to overwrite the original results?  Yes/No: ';
        choice = input(display,'s');
        fprintf('\n');
        % Handle response
        switch choice
            case 'Yes'
                result.MPG.orig = MPG;
                result.NOx.orig = emission.NOx;
                result.CO.orig = emission.CO;
                result.HC.orig = emission.HC;
                eval(['save(''','result.mat',''',','''result'');'])
                disp(['The original results have been overwritten'])
            case 'No'
                disp(['Nothing was maniplated'])
        end
    else
         fprintf('The Regression Test Completed Successfully.');
         fprintf('\n');
    end
    
else
    result.MPG.orig = MPG;
    result.NOx.orig = emission.NOx;
    result.CO.orig = emission.CO;
    result.HC.orig = emission.HC;
    eval(['save(''','result.mat',''',','''result'');'])
end
cd .. 
cd .. 
cd ..
cd ..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------------Final Plots ect.----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%
if RUN_TYPE.sim == 0
    if RUN_TYPE.plot == 1
        cd('Plots')
        Main_Plot;
        Engine_Plot;
        Torque_Check;
        Speed_Check;
        if RUN_TYPE.emiss_on == 1
            Engine_NOx_Plot;
            Engine_HC_Plot;
            Engine_CO_Plot;
        end
        Motor_Plot;
        Cost_Plot;
        Battery_Plot;
        cd ..
    end
    MPG
    delta_SOC
    if RUN_TYPE.emiss_data == 1
        emission
    end
    FAIL.final  
end