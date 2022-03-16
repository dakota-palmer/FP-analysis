%% ~~~Behavioral plots ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% %% PLOT PORT ENTRY COUNT ACROSS DAYS FOR ALL SUBJECTS - not very meaningful,  but good template for DS PE ratio or latency
% 
% %In this section, we'll loop through our subjData struct, extracting a port entry
% %count for each session. Then we'll plot # of port entries as training
% %progresses.
% 
% disp('plotting port entry counts')
% 
% figure(figureCount) %one figure with poxCount across sessions for all subjects
% 
% figureCount= figureCount+1; %iterate the figure count
% for subj= 1:numel(subjects) %for each subject
%     
%     %initialize
%     poxCount = [];
%     days = [];
%     
%    for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
%        
%        currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
%       
%        %Plot number of port entries across all sessions
%        
%         poxCount(session)= numel(currentSubj(session).pox); %get the total number of port entries across days
%         days(session)= currentSubj(session).trainDay; %keep track of days to associate with poxCount
%    end
%    hold on;
%    plot(days, poxCount)
% end
% 
% title(strcat(currentSubj(session).experiment,' port entry count across days'));
% xlabel('training day');
% ylabel('port entry count');
% legend(subjects); %add rats to legend
% 
% %make figure full screen, save, and close this figure
% set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'port_entries_by_session','.fig'));
% %         close; %close 

%% PLOT AVERAGE PORT ENTRY COUNT BETWEEN DAYS FOR ALL ANIMALS

%In this section, we'll loop through our subjData struct to get a port
%entry count for each session. Then, we'll calculate an avg port entry
%count for each subject across sessions, along with an SEM for each subject
%with n= number of sessions. This information will be used to make a
%scatter plot of individual port entry counts by day, along with the mean +/- SEM.

clear poxCount; %used the same variable name as previous section, so clear it

disp('plotting avg port entry counts by animal');

%get the figure ready before starting subj loop
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure counttitle(strcat(currentSubj(session).experiment,'avg port entry count by subject +/- SEM'));
xlabel('subject');
ylabel(' port entry count');

for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       
       %Get number of port entries for all sessions
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
       
       poxCount{1,subj}(session,1)= numel(currentSubj(session).pox);%get the total number of port entries across days %use a cell array in case # of sessions differs between subjects
       
       subjectLabel{1,subj}(session,1)= currentSubj(session).rat; %label each data point with a subject ID %use a cell array in case subjects have different # of sessions
       
   end %end session loop
   
   %Get the mean and SEM for each subject
   poxCountMean(1, subj)= nanmean(poxCount{1,subj}(:,1)); %calculate avg poxCount across sessions for each subject
   poxCountSEM(1,subj)= nanstd(poxCount{1,subj}(:,1))/sqrt(numel(currentSubj)); %calculate SEM for each subject: standard deviation of number of port entries across sessions / number of sessions for this subject


   %now plot the data
   hold on;
   
   scatter(subjectLabel{1,subj}, poxCount{1,subj}(:,:)); %scatter daily port entry counts by subject
   plot([subjectLabel{1,subj}-.2,subjectLabel{1,subj}+.2] , [poxCountMean(1,subj), poxCountMean(1,subj)], 'k'); %overlay mean of each subject
     
   plot([subjectLabel{1,subj}-.2,subjectLabel{1,subj}+.2] , [poxCountMean(1,subj)-poxCountSEM(1,subj), poxCountMean(1,subj)-poxCountSEM(1,subj)], 'k--');%overlay - sem of each subject
   plot([subjectLabel{1,subj}-.2,subjectLabel{1,subj}+.2] , [poxCountMean(1,subj)+poxCountSEM(1,subj), poxCountMean(1,subj)+poxCountSEM(1,subj)], 'k--');%overlay + sem of each subject
   plot([subjectLabel{1,subj}, subjectLabel{1,subj}], [poxCountMean(1,subj),poxCountMean(1,subj)-poxCountSEM(1,subj)], 'k--'); %connect -SEM to mean
   plot([subjectLabel{1,subj}, subjectLabel{1,subj}], [ poxCountMean(1,subj), poxCountMean(1,subj)+poxCountSEM(1,subj)], 'k--'); %connect +SEM to mean
end

%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'average_port_entries_by_subject','.fig'));
%         close; %close 

