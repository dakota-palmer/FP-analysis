%% CROSS CORRELATION OF PHOTOMETRY SIGNALS

% %% Try to ID bad/noisy sessions through simple correlation of 465nm and 405nm fp signals
% 

%% Custom colormap for plots

%green and purple %3 levels each, dark to light extremes + neutral middle
mapCustom= [ 27,120,55;
            127,191,123;
            217,240,211;
            247,247,247
            231,212,232
            175,141,195;
            118,42,131;

           ];


        mapCustom= mapCustom/255;


%% ----------------- Session Correlation -----------------------------------
% ------ Instead of whole raw trace, run Corr of concatenated trial-by-trial data  ------


r= []; %collect coeffs

rPeriCue= [];

corrTable= table();

sesInd= 1;

%For a given session, let's get a correlation coefficient of Blue & Purple
%signal over time
for subj= 1:numel(subjects) %for each subject
   currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   
%    figure(); %1 fig per subject
   
   for session = 1:numel(currentSubj) %for each training session this subject completed

%        currentSubj(session).signalCorrelation= xcorr(currentSubj(session).raw.reblue,currentSubj(session).raw.repurple,0,'coeff');
%         
% %        simple xcorr
% %   ~ dont think this is really appropriate. xcorr is two for time series,
% %   shifted version of one x another
% 
%          currentSubj(session).signalCorrelation= xcorr(currentSubj(session).raw.reblue,currentSubj(session).raw.repurple,0,'coeff');
% %          r= [r, currentSubj(session).signalCorrelation(1,1)];
%         

    %corr()
       currentSubj(session).signalCorrelation= corr(currentSubj(session).raw.reblue,currentSubj(session).raw.repurple);
       r= [r, currentSubj(session).signalCorrelation(1,1)];

         r= nan(1,1);
         r= currentSubj(session).signalCorrelation(1,1);
                 
        
        %dp 2022-04-26 remove artifact trials
               
        
        y1= []; y2=[];
        y1= squeeze(currentSubj(session).periDS.DSzblue(:,:,:));
        y2= squeeze(currentSubj(session).periDS.DSzpurple(:,:,:));
        
        ind= [];
        ind=((any((y1>= artifactThreshold),1)) |(any((y2>= artifactThreshold),1)));
        
        y1(ind)= nan;
        y2(ind)=nan;
        
        currentSubj(session).periDS.DSzblue(:,:,ind)= nan;
        currentSubj(session).periDS.DSzpurple(:,:,ind)= nan;
        currentSubj(session).periDS.DSblue(:,:,ind)= nan;
        currentSubj(session).periDS.DSpurple(:,:,ind)= nan;
        
        %dp 2022-04-26 instead of corrCoef, calculate AUC of 465 and 405
        %for comparison
        
                
        %include only time after cue onset in correlation
        tsInd= [];
        tsInd= currentSubj(session).periDS.timeLock>=0;
        
       
        y1= squeeze(currentSubj(session).periDS.DSzblue(tsInd,:,:));
        y2= squeeze(currentSubj(session).periDS.DSzpurple(tsInd,:,:));
       
        auc=[]; aucAbs=[]; aucCum= []; aucCumAbs=[];
        [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(y1);
        
        %make sure table has equal sized cells or gramm will be upset (fill empty w nan)
        if numel(auc) ~= 30
           auc(numel(auc)+1:30)= nan; 
        end

        corrTable(sesInd, "aucDSblueAll")= {{auc}};
        corrTable(sesInd, "aucDSblue")= table(nanmean(auc));
        
        auc=[]; aucAbs=[]; aucCum= []; aucCumAbs=[];
        [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(y2);
        
        %make sure table has equal sized cells or gramm will be upset (fill empty w nan)
        if numel(auc) ~= 30
           auc(numel(auc)+1:30)= nan; 
        end
        
        corrTable(sesInd, "aucDSpurpleAll")= {{auc}};
        corrTable(sesInd, "aucDSpurple")= table(nanmean(auc));
        
        
        %calculate delta in AUCs
        y1=[]; y2=[];

        y1= corrTable(sesInd,:).aucDSblueAll;
        y2= corrTable(sesInd,:).aucDSpurpleAll;

        corrTable(sesInd, "aucDSdeltaAll")= {{y1{:}-y2{:}}};
        
        corrTable(sesInd, "aucDSdelta")= table(nanmean(y1{:}-y2{:}));
        
        
         %PERI-EVENT correlation- collapsed, single value for all
        y1= [];
        y2= [];
        
        %include only time after cue onset in correlation
        tsInd= [];
        tsInd= currentSubj(session).periDS.timeLock>=0;
        
        %dp 2022-04-25 single corrCoef per session of cat() peri-cue Z score
        y1= squeeze(currentSubj(session).periDS.DSzblue(tsInd,:,:));
        y2= squeeze(currentSubj(session).periDS.DSzpurple(tsInd,:,:));
        
%         test= corr(y1,y2);
        
        y1= y1(:);
        y2= y2(:);
        
%         test2= corr(y1,y2);
        
        currentSubj(session).periCueCorrelation= corr(y1,y2);

         rPeriCue= [rPeriCue, currentSubj(session).periCueCorrelation(1,1)];

         rPeriCue= nan(1,1);
         rPeriCue= currentSubj(session).periCueCorrelation(1,1);
         
         corrTable(sesInd, "rPeriCue")= table(rPeriCue);
         
%          corrTable(sesInd,"r")= table(r);
         corrTable(sesInd, "r")= table(rPeriCue);
         


         corrTable(sesInd,"fileID")= table(sesInd);
         
         corrTable(sesInd,"trainDay")= table(currentSubj(session).trainDay);
         
         corrTable(sesInd,"stage")= table(currentSubj(session).trainStage);
         
         corrTable(sesInd,'subject')= {subjects{subj}};
         
         corrTable(sesInd, 'reblue')= {currentSubj(session).raw.reblue};
         corrTable(sesInd, 'repurple')= {currentSubj(session).raw.repurple};
         corrTable(sesInd, 'cutTime')= {{currentSubj(session).raw.cutTime}};
         
         corrTable(sesInd,"reDelta")= {currentSubj(session).raw.reblue-currentSubj(session).raw.repurple};

         %-- collect mean Peri-Event traces for viz
         corrTable(sesInd,"timeLock")= {currentSubj(session).periDS.timeLock}; 
         corrTable(sesInd,"periDSblue")= {currentSubj(session).periDS.DSblueMean};
         corrTable(sesInd,"periDSpurple")= {currentSubj(session).periDS.DSpurpleMean};
         
         corrTable(sesInd,"periDSzblue")= {currentSubj(session).periDS.DSzblueMean};
         corrTable(sesInd,"periDSzpurple")= {currentSubj(session).periDS.DSzpurpleMean};
            
        %-- collect all trial data for correlation of peri-event
         corrTable(sesInd,"periDSblueAll")= {currentSubj(session).periDS.DSblue};
         corrTable(sesInd,"periDSpurpleAll")= {currentSubj(session).periDS.DSpurple};

         corrTable(sesInd,"periDSzblueAll")= {currentSubj(session).periDS.DSzblue};
         corrTable(sesInd,"periDSzpurpleAll")= {currentSubj(session).periDS.DSzpurple};

         
   sesInd= sesInd+1;
   
   end %end session loop
end %end subject loop

%% Viz AUC 465 v 405nm across sessions

% individual subj
for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
   data2= data;
%    for stage= 1:numel(stagesToPlot)         
       
%       data2= data(data.stage==stagesToPlot(stage),:);

      figure;
      clear i;
      
      i= gramm('x', data2.trainDay, 'y', data2.aucDSblueAll);
      
%       i.facet_wrap(data2.stage);
      
      i.geom_point();
%       i.geom_line();

      i().set_color_options('map', mapCustom(3,:));        
      i().set_line_options('base_size',0.5)
      
      i.draw();
      
      i.update('x', data2.trainDay, 'y', data2.aucDSblue);
      
%       i.geom_point();
%       i.geom_line();
      i.stat_summary('type','sem','geom','area');
      i().set_color_options('map', mapCustom(2,:));        
      i().set_line_options('base_size',1)    

      i.draw();
      
      %--405
       i.update('x', data2.trainDay, 'y', data2.aucDSpurpleAll);
      
      i.geom_point();
%       i.geom_line();

      i().set_color_options('map', mapCustom(5,:));        
      i().set_line_options('base_size',0.5)
      i.draw();
      
      i.update('x', data2.trainDay, 'y', data2.aucDSpurple);
      
%       i.geom_point();
%       i.geom_line();
      i.stat_summary('type','sem','geom','area');
      i().set_color_options('map', mapCustom(6,:));        
      i().set_line_options('base_size',1)    
      
      
      i.axe_property('YLim',[-20,20]);
      title= strcat(subjMode,'-subject-',subjects{subj},'allStages-','-auc-sessions-DS');
      i.set_title(title);
      i.set_names('x','train day','y','AUC zscore','color','signal type');

      i.draw();

      saveFig(gcf, figPath, title, figFormats)
      
       
%    end


% by stage
 data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
   data2= data;
%    for stage= 1:numel(stagesToPlot)         
       
%       data2= data(data.stage==stagesToPlot(stage),:);

      figure;
      clear i;
      
      i= gramm('x', data2.trainDay, 'y', data2.aucDSblueAll);
      
      i.facet_wrap(data2.stage);
      
      i.geom_point();
%       i.geom_line();

      i().set_color_options('map', mapCustom(3,:));        
      i().set_line_options('base_size',0.5)
      
      i.draw();
      
      i.update('x', data2.trainDay, 'y', data2.aucDSblue);
      
%       i.geom_point();
%       i.geom_line();
      i.stat_summary('type','sem','geom','area');
      i().set_color_options('map', mapCustom(2,:));        
      i().set_line_options('base_size',1)    

      i.draw();
      
      %--405
       i.update('x', data2.trainDay, 'y', data2.aucDSpurpleAll);
      
      i.geom_point();
%       i.geom_line();

      i().set_color_options('map', mapCustom(5,:));        
      i().set_line_options('base_size',0.5)
      
      i.draw();
      
      i.update('x', data2.trainDay, 'y', data2.aucDSpurple);
      
%       i.geom_point();
%       i.geom_line();
      i.stat_summary('type','sem','geom','area');
      i().set_color_options('map', mapCustom(6,:));        
      i().set_line_options('base_size',1)    
      
      
      i.axe_property('YLim',[-20,20]);
      title= strcat(subjMode,'-subject-',subjects{subj},'-byStage-','-auc-sessions-DS');
      i.set_title(title);
      i.set_names('x','train day','y','AUC zscore','color','signal type');

      i.axe_property('YLim',[-20,20]);

      i.draw();

      saveFig(gcf, figPath, title, figFormats)
      

end


%% viz auc distribution

data= corrTable;


figure;
clear i;

i= gramm('x', data.subject, 'y', data.aucDSdeltaAll, 'group', data.subject);


i.stat_boxplot();

title= strcat(subjMode,'-allSubject-aucZ-distributionAllStages-DS');

i.set_title(title);

i.axe_property('YLim',[-20,40]);

i.draw()

saveFig(gcf, figPath, title, figFormats);

%stages

figure;
clear i;

i= gramm('x', data.subject, 'y', data.aucDSdeltaAll, 'color', data.stage);


i.stat_boxplot();

title= strcat(subjMode,'-allSubject-aucZ-distributionByStage-DS');

i.set_title(title);

i.axe_property('YLim',[-20,40]);

i.draw()

saveFig(gcf, figPath, title, figFormats);

%% Facet peri-cue z by AUC delta

% bin auc and facet periEventTraces by this

% convert into 10 bins 
y= [];
e= [];

[y, e]= discretize(corrTable.aucDSdelta, 10);

corrTable.aucBin= y;

% save labels of bin edges too 
for bin= 1:numel(e)-1
    
    ind= [];
    ind= corrTable.aucBin== bin;
    
   corrTable(ind, "aucBinEdge")= table(e(bin)); 
end

% Final improvement: 465 vs 405 z score with r facet

stagesToPlot= unique(corrTable.stage);

for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
   for stage= 1:numel(stagesToPlot)
   
       
%         TODO: much more efficient method would be to stack() and form
%         signalType column to facet color= 405 or 465
           
       
       data2= data(data.stage==stagesToPlot(stage),:);

        figure();
        clear i;

%         
%         draw in order of background-> foreground
%          individual trials -> sessions -> grand mean
         
%         - sessions, 465
        y= data2.periDSzblueAll;
        y= data2.periDSzblue; 
        i= gramm('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        
        i.facet_wrap(data2.aucBinEdge, 'ncols', 5);
        
        i().stat_summary('type','sem', 'geom','line');
        
        i.geom_line();
        
        i().set_color_options('map', mapCustom(2,:));        
        i().set_line_options('base_size',1)        
   
        i.draw();
        
%        - sessions, 405
        y= data2.periDSzpurple; 

        i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        i().stat_summary('type','sem', 'geom','line');
        i.geom_line();
        
        i().set_color_options('map', mapCustom(6,:));        
        i().set_line_options('base_size',1)        
   
        i.draw();
        
%         - Grand mean, 465
        y= data2.periDSzblue; 

        i.update('x', data2.timeLock, 'y', y, 'group', []);
                
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('map', mapCustom(1,:));        
        i().set_line_options('base_size',2)        
   
        i.draw();
        
        
%           - Grand mean, 405
        y= data2.periDSzpurple; 

        i.update('x', data2.timeLock, 'y', y, 'group', []);
                
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('map', mapCustom(7,:));        
        i().set_line_options('base_size',2)        
         
      i.axe_property('YLim',[-5,10]);
      title= strcat(subjMode,'-subject-',subjects{subj},'-stage-',num2str(stagesToPlot(stage)),'-aucDelta-zTraces-DS');
      i.set_title(title);
      i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'aucDeltaBinEdge >');

      i.draw();

      saveFig(gcf, figPath, title, figFormats)
      
   end 
         
end


% - between subjects z plots

data= corrTable;

for stage= 1:numel(stagesToPlot)

%     Between-subj figs
        data2= data(data.stage==stagesToPlot(stage),:);


            figure();
            clear i;


            % draw in order of background-> foreground
             %individual trials -> sessions -> grand mean

%             - sessions, 465
            y= data2.periDSzblue; 

%             i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
            i= gramm('x', data2.timeLock, 'y', y, 'group', data2.subject);
            i.facet_wrap(data2.aucBinEdge, 'ncols', 5);

            i().stat_summary('type','sem', 'geom','line');
            i.geom_line();

            i().set_color_options('map', mapCustom(2,:));        
            i().set_line_options('base_size',1)        

            i.draw();

%            - sessions, 405
            y= data2.periDSzpurple; 

            i.update('x', data2.timeLock, 'y', y, 'group', data2.subject);
            i().stat_summary('type','sem', 'geom','line');
            i.geom_line();

            i().set_color_options('map', mapCustom(6,:));        
            i().set_line_options('base_size',1)        

            i.draw();

%             - Grand mean, 465
            y= data2.periDSzblue; 

            i.update('x', data2.timeLock, 'y', y, 'group', []);

            i().stat_summary('type','sem', 'geom','area');

            i().set_color_options('map', mapCustom(1,:));        
            i().set_line_options('base_size',2)        

            i.draw();


%               - Grand mean, 405
            y= data2.periDSzpurple; 

            i.update('x', data2.timeLock, 'y', y, 'group', []);

            i().stat_summary('type','sem', 'geom','area');

            i().set_color_options('map', mapCustom(7,:));        
            i().set_line_options('base_size',2)        

          i.axe_property('YLim',[-5,10]);
          title= strcat(subjMode,'-allSubj-stage-',num2str(stagesToPlot(stage)),'-aucDelta-zTraces-DS');
          i.set_title(title);
          i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'aucBinEdge >');

          i.draw();

          saveFig(gcf, figPath, title, figFormats)
end


%% Statistical comparison of 465nm and 405nm AUC

%Run a T-Test for each session comparing 465nm and 405nm AUCs from all
%trials.

%Easy prediction should lend itself to straightforward exclusion:
%if no signal, mean 465 and 405 AUC are not *significantly* different (delta= 0)

%initialize new col with nan
corrTable(:, "aucTtestH")= {nan};

corrTable(:, "aucTtestP")= {nan};

allSessions= unique(corrTable.fileID);  

for session = 1:numel(allSessions)

    %subset data by fileID
    ind= [];
    ind= corrTable.fileID== allSessions(session);
    
    data= corrTable(ind, :);
    
    %Paired samples t test (same subject, same session so not independent samples)
    
    y1=[]; y2=[];
    
    y1= data.aucDSblueAll{:};
    y2= data.aucDSpurpleAll{:};
    

    h=[]; p=[]; ci=[]; stats=[];
    
    alpha= 0.05;
    
    [h,p,ci,stats]= ttest(y1,y2, 'Alpha', alpha);
         
%      The result h is 1 if the test rejects the null hypothesis
    
    corrTable(ind, "aucTtestH")= {h};
    
    corrTable(ind, "aucTtestP")= {p};
    
    
end


%% Plot AUC ttest results


% individual subj
for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
   data2= data;
%    for stage= 1:numel(stagesToPlot)         
       
%       data2= data(data.stage==stagesToPlot(stage),:);

      figure;
      clear i;
      
      i= gramm('x', data2.trainDay, 'y', data2.aucTtestP);
            
      i.geom_point();

      i().geom_hline('yintercept', alpha, 'style', 'k--'); 
      
      i.draw();      
      
      
      i.axe_property('YLim',[0,1]);
      title= strcat(subjMode,'-subject-',subjects{subj},'allStages-','-auc-tTestP-sessions-DS');
      i.set_title(title);
      i.set_names('x','train day','y','AUC 465v405 p','color','signal type');

      i.draw();

      saveFig(gcf, figPath, title, figFormats)
      
       
%    end


% by stage
 data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
   data2= data;
%    for stage= 1:numel(stagesToPlot)         
       
%       data2= data(data.stage==stagesToPlot(stage),:);

      figure;
      clear i;
      
      i= gramm('x', data2.trainDay, 'y', data2.aucTtestP);
      
      i.facet_wrap(data2.stage);
      
      i.geom_point();
%       i.geom_line();
      i().geom_hline('yintercept', alpha, 'style', 'k--'); 
      
      i.draw();
     
      
      i.axe_property('YLim',[0,1]);
      title= strcat(subjMode,'-subject-',subjects{subj},'-byStage-','-auc-tTest-sessions-DS');
      i.set_title(title);
      i.set_names('x','train day','y','AUC 465v405 p','color','signal type');

%       i.axe_property('YLim',[-20,20]);

      i.draw();

      saveFig(gcf, figPath, title, figFormats)
      

end

%% plot AUC ttest between subj 

data= corrTable;


figure;
  clear i;

  i= gramm('x', data.trainDay, 'y', data.aucTtestP, 'color', data.subject);

%       i.facet_wrap(data2.stage);

  i.geom_point();
  i.geom_line();
  i().geom_hline('yintercept', alpha, 'style', 'k--'); 

  i.draw();

  %mean btwn subj
  i.update('x', data.trainDay, 'y', data.aucTtestP, 'color', []);

  i.stat_summary('type', 'sem', 'geom', 'area');
  
  i().set_color_options('chroma', 2);        

  i.axe_property('YLim',[0,1]);
  title= strcat(subjMode,'-allSubj-byStage-','-auc-tTest-sessions-DS');
  i.set_title(title);
  i.set_names('x','train day','y','AUC 465v405 p','color','signal type');

  i.draw();

  saveFig(gcf, figPath, title, figFormats)

%% Session corrcoef stuff
% %% ----- session corrCoef stuff:
% % 
% % % bin corrcoef and facet periEventTraces by this
% % 
% % 
% % convert into 10 bins 
% % y= [];
% % e= [];
% % 
% % this method is not making even bins, some are even empty...
% % dataset is pretty heavily skewed toward +1 with some extreme negative
% % exceptions
% % [y, e]= discretize(corrTable.r, 10);
% % 
% % corrTable.rBin= y;
% % 
% % save labels of bin edges too 
% % for bin= 1:numel(e)-1
% %     
% %     ind= [];
% %     ind= corrTable.rBin== bin;
% %     
% %    corrTable(ind, "rBinEdge")= table(e(bin)); 
% % end
% % 
% % % Final improvement: 465 vs 405 z score with r facet
% % 
% % stagesToPlot= unique(corrTable.stage);
% % 
% % for subj= 1:numel(subjects)
% %    data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
% %        
% %    for stage= 1:numel(stagesToPlot)
% %    
% %        
% %         TODO: much more efficient method would be to stack() and form
% %         signalType column to facet color= 405 or 465
% %            
% %        
% %        data2= data(data.stage==stagesToPlot(stage),:);
% % 
% %         figure();
% %         clear i;
% % 
% %         
% %         draw in order of background-> foreground
% %          individual trials -> sessions -> grand mean
% %          
% %         - sessions, 465
% %         y= data2.periDSzblueAll;
% %         y= data2.periDSzblue; 
% %         i= gramm('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %         
% %         i.facet_wrap(data2.rBinEdge, 'ncols', 5);
% %         
% %         i().stat_summary('type','sem', 'geom','line');
% %         
% %         i.geom_line();
% %         
% %         i().set_color_options('map', mapCustom(2,:));        
% %         i().set_line_options('base_size',1)        
% %    
% %         i.draw();
% %         
% %        - sessions, 405
% %         y= data2.periDSzpurple; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %         i().stat_summary('type','sem', 'geom','line');
% %         i.geom_line();
% %         
% %         i().set_color_options('map', mapCustom(6,:));        
% %         i().set_line_options('base_size',1)        
% %    
% %         i.draw();
% %         
% %         - Grand mean, 465
% %         y= data2.periDSzblue; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', []);
% %                 
% %         i().stat_summary('type','sem', 'geom','area');
% %         
% %         i().set_color_options('map', mapCustom(1,:));        
% %         i().set_line_options('base_size',2)        
% %    
% %         i.draw();
% %         
% %         
% %           - Grand mean, 405
% %         y= data2.periDSzpurple; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', []);
% %                 
% %         i().stat_summary('type','sem', 'geom','area');
% %         
% %         i().set_color_options('map', mapCustom(7,:));        
% %         i().set_line_options('base_size',2)        
% %          
% %       i.axe_property('YLim',[-5,10]);
% %       title= strcat(subjMode,'-subject-',subjects{subj},'-stage-',num2str(stagesToPlot(stage)),'-sessionCorrRaw-zTraces-DS');
% %       i.set_title(title);
% %       i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'sessionCorrRaw raw >');
% % 
% %       i.draw();
% % 
% %       saveFig(gcf, figPath, title, figFormats)
% %       
% %    end 
% %          
% % end
% % 
% % 
% % % - between subjects z plots
% % 
% % data= corrTable;
% % 
% % for stage= 1:numel(stagesToPlot)
% % 
% %     Between-subj figs
% %         data2= data(data.stage==stagesToPlot(stage),:);
% % 
% % 
% %             figure();
% %             clear i;
% % 
% % 
% %             % draw in order of background-> foreground
% %              %individual trials -> sessions -> grand mean
% % 
% %             - sessions, 465
% %             y= data2.periDSzblue; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %             i= gramm('x', data2.timeLock, 'y', y, 'group', data2.subject);
% %             i.facet_wrap(data2.rBinEdge, 'ncols', 5);
% % 
% %             i().stat_summary('type','sem', 'geom','line');
% %             i.geom_line();
% % 
% %             i().set_color_options('map', mapCustom(2,:));        
% %             i().set_line_options('base_size',1)        
% % 
% %             i.draw();
% % 
% %            - sessions, 405
% %             y= data2.periDSzpurple; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', data2.subject);
% %             i().stat_summary('type','sem', 'geom','line');
% %             i.geom_line();
% % 
% %             i().set_color_options('map', mapCustom(6,:));        
% %             i().set_line_options('base_size',1)        
% % 
% %             i.draw();
% % 
% %             - Grand mean, 465
% %             y= data2.periDSzblue; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', []);
% % 
% %             i().stat_summary('type','sem', 'geom','area');
% % 
% %             i().set_color_options('map', mapCustom(1,:));        
% %             i().set_line_options('base_size',2)        
% % 
% %             i.draw();
% % 
% % 
% %               - Grand mean, 405
% %             y= data2.periDSzpurple; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', []);
% % 
% %             i().stat_summary('type','sem', 'geom','area');
% % 
% %             i().set_color_options('map', mapCustom(7,:));        
% %             i().set_line_options('base_size',2)        
% % 
% %           i.axe_property('YLim',[-5,10]);
% %           title= strcat(subjMode,'-allSubj-stage-',num2str(stagesToPlot(stage)),'-sessionCorrCoef-zTraces-DS');
% %           i.set_title(title);
% %           i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'sessionCorrCoef raw >');
% % 
% %           i.draw();
% % 
% %           saveFig(gcf, figPath, title, figFormats)
% % end
% % 
% % 
% % %% Establish some corrcoef threshold beyond which to call "noisy" or "nosignal" trial
% % 
% % thresholdCorrCoef= 0.5;
% % 
% % 
% % %% Count of trials beyond threshold per session
% % 
% % corrTable(:,'corrThresholdTrial')= table(nan);
% % 
% % ind=[];
% % ind= corrTable.r >= thresholdCorrCoef;
% % 
% % corrTable(ind, "rThreshold")= table(1);
% % 
% % data= corrTable(corrTable.rThreshold==1,:);
% % 
% % figure();
% % clear i;
% % 
% % 
% % i= gramm('x', data.trainDay, 'y', data.rThreshold, 'group', data.subject, 'color', data.subject);
% % 
% % i.facet_wrap(data.subject);
% % 
% % i.geom_line();
% % i.geom_point();
% % 
% % 
% % title= strcat(subjMode,'-allSubject-sessionCorrRaw-corrThresholdCount-DS');
% % i.set_title(title);
% % 
% % i.draw();
% % 
% % saveFig(gcf, figPath, title, figFormats);
% 
% %% Set a threshold of session corrCoef
% 
% thresholdCorrCoef= 0.5;
% 
% 
% %% viz distro of this trial by trial corrCoef by subj (and across stages)
% %this distro viz doesn't seem to make sense with discrete bins
% 
% data= corrTable;
% 
% figure;
% clear i;
% 
% i= gramm('x', data.subject, 'y', data.("r"));
% 
% i.stat_boxplot();
% 
% 
% title= strcat(subjMode,'-allSubject-sessionCorrRaw-distribution-DS');
% 
% i.set_title(title);
% 
% i.draw()
% 
% saveFig(gcf, figPath, title, figFormats);
% 
% 
% 
% 
% figure;
% clear i;
% 
% i= gramm('x', data.subject, 'y', data.("r"), 'color', data.stage);
% 
% 
% i.stat_boxplot();
% 
% title= strcat(subjMode,'-allSubject-sessionCorrRaw-distributionByStage-DS');
% 
% i.set_title(title);
% 
% i.draw()
% 
% saveFig(gcf, figPath, title, figFormats);
% 
% 
% %% plot session corrCoef over time
% data= corrTable;
% 
% figure;
% clear i;
% 
% i= gramm('x', data.trainDay, 'y', data.("r"), 'color', data.subject);
% 
% i.facet_wrap(data.stage, 'ncol', 6);
% 
% i.geom_point();
% i.geom_line();
% 
% i().geom_hline('yintercept', thresholdCorrCoef, 'style', 'k--');
% 
% title= strcat(subjMode,'-allSubject-sessionCorrRaw-byDate-DS');
% 
% i.set_title(title);
% 
% i.draw();
% 
% saveFig(gcf, figPath, title, figFormats);
% 
% 
% 
% %% ---------- Trial by Trial Correlation -----
% % %% -- trial by triall corr raw , periEventTable
% % 
% % %very interesting... much different distro
% % 
% % r= [];
% % 
% % allFiles= unique(periEventTable.fileID);
% % 
% % for file= 1:numel(allFiles)
% % 
% %     ind= [];
% %     ind= (periEventTable.fileID==(allFiles(file)));
% %     
% %     trials= [];
% %     
% %     
% %     trials= unique(periEventTable(ind,"DStrialID"));
% %     trials= table2array(trials);
% %     
% %     trials= trials(~isnan(trials));
% %     
% %     for trial = 1:numel(trials)
% %         ind2= [];
% % 
% %         ind2= find(ind & (periEventTable.DStrialID== trials(trial)));
% % 
% % 
% %         y1= periEventTable(ind2,"DSblueRaw");
% %         y2= periEventTable(ind2,"DSpurpleRaw");
% % 
% %         y1= table2array(y1);
% %         y2= table2array(y2);
% % 
% % 
% %         %remove nans prior to corr()
% %         y1= y1(~isnan(y1));
% %         y2= y2(~isnan(y2));
% % 
% % 
% %     %     y1= y1(isnan(y1));
% % 
% %     %     periEventTable(ind,"r")= xcorr(y1, y2);
% % 
% % 
% %         periEventTable(ind2, "rDStrialRaw")= table(nan);
% % 
% %         %fill only first per fileID with ses corr
% %     %     periEventTable(ind(1),"r")= table(corr(y1, y2));
% % 
% %         %fill all
% %         %will throw error if artifacts removed before this (e.g. all nan)
% %         periEventTable(ind2,"rDStrialRaw")= table(corr(y1, y2));
% %     end
% % 
% % 
% % % 
% % end
% % 
% % 
% % figure();
% % clear i;
% % 
% % i= gramm('x', periEventTable.subject, 'y', periEventTable.rDStrialRaw);
% % 
% % i.stat_boxplot();
% % 
% % i.draw();
% % 
% % 
% % %% bin peri-event r raw and facet
% % 
% % 
% % %convert into 10 bins 
% % y= [];
% % e= [];
% % [y, e]= discretize(periEventTable.rDStrialRaw, 10);
% % 
% % periEventTable.rDStrialRawBin= y;
% % 
% % %save labels of bin edges too 
% % for bin= 1:numel(e)-1
% %     
% %     ind= [];
% %     ind= periEventTable.rDStrialRawBin== bin;
% %     
% %    periEventTable(ind, "rDStrialRawBinEdge")= table(e(bin)); 
% % end
% % 
% % 
% % 
% % %% Final improvement: 465 vs 405 z score with r facet
% % % stagesToPlot= [4,5,7]
% % 
% % stagesToPlot= unique(periEventTable.stage);
% % 
% % for subj= 1:numel(subjects)
% %    data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
% %        
% %    for stage= 1:numel(stagesToPlot)
% %    
% %        
% %         %TODO: much more efficient method would be to stack() and form
% %         %signalType column to facet color= 405 or 465
% %            
% %        
% %        data2= data(data.stage==stagesToPlot(stage),:);
% % 
% %         figure();
% %         clear i;
% % 
% %         
% %         % draw in order of background-> foreground
% %          %individual trials -> sessions -> grand mean
% %          
% %          %- individual trials; 465
% %         y= data2.DSblue; 
% % 
% %         
% %         i= gramm('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);
% % 
% %         i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);
% % 
% %         i().geom_line();
% %         
% %         i().set_color_options('map', mapCustom(3,:));        
% % 
% %         i().set_line_options('base_size',0.5); 
% %         
% %         i.draw();
% %         
% %         %- individual trials; 405
% %         y= data2.DSpurple; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);
% % 
% %         i().geom_line();
% %         
% %         i().set_color_options('map', mapCustom(5,:));        
% % 
% %         i().set_line_options('base_size',0.5); 
% %        
% %         i.draw();
% %         
% %         %- sessions, 465
% %         y= data2.DSblue; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %         i().stat_summary('type','sem', 'geom','line');
% %         
% %         i().set_color_options('map', mapCustom(2,:));        
% %         i().set_line_options('base_size',1)        
% %    
% %         i.draw();
% %         
% %        %- sessions, 405
% %         y= data2.DSpurple; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %         i().stat_summary('type','sem', 'geom','line');
% %         
% %         i().set_color_options('map', mapCustom(6,:));        
% %         i().set_line_options('base_size',1)        
% %    
% %         i.draw();
% %         
% %         %- Grand mean, 465
% %         y= data2.DSblue; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', []);
% %                 
% %         i().stat_summary('type','sem', 'geom','area');
% %         
% %         i().set_color_options('map', mapCustom(1,:));        
% %         i().set_line_options('base_size',2)        
% %    
% %         i.draw();
% %         
% %         
% %           %- Grand mean, 405
% %         y= data2.DSpurple; 
% % 
% %         i.update('x', data2.timeLock, 'y', y, 'group', []);
% %                 
% %         i().stat_summary('type','sem', 'geom','area');
% %         
% %         i().set_color_options('map', mapCustom(7,:));        
% %         i().set_line_options('base_size',2)        
% %          
% %       i.axe_property('YLim',[-5,10]);
% %       title= strcat(subjMode,'-subject-',subjects{subj},'-stage-',num2str(stagesToPlot(stage)),'-trialCorrRaw-zTraces-DS');
% %       i.set_title(title);
% %       i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'trialCorrCoef raw >');
% % 
% %       i.draw();
% % 
% %       saveFig(gcf, figPath, title, figFormats)
% %       
% %    end 
% %          
% % end
% % 
% % 
% % %% - between subjects z plots
% % 
% % data= periEventTable;
% % 
% % for stage= 1:numel(stagesToPlot)
% % 
% %     %Between-subj figs
% %         data2= data(data.stage==stagesToPlot(stage),:);
% % 
% % 
% %             figure();
% %             clear i;
% % 
% % 
% %             % draw in order of background-> foreground
% %              %individual trials -> sessions -> grand mean
% % 
% %              %- individual trials; 465
% %             y= data2.DSblue; 
% % 
% % 
% %             i= gramm('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);
% % 
% %             i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);
% % 
% %             i().geom_line();
% % 
% %             i().set_color_options('map', mapCustom(3,:));        
% % 
% %             i().set_line_options('base_size',0.5); 
% % 
% %             i.draw();
% % 
% %             %- individual trials; 405
% %             y= data2.DSpurple; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);
% % 
% %             i().geom_line();
% % 
% %             i().set_color_options('map', mapCustom(5,:));        
% % 
% %             i().set_line_options('base_size',0.5); 
% % 
% %             i.draw();
% % 
% %             %- sessions, 465
% %             y= data2.DSblue; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %             i().stat_summary('type','sem', 'geom','line');
% % 
% %             i().set_color_options('map', mapCustom(2,:));        
% %             i().set_line_options('base_size',1)        
% % 
% %             i.draw();
% % 
% %            %- sessions, 405
% %             y= data2.DSpurple; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
% %             i().stat_summary('type','sem', 'geom','line');
% % 
% %             i().set_color_options('map', mapCustom(6,:));        
% %             i().set_line_options('base_size',1)        
% % 
% %             i.draw();
% % 
% %             %- Grand mean, 465
% %             y= data2.DSblue; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', []);
% % 
% %             i().stat_summary('type','sem', 'geom','area');
% % 
% %             i().set_color_options('map', mapCustom(1,:));        
% %             i().set_line_options('base_size',2)        
% % 
% %             i.draw();
% % 
% % 
% %               %- Grand mean, 405
% %             y= data2.DSpurple; 
% % 
% %             i.update('x', data2.timeLock, 'y', y, 'group', []);
% % 
% %             i().stat_summary('type','sem', 'geom','area');
% % 
% %             i().set_color_options('map', mapCustom(7,:));        
% %             i().set_line_options('base_size',2)        
% % 
% %           i.axe_property('YLim',[-5,10]);
% %           title= strcat(subjMode,'-allSubj-stage-',num2str(stagesToPlot(stage)),'-trialCorrRaw-zTraces-DS');
% %           i.set_title(title);
% %           i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'trialCorrCoef raw >');
% % 
% %           i.draw();
% % 
% %           saveFig(gcf, figPath, title, figFormats)
% % end
% % 
% % %% Count of trials per corrcoef bin per session
% % 
% % data= periEventTable;
% % 
% % %use groupsummary() to compute count
% % data2= groupsummary(data, ["stage", "subject", "fileID", "rDStrialRawBinEdge"]);%, 'count', "DStrialIDcum");
% % 
% % %divide count by num tBins per trial to get count of trials
% % data2.GroupCount= data2.GroupCount/numel(unique(data.timeLock));
% % 
% % 
% % figure();
% % clear i;
% % 
% % i= gramm('x', data2.rDStrialRawBinEdge, 'y', data2.GroupCount, 'color', data2.subject);
% % 
% % i.facet_wrap(data2.stage);
% % 
% % i.geom_point();
% % 
% % 
% % title= strcat(subjMode,'-allSubject-trialCorrRaw-binCountByStage-DS');
% % i.set_title(title);
% % i.set_names('x','corrCoefBin','y','trial count','color','subject', 'column', 'stage');
% % 
% % i.draw();
% % 
% % saveFig(gcf, figPath, title, figFormats);
% % 
% % 
% % %% Establish some corrcoef threshold beyond which to call "noisy" or "nosignal" trial
% % 
% % thresholdCorrCoef= 0.5;
% % 
% % 
% % %% Count of trials beyond threshold per session
% % 
% % periEventTable(:,'corrThresholdTrial')= table(nan);
% % 
% % ind=[];
% % ind= periEventTable.rDStrialRaw >= thresholdCorrCoef;
% % 
% % periEventTable(ind, "rThreshold")= table(1);
% % 
% % data= periEventTable(periEventTable.rThreshold==1,:);
% % 
% % %use groupsummary() to compute count
% % data2= groupsummary(data, ["stage", "subject", "fileID", "trainDay", "rThreshold"]);
% % 
% % %divide count by num tBins per trial to get count of trials
% % data2.GroupCount= data2.GroupCount/numel(unique(data.timeLock));
% % 
% % 
% % figure();
% % clear i;
% % 
% % i= gramm('x', data2.trainDay, 'y', data2.GroupCount, 'group', data2.subject, 'color', data2.subject);
% % 
% % % i.facet_wrap(data2.stage);
% % 
% % i.geom_line();
% % i.geom_point();
% % 
% % 
% % title= strcat(subjMode,'-allSubject-trialCorrRaw-corrThresholdCount-DS');
% % i.set_title(title);
% % % i.set_names('x','corrCoefBin','y','trial count','color','subject', 'column', 'stage');
% % 
% % i.draw();
% % 
% % saveFig(gcf, figPath, title, figFormats);
% % 
% % %% viz distro of this trial by trial corrCoef by subj (and across stages)
% % %this distro viz doesn't seem to make sense with discrete bins
% % 
% % data= periEventTable;
% % %use groupsummary() to reduce to one observation per trial
% % data2= groupsummary(data, ["stage", "subject", "fileID", "DStrialIDcum"], 'mean', "rDStrialRaw");
% % 
% % 
% % figure;
% % clear i;
% % 
% % i= gramm('x', data2.subject, 'y', data2.("mean_rDStrialRaw"));
% % 
% % i.stat_boxplot();
% % 
% % 
% % title= strcat(subjMode,'-allSubject-trialCorrRaw-distribution-DS');
% % 
% % i.set_title(title);
% % 
% % i.draw()
% % 
% % saveFig(gcf, figPath, title, figFormats);
% % 
% % 
% % 
% % 
% % figure;
% % clear i;
% % 
% % i= gramm('x', data2.subject, 'y', data2.("mean_rDStrialRaw"), 'color', data2.stage);
% % 
% % 
% % i.stat_boxplot();
% % 
% % title= strcat(subjMode,'-allSubject-trialCorrRaw-distributionByStage-DS');
% % 
% % i.set_title(title);
% % 
% % i.draw()
% % 
% % saveFig(gcf, figPath, title, figFormats);
% % 
