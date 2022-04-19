%% Might a better metric be something like variability in the 405 and 465nm channels?

%big artifacts = big correlation coefficients session-wide

%but noise might manifest as big baseline variability?

%or some kind of spectral analysis? (frequency, forier transform?)

%trial-by-trial correlation coefs may work too



%% -- Correlation coefficient methods below: 465 & 405
%% Try to ID bad/noisy sessions through simple correlation of 465nm and 405nm fp signals


fs=40;



%% CROSS CORRELATION OF PHOTOMETRY SIGNALS
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
         
         %PERI-EVENT correlation- collapsed, single value for all
        y1= [];
        y2= [];
        
        y1= squeeze(currentSubj(session).periDS.DSblue);
        y2= squeeze(currentSubj(session).periDS.DSpurple);

        
        y1= y1(:);
        y2= y2(:);

        
        currentSubj(session).periCueCorrelation= corr(y1,y2);

         rPeriCue= [rPeriCue, currentSubj(session).periCueCorrelation(1,1)];

         rPeriCue= nan(1,1);
         rPeriCue= currentSubj(session).periCueCorrelation(1,1);
         
         corrTable(sesInd, "rPeriCue")= table(rPeriCue);
         
         corrTable(sesInd,"r")= table(r);
         
         corrTable(sesInd,"fileID")= table(sesInd);
         
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


%         cutTime = currentSubj(session).raw.cutTime;
%         r= [];
%         p= [];
% 
%         
% %         Try sliding corrcoef calc
%         slideFrames= 10*fs;
%         for ts = 1:numel(cutTime) %for each timestamp
%             
%             if ts-slideFrames> 0 && ts+slideFrames<numel(cutTime)
%                 startTime= ts-slideFrames;
%                 endTime= ts+slideFrames;
% 
%                 [R,P] = corrcoef(currentSubj(session).raw.reblue(startTime:endTime), currentSubj(session).raw.repurple(startTime:endTime));
%                 r(ts)= R(2);
%                 p(ts)= P(2);
%             end
%         end
%         
%         plot(r);
% figure;
% 
%         currentSubj(session).signalCorrelation= corrcoef(currentSubj(session).raw.reblue,currentSubj(session).raw.repurple);
%         [r, lags]= xcorr(currentSubj(session).raw.reblue, currentSubj(session).raw.repurple, 'unbiased');
%         hold on;
%         
%         [r, lags]= xcorr(currentSubj(session).raw.reblue, currentSubj(session).raw.repurple, 'coeff');
% 
% 
% %         xcorr on the raw signals returns a triangle shaped plot with a
% %         peak at 0, possibly due to DC offset component in signals... Will
% %         try to remove this by subtracting mean
% 
%         
%         [r, lags]= xcorr(currentSubj(session).raw.reblue-nanmean(currentSubj(session).raw.reblue), currentSubj(session).raw.repurple-nanmean(currentSubj(session).raw.repurple), 'coeff');
%         stem(lags, r);

%         still getting a weird shape, let's try this on a rolling z score?
               
% %trying movcorr function
% r2= [];
% p2=[];
%     [r2, p2, n]=movcorr(currentSubj(session).raw.reblue, currentSubj(session).raw.repurple, 400); %sliding 10s pearson
% 
%     subplot(4,1,1);
%     plot(cutTime, currentSubj(session).raw.reblue, 'b');
%     subplot(4,1,2);
%     plot(cutTime, currentSubj(session).raw.repurple, 'm');
%     subplot(4,1,3);
%     plot(cutTime, r2, 'k');
%     title('sliding r')
%     hold on
%     plot([1, cutTime(end)], [0, 0], 'k--');
%     hold off
%     subplot(4,1,4);
%     plot(cutTime,p2, 'r');
%     title('p value');
%     hold on
%     plot([1, cutTime(end)], [0.05, 0.05], 'k--');
%     hold off
%            
%     figure;
%     plot(r2);
%     scatter(currentSubj(session).trainDay,currentSubj(session).signalCorrelation(2));
   
   sesInd= sesInd+1;
   
   end %end session loop
end %end subject loop

% figure();
% 
% x= zeros(numel(r),1);
% 
% clear i;
% i= gramm('x', x, 'y', r); 
% 
% i.stat_boxplot();
% 
% i.draw();
% 