%% PLOT DS & NS PE RATIO ACROSS DAYS

disp('plotting port entry ratios')

stagesToPlot= [1:5] %only plot training stages

%initialize
    id=[];
    days = []; 
    DSpeRatio= [];
    NSpeRatio= [];
    tensecDSpeRatio= [];
    tensecNSpeRatio= [];
    
%create one vector for each identifier of the data by concatinating all
%subject data for each respective variable, for all days
for subj= 1:numel(subjects) %for each subject
    for day=1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj}));
    
        if ismember(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainStage, stagesToPlot)
            id=vertcat(id,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).rat);
            days = vertcat(days,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainDay); 
            DSpeRatio= vertcat(DSpeRatio,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).behavior.DSpeRatio);
            NSpeRatio= vertcat(NSpeRatio,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).behavior.NSpeRatio);
            tensecDSpeRatio= vertcat(tensecDSpeRatio,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).behavior.tensecDSpeRatio);
            tensecNSpeRatio= vertcat(tensecNSpeRatio,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).behavior.tensecNSpeRatio);
        end
    end
end

%    for session = 1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj})) %for each training session this subject completed
%        
%        currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
%       
%        %Plot number of port entries across all sessions
%        
%         days(session)= currentSubj(session).trainDay; %keep track of days to associate with PE ratios
%        
%         DSpeRatio(session)= currentSubj(session).behavior.DSpeRatio; %get the DSpeRatio
%        
%         NSpeRatio(session)= currentSubj(session).behavior.NSpeRatio; %get NSpeRatio
%    end
%   
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
   g(1,1)=gramm('x',days,'y', DSpeRatio,'color',id);
   g(1,1).geom_line()
   g(1,1).set_names('x','training day','y','port entry ratio (# of trials with PE / total # of trials)','color','Subject')
   g(1,1).set_title(' DS PE Ratio across days')
   %todo: error "too many color categories for this color map"
%    g (1,1).set_color_options('map','brewer_dark') 
     g(1,1).set_color_options('map','pm') %pm has enough colors to prevent errors (so far)
      

%    g (1,1).set_color_options('map','brewer_dark')
   

   g(2,1)= gramm('x',days,'y',NSpeRatio,'color',id)
   g(2,1).geom_line()
   g(2,1).set_names('x','training day','y','port entry ratio (# of trials with PE / total # of trials)','color','Subject')
   g(2,1).set_title(' NS PE Ratio across days')
   g(2,1).set_line_options('styles',{'--'})
%    g(2,1).set_color_options('map','brewer_dark')
   g(2,1).set_color_options('map','pm')
    g.draw()



   
   saveas(gcf, strcat(figPath,'AvgDSPE_NSPE'),'fig');
   %% PLOT PE RATIO IN FIRST 10SEC
   disp('plotting DS & NS ratios in first 10 sec')
   figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
   %mean DS PE ratio in first 10 sec across animals, will display as a dark
   %black line
   j(1,1)= gramm('x',days,'y', tensecDSpeRatio)
%    j(1,1).stat_summary('geom','line');
    j(1,1).stat_summary('type','sem','geom','area');

   j(1,1).set_title(' DS PE Ratio across days')
   j(1,1).set_color_options('chroma',0,'lightness',30);
   
   %mean NS PE ratio in first 10 sec across animals, will display as a dark
   %black line
   j(2,1)= gramm('x',days,'y',tensecNSpeRatio)
%    j(2,1).stat_summary('geom','line');
    j(2,1).stat_summary('type','sem','geom','area');
%    j(2,1).set_line_options('styles',{'--'})
   j(2,1).set_title(' NS PE Ratio across days')
   j(2,1).set_color_options('chroma',0,'lightness',30);
% %    j(2,1).set_color_options('chroma',0,'lightness',30);

 
   %DS PE ratio in first 10 sec for all animals, will display as pastel
   %lines
   j(1,1).update('color',id);%update plots on same subplot, in this case (1,1)
   j(1,1).geom_line()
   j(1,1).set_names('x','training day','y','port entry ratio in first 10 sec(# of trials with PE / total # of trials)','color','Subject')
   j(1,1).set_color_options('map','pm')

