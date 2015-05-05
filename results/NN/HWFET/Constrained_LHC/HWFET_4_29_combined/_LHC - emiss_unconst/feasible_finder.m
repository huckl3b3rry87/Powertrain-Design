clear

load NOx.mat
load MPG.mat
load HC.mat
load DV.mat
load CO.mat

FAIL_LHC = -ones(size(MPG));
S = size(FAIL_LHC,1);
f = 1; % feasible counter
for n = 1:S
    if FAIL_LHC(n) == -1 
        feasible_MPG(f,1) = MPG(n);
        feasible_NOx(f,1) = NOx(n);
        feasible_CO(f,1) = CO(n);
        feasible_HC(f,1) = HC(n);
        feasible_DV(f,:) = X(n,:);
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
eval(['save(''','DV',''',','''feasible_DV'');'])
eval(['save(''','DV_f',''',','''feasible_DV'');'])
eval(['save(''','FAIL_LHC_save',''',','''FAIL_LHC'');'])