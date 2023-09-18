%% ~~~Traces~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Organize data into a format the @gramm package can utilize to easily subset data
%initialize
    idDS=[];
    idNS=[];
    daysDS =[]; 
    daysNS =[]; 
    DSzSessionblueMean=[];
    NSzSessionblueMean=[];
    DSzSessionpurpleMean=[];
    NSzSessionpurpleMean=[];
    timeLocktracesDS=[];
    timeLocktracesNS=[];
    NSintroDS=[];
    NSintroNS=[];
    CriteriaStage5DS=[];
    CriteriaStage5NS=[];
    stageDS=[];
    stageNS=[];
    pumpDS=[];
    pumpbluesignalDS=[];
    pumppurplesignalDS=[];
    pumpdayTimeLock=[];
    pumpTimeLock=[];
    tracecuetype=[];
    tracezblueall=[];
    tracezpurpleall=[];
    traceidall=[];
    tracedaysall=[];
    tracecriteriastage5all=[];
    traceNSintroall=[];
    timeLocktracesall=[];
    tracestageall=[];

%this is gathering average data across days from each animal, there is no individual trials represented in this data    
figureCount= figureCount+1; %iterate the figure count
for subj= 1:numel(subjects) %for each subject
    
    for day=1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj}));
%need to get ID for each time point, therefore just repeat it the length of
%the signal we are plotting
    repid= repelem(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).rat,length(timeLock));
    
%repeat for training days, stages
    days=subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainDay;
    days=repelem(days,length(timeLock))';
    stage=subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainStage;
    stage=repelem(stage,length(timeLock))';
