clear;
load NOx1
load MPG1
load HC1
load DV1
load CO1
load FAIL_LHC1
load X_save1

MPG_ = [feasible_MPG]
NOx_ = [feasible_NOx];
CO_ = [feasible_CO];
HC_ = [feasible_HC];
FAIL_LHC_ = [FAIL_LHC_save];
DV_f = [feasible_DV];
X_save_ = [X_save];

load NOx2
load MPG2
load HC2
load DV2
load CO2
load FAIL_LHC2
load X_save2

MPG_ = [MPG_; feasible_MPG];
NOx_ = [NOx_; feasible_NOx];
CO_ = [CO_; feasible_CO];
HC_ = [HC_; feasible_HC];
FAIL_LHC_ = [FAIL_LHC_; FAIL_LHC_save];
DV_f = [DV_f; feasible_DV];
X_save_ = [X_save_; X_save];

load NOx3
load MPG3
load HC3
load DV3
load CO3
load FAIL_LHC3
load X_save3

MPG_ = [MPG_; feasible_MPG];
NOx_ = [NOx_; feasible_NOx];
CO_ = [CO_; feasible_CO];
HC_ = [HC_; feasible_HC];
FAIL_LHC_ = [FAIL_LHC_; FAIL_LHC_save];
DV_f = [DV_f; feasible_DV];
X_save_ = [X_save_; X_save];

folder = 'all_data';
mkdir(folder)
cd(folder)

eval(['save(''','MPG',''',','''MPG_'');'])
eval(['save(''','DVf',''',','''DV_f'');'])
eval(['save(''','NOx',''',','''NOx_'');'])
eval(['save(''','CO',''',','''CO_'');'])
eval(['save(''','HC',''',','''HC_'');'])
eval(['save(''','FAIL_LHC',''',','''FAIL_LHC_'');'])
eval(['save(''','X',''',','''X_save_'');'])


