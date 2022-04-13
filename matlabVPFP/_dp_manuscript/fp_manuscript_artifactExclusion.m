%% --Artifact exclusion from periEventTable

artifactThreshold=15;

%% ----Histograms of extreme Z values by trial to establish threshold criteria-----

% ABS max/min z: peri cue vs peri PE

%--DS trials
y= 'DSpurple';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);


%subset data to viz
data= zSummary;

%compute absolute max value for each trial
data(:,strcat("abs_max_",y))= table(max(abs(data.(strcat("max_",y))), abs(data.(strcat("min_",y)))));

% col to viz
x= strcat("abs_max_",y);

figure;

i(1,1)= gramm('x', data.(x), 'color', data.subject);

i(1,1).stat_bin('geom','stairs');

i(1,1).set_names('x', x);
i(1,1).set_title('Artifact thresholding: Distribution of trial z score extremes');

i(1,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 

%--pox timelock (expect more extreme artifacts than DS timelock)

y= 'DSpurplePox';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);

%subset data to viz
data= zSummary;

%compute absolute max value for each trial
data(:,strcat("abs_max_",y))= table(max(abs(data.(strcat("max_",y))), abs(data.(strcat("min_",y)))));

% col to viz
x= strcat("abs_max_",y);

% col to viz
x= strcat("abs_max_",y);

i(2,1)= gramm('x', data.(x), 'color', data.subject);