%create vectors for all subjects for the DS
    idDS=vertcat(idDS,repid');
    daysDS=vertcat(daysDS,days);
    stageDS=vertcat(stageDS,stage);
    DSzSessionblueMean= vertcat(DSzSessionblueMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzblueMean);
   
    DSzSessionpurpleMean= vertcat(DSzSessionpurpleMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzpurpleMean);
  
    timeLocktracesDS= vertcat(timeLocktracesDS,timeLock');
    
    
    % for DS signal vector, find the days in which NS was introduced (NSintro=1) and repeat that one for the entire signal for that day for each rat 
    if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).NSAintro == 1)
                 repNSintroDS = repelem(1, length(timeLock));
             else
                 repNSintroDS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1)
                repNSintroDS = repelem(1, length(timeLock));
             else 
                repNSintroDS = repelem(0, length(timeLock));
             end     
    end
      NSintroDS = vertcat(NSintroDS, repNSintroDS'); 
    %find non zero days where Stage 5 criteria was met (criteria= 1)and
    %repeat that one for the entire calcium signal for that day for each
    %rat
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1)
                 repCriteriaStage5DS = repelem(1, length(timeLock));
             else
                 repCriteriaStage5DS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1)
                repCriteriaStage5DS = repelem(1, length(timeLock));
             else 
                repCriteriaStage5DS = repelem(0, length(timeLock));
             end
             
       end
     CriteriaStage5DS = vertcat(CriteriaStage5DS, repCriteriaStage5DS');
     
 %NS has different length vector, so need distinct variables for NS   
    if ~isnan(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzblueMean);
         
%         if subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainStage==8
%          pumpN=repelem(4,length(timeLock))';
%          pumpNS=vertcat(pumpNS,pumpN);% tagging NS trials from stage 8 with '4'
%         else
%         pumpN=nan;
%         pumpN=repelem(pumpN,length(timeLock))';
%         pumpNS=vertcat(pumpNS,pumpN);
%          end
         
         stageNS=vertcat(stageNS,stage);
         daysNS=vertcat(daysNS,days);
         timeLocktracesNS= vertcat(timeLocktracesNS,timeLock');
         idNS=vertcat(idNS,repid');
         NSzSessionblueMean= vertcat(NSzSessionblueMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzblueMean);
         NSzSessionpurpleMean= vertcat(NSzSessionpurpleMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzpurpleMean);
          
          % find the non zero indicies in NSitroduced column 
         if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).NSAintro == 1)
                 repNSintroNS = repelem(1, length(timeLock));
             else
                 repNSintroNS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1)
                repNSintroNS = repelem(1, length(timeLock));
             else 
                repNSintroNS = repelem(0, length(timeLock));
             end
              
         end  
       NSintroNS = vertcat(NSintroNS, repNSintroNS'); 
        %find non zero days where criteria was met (Stage 5)
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1)
                 repCriteriaStage5NS = repelem(1, length(timeLock));
             else
                 repCriteriaStage5NS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1)
                repCriteriaStage5NS = repelem(1, length(timeLock));
             else 
                repCriteriaStage5NS = repelem(0, length(timeLock));
             end
             
       end
         CriteriaStage5NS = vertcat(CriteriaStage5NS, repCriteriaStage5NS'); 
    end % end loop specific to NS 
         

    
     %FOR PROBES TRIALS: repeating the pump numbers to align with the length of the signal we
    %are plotting.  
    
    if subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainStage==8;
    
    pump1=repelem(1, length(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzbluemeanPump1))';
    pump2=repelem(2,length(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzbluemeanPump2))';
    pumpday=vertcat(pump1,pump2);
    pumpDS=vertcat(pumpDS,pumpday);
    
    pump1bluesignal= subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzbluemeanPump1;
    pump2bluesignal= subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzbluemeanPump2;
    pumpbluesignalday=vertcat(pump1bluesignal,pump2bluesignal);
    pumpbluesignalDS=vertcat(pumpbluesignalDS,pumpbluesignalday);
    
    pump1purplesignal= subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzpurplemeanPump1;
    pump2purplesignal= subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzpurplemeanPump2;
    pumppurplesignalday=vertcat(pump1purplesignal,pump2purplesignal);
    pumppurplesignalDS=vertcat(pumppurplesignalDS,pumppurplesignalday);
    
    pumpdayTimeLock=vertcat(timeLock',timeLock');
    pumpTimeLock=vertcat(pumpTimeLock,pumpdayTimeLock);
    end
    
    
    end
    end
    

%cue type
tracecuetypeDS=repelem({'DS'},length(DSzSessionblueMean))';
tracecuetypeNS=repelem({'NS'},length(NSzSessionblueMean))';

% combine DS and NS vectors to more easily plot data in @gramm
tracecuetype=vertcat(tracecuetypeDS,tracecuetypeNS);
tracezblueall=vertcat(DSzSessionblueMean,NSzSessionblueMean);
tracezpurpleall=vertcat(DSzSessionpurpleMean,NSzSessionpurpleMean);
traceidall=vertcat(idDS,idNS);
tracedaysall=vertcat(daysDS,daysNS);
tracecriteriastage5all=vertcat(CriteriaStage5DS,CriteriaStage5NS);
traceNSintroall=vertcat(NSintroDS,NSintroNS);
timeLocktracesall=vertcat(timeLocktracesDS,timeLocktracesNS);
tracestageall=vertcat(stageDS,stageNS); 





%% PLOTS of traces
%Day 1
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
   a(1,1)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracedaysall==1);
   a(1,1).stat_summary('type','sem','geom','area');
   a(1,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(1,1).set_title(' Average DS 465 nm Z Score-First Day of Training')
   a(1,1).axe_property('YLim',[-2 3])
   a(1,1).set_color_options('map','brewer_dark')
 
   a(2,1)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracedaysall==1);
   a(2,1).stat_summary('type','sem','geom','area');
   a(2,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(2,1).set_title(' Average DS 405 nm Z Score-First Day of Training')
   a(2,1).axe_property('YLim',[-2 3])
   a(2,1).set_color_options('map','brewer_dark') 

%Stage 5-day 1- when NS is introduced
   a(1,2)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',traceNSintroall==1);
   a(1,2).stat_summary('type','sem','geom','area');
   a(1,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(1,2).set_title(' Average DS 465 nm Z Score-NS Intro Day')
   a(1,2).axe_property('YLim',[-2 3])
   a(1,2).set_color_options('map','brewer_dark')
 
   a(2,2)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',traceNSintroall==1);
   a(2,2).stat_summary('type','sem','geom','area');
   a(2,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(2,2).set_title(' Average DS 405 nm Z Score-NS Intro Day')
   a(2,2).axe_property('YLim',[-2 3])
   a(2,2).set_color_options('map','brewer_dark') 

 %Day animal reached criteria 
   a(1,3)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracecriteriastage5all==1);
   a(1,3).stat_summary('type','sem','geom','area');
   a(1,3).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(1,3).set_title(' Average DS 465 nm Z Score-Day Reached Criteria')
   a(1,3).axe_property('YLim',[-2 3])
   a(1,3).set_color_options('map','brewer_dark')

   a(2,3)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracecriteriastage5all==1);
   a(2,3).stat_summary('type','sem','geom','area');
   a(2,3).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   a(2,3).set_title(' Average DS 405 nm Z Score-Day Reached Criteria')
   a(2,3).axe_property('YLim',[-2 3])
   a(2,3).set_color_options('map','brewer_dark') 

   a.draw()
      
   
   %make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'AvgTraces_SEM_Day1_Stage5Day1_Stage5CriteriaDay'),'fig');
%         close; %close 

