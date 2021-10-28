%% define function
function [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(signal) %(time, signal)
auc= trapz(signal);

%take absolute value of signal prior to AUC
aucAbs= trapz(abs(signal));

%cumulative
aucCum= cumtrapz(signal);
 
aucCumAbs= cumtrapz(abs(signal));

end

