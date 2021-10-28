%% create plots of bulk AUC from aucTable

data=aucTable;

%subset specific data to plot
selection= data(data.stage<8,:);

% making subplot of 1) bulk AUC  

%overall mean between subjects (by date)
g(1,1)= gramm('x', selection.date, 'y', selection.auc);
g(1,1).stat_summary('type','sem','geom','area');

%individual subject lines
g(1,1).update('x', selection.date, 'y', selection.auc, 'color', selection.subject); 
g(1,1).geom_point('alpha', 0.5);
g(1,1).geom_line('alpha', 0.15);

%define labels for plot axes
g(1,1).set_names('x','date','y','AUC (peri-DS 465 z))','color','subject')
g(1,1).set_title('bulk AUC by subject')

g(1,1).geom_hline('yintercept',0, 'style', 'k--');

% g(1,1).draw() 

% making subplot of 2) bulk ABSOLUTE AUC
%overall mean between subjects (by date)
g(2,1)= gramm('x', selection.date, 'y', selection.aucAbs);
g(2,1).stat_summary('type','sem','geom','area');

%individual subject lines
g(2,1).update('x', selection.date, 'y', selection.auc, 'color', selection.subject); 
g(2,1).geom_point('alpha', 0.5);
g(2,1).geom_line('alpha', 0.15);

%define labels for plot axes
g(2,1).set_names('x','date','y','AUC (peri-DS 465 z))','color','subject')
g(2,1).set_title('bulk AUC by subject')

g(2,1).geom_hline('yintercept',0, 'style', 'k--');

g.draw() 

%% testing function
% 
% 
% signal= subjDataAnalyzed.rat9(20).periDS.DSzblueMean;
% timeBin= timeLock;
% 
% [auc, aucAbs, aucCum, aucCumAbs]= fp_AUC(signal);
% 
% figure(); hold on;
% plot(signal, 'k');
% plot(1:size(signal), ones(size(signal))*auc, 'r--');
% plot(1:size(signal), ones(size(signal))*aucAbs, 'm-.');
% plot(aucCum, 'g');
% plot(aucCumAbs, 'b');
% legend('signal', 'auc', 'absolute AUC', 'cumulative auc', 'absolute cumulative auc');