%TRACES FROM Stage 1, Stage 5,Stage 6, Stage 7,Stage 8
%stage 1
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
   g(1,1)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracestageall==1);
   g(1,1).stat_summary('type','sem','geom','area');
   g(1,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(1,1).set_title(' Average DS 465 nm Z Score-Stage 1')
   g(1,1).axe_property('YLim',[-3 5])
   g(1,1).set_color_options('map','brewer_dark')
 
   g(2,1)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracestageall==1);
   g(2,1).stat_summary('type','sem','geom','area');
   g(2,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(2,1).set_title(' Average DS 405 nm Z Score-Stage 1')
   g(2,1).axe_property('YLim',[-3 5])
   g(2,1).set_color_options('map','brewer_dark') 

%Stage 5
   g(1,2)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracestageall==5);
   g(1,2).stat_summary('type','sem','geom','area');
   g(1,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(1,2).set_title(' Average DS 465 nm Z Score-Stage 5')
   g(1,2).axe_property('YLim',[-3 5])
   g(1,2).set_color_options('map','brewer_dark')

   g(2,2)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracestageall==5);
   g(2,2).stat_summary('type','sem','geom','area');
   g(2,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(2,2).set_title(' Average DS 405 nm Z Score-Stage 5')
   g(2,2).axe_property('YLim',[-3 5])
   g(2,2).set_color_options('map','brewer_dark') 

 %Satge 6
   g(1,3)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracestageall==6);
   g(1,3).stat_summary('type','sem','geom','area');
   g(1,3).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(1,3).set_title(' Average DS 465 nm Z Score-Stage 6')
   g(1,3).axe_property('YLim',[-3 5])
   g(1,3).set_color_options('map','brewer_dark')

   g(2,3)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracestageall==6);
   g(2,3).stat_summary('type','sem','geom','area');
   g(2,3).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(2,3).set_title(' Average DS 405 nm Z Score-Stage 6')
   g(2,3).axe_property('YLim',[-3 5])
   g(2,3).set_color_options('map','brewer_dark') 

    %Satge 7
   g(1,4)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracestageall==7);
   g(1,4).stat_summary('type','sem','geom','area');
   g(1,4).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(1,4).set_title(' Average DS 465 nm Z Score-Stage 7')
   g(1,4).axe_property('YLim',[-3 5])
   g(1,4).set_color_options('map','brewer_dark')

   g(2,4)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracestageall==7);
   g(2,4).stat_summary('type','sem','geom','area');
   g(2,4).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(2,4).set_title(' Average DS 405 nm Z Score-Stage 7')
   g(2,4).axe_property('YLim',[-3 5])
   g(2,4).set_color_options('map','brewer_dark') 
   
    %Satge 8
   g(1,5)=gramm('x',timeLocktracesall,'y', tracezblueall,'color',tracecuetype,'subset',tracestageall==8);
   g(1,5).stat_summary('type','sem','geom','area');
   g(1,5).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(1,5).set_title(' Average DS 465 nm Z Score-Stage 8')
   g(1,5).axe_property('YLim',[-3 5])
   g(1,5).set_color_options('map','brewer_dark')
   
   g(2,5)=gramm('x',timeLocktracesall,'y', tracezpurpleall,'color',tracecuetype,'subset',tracestageall==8);
   g(2,5).stat_summary('type','sem','geom','area');
   g(2,5).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   g(2,5).set_title(' Average DS 405 nm Z Score-Stage 8')
   g(2,5).axe_property('YLim',[-3 5])
   g(2,5).set_color_options('map','brewer_dark') 
   
   g.draw()
      
    
   %make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'AvgTraces_SEM_allstages'),'fig');
%         close; %close  



%% Plot traces for probe trials (avg across all animals)

[indexstage8,~]=find(tracestageall==8);

%pump 1
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1; %iterate the figure count
   k(1,1)=gramm('x',pumpTimeLock,'y', pumpbluesignalDS,'subset',pumpDS==1);
   k(1,1).stat_summary('type','sem','geom','area');
   k(1,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   k(1,1).set_title(' Average DS 465 nm Z Score- Stage 8 DS + 10% Sucrose')
   k(1,1).axe_property('YLim',[-3 5])
   k(1,1).set_color_options('map','brewer_dark')
 
   k(2,1)=gramm('x',pumpTimeLock,'y', pumppurplesignalDS,'subset',pumpDS==1);
   k(2,1).stat_summary('type','sem','geom','area');
   k(2,1).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   k(2,1).set_title(' Average DS 405 nm Z Score-Stage 8 10% Sucrose')
   k(2,1).axe_property('YLim',[-3 5])
   k(2,1).set_color_options('map','brewer_dark') 

%pump2
   k(1,2)=gramm('x',pumpTimeLock,'y', pumpbluesignalDS,'subset',pumpDS==2);
   k(1,2).stat_summary('type','sem','geom','area');
   k(1,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   k(1,2).set_title(' Average DS 465 nm Z Score-Stage 8 DS + No Sucrose')
   k(1,2).axe_property('YLim',[-3 5])
   k(1,2).set_color_options('map','brewer_dark')
 
   k(2,2)=gramm('x',pumpTimeLock,'y', pumppurplesignalDS,'subset',pumpDS==2);
   k(2,2).stat_summary('type','sem','geom','area');
   k(2,2).set_names('x','Time from Cue Onset (sec)','y','Z-Score')
   k(2,2).set_title(' Average DS 405 nm Z Score-Stage 8 DS+ No Sucrose')
   k(2,2).axe_property('YLim',[-3 5])
   k(2,2).set_color_options('map','brewer_dark') 

   k.draw()
   
      %make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'Stage8ProbetrialTraces_SEM_stages'),'fig');
%         close; %close  