% 
figure();
clear i;

i= gramm('x', corrTable.subject, 'y', corrTable.r);

i.stat_boxplot();

i.draw();

figure();
clear i;

i= gramm('x', corrTable.subject, 'y', corrTable.r, 'color', corrTable.stage);

i.stat_boxplot();

i.draw();

%peri-cue r 
figure();
clear i;

i= gramm('x', corrTable.subject, 'y', corrTable.rPeriCue);

i.stat_boxplot();

i.draw();

%%
%examine fp traces from sessions with different r values

%subset based on r
% data=corrTable(corrTable.r>0.9,:);
data=corrTable(corrTable.r<0.5,:);


figure();
clear i;

i(1,1)= gramm('x', data.cutTime, 'y', data.reblue, 'color', data.r);

i(1,1).geom_line();

i(2,1)= gramm('x', data.cutTime, 'y', data.repurple, 'color', data.r);

i(2,1).geom_line();

i.draw();

%% perhaps split up 'r' into bins and facet by r

threshA= 0.9;
threshB= 0.7;
threshC= 0.5;


corrTable(:,"rBin")= {''};

corrTable(corrTable.r>= threshA, "rBin")= {'hi-A'};

corrTable(((corrTable.r >= threshB) &(corrTable.r < threshA)), "rBin")= {'hi-B'};

corrTable(((corrTable.r >= threshC) &(corrTable.r < threshB)), "rBin")= {'med-C'};

corrTable(((corrTable.r < threshC)), "rBin")= {'low-D'};
% 


% figure();
% clear i;
% 
% data= corrTable;
% 
% i= gramm('x', data.cutTime, 'y', data.reblue, 'color', data.r);
% 
% i().facet_wrap(data.rBin);
% 
% i().geom_line();
% 
% i.draw();
%% maybe viz delta between 465 and 405 for comparison?


figure();
clear i;

data= corrTable;

i= gramm('x', data.cutTime, 'y', data.reDelta, 'color', data.r);

i().facet_wrap(data.rBin);

i().geom_line();

i.draw();


%% Plot whole sess traces by stage (color=r)

% 
for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
    figure();
    clear i;
    
     
    i= gramm('x', data.cutTime, 'y', data.reblue, 'color', data.r);


    i().facet_wrap(data.stage);

    i.geom_line();
   

    i.draw();
    
    i.set_names('x','time (s)','y','signal','color','corrCoef', 'column', 'stage');
    i.set_title(strcat('subject-',subjects{subj},'-sessionCorr-rawTraces'));
    
    

end

%%  seems large r corresponds to ses with big artifacts/baseline shifts...
% to be expected tho i wonder if largest artifacts are highly biasing the
% correlation coefficient (not necessarily a good measure of signal:noise)?

%maybe should run corr on trial by trial raw data?

% might a better metric be something like variability in the 405? or some
% comparison between trial by trial z score 405 & 465?


%% --
%% Plot session mean peri event data (color=r)

% 
% for subj= 1:numel(subjects)
%    data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
%        
%     figure();
%     clear i;
%     
%      
%     i= gramm('x', data.timeLock, 'y', data.periDSblue, 'color', data.r);
% 
% 
%     i().facet_wrap(data.stage);
% 
%     i.geom_line();
%    
% 
%     i.draw();
%     
% 
% end


% -z score peri event
for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
    figure();
    clear i;
    
     
    i= gramm('x', data.timeLock, 'y', data.periDSzpurple, 'color', data.r);


    i().facet_wrap(data.stage);

    i.geom_line();
   

    i.draw();
    
end

%% 

for subj= 1:numel(subjects)
   data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
       
    figure();
    clear i;
    
     
    i= gramm('x', data.timeLock, 'y', data.periDSzblue, 'color', data.rPeriCue);


    i().facet_wrap(data.stage);

    i.geom_line();
   

    i.draw();
    
end



