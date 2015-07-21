clear
clc
close all
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Check Matlab Version------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
version -release;
Matlab_ver = str2num(ans(1:4)); %#ok<NOANS,ST2NM>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 1;        % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss_data = 1; % RUN_TYPE.emiss = 1 - maps have emissions  &   RUN_TYPE.emiss = 0 - maps do not have emissions
RUN_TYPE.emiss_on = 1;   % to turn of and on emissions
RUN_TYPE.plot = 0;       % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.save = 1;       % to save results
RUN_TYPE.FLUX = 0;       % if it is running on flux, there is no display
if RUN_TYPE.FLUX == 1; RUN_TYPE.sim = 1; end % do not want to continuously print the current time to an output file
RUN_TYPE.soc_size = 0.2;
RUN_TYPE.trq_size = 15;   % Nm
RUN_TYPE.folder_name = 'grid_tests_UDDS';
result_name = 'SOC_grid_0_01_trq_1_Nm';

% code parameters
beta = 20;
alpha = 20;
h = 20;
if RUN_TYPE.emiss_on == 1
    for k = 1:6
        for u = 1:alpha
            if k ==1;
                a1=5*(u-1)/beta;
                a2=0;
                a3=0;
                shift = 0;
                eng = 0;
                clutch = 0;
            elseif k==2
                a1=0;
                a2 = 5*(u-1)/beta;
                a3=0;
                shift = 0;
                eng = 0;
                clutch = 0;
            elseif k == 3
                a1=0;
                a2 = 0;
                a3= 5*(u-1)/beta;
                shift = 0;
                eng = 0;
                clutch = 0;
                
            elseif k == 4
                a1=0;
                a2=0;
                a3=0;
                shift = 5*(u-1)/beta;
                eng= 0;
                clutch = 0;
                
            elseif k == 5
                a1=0;
                a2=0;
                a3=0;
                shift = 0;
                eng = 15*(u-1)/beta;
                clutch = 0;
            else
                a1=0;
                a2=0;
                a3=0;
                shift = 0;
                eng = 0;
                clutch = 5*(u-1)/beta;
            end
            
            [ FAIL, MPG, emission, delta_SOC, sim ] = find_weights(a1,a2,a3,shift,eng,clutch,RUN_TYPE);
            
            if FAIL.final == 1;
                result.mpg(k,u) = NaN;
                result.NOx(k,u) = NaN;
                result.HC(k,u)= NaN;
                result.CO(k,u) = NaN;
                result.EE(k,u) = NaN;
                result.SE(k,u) = NaN;
                result.CE(k,u) = NaN;
            else
                result.mpg(k,u) = MPG;
                result.NOx(k,u) = emission.NOx;
                result.HC(k,u)= emission.HC;
                result.CO(k,u) = emission.CO;
                result.EE(k,u) = sim.EE;
                result.SE(k,u) = sim.SE;
                result.CE(k,u) = sim.CE;
            end
            result.dSOC(k,u) = delta_SOC;
            result.a1(k,u) = a1;
            result.a2(k,u) = a2;
            result.a3(k,u) = a3;
            result.shift(k,u) = shift;
            result.eng(k,u) = eng;
            result.clutch(k,u) = clutch;
            result.feasible(k,u) = FAIL; % If it is zero then it is OK
            
            figure(1);
            plot(u,k,'r.','markersize',25)
            ylabel('k total ')
            xlabel('u - 20 per'),grid
            hold on
            pause(0) 
            % save intermediate results
            cd('results')
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
            eval(['save(''',result_name,''',','''result'');'])
            cd ..
            cd ..  % back in the main folder
        end
    end
    
    clf;
    figure(1)
    subplot(6,1,1)
    plot(result.a1(1,:),result.mpg(1,:),'r.','markersize',h)
    hold on
    plot(result.a1(1,:),result.mpg(1,:))
    ylabel('MPG')
    xlabel('NOx weights'),grid
    
    subplot(6,1,2)
    plot(result.a2(2,:),result.mpg(2,:),'r.','markersize',h)
    hold on
    plot(result.a2(2,:),result.mpg(2,:))
    ylabel('MPG')
    xlabel('CO weights'),grid
    
    subplot(6,1,3)
    plot(result.a3(3,:),result.mpg(3,:),'r.','markersize',h)
    hold on
    plot(result.a3(3,:),result.mpg(3,:))
    ylabel('MPG')
    xlabel('HC weights'),grid
    
    subplot(6,1,4)
    plot(result.shift(4,:),result.mpg(4,:),'r.','markersize',h)
    hold on
    plot(result.shift(4,:),result.mpg(4,:))
    ylabel('MPG')
    xlabel('SHIFT weights'),grid
    
    subplot(6,1,5)
    plot(result.eng(5,:),result.mpg(5,:),'r.','markersize',h)
    hold on
    plot(result.eng(5,:),result.mpg(5,:))
    ylabel('MPG')
    xlabel('ENG weights'),grid
    
    subplot(6,1,6)
    plot(result.clutch(6,:),result.mpg(6,:),'r.','markersize',h)
    hold on
    plot(result.clutch(6,:),result.mpg(6,:))
    ylabel('MPG')
    xlabel('Clutch weights'),grid
else
    fprintf('Functionality was removed to evaluate vehicle without emissions!\n')
end
