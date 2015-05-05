clear

load NOx.mat
load MPG.mat
load HC.mat
load FAIL_LHC.mat
load DV.mat
load CO.mat

S = size(FAIL_LHC_save,1);
f = 1; % feasible counter
for n = 1:S
    if FAIL_LHC_save(n) == -1 
        feasible_MPG(f,1) = MPG_save(n);
        feasible_NOx(f,1) = NOx_save(n);
        feasible_CO(f,1) = CO_save(n);
        feasible_HC(f,1) = HC_save(n);
        feasible_DV(f,:) = X_save(n,:);
        f = f + 1;
    end
end

folder = 'feasible';
mkdir(folder);
cd(folder);   % Also copy all dvs and the fail to build constraint in NN 

eval(['save(''','MPG_f',''',','''feasible_MPG'');'])
eval(['save(''','NOx_f',''',','''feasible_NOx'');'])
eval(['save(''','CO_f',''',','''feasible_CO'');'])
eval(['save(''','HC_f',''',','''feasible_HC'');'])
eval(['save(''','DV_f',''',','''feasible_DV'');'])
eval(['save(''','FAIL_LHC_save',''',','''FAIL_LHC_save'');'])