%% 
% 
% stagesToPlot= [4,5,7]
% 
% for subj= 1:numel(subjects)
%    data= corrTable(strcmp(corrTable.subject, subjects{subj}),:);
%        
%    for stage= 1:numel(stagesToPlot)
%    
%        data2= data(data.stage==stagesToPlot(stage),:);
%        
%         figure();
%         clear i;
% 
% 
%         i(1,1)= gramm('x', data2.timeLock, 'y', data2.periDSzblue, 'group', data2.fileID, 'color', data2.r);
%         i(1,1).geom_line();
%         
% 
%         i(1,2)= gramm('x', data2.timeLock, 'y', data2.periDSzpurple, 'group', data2.fileID, 'color', data2.r);
%         i(1,2).geom_line();
% 
%         i.draw();
%         linkaxes();
%    end
% 
% end

%% -- trial by triall corr raw , periEventTable

%very interesting... much different distro

r= [];

allFiles= unique(periEventTable.fileID);

for file= 1:numel(allFiles)

    ind= [];
    ind= (periEventTable.fileID==(allFiles(file)));
    
    trials= [];
    
    
    trials= unique(periEventTable(ind,"DStrialID"));
    trials= table2array(trials);
    
    trials= trials(~isnan(trials));
    
    for trial = 1:numel(trials)
        ind2= [];

        ind2= find(ind & (periEventTable.DStrialID== trials(trial)));


        y1= periEventTable(ind2,"DSblueRaw");
        y2= periEventTable(ind2,"DSpurpleRaw");

        y1= table2array(y1);
        y2= table2array(y2);


        %remove nans prior to corr()
        y1= y1(~isnan(y1));
        y2= y2(~isnan(y2));


    %     y1= y1(isnan(y1));

    %     periEventTable(ind,"r")= xcorr(y1, y2);


        periEventTable(ind2, "rDStrialRaw")= table(nan);

        %fill only first per fileID with ses corr
    %     periEventTable(ind(1),"r")= table(corr(y1, y2));

        %fill all
        %will throw error if artifacts removed before this (e.g. all nan)
        periEventTable(ind2,"rDStrialRaw")= table(corr(y1, y2));
    end


% 
end


figure();
clear i;

i= gramm('x', periEventTable.subject, 'y', periEventTable.rDStrialRaw);

i.stat_boxplot();

i.draw();

%% bin peri-event r raw and facet


%convert into 10 bins 
y,e= [];
[y, e]= discretize(periEventTable.rDStrialRaw, 10);

periEventTable.rDStrialRawBin= y;

%save labels of bin edges too 
for bin= 1:numel(e)-1
    
    ind= [];
    ind= periEventTable.rDStrialRawBin== bin;
    
   periEventTable(ind, "rDStrialRawBinEdge")= table(e(bin)); 
end


%% facet by bin -- good facet!


stagesToPlot= [4,5,7]

for subj= 1:numel(subjects)
   data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
       
   for stage= 1:numel(stagesToPlot)
   
       data2= data(data.stage==stagesToPlot(stage),:);

        figure();
        clear i;

        i= gramm('x', data2.timeLock, 'y', data2.DSpurpleRaw, 'color', data2.rDStrialRaw, 'group', data2.DStrialIDcum);

        i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);

        i().geom_line();

        i.draw();

        %405

   end 
end

%% good facet, but now plot z score better for interpretability

stagesToPlot= [4,5,7]

for subj= 1:numel(subjects)
   data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
       
   for stage= 1:numel(stagesToPlot)
   
       data2= data(data.stage==stagesToPlot(stage),:);

        figure();
        clear i;

        i= gramm('x', data2.timeLock, 'y', data2.DSblue, 'color', data2.rDStrialRaw, 'group', data2.DStrialIDcum);

        i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);

        i().geom_line();

        i.draw();

        %405

   end 
end


%% Custom colormap

%custom map here using colorbrewer 

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


%% Final improvement: 465 vs 405 z score with r facet
stagesToPlot= [4,5,7]