%    j(1,1).set_color_options('map','brewer2')
  

   %NS PE ratio in first 10 sec for all animals, will display as pastel
   %lines  
   j(2,1).update('color',id)
   j(2,1).geom_line()
   j(2,1).set_names('x','training day','y','port entry ratio in first 10 sec(# of trials with PE / total # of trials)','color','Subject')
%    j(2,1).set_line_options('styles',{'--'})
   j(2,1).set_color_options('map','pm')
%    j(2,1).set_color_options('chroma',0,'lightness',30);

%    j(2,1).set_color_options('map','brewer2')

   j.draw();
 
    %make figure full screen, save, and close this figure
saveas(gcf, strcat(figPath,'AvgDSPE_NSPE_first10sec'),'fig');
%    subplot(2,1,1)
%    hold on;
%    h= plot(days, DSpeRatio); %save a handle so we can get the color of this plot and use it for NS
%    
%    %get this plot's color and x axis so we can use the same color for the NS plot
%    c= get(h,'Color');
%    x= xlim;
%    y=[0,1];
%    
%    subplot(2,1,2)
%    hold on;
%    plot(days, NSpeRatio, 'Color', c, 'LineStyle','--');
%    xlim(x);
%    ylim(y);
%    
% end

% subplot(2,1,1)
% title(strcat(currentSubj(session).experiment,' DS PE Ratio across days'));
% xlabel('training day');
% ylabel('port entry ratio (# of trials with PE / total # of trials)');
% legend(subjects, 'Location', 'eastoutside'); %add rats to legend, location outside of plot
% 
% subplot(2,1,2)
% title(strcat(currentSubj(session).experiment,' NS PE Ratio across days'));
% xlabel('training day');
% ylabel('port entry ratio (# of trials with PE / total # of trials)');
% legend(subjects, 'Location', 'eastoutside'); %add rats to legend, location outside of plot
% 
% 
% %make figure full screen, save, and close this figure
% set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'pe_ratio_by_session','.fig'));
% %         close; %close 

linkaxes()
xlim([1,20])
ylim([0,1])

%% PLOT DS & NS LICKS ACROSS DAYS

%In this section, we'll loop through our subjData struct, extracting a port entry
%count for each session. Then we'll plot # of port entries as training
%progresses.

disp('plotting DS & NS licks')

figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
for subj= 1:numel(subjects) %for each subject
    
    %initialize
    days = []; 
    DSlicks= [];
    NSlicks= [];
   
   for session = 1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj})) %for each training session this subject completed
       
       currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
      
       %Plot number of port entries across all sessions
       
        days(session)= currentSubj(session).trainDay; %keep track of days to associate with PE ratios
       
        
        %we have saved timestamps of each lick during the cue saved in
        %SubjDataAnalyzed.behavior. We'll use cellfun to get the length of
        %each cell (the number of licks in each cue presentation), then
        %we'll sum this to get a total lick count during cues in that
        %session
        DSlicks(session)= sum(cellfun('length', currentSubj(session).behavior.loxDS)); %get the DS licks
       
        if isempty(currentSubj(session).periNS.NS) %if this is a trial without NS data, make lick count nan (just makes plot nicer)
            NSlicks(session)=nan;
        else %otherwise, if there's valid NS data get the lick count
            NSlicks(session)= sum(cellfun('length',currentSubj(session).behavior.loxNS)); %get NS licks
        end   
        
        
   end
   subplot(2,1,1)
   hold on;
   h= plot(days, DSlicks); %save a handle so we can get the color of this plot and use it for NS
   
   %get this plot's color and x axis so we can use the same color for the NS plot
   c= get(h,'Color');
   x= xlim;
%    y=ylim;
   
   subplot(2,1,2)
   hold on;
   plot(days, NSlicks, 'Color', c, 'LineStyle','--');
   xlim(x);
%    ylim(y);
   
end

subplot(2,1,1)
title(strcat(currentSubj(session).experiment,' DS licks across days'));
xlabel('training day');
ylabel('# of licks in DS epoch (cue onset+ cue duration)');
legend(subjects, 'Location', 'eastoutside'); %add rats to legend, location outside of plot

subplot(2,1,2)
title(strcat(currentSubj(session).experiment,' NS licks across days'));
xlabel('training day');
ylabel('# of licks in NS epoch (cue onset+ cue duration)');
legend(subjects, 'Location', 'eastoutside'); %add rats to legend, location outside of plot


%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'allrats_cueLicks','.fig'));
%         close; %close 

