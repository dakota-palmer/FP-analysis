%% define function
function [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(signal) %(time, signal)

fs=40;

auc= trapz(1/fs, signal);

%take absolute value of signal prior to AUC
aucAbs= trapz(1/fs, abs(signal));

%cumulative
aucCum= cumtrapz(1/fs, signal);
 
aucCumAbs= cumtrapz(1/fs, abs(signal));

end