for subj= 1:numel(subjects)
   data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
       
   for stage= 1:numel(stagesToPlot)
   
       data2= data(data.stage==stagesToPlot(stage),:);

        figure();
        clear i;

        %-465
        y= data2.DSblue;
       
        
            %-grand mean %manually declare group between updates() or gramm will assume they carry over
        i= gramm('x', data2.timeLock, 'y', y, 'group', []);
        
        i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);
        
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('map', mapCustom(1,:));        
        i().set_line_options('base_size',2)        
   
        i.draw();
        
          %-session means
        i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        i().stat_summary('type','sem', 'geom','line');
        
        i().set_color_options('map', mapCustom(2,:));        
        i().set_line_options('base_size',1)        
   
        i.draw();
        
            %-ind trials
        i.update('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);


        i().geom_line();
        
        i().set_color_options('map', mapCustom(3,:));        

        i().set_line_options('base_size',0.5); 


        i.draw();
        
          
        
        
        %405
        y= data2.DSpurple;
             
           
            %-grand mean
        i.update('x', data2.timeLock, 'y', y, 'group', []);
               
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('map', mapCustom(7,:));        
        i().set_line_options('base_size',2)        
   
        i.draw();
        
          %-session means
        i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        i().stat_summary('type','sem', 'geom','line');
        
        i().set_color_options('map', mapCustom(6,:));        
        i().set_line_options('base_size',1)        
   
        i.draw();
        
            %-ind trials
        i.update('x', data2.timeLock, 'y', y, 'group', data2.DStrialIDcum);


        i().geom_line();
        
        i().set_color_options('map', mapCustom(5,:));        

        i().set_line_options('base_size',0.5); 
  
        
        
      i.axe_property('YLim',[-5,10]);

      title= strcat('subject-',subjects{subj},'-stage-',num2str(stagesToPlot(stage)),'-trialCorrRaw-zTraces-DS');
           
      i.set_title(title);
      
      i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'trialCorrCoef raw >');

      i.draw();

      
      saveFig(gcf, figPath, title, figFormats)
      
   end 
   
   
   %Between-subj figs
       data2= periEventTable(periEventTable.stage==stagesToPlot(stage),:);
   
        figure();
        clear i;

        %-465
        y= data2.DSblue;
        map= 'brewer3';
    
        
%             %-session means
        i=gramm('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        i().facet_wrap(data2.rDStrialRawBinEdge, 'ncols', 5);

        i().stat_summary('type','sem', 'geom','line');
        
        i().set_color_options('lightness_range', [20,20], 'map', map)
        i().set_line_options('base_size',0.5)        
   
        i.draw();
        
            %-grand mean
        i.update('x', data2.timeLock, 'y', y);
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('lightness_range', [200,200], 'map', map)
        i().set_line_options('base_size',2.5)        
   
        i.draw();
        
        %405
        y= data2.DSpurple;
        map= 'brewer1';
             
                  
            %-session means
        i.update('x', data2.timeLock, 'y', y, 'group', data2.fileID);
        i().stat_summary('type','sem', 'geom','line');
        
        i().set_color_options('lightness_range', [100,100], 'map', map)
        i().set_line_options('base_size',0.5)        
   
        i.draw();
        
            %-grand mean
        i.update('x', data2.timeLock, 'y', y);
        i().stat_summary('type','sem', 'geom','area');
        
        i().set_color_options('lightness_range', [200,200], 'map', map)
        i().set_line_options('base_size',2.5)        
   
        
        
      i.axe_property('YLim',[-5,10]);

      title= strcat('allSubjects-stage-',num2str(stagesToPlot(stage)),'-trialCorrRaw-zTraces-DS');
           
      i.set_title(title);
      
      i.set_names('x','time from DS (s)','y','z score','color','signal type', 'column', 'trialCorrCoef raw >');

      i.draw();

      
      saveFig(gcf, figPath, title, figFormats)
      
   
end

%% Count of trials per corrcoef bin per session

data= periEventTable;

%use groupsummary() to compute count
data2= groupsummary(data, ["stage", "subject", "fileID", "rDStrialRawBinEdge"]);%, 'count', "DStrialIDcum");

%divide count by num tBins per trial to get count of trials
data2.GroupCount= data2.GroupCount/numel(unique(data.timeLock));


figure();
clear i;

i= gramm('x', data2.rDStrialRawBinEdge, 'y', data2.GroupCount, 'color', data2.subject);

i.facet_wrap(data2.stage);

i.geom_point();

i.draw();

%%
figure();
clear i;

i= gramm('x', data2.rDStrialRawBinEdge, 'y', data2.GroupCount, 'color', data2.subject);

i.facet_wrap(data2.stage);

i.geom_b();

i.draw();


%% viz distro of this trial by trial corrCoef by subj (and across stages)
%this distro viz doesn't seem to make sense with discrete bins

