clear
close all
clc
format bank
tic
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Check Matlab Version------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
version -release;
Matlab_ver = str2num(ans(1:4)); %#ok<NOANS,ST2NM>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.plot = 1;  % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.orig = 0;  % 1 to initialize the results
RUN_TYPE.save = 1;       % to save results
RUN_TYPE.FLUX = 1;       % if it is running on flux, there is no display
if RUN_TYPE.FLUX == 1; RUN_TYPE.sim = 1; end % do not want to continuously print the current time to an output file

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
cd('UDDS')
% cd('HWFET')
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
% plots and saves
Final_Plots;