i(2,1).stat_bin('geom', 'stairs');
i(2,1).set_names('x', x);
i(2,1).set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
i(2,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i.draw();

linkaxes();

%% box plot may help?

figure();
clear i;

% i(2,1)= gramm('y', data.(x), 'x', data.stage, 'color', data.subject);
i= gramm('y', data.(x), 'x', data.subject, 'color', data.stage);

i.stat_boxplot();
% i(2,1).set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
% i(2,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i().geom_hline('yintercept', artifactThreshold, 'style', 'k--');
i.draw();


figure();
clear i;

% i(2,1)= gramm('y', data.(x), 'x', data.stage, 'color', data.subject);
i= gramm('y', data.(x), 'x', data.subject);%, 'color', data.stage);

i.stat_boxplot();
% i(2,1).set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
% i().geom_hline('yintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i().geom_hline('yintercept', artifactThreshold, 'style', 'k--'); 

i.draw();


%% Mark 'artifact' trials for exclusion

%initialize new column
periEventTable(:, "artifact")= table(nan);


%melt into single signal column (check timelock to all event types, dont restrict to one)
% data= stack(data, {'DSpurple', 'DSpurplePox', 'DSpurpleLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventDSpurple');


%z score max beyond which to exclude
artifactThreshold= 15;

%- DS trials
y= 'DSpurple';

zSummary= table;
zSummary= groupsummary(periEventTable,["DStrialIDcum"],'all', y);

%find unique trialIDs where z max or min exceed threshold
ind= []; 
ind= abs(table2array(zSummary(:,strcat("max_"+y)))) >= artifactThreshold;

ind= ind | abs(table2array(zSummary(:,strcat("min_"+y)))) >= artifactThreshold;

trialsToExclude= zSummary(ind,'DStrialIDcum');



trialsToExclude= table2array(trialsToExclude);

data= periEventTable;

%Mark artifact trials
for trial= 1:numel(trialsToExclude)
    signalCol= ["DSblue", "DSbluePox", "DSblueLox", "DSpurple", "DSpurplePox", "DSpurpleLox"];
    
%     ind= find((data.DStrialIDcum== trialsToExclude(trial))==0);
    ind= find((data.DStrialIDcum== trialsToExclude(trial)));

    data(ind, "artifact")= table(1);
    
end

periEventTable= data; %assign back to table

%- NS trials
y= 'NSpurple';

zSummary= table;
zSummary= groupsummary(periEventTable,["NStrialIDcum"],'all', y);

%find unique trialINS where z max or min exceed threshold
ind= []; 
ind= abs(table2array(zSummary(:,strcat("max_"+y)))) >= artifactThreshold;

ind= ind | abs(table2array(zSummary(:,strcat("min_"+y)))) >= artifactThreshold;

trialsToExclude= zSummary(ind,'NStrialIDcum');



trialsToExclude= table2array(trialsToExclude);

data= periEventTable;

%Mark artifact trials
for trial= 1:numel(trialsToExclude)
    signalCol= ["NSblue", "NSbluePox", "NSblueLox", "NSpurple", "NSpurplePox", "NSpurpleLox"];
    
%     ind= find((data.NStrialIDcum== trialsToExclude(trial))==0);
    ind= find((data.NStrialIDcum== trialsToExclude(trial)));

    data(ind, "artifact")= table(1);
    
end

periEventTable= data; %assign back to table


%% ---- Review artifact trials ----
%% individual artifact trial review

%% - peri cue


%subset artifact trials
data= periEventTable(periEventTable.artifact==1,:);

y= "DSblue"; % column to plot

clear i;

figure();
i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
i(1,1).set_names('x','time from event (s)','y','z-score');
i(1,1).set_title('Artifact trials: 465nm');

i(1,1).geom_line(); 
% i(1,1).stat_summary('type','sem','geom','area');

i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


y= "DSpurple"; % column to plot
i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
% i(2,1).stat_summary('type','sem','geom','area');
i(2,1).geom_line();
i(2,1).set_names('x','time from event (s)','y','z-score');
i(2,1).set_title('Artifact trials: 405nm');
i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


i.draw();
linkaxes();


%--NS trials
 clear i;
    
 y= "NSblue"; % column to plot

    figure();
    i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(1,1).set_names('x','time from event (s)','y','z-score');
    i(1,1).set_title('Artifact trials: 465nm');
    
    i(1,1).geom_line(); 
    
    i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

y= "NSpurple"; % column to plot

    i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(2,1).geom_line();
    i(2,1).set_names('x','time from event (s)','y','z-score');
    i(2,1).set_title('Artifact trials: 405nm');
    i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

    
    i.draw();
    linkaxes();


%% - peri pox
%subset artifact trials
data= periEventTable(periEventTable.artifact==1,:);

y= "DSbluePox"; % column to plot

clear i;

figure();
i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
i(1,1).set_names('x','time from event (s)','y','z-score');
i(1,1).set_title('Artifact trials: 465nm');

i(1,1).geom_line(); 
% i(1,1).stat_summary('type','sem','geom','area');

i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


y= "DSpurplePox"; % column to plot
i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
% i(2,1).stat_summary('type','sem','geom','area');
i(2,1).geom_line();
i(2,1).set_names('x','time from event (s)','y','z-score');
i(2,1).set_title('Artifact trials: 405nm');
i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


i.draw();
linkaxes();


%--NS trials
 clear i;
    
 y= "NSbluePox"; % column to plot

    figure();
    i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(1,1).set_names('x','time from event (s)','y','z-score');
    i(1,1).set_title('Artifact trials: 465nm');
    
    i(1,1).geom_line(); 
    
    i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

y= "NSpurplePox"; % column to plot

    i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(2,1).geom_line();
    i(2,1).set_names('x','time from event (s)','y','z-score');
    i(2,1).set_title('Artifact trials: 405nm');
    i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

    
    i.draw();
    linkaxes();
    
%% - view remaining trials
data= periEventTable(periEventTable.artifact~=1,:);

y= "DSbluePox"; % column to plot

clear i;

figure();
i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
i(1,1).set_names('x','time from event (s)','y','z-score');
i(1,1).set_title('Non-artifact trials: 465nm');

i(1,1).geom_line(); 
% i(1,1).stat_summary('type','sem','geom','area');

i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


y= "DSpurplePox"; % column to plot
i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
% i(2,1).stat_summary('type','sem','geom','area');
i(2,1).geom_line();
i(2,1).set_names('x','time from event (s)','y','z-score');
i(2,1).set_title('Non-artifact trials: 405nm');
i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);


i.draw();
linkaxes();


%--NS trials
 clear i;
    
 y= "NSbluePox"; % column to plot

    figure();
    i(1,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(1,1).set_names('x','time from event (s)','y','z-score');
    i(1,1).set_title('Artifact trials: 465nm');
    
    i(1,1).geom_line(); 
    
    i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

y= "NSpurplePox"; % column to plot

    i(2,1)=gramm('x',data.timeLock,'y',data.(y), 'color', data.NStrialIDcum, 'group', data.NStrialIDcum);
    i(2,1).geom_line();
    i(2,1).set_names('x','time from event (s)','y','z-score');
    i(2,1).set_title('Artifact trials: 405nm');
    i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);

    
    i.draw();
    linkaxes();


%% ---- Exclude artifacts ----

signalCol= ["DSblue", "DSbluePox", "DSblueLox", "DSpurple", "DSpurplePox", "DSpurpleLox"
    "NSblue", "NSbluePox", "NSblueLox", "NSpurple", "NSpurplePox", "NSpurpleLox"];

periEventTable(periEventTable.artifact==1, signalCol)= table(nan);


%% %confirm w viz:
% data= periEventTable(periEventTable.artifact==1,:);
% 
%   figure();
%     i(1,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
%     i(1,1).set_names('x','time from pox (s)','y','z-score');
%     i(1,1).set_title('Artifact trials: 465nm');
%     
%     i(1,1).geom_line(); 
%     % i(1,1).stat_summary('type','sem','geom','area');
%     
%     i(1,1).geom_hline('y',artifactThreshold, 'linewidth', 2);
% 
%     i(2,1)=gramm('x',data.timeLock,'y',data.DSpurplePox, 'color', data.DStrialIDcum, 'group', data.DStrialIDcum);
%     % i(2,1).stat_summary('type','sem','geom','area');
%     i(2,1).geom_line();
%     i(2,1).set_names('x','time from pox (s)','y','z-score');
%     i(2,1).set_title('Artifact trials: 405nm');
%     i(2,1).geom_hline('y',artifactThreshold, 'linewidth', 2);
% 
%     
%     i.draw();