data= periEventTable;
%use groupsummary() to reduce to one observation per trial
data2= groupsummary(data, ["stage", "subject", "fileID", "DStrialIDcum"], 'mean', "rDStrialRaw");


figure;
clear i;

i= gramm('x', data2.subject, 'y', data2.("mean_rDStrialRaw"));

i.stat_boxplot();


title= strcat('allSubject-trialCorrRaw-distribution-DS');

i.set_title(title);

i.draw()

saveFig(gcf, figPath, title, figFormats);

i.draw();



figure;
clear i;

i= gramm('x', data2.subject, 'y', data2.("mean_rDStrialRaw"), 'color', data2.stage);


i.stat_boxplot();

title= strcat('allSubject-trialCorrRaw-distributionByStage-DS');

i.set_title(title);

i.draw()

saveFig(gcf, figPath, title, figFormats);
%% viz ind trials peri-event (color=r)

% for subj= 1:numel(subjects)
%         
%    data1= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
%    
%     for thisStage= 1:numel(unique(data1.stage))
% 
%         clear data2 data3 data
%         
%         data= data1(data1.stage==thisStage,:);
%         
% %        figure();
% %         clear i;
% % 
% % 
% %         i(1,1)= gramm('x', data2.timeLock, 'y', data2.DSblue, 'group', data2.DStrialIDcum, 'color', data2.rDStrial);
% % 
% %         i(1,1).geom_line();
% % 
% %         
% %         i(2,1)= gramm('x', data2.timeLock, 'y', data2.DSpurple, 'group', data2.DStrialIDcum, 'color', data2.rDStrial);
% % 
% %         i(2,1).geom_line();
% %         
% %         i.draw();
% 
% 
%        figure();
%        clear i; 
% 
%         y= "DSblueRaw";
% 
%        data2= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', y);
% 
%        data3= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', "rDStrialRaw");
%          
% 
%    
%         i(1,1)= gramm('x', data2.timeLock, 'y', data2.mean_DSblueRaw, 'group', data2.fileID, 'color', data3.mean_rDStrialRaw);
% 
%         i(1,1).geom_line();
% %         i(1,1).stat_summary('type','sem','geom','line');
% 
% 
%         y= "DSpurpleRaw";
% 
%        data2= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', y);
%         
%         i(2,1)= gramm('x', data2.timeLock, 'y', data2.mean_DSpurpleRaw, 'group', data2.fileID, 'color', data3.mean_rDStrialRaw);
%                
%         i(2,1).geom_line();
% 
% %         i(2,1).stat_summary('type','sem','geom','line');
% 
%         
%         i.draw();
% 
%     end
% end
% 
% 
% 
% 
% %% -------- Trial by trial corr z scored, periEventTable ------ Z 
% 
% 
% r= [];
% 
% allFiles= unique(periEventTable.fileID);
% 
% for file= 1:numel(allFiles)
% 
%     ind= [];
%     ind= (periEventTable.fileID==(allFiles(file)));
%     
%     trials= [];
%     
%     
%     trials= unique(periEventTable(ind,"DStrialID"));
%     trials= table2array(trials);
%     
%     trials= trials(~isnan(trials));
%     
%     for trial = 1:numel(trials)
%         ind2= [];
% 
%         ind2= find(ind & (periEventTable.DStrialID== trials(trial)));
% 
% 
%         y1= periEventTable(ind2,"DSblue");
%         y2= periEventTable(ind2,"DSpurple");
% 
%         y1= table2array(y1);
%         y2= table2array(y2);
% 
% 
%         %remove nans prior to corr()
%         y1= y1(~isnan(y1));
%         y2= y2(~isnan(y2));
% 
% 
%     %     y1= y1(isnan(y1));
% 
%     %     periEventTable(ind,"r")= xcorr(y1, y2);
% 
% 
%         periEventTable(ind2, "rDStrial")= table(nan);
% 
%         %fill only first per fileID with ses corr
%     %     periEventTable(ind(1),"r")= table(corr(y1, y2));
% 
%         %fill all
%         %will throw error if artifacts removed before this (e.g. all nan)
%         periEventTable(ind2,"rDStrial")= table(corr(y1, y2));
%     end
% 
% 
% % 
% end
% 
% 
% figure();
% clear i;
% 
% i= gramm('x', periEventTable.subject, 'y', periEventTable.rDStrial);
% 
% i.stat_boxplot();
% 
% i.draw();
% 
% 
% %% viz ind trials peri-event (color=r)
% 
% for subj= 1:numel(subjects)
%         
%    data1= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
%    
%     for thisStage= 1:numel(unique(data1.stage))
% 
%         clear data2 data3 data
%         
%         data= data1(data1.stage==thisStage,:);
%         
% %        figure();
% %         clear i;
% % 
% % 
% %         i(1,1)= gramm('x', data2.timeLock, 'y', data2.DSblue, 'group', data2.DStrialIDcum, 'color', data2.rDStrial);
% % 
% %         i(1,1).geom_line();
% % 
% %         
% %         i(2,1)= gramm('x', data2.timeLock, 'y', data2.DSpurple, 'group', data2.DStrialIDcum, 'color', data2.rDStrial);
% % 
% %         i(2,1).geom_line();
% %         
% %         i.draw();
% 
% 
%        figure();
%        clear i; 
% 
%         y= "DSblue";
% 
%        data2= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', y);
% 
%        data3= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', "rDStrial");
%          
% 
%    
%         i(1,1)= gramm('x', data2.timeLock, 'y', data2.mean_DSblue, 'group', data2.fileID, 'color', data3.mean_rDStrial);
% 
%         i(1,1).geom_line();
% %         i(1,1).stat_summary('type','sem','geom','line');
% 
% 
%         y= "DSpurple";
% 
%        data2= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', y);
%         
%         i(2,1)= gramm('x', data2.timeLock, 'y', data2.mean_DSpurple, 'group', data2.fileID, 'color', data3.mean_rDStrial);
%                
%         i(2,1).geom_line();
% 
% %         i(2,1).stat_summary('type','sem','geom','line');
% 
%         
%         i.draw();
% 
%     end
% end

