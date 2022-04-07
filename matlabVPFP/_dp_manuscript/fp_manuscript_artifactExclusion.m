%% --Artifact exclusion from periEventTable

%% checking traces... seems like incongruous bleedthrough somewhere when ind trials are plotted
figure;
stackedplot(periEventTable, ["timeLock","DStrialIDcum","NStrialIDcum"]);

figure;
plot(periEventTable.timeLock);

figure;
% hist(periEventTable.NStrialID, periEventTable.timeLock);
hist(periEventTable.NStrialID);
hist(periEventTable.DStrialID);


%% viz summary stats of z score
%summary stats of z score 
y= 'DSpurple';

% zSummary= groupsummary(periEventTable,["subject","stage","DStrialID"],'all', y);


zSummary= groupsummary(periEventTable,["DStrialIDcum"],'all', y);

%viz 
figure;
stackedplot(zSummary, [strcat("max_",y), strcat("min_",y), strcat("var_",y)]);

figure;
stackedplot(zSummary, [strcat("max_",y), strcat("min_",y)]);


%% try to find example
data= periEventTable(contains(periEventTable.subject,'rat13'),:);

data= data(data.stage == 7, :);

figure();

i= gramm('x', data.timeLock, 'y', data.DSbluePox,'color', data.DStrialID);

i.geom_line();

i.draw();

%
figure();

i= gramm('x', data.timeLock, 'y', data.DSbluePox,'color', data.DStrialID);


i.facet_wrap(data.DStrialID);

i.geom_line();

i.draw()
%trial by trial facet looks fine... agian could be unique values of
%timeLock (small differences between trials that are causing stats to be
%off?)

figure();

i= gramm('x', data.timeLock, 'y', data.DSbluePox,'color', data.DStrialIDcum);

i.facet_wrap(data.DStrialIDcum);

i.geom_line();

i.draw()

%should only have 601 unique values...looks good
test= unique(data.timeLock);


%related to how trialID is being treated? subsets looks fine but whole
%dataset plotted looks very off...

%seems like a gramm bug...
figure();

i= gramm('x', data.timeLock, 'y', data.DSbluePox,'color', data.DStrialID);

i.geom_line();

i.draw()

% see subset fine

%seems to happen when color map changes. when selection is too large to fit
%within discrete cmap. once continuous cmap used lines appear that shouldnt
%exist. why?? think it is a bug in gramm, not the dataset itself.
data2= data(data.DStrialID>=15 & data.DStrialID <= 29 ,:);

figure();

i= gramm('x', data2.timeLock, 'y', data2.DSbluePox,'color', data2.DStrialID);

i.geom_line();
i.stat_summary('type','sem','geom','area');

i.draw();

data2= data(data.DStrialID>=15 ,:);

figure();

%adding stat line makes very clear grouping is wrong... but why only on
%this subset?
figure();
i= gramm('x', data2.timeLock, 'y', data2.DSbluePox,'color', data2.DStrialID);

i.geom_line();
i.stat_summary('type','sem','geom','area');


i.draw()

% try another geom? raw data in points is fine...
data2= data(data.DStrialID>=15,:);

figure();

i= gramm('x', data2.timeLock, 'y', data2.DSbluePox,'color', data2.DStrialID);

i.geom_point();

i.draw()

data2= data(data.DStrialID>=15 ,:);

%without color facet: bad
figure();
i= gramm('x', data2.timeLock, 'y', data2.DSbluePox);

i.geom_line();
i.stat_summary('type','sem','geom','area');


i.draw()

%group maybe?
%~~~ this is it. fixed.
figure();
i= gramm('x', data2.timeLock, 'y', data2.DSbluePox, 'group', data2.DStrialID);

i.geom_line();
i.stat_summary('type','sem','geom','area');


i.draw()

%group + color
figure();
i= gramm('x', data2.timeLock, 'y', data2.DSbluePox, 'group', data2.DStrialID, 'color', data2.DStrialID);

i.geom_line();
% i.stat_summary('type','sem','geom','area');


i.draw()


%% -- Viz distribution of z stats

%--DS trials
y= 'DSpurple';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);


%subset data to viz
data= zSummary;

% col to viz
x= strcat("max_",y);

figure;
i= gramm('x', data.(x));

i.stat_bin();

i.set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');
i.draw();


%--pox timelock (expect more extreme artifacts than DS timelock)

y= 'DSpurplePox';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);

%subset data to viz
data= zSummary;

% col to viz
x= strcat("max_",y);

figure;
i= gramm('x', data.(x), 'color', data.subject);

i.stat_bin('geom', 'stairs');

i.set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');
i.draw();

x= strcat("max_",y);

figure;
i= gramm('x', data.(x), 'color', data.subject);

