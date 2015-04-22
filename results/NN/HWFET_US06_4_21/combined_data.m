clear;

NOx1 = [];
MPG1= [];
HC1 = [];
CO1 = [];
DV1 = [];

load NOx_HWFET
load MPG_HWFET
load HC_HWFET
load DV_HWFET
load CO_HWFET

NOx1 = [NOx1; NOx];
MPG1 = [MPG1; MPG];
HC1 = [HC1; HC];
CO1 = [CO1; CO];
DV1 = [DV1; X];

load NOx_US06
load MPG_US06
load HC_US06
load DV_US06
load CO_US06

NOx1 = [NOx1; NOx];
MPG1 = [MPG1; MPG];
HC1 = [HC1; HC];
CO1 = [CO1; CO];
DV1 = [DV1; X];

folder = 'NN_HWFET_US06_data';
mkdir(folder)
cd(folder)

eval(['save(''','MPG',''',','''MPG1'');'])
eval(['save(''','DV',''',','''DV1'');'])
eval(['save(''','NOx',''',','''NOx1'');'])
eval(['save(''','CO',''',','''CO1'');'])
eval(['save(''','HC',''',','''HC1'');'])