%% manual mean calc then session viz (necessary for color mapping to be correct?)
%clim giving errors when grouping by fileID
%so just plot means

for subj= 1:numel(subjects)
   data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
       
   y= "DSpurple";
   
   data2= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', y);
   
   data3= groupsummary(data, ["stage", "fileID", "timeLock"], 'mean', "rDStrial");
      
   ind=[];
   ind= (strcmp(periEventTable.subject, subjects{subj}));
   
    figure();
    clear i;
   

    i= gramm('x', data2.timeLock, 'y', data2.mean_DSpurple, 'group', data2.fileID, 'color', data3.mean_rDStrial);

    i().facet_wrap(data2.stage);

    i.geom_line();

%     i.stat_summary('type','sem','geom','area');
    
    i.draw();
    
end


%% ---- corr() of trial by trial z score , not wanted -------


%% Try corr of trial-by-trial z scored signal??

%this distro looks quite different, not sure what is most effective
% this way it does seem subj 20 (GFP) and 10 (no signal) are close to 1)

r= [];

allFiles= unique(periEventTable.fileID);

for file= 1:numel(allFiles)

    ind= [];
    ind= find(periEventTable.fileID==(allFiles(file)));
    
%     periEventTable(ind,"r")= xcorr(periEventTable(ind,"DSblue"), periEventTable(ind,"DSpurple"));

    
    y1= periEventTable(ind,"DSblue");
    y2= periEventTable(ind,"DSpurple");
    
    y1= table2array(y1);
    y2= table2array(y2);
    
    
    %remove nans prior to corr()
    y1= y1(~isnan(y1));
    y2= y2(~isnan(y2));
    
    
%     y1= y1(isnan(y1));
    
%     periEventTable(ind,"r")= xcorr(y1, y2);


    periEventTable(ind, "r")= table(nan);
    
    %fill only first per fileID with ses corr
%     periEventTable(ind(1),"r")= table(corr(y1, y2));

    %fill all
    periEventTable(ind,"r")= table(corr(y1, y2));



% 
end


figure();
clear i;

i= gramm('x', periEventTable.subject, 'y', periEventTable.r);

i.stat_boxplot();

i.draw();

%% again, bin based on r and facet 


threshA= 0.9;
threshB= 0.7;
threshC= 0.5;


periEventTable(:,"rBin")= {''};