i.stat_bin('normalization','cumcount');

i.set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');
i.draw();

%--abs val
x= strcat("var_",y);

figure;
i= gramm('x', abs(data.(x)), 'color', data.subject);

i.stat_bin('geom','stairs');

i.set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');
i.draw();

figure;
i= gramm('x', abs(data.(x)), 'color', data.subject);

i.stat_bin('geom','stairs');

i.set_names('x', x);
i.set_title('Artifact thresholding: Distribution of trial z score extremes');
i.draw();


%% MIN z: peri cue vs peri PE

%--DS trials
y= 'DSpurple';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);


%subset data to viz
data= zSummary;

% col to viz
x= strcat("min_",y);

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

% col to viz
x= strcat("min_",y);

i(2,1)= gramm('x', data.(x), 'color', data.subject);

i(2,1).stat_bin('geom', 'stairs');
i(2,1).set_names('x', x);
i(2,1).set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
i(2,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i.draw();

linkaxes();


%--DS trials
y= 'DSpurple';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);


%subset data to viz
data= zSummary;

% col to viz
x= strcat("min_",y);

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

% col to viz
x= strcat("min_",y);

i(2,1)= gramm('x', data.(x), 'color', data.subject);

i(2,1).stat_bin('geom', 'stairs');
i(2,1).set_names('x', x);
i(2,1).set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
i(2,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i.draw();

linkaxes();

%% ABS max/min z: peri cue vs peri PE

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


%--DS trials
y= 'DSpurple';

zSummary= groupsummary(periEventTable,["subject","stage","DStrialID", "DStrialIDcum"],'all', y);


%subset data to viz
data= zSummary;

%compute absolute max value for each trial
data(:,strcat("abs_max_",y))= table(max(abs(data.(strcat("max_",y))), abs(data.(strcat("min_",y)))));

% col to viz
x= strcat("abs_max_",y);

% col to viz
x= strcat("max_",y);

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
x= strcat("max_",y);

i(2,1)= gramm('x', data.(x), 'color', data.subject);

i(2,1).stat_bin('geom', 'stairs');
i(2,1).set_names('x', x);
i(2,1).set_title('Artifact thresholding: Distribution of trial z score extremes');

%overlay line for a few stds (trying to viz good threshold)
i(2,1).geom_vline('xintercept', 3*nanstd(data.(x)), 'style', 'k--'); 
i.draw();

linkaxes();

%% Viz 'Artifact' trials before excluding

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
%Replace data with nan for these trials
for trial= 1:numel(trialsToExclude)
    signalCol= ["DSblue", "DSbluePox", "DSblueLox", "DSpurple", "DSpurplePox", "DSpurpleLox"];
    
    data(data.DStrialIDcum== trialsToExclude(trial), signalCol)= table(nan);
end

figure();


% melt different signal columns into one based on eventType (easy plotting/faceting)
data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');

%group= 1 unique cumulative trialID per trial plotted seems to fix the incorrect line issue.
i=gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'group', data.DStrialIDcum);


%facet by stage
i.facet_wrap(data.subject);

%means
% i.stat_summary('type','sem','geom','area');

i.geom_line();

i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

%label and draw
% i.axe_property('YLim',[-5, 10]);
i.set_names('x','time from event (s)','y','z-score','color','eventType', 'column', 'subject');
i.set_title(strcat(subjects{subj},'peri-event-allStages'));

i.draw();


%% Exclude artifacts

%z score max beyond which to just exclude
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
%Replace data with nan for these trials
for trial= 1:numel(trialsToExclude)
    signalCol= ["DSblue", "DSbluePox", "DSblueLox", "DSpurple", "DSpurplePox", "DSpurpleLox"];
    
    periEventTable(periEventTable.DStrialIDcum== trialsToExclude(trial), signalCol)= table(nan);
end

%-NS trials
y= 'NSpurple';

zSummary= table;
zSummary= groupsummary(periEventTable,["NStrialIDcum"],'all', y);


%find unique trialIDs where z max or min exceed threshold
ind= [];
ind= abs(table2array(zSummary(:,strcat("max_"+y)))) >= artifactThreshold;

ind= ind | abs(table2array(zSummary(:,strcat("min_"+y)))) >= artifactThreshold;

trialsToExclude= zSummary(ind,'NStrialIDcum');


trialsToExclude= table2array(trialsToExclude);
%Replace data with nan for these trials
for trial= 1:numel(trialsToExclude)
    signalCol= ["NSblue", "NSbluePox", "NSblueLox", "NSpurple", "NSpurplePox", "NSpurpleLox"];
    
    periEventTable(periEventTable.NStrialIDcum== trialsToExclude(trial), signalCol)= table(nan);
end



