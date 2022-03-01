%% Assume you have periEventTable

%% Mean peri-DS lick by reward identity, all reward stages
%subset specific data to plot
data= periEventTable;

data= data(data.stage>=8,:);


%define variables to plot and grouping 
% i=gramm('x',data.timeLock,'y',data.DSbluePox, 'color', data.rewardID, 'lightness', data.subject);
i=gramm('x',data.timeLock,'y',data.DSbluePox, 'color', data.rewardID);


% i.geom_line();

i.facet_wrap(data.stage);

%define stats to show
i.stat_summary('type','sem','geom','area');


%define labels for plot axes
i.set_names('x','time from event (s)','y','z-score','color','subject');
i.set_title('Peri-DS');

%set y axes limits manually
i.axe_property('YLim',[-1,4]);

%draw the actual plot
i.draw();

%%
saveFig(gcf, figPath, 'allSubj-reward-periDS-allStages', figFormats)