periEventTable(periEventTable.r>= threshA, "rBin")= {'hi-A'};

periEventTable(((periEventTable.r >= threshB) &(periEventTable.r < threshA)), "rBin")= {'hi-B'};

periEventTable(((periEventTable.r >= threshC) &(periEventTable.r < threshB)), "rBin")= {'med-C'};

periEventTable(((periEventTable.r < threshC)), "rBin")= {'low-D'};

% figure();
% clear i;
% 
% data= periEventTable;
% 
% i= gramm('x', data.timeLock, 'y', data.DSblue, 'color', data.r, 'group', data.DStrialIDcum);
% 
% i().facet_wrap(data.rBin);
% 
% i().geom_line();
% 
% i.draw();
% 
% %405
% i= gramm('x', data.timeLock, 'y', data.DSpurple, 'color', data.r, 'group', data.DStrialIDcum);
% 
% i().facet_wrap(data.rBin);
% 
% i().geom_line();
% 
% i.draw();


%% very hard to viz this... trying to get at noisy/bad sessions 
%but viewing whole traces not really informative. 

% %Try individual subj peri-event so  465 vs 405 diff is more clear?
% 
% for subj= 1:numel(subjects)
%    data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
%     
%     figure();
%     clear i;
%    
% %     i= gramm('x', data.timeLock, 'y', data.DSblue, 'color', data.r, 'group', data.DStrialIDcum);
% 
%     i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.DStrialIDcum);
% 
% 
%     i().facet_wrap(data.rBin);
% 
%     i().geom_line();
%     
%     i.set_color_options('map','brewer3');
% 
%     i.draw();
%     
%     i.update('x', data.timeLock, 'y', data.DSpurple, 'group', data.DStrialIDcum);
%     i().geom_line();
%     i.set_color_options('map','brewer1');
%     
%     i.draw();
% 
%    
% end
%% session means?

%as expected, sess with high corrCoef have less distinct peri- 465 and 405

%but, doesn't appear totally consistent and hard to tell with this faceting
for subj= 1:numel(subjects)
   data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
    
    figure();
    clear i;
  
    i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.fileID);


    i().facet_wrap(data.rBin);

    i().stat_summary('type','sem','geom','area');
    
    i.set_color_options('map','brewer3');

    i.draw();
    
    i.update('x', data.timeLock, 'y', data.DSpurple, 'group', data.fileID);
    i().stat_summary('type','sem','geom','area');
    i.set_color_options('map','brewer1');
    
    
    i.set_names('x','time from event (s)','y','z score (ses mean)','color','signal type', 'column', 'corrCoef');
    i.set_title(strcat('subject-',subjects{subj},'-sessionCorr-meanPeriEvent'));
    
    i.draw();
   

   
end

%% all subj
data= periEventTable;
    
figure();
clear i;

i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.fileID);


i().facet_wrap(data.rBin);

i().stat_summary('type','sem','geom','area');

i.set_color_options('map','brewer3');

i.draw();

i.update('x', data.timeLock, 'y', data.DSpurple, 'group', data.fileID);
i().stat_summary('type','sem','geom','area');
i.set_color_options('map','brewer1');


i.set_names('x','time from event (s)','y','z score (ses mean)','color','signal type', 'column', 'corrCoef');
i.set_title(strcat('allSubjects','-sessionCorr-meanPeriEvent'));

i.draw();

%% session means facet by stage, color=r ?

% for subj= 1:numel(subjects)
%    data= periEventTable(strcmp(periEventTable.subject, subjects{subj}),:);
%        
%    ind=[];
%    ind= (strcmp(periEventTable.subject, subjects{subj}));
%    
%     figure();
%     clear i;
%     
%      
% %     i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.DStrialIDcum, 'color', data.r);
% %     i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.fileID, 'color', data.r);
% %     i= gramm('x', data.timeLock, 'y', data.DSblue, 'color', data.r);
% 
%     %cLim error, try with manual subset of whole table?
% %     i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.fileID, 'color', data.r);
% 
%     i= gramm('x', data.timeLock, 'y', data.DSblue, 'group', data.fileID, 'color', data.r);
% 
% 
% %     i().facet_wrap(data.stage);
% 
% %     i.geom_line();
%     
% %color not working with stat_summary here?
%     i.stat_summary('type','sem','geom','line');
%     
% 
%     i.draw();
%     
% %     
% %       %cLim error, try with manual subset of whole table?
% %     clear i;
% %     figure();
% %     i= gramm('subset', ind, 'x', periEventTable.timeLock, 'y', periEventTable.DSblue, 'group', periEventTable.fileID, 'color', periEventTable.r);
% % 
% %     i().facet_wrap(periEventTable.stage);
% %     
% %     %     i.geom_line();
% % 
% %     i.stat_summary('type','sem','geom','line');
% %     
% % 
% %     i.draw();
% 
% end


