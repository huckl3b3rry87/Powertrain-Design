clear;

load NOx
load MPG
load HC
load DV
load CO

% Transpose Output Data to Columns
MPG = MPG_save';
NOx = NOx_save';
CO = CO_save';
HC = HC_save';
X = X_save;

eval(['save(''','MPG',''',','''MPG'');'])
eval(['save(''','DV',''',','''X'');'])
eval(['save(''','NOx',''',','''NOx'');'])
eval(['save(''','CO',''',','''CO'');'])
eval(['save(''','HC',''',','''HC'');'])



