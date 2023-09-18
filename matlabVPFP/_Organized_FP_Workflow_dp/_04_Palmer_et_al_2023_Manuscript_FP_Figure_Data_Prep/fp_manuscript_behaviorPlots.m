%% metadata for plotting

criteriaDS= 0.6;

criteriaLatency= 10;

stagesToPlot= [1:7];

%% todo: subset n days from criteria?

%Compare Early vs. Late training data

% n first days vs. n final days (prior to meeting criteria)





%% Figure 1: DS vs NS PE Ratio across sessions

%subplot of DS pe ratio, subplot of NS pe ratio

mapCustomCue= cmapCueGrand;

%- subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%- aggregate to one observation per session (PE ratio is aggregated measure)

    %columns to group by
groupers= ["stage","subject","trainDay", "fileID"];
    %simplfy to one observation (using mean)
data2= groupsummary(data, [groupers],'mean', ["DSpeRatio", "NSpeRatio"]);



% -make fig
figure();
clear i


 % -DS 
y= "mean_DSpeRatio";

% individual subjects means

i(1,1)= gramm('x',data2.trainDay,'y',data2.(y), 'group', data2.subject);

i(1,1).stat_summary('type','sem','geom','line');

i(1,1).set_color_options('map',mapCustomCue([2],:)); %subselecting the specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(1,1).geom_hline('yintercept', criteriaDS, 'style', 'k--'); 

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data2.trainDay,'y',data2.(y), 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',mapCustomCue([1],:)); %subselecting the specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

i(1,1).axe_property('YLim',[0,1]);
% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-DSpeRatio');   
titleFig= strcat('-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-DSpeRatio');   

i(1,1).set_title(titleFig);    
i(1,1).set_names('x','training day','y','PE probability','color','Cue type (grand mean)');


% i(1,1).draw()

%- NS

y= "mean_NSpeRatio";

% individual subjects means

i(2,1)= gramm('x',data2.trainDay,'y',data2.(y), 'group', data2.subject);

i(2,1).stat_summary('type','sem','geom','line');

i(2,1).set_color_options('map',mapCustomCue([6],:)); %subselecting the specific color levels i want from map

i(2,1).set_line_options('base_size',linewidthSubj);
i(2,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(2,1).geom_hline('yintercept', criteriaDS, 'style', 'k--'); 

i().draw();

%mean between subj + sem
i(2,1).update('x',data2.trainDay,'y',data2.(y), 'group',[]);

i(2,1).stat_summary('type','sem','geom','area');

i(2,1).set_color_options('map',mapCustomCue([7],:)); %subselecting the specific color levels i want from map

i(2,1).set_line_options('base_size',linewidthGrand)

i(2,1).axe_property('YLim',[0,1]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-NSpeRatio');   
i(2,1).set_title(title);    
i(2,1).set_names('x','training day','y','PE probability','color','Cue type (grand mean)');

i(2,1).draw()



%% stacked version for color facet of trialType (instead of subplots)
%- stack() to make cueType variable
data2= stack(data2, {'mean_DSpeRatio', 'mean_NSpeRatio'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'peRatio');

cmapGrand= cmapCueGrand;
cmapSubj= cmapCueSubj;

% -make fig
figure();
clear i

y= 'peRatio'

% individual subjects means
i(1,1)= gramm('x',data2.trainDay,'y',data2.(y), 'color', data2.trialType, 'group', data2.subject);

i(1,1).stat_summary('type','sem','geom','line');

i(1,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y',y,'color','Cue type (ind subj mean)');

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data2.trainDay,'y',data2.(y), 'color', data2.trialType, 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

% i(1,1).axe_property('YLim',[0,1]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-latency-poxRel');   
i(1,1).set_title(title);    
i(1,1).set_names('x','training day','y',y,'color','Cue type (grand mean)');

i(1,1).draw()

title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-training-peRatio');   
i(1,1).set_title(title);    
i(1,1).set_names('x','train day)','y','10s pe Probability','color','Cue type (grand mean)');

saveFig(gcf, figPath, title, figFormats);



    %% Figure 1: DS vs NS PE Latency across sessions
    
    %subplot of DS pe ratio, subplot of NS pe ratio


%- subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%- aggregate to one observation per session (PE ratio is aggregated measure)

    %columns to group by
groupers= ["stage","subject","trainDay", "fileID"];
    %simplfy to one observation (using mean)
data2= groupsummary(data, [groupers],'mean', ["poxDSrel", "poxNSrel"]);



% -make fig
figure();
clear i


 % -DS 
y= "mean_poxDSrel";

% individual subjects means

i(1,1)= gramm('x',data2.trainDay,'y',data2.(y), 'group', data2.subject);

i(1,1).stat_summary('type','sem','geom','line');

i(1,1).set_color_options('map',mapCustomCue([2],:)); %subselecting the specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% i(1,1).geom_hline('yintercept', criteriaDS, 'style', 'k--'); 

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data2.trainDay,'y',data2.(y), 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',mapCustomCue([1],:)); %subselecting the specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

i(1,1).axe_property('YLim',[0,10]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-latency-poxDS');   
i(1,1).set_title(title);    
i(1,1).set_names('x','training day','y','PE probability','color','Cue type (grand mean)');


% i(1,1).draw()

%- NS

y= "mean_poxNSrel";

% individual subjects means

i(2,1)= gramm('x',data2.trainDay,'y',data2.(y), 'group', data2.subject);

i(2,1).stat_summary('type','sem','geom','line');

i(2,1).set_color_options('map',mapCustomCue([6],:)); %subselecting the specific color levels i want from map

i(2,1).set_line_options('base_size',linewidthSubj);
i(2,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% i(2,1).geom_hline('yintercept', criteriaDS, 'style', 'k--'); 

i().draw();

%mean between subj + sem
i(2,1).update('x',data2.trainDay,'y',data2.(y), 'group',[]);

i(2,1).stat_summary('type','sem','geom','area');

i(2,1).set_color_options('map',mapCustomCue([7],:)); %subselecting the specific color levels i want from map

i(2,1).set_line_options('base_size',linewidthGrand)

i(2,1).axe_property('YLim',[0,10]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-latency-poxNS');   
i(2,1).set_title(title);    
i(2,1).set_names('x','training day','y','PE probability','color','Cue type (grand mean)');

i(2,1).draw()





% stacked version for color facet of trialType (instead of subplots)
%- stack() to make cueType variable
data2= stack(data2, {'mean_poxDSrel', 'mean_poxNSrel'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'poxRel');


% -make fig
figure();
clear i

y= 'poxRel'

% individual subjects means
i(1,1)= gramm('x',data2.trainDay,'y',data2.(y), 'color', data2.trialType, 'group', data2.subject);

i(1,1).stat_summary('type','sem','geom','line');

i(1,1).set_color_options('map',mapCustomCue([2,6],:)); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y',y,'color','Cue type (ind subj mean)');

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data2.trainDay,'y',data2.(y), 'color', data2.trialType, 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',mapCustomCue([1,7],:)); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

% i(1,1).axe_property('YLim',[0,1]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure1-latency-poxRel');   
i(1,1).set_title(title);    
i(1,1).set_names('x','training day','y',y,'color','Cue type (grand mean)');

i(1,1).draw()