%% Trying correlation with dff calculated in previous section
% for subj= 1:numel(subjects)
%     for session= 1:numel(subjDataAnalyzed.(subjects{subj}))
%         
%         cutTime= subjData.(subjects{subj})(session).cutTime;
%         currentSubj= subjDataAnalyzed.(subjects{subj}); %easy indexing into subject
% %               going to try on dff calculated by previous section
%         [r, lags]= xcorr(currentSubj(session).photometry.bluedff,currentSubj(session).photometry.purpledff, 'coeff');
%         stem(lags, r);
%         
%        
%         
%         %trying movcorr function
%     [r, p, n]=movcorr(currentSubj(session).photometry.bluedff, currentSubj(session).photometry.purpledff, 400); %sliding 10s pearson
% 
%     figure(figureCount);
%     figureCount= figureCount+1;
%     
%     subplot(4,1,1);
%     plot(cutTime, currentSubj(session).photometry.bluedff, 'b');
%     hold on;
%     title('blue dff');
%     subplot(4,1,2);
%     plot(cutTime, currentSubj(session).photometry.purpledff, 'm');
%     hold on;
%     title('purple dff');
%     subplot(4,1,3);
%     plot(cutTime, r, 'k');
%     title('sliding r')
%     hold on
%     plot([1, cutTime(end)], [0, 0], 'k--');
%     hold off
%     subplot(4,1,4);
%     plot(cutTime,p, 'r');
%     title('p value');
%     hold on
%     plot([1, cutTime(end)], [0.05, 0.05], 'k--');
%     hold off
%     
%     set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
%     waitforbuttonpress;
%     close;
% 
%     end %end session loop
% end %end subj loop


%% Create subjDataAnalyzed struct to hold analyzed data
%In this section, we'll initialize a subjDataAnalyzed struct to hold any
%relevant analyzed data separately from raw data. We will populate it with
%some metadata before doing any analyses. This metadata all originates from
%the metadata.xlsx file and the subjData struct generated by
%fpExtractData.m

%Fill with metadata
 for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
       
       experimentName= currentSubj(session).experiment; 
       
       subjDataAnalyzed.(subjects{subj})(session).experiment= currentSubj(session).experiment;
       
       subjDataAnalyzed.(subjects{subj})(session).date= currentSubj(session).date;
       
       subjDataAnalyzed.(subjects{subj})(session).rat= currentSubj(session).rat;
       subjDataAnalyzed.(subjects{subj})(session).fileName= currentSubj(session).fileName;
       subjDataAnalyzed.(subjects{subj})(session).trainDay= currentSubj(session).trainDay;
       subjDataAnalyzed.(subjects{subj})(session).trainStage= currentSubj(session).trainStage;
       subjDataAnalyzed.(subjects{subj})(session).box= currentSubj(session).box;     
       
       %saving raw data here probably makes variable too big/slows things
       %save raw event timestamps too- will be useful for deconvolution later
       subjDataAnalyzed.(subjects{subj})(session).raw.pox= currentSubj(session).pox;
       subjDataAnalyzed.(subjects{subj})(session).raw.out= currentSubj(session).out;
       subjDataAnalyzed.(subjects{subj})(session).raw.lox= currentSubj(session).lox;
       
       %save photometry signals- will be useful for deconvolution later
       subjDataAnalyzed.(subjects{subj})(session).raw.cutTime= currentSubj(session).cutTime;
       subjDataAnalyzed.(subjects{subj})(session).raw.reblue= currentSubj(session).reblue;
       subjDataAnalyzed.(subjects{subj})(session).raw.repurple= currentSubj(session).repurple;

       
   end %end session loop
end %end subject loop
