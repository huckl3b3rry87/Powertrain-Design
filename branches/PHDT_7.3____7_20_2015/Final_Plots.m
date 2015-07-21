%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------------Final Plots ect.----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clc
close all;

if RUN_TYPE.plot == 1 || RUN_TYPE.save == 1
    cd('Plots')
    Main_Plot;
    Engine_Plot;
    Torque_Check;
    Speed_Check;
    Motor_Plot;
    Cost_Plot;
    Battery_Plot;
    if RUN_TYPE.emiss_data == 1
        Engine_NOx_Plot;
        Engine_HC_Plot;
        Engine_CO_Plot;
    end
    cd ..
    if RUN_TYPE.save == 1
        cd('temp')
        if Matlab_ver >= 2015
            t = datetime;
            t.Format = 'eeee, MMMM d, yyyy';
            name = strcat(RUN_TYPE.folder_name,char(t));
        else
            name = strcat(RUN_TYPE.folder_name);
        end
        
        check_exist = exist(fullfile(cd,name),'dir');
        if check_exist == 7
            rmdir(name,'s')                 % delete any left over info
        end
        mkdir(name)
        cd(name)
        
        eval(['save(''','MPG',''',','''MPG'');'])
        eval(['save(''','emission',''',','''emission'');'])
        eval(['save(''','FAIL',''',','''FAIL'');'])
        eval(['save(''','sim',''',','''sim'');'])
        eval(['save(''','delta_SOC',''',','''delta_SOC'');'])
        eval(['save(''','weight',''',','''weight'');'])
        eval(['save(''','RUN_TYPE',''',','''RUN_TYPE'');'])
        
        if Matlab_ver >= 2015
            savefig(h1, 'main.fig')
            savefig(h2, 'fuel.fig')
            savefig(h3, 'torque_check.fig')
            savefig(h4, 'speed_check.fig')
            savefig(h5, 'motor.fig')
            savefig(h6, 'cost.fig')
            savefig(h7, 'battery.fig')
            if RUN_TYPE.emiss_data == 1
                savefig(h8, 'NOx.fig')
                savefig(h9, 'HC.fig')
                savefig(h10, 'CO.fig')
            end
        else
            fprintf('Did not save figures, this functionality is only currently avaulable for MATLAB 2015a.')
        end
        
        cd ..
        cd ..  % back in the main folder
    end
end

MPG
delta_SOC
if RUN_TYPE.emiss_data == 1
    emission
end
FAIL.final