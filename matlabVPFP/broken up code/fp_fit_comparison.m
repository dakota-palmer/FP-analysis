
%save common table to compare signals?
% tableFP= table();


for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       clear cutTime reblue repurple fit
       
       cutTime= currentSubj(session).cutTime';
       reblue= currentSubj(session).reblue;
       repurple= currentSubj(session).repurple;
       
      
       %---- table initialization ----
       
%        % transformation steps
%        signal= []; reference= []; %1= raw
%        signalBaseline= []; referenceBaseline= []; %baseline estimates
%        
%        signalBaselineCorrected= []; referenceBaselineCorrected= []; %2= baseline-corrected (if applicable)
%        
%        referenceFitted; % Fitted reference
%        
%        signalReferenceCorrected= []; % corrected signal - fitted, corrected reference
%        
       %pre initialize table vars
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));
       
       %save list of the vars for dynamic assignment & less code
       tableVars= {'cutTime','signalRaw','referenceRaw','signalBaseline'...,
           'referenceBaseline','signalBaselineCorrected'...,
           'referenceBaselineCorrected','referenceFitted'...,
           'signalReferenceCorrected','signalNorm'};
       
       %initialize tables to store data transformed with different methods
       tableDFF= table();
       tableAirPLS= table();
       
       for var= 1:numel(tableVars)
           tableDFF.(tableVars{var})= eval(tableVars{var});
           tableAirPLS.(tableVars{var})= eval(tableVars{var});
       end
                  
       
      %---- airPLS------
        %clear table vars between methods
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));

       
           % use airPLS to estimate baseline of signal & baseline prior to
           % fitting and subtraction
           signalRaw= reblue;
           referenceRaw=repurple;
           
           
%            signalBaseline= [];
%            referenceBaseline= [];
           
           signalBaseline= airPLS(signalRaw');
         
           [~, signalBaseline] = airPLS(signalRaw');

           [~, referenceBaseline]= airPLS(referenceRaw');
           
           signalBaseline= signalBaseline';
           referenceBaseline= referenceBaseline';
           
%            %- Viz
%            figure();
%            hold on; 
%            plot(reblue,'b');
%            plot(signalBaseline,'k--');
%            plot(repurple,'m');
%            plot(referenceBaseline,'k--');
%            legend('reblue','signal baseline', 'repurple', 'ref baseline');
           
%           -Overwrite reblue and repurple as these baselines prior to fit?
           
% %            [~, signalBaseline] = airPLS(signalArtifactFreeSmooth', configuration.airPLS{:});
% %             signalBaseline = signalBaseline';
% %             signalCorrected = signalArtifactFree - signalBaseline;
            % how i've seen this used is 
            % 1) use airPLS to estimate 'Baseline' of signal (& reference)
            % 2) subtract 'baseline' from each signal (& reference)
            % 3) if fitting reference signal, fit corrected reference to corrected signal
            % 4) Remove motion artifact by subtracting fitted, corrected reference from corrected signal
            % 5) Some normalization (e.g. df/f or z score)

            %2- subtract 'baseline' shifts/artifact from both signal & reference
            signalBaselineCorrected= []; referenceBaselineCorrected= [];

            signalBaselineCorrected= signalRaw-signalBaseline;
            
            referenceBaselineCorrected= referenceRaw- referenceBaseline;
            
            %3- fit 'corrected' signals
           referenceFitted= [];
           referenceFitted= controlFit(signalBaselineCorrected, referenceBaselineCorrected);

           % 4- motion artifact subtraction (signal-fitted ref) 
           signalReferenceCorrected= signalBaselineCorrected-referenceFitted;
            
           
           %save into table
            for var= 1:numel(tableVars)
                tableAirPLS.(tableVars{var})= eval(tableVars{var});
             end
           
%            airPls= table();
%            airPls.signalBaselineCorrected= signalBaselineCorrected;
%            airPls.referenceBaselineCorrected= referenceBaselineCorrected;
%            airPls.referenceFitted= referenceFitted;
%            
           % 4- motion artifact subtraction (signal-fitted ref) 
           %dff fxn below does this?
%             signalReferenceCorrected= [];
%             signalReferenceCorrected= signalBaselineCorrected-fit;
            
          
            % - - overwriting reblue & fit
%             reblue= signalReferenceCorrected;

            % without assuming dff - - overwriting reblue & fit
%             reblue= signalBaselineCorrected;
            
            %TODO: normalization 
            %5- normalization?
            %dff follows below
            %currently the deltaFF() fxn subtracts AND normalizes...
            
%            fit= airPLS(reblue);
%            subjDataAnalyzed.(subjects{subj})(session).photometry.fit= fit;
%        end

    %-- Clear vars between Methods
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));
       
    
    
%        %---- simple linear fit with controlfit function-----
%         % ControlFit (fits 2 signals together) 
%        fitLinear=[];
%        fitLinear= controlFit(reblue, repurple);
       


    %------ Delta F/F  ----------
        signalRaw= reblue;
        referenceRaw= repurple;
        
       %- simple linear fit with controlfit function
       referenceFitted= controlFit(signalRaw, referenceRaw);
       
        % Subtract reference from signal
        %-- note older code uses deltaFF fxn which normalize / F as well.
       signalReferenceCorrected= signalRaw-referenceFitted;
       
       %deltaFF function --
%        df=[];
%        df = deltaFF(reblue,referenceFit); %This is dF for boxA in %, calculated by running the deltaFF function on the resampled blue data from boxA and the fitted data from boxA
       
        %save into table
        for var= 1:numel(tableVars)
            tableDFF.(tableVars{var})= eval(tableVars{var});
         end
       
       
      %--Replace reblue with dff if desired dp 2022-07-28
%        if strcmp(signalMode, 'dff')
%           subjDataAnalyzed.(subjects{subj})(session).raw.reblue= df; %currentSubj(session).photometry.df;
%           subjData.(subjects{subj})(session).reblue= df;
        
%             %also replace repurple with some normalized dff value of isosbestic?
%           % time based instantaneous delta vs some baseline...
% %             would be nice as comparison but not worth it at this point
% %             test= diff(fit);
% %           test= deltaFF(fit,fit);
% 
%             % based on moving baseline above?
%           test= subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff;
%             
%           subjDataAnalyzed.(subjects{subj})(session).raw.repurple= fit; %currentSubj(session).photometry.df;
%           subjData.(subjects{subj})(session).repurple= fit;

       
       
%       %----- FIGURES ----------
       %- Viz - Save figure of fp signals and fitting for each session
       figPath = strcat(pwd,'\_fpFits\'); %location for output figures to be saved

%        %subset data
%        data= [];
%        data= table();
%        
%        data.reblue= reblue;
%        data.repurple= repurple;
%        data.fit= referenceFit;
%        data.df= df;
%        
%        data.time= currentSubj(session).cutTime';
%        
%        %make fig
%        %fitted vs reblue ; dff
%        figure();
%        
%        titleFig= strcat('fp-fitMode-',modeFitFP,'-fileID-',num2str(currentSubj(session).fileID));
      
        %------DFF FIGURE --
        %subset data
       data= tableDFF;
           
       %make fig
       figure(); clear i;
       ax1= [], ax2=[]; ax3=[], ax4=[];

       titleFig= strcat('fp-fit-comparison-','-DFF-','-fileID-',num2str(currentSubj(session).fileID));

       sgtitle(titleFig);
       
       %just matlab 
       ax1= subplot(4,1,1); hold on; title('raw');
       plot(data.signalRaw, 'b');
       plot(data.referenceRaw,'m');
       
       legend('465','405');
       
       ax2= subplot(5,1,2); hold on; title('baseline corrected');
       plot(data.signalBaselineCorrected, 'b');
       plot(data.referenceBaselineCorrected,'m');
       
       ax3= subplot(4,1,3); hold on; title('fitted');
       plot(data.signalRaw,'b');
       plot(data.referenceFitted,'m');
       
       legend('465','fitted reference');
       
       ax4= subplot(4,1,4); hold on;
       plot(data.signalReferenceCorrected, 'g');
       
       legend('corrected signal')
       
       linkaxes([ax1, ax2, ax3, ax4], 'x');

       
       saveFig(gcf, figPath, titleFig, figFormats);
        
       %------AIRPLS FIGURE --
        %subset data
       data= tableAirPLS;
           
       %make fig
       figure(); clear i;
       
       

       titleFig= strcat('fp-fit-comparison-','-airPLS-','-fileID-',num2str(currentSubj(session).fileID));

       sgtitle(titleFig);
       
       %just matlab 
       ax1= subplot(5,1,1); hold on; title('raw');
       plot(data.signalRaw, 'b');
       plot(data.referenceRaw,'m');
       
       plot(data.signalBaseline, 'k:', 'linewidth', 2);
       plot(data.referenceBaseline, 'k:', 'linewidth', 2);

       legend('465','405', '465 baseline', '405 baseline');
       
       ax2= subplot(5,1,2); hold on; title('baseline corrected');
       plot(data.signalBaselineCorrected, 'b');
       plot(data.referenceBaselineCorrected,'m');
       
       ax3= subplot(5,1,3); hold on; title('fitted');
       plot(data.signalBaselineCorrected,'b');
       plot(data.referenceFitted,'m');
       
       legend('465','fitted reference');
       
       ax4= subplot(5,1,4); hold on;
       plot(data.signalReferenceCorrected, 'g');
       
       legend('corrected signal')
       
       linkaxes([ax1, ax2, ax3, ax4], 'x');
       
       saveFig(gcf, figPath, titleFig, figFormats);
        

       
       
       
   %%-??------- Save all signals into table for direct comparison?
   tableFP= table();

%    
%    tableFP.signalAirPLS = table(nan(size(reblue)));
%    tableFP.signalDF =  table(nan(size(reblue)));

   
   tableFP(:,'signalAirPLS')= tableAirPLS(:,'signalReferenceCorrected');
   tableFP(:,'signalDFF')= tableDFF(:,'signalReferenceCorrected');
   
  
   %----- Direct comparisons of signal
     data= tableFP;
           
       %make fig
       figure(); clear i;
      

       titleFig= strcat('fp-fit-comparison-','-signalCompare-','-fileID-',num2str(currentSubj(session).fileID));

       sgtitle(titleFig);
       
       %just matlab 
       ax1= subplot(1,2,1); hold on; title('airPLS');
       plot(data.signalAirPLS, 'b');
       ax2= subplot(1,2,2); hold on; title('DFF');

       plot(data.signalDFF,'k');
       
       legend('airPLS','DFF');

       linkaxes();
   
   
%    end %end session loop
% end %end subject loop



%% ------ PERI EVENT analysis 


%Most straightforward approach to work with existing script is to make
%distinct subjDataAnalyzed structs for each signal to compute through peri-event... keeping fields and
%looping structure etc same

%-- Just to make things very easy, going to save some fields into subjData
% for dynamic access and genralizability

%simply saving cue onsets in this field for dynamic triggerEvent 
subjDataAnalyzed.(subjects{subj})(session).behavior.DS= currentSubj(session).DS;
subjDataAnalyzed.(subjects{subj})(session).behavior.NS= currentSubj(session).NS;


%-- Basic, og version without preprocessing

subjDataBasic= subjData.(subjects{subj});%(session);

subjDataAnalyzedBasic= subjDataAnalyzed.(subjects{subj});%(session);


%--airPLS

subjDataAirPLS= subjData.(subjects{subj});%(session);
subjDataAirPLS(session).reblue= tableAirPLS.signalReferenceCorrected;
subjDataAirPLS(session).repurple= tableAirPLS.referenceFitted;

subjDataAnalyzedAirPLS= subjDataAnalyzed.(subjects{subj});%(session);
subjDataAnalyzedAirPLS(session).raw.reblue= tableAirPLS.signalReferenceCorrected;
subjDataAnalyzedAirPLS(session).raw.repurple= tableAirPLS.referenceFitted;


%-- DFF
subjDataDFF= subjData.(subjects{subj});%(session);
subjDataDFF(session).reblue= tableDFF.signalReferenceCorrected;
subjDataDFF(session).repurple= tableDFF.referenceFitted;

subjDataAnalyzedDFF= subjDataAnalyzed.(subjects{subj});%(session);
subjDataAnalyzedDFF(session).raw.reblue= tableDFF.signalReferenceCorrected;
subjDataAnalyzedDFF(session).raw.repurple= tableDFF.referenceFitted;

% %make list of 'structs' within table to loop thru
structsToCompare= {'AirPLS', 'DFF', 'Basic'} %''

% %make list of 'signals' within table to loop thru 
% signalCol= {'signalAirPLS', 'signalDff', 'signalRaw'}


%parameters- here we are establishing some variables for our event triggered-analysis
preCueTime= 5; %t in seconds to examine before cue
postCueTime=10; %t in seconds to examine after cue

preCueFrames= preCueTime*fs;
postCueFrames= postCueTime*fs;

periCueFrames= preCueFrames+postCueFrames;

slideTime = 10; %time in seconds pre-cue for baseline  %400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)

%- Save data between methods into grand table?
periEventTable= table();

numTrials= 60; %assume 60 trials per ses

% periEventTable.fitMethod= cell(numel(structsToCompare)*periCueFrames*numTrials,1);
% periEventTable.signal= nan(

%initialize columns
% preallocate= nan(numel(structsToCompare)*periCueFrames*numTrials,1);

preallocate= nan((numel(structsToCompare)*periCueFrames*numTrials)+1,1);


periEventTable.signalPeriEvent= preallocate;
periEventTable.referencePeriEvent= preallocate;
periEventTable.signalPeriEventZ= preallocate;
periEventTable.referencePeriEventZ= preallocate;

   %fill string cols with empty
periEventTable(:,'fitMethod')= {''};
periEventTable(:,'eventCondition')= {''};
periEventTable(:,'refEvent')= {''};
periEventTable(:,'triggerEvent')= {''};


% for subj= 1:numel(subjects)
    
%     currentSubj= subjData.(subjects{subj});
%     currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    sesCount= 1; %cumulative session counter for aucTable
    tsInd= 1:periCueFrames+1; %cumulative timestamp index for aucTableTS

    timeLockID= 1; %unique ID for every timeLock for grouping observations

%     for session= 1:numel(currentSubjAnalyzed)
        
              
        %--run peri-event fxn to get fp signal
        
    for thisStruct= 1:numel(structsToCompare)
                
        %TODO: consider loop thru eventTypes for periEvent
        %can use to dyamically trigger in fxn call below?
        eventsToReference= {'DS'};
        
        %--note eventsToTrigger here currently limited to
        %subjDataAnalyzed.behavior, where 1st event of each type is saved
        %for each trial..
        eventsToTrigger= {'DS','poxDS'};
        
                
        %use struct name to dynamically access data
        currentSubj= eval(strcat('subjData',structsToCompare{thisStruct}));
        currentSubjAnalyzed= eval(strcat('subjDataAnalyzed',structsToCompare{thisStruct}));
        
        
        for thisReferenceEvent= 1:numel(eventsToReference)
            
            for thisTriggerEvent= 1:numel(eventsToTrigger)
            
                %dyanmically access struct fields based on string
                refEvent= strcat('currentSubj(session).', eventsToReference{thisReferenceEvent});
                triggerEvent= strcat('currentSubjAnalyzed(session).behavior.', eventsToTrigger{thisTriggerEvent});
                
%         [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubj(session).DS', slideTime, preCueTime, postCueTime);                   
        [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, refEvent, triggerEvent, slideTime, preCueTime, postCueTime);                   

        
%         periEventTable(tsInd,"fitMethod")= structsToCompare(thisStruct);
%      
%         periEventTable(tsInd,"refEvent")= eventsToReference(thisReferenceEvent);
%         periEventTable(tsInd,"triggerEvent")= eventsToTrigger(thisTriggerEvent);
%         
%         periEventTable(tsInd,"eventCondition")= strcat('peri-', eventsToTrigger(thisTriggerEvent),'-',eventsToReference(thisReferenceEvent),'-trials');
%         
%         periEventTable(tsInd, 'timeLock')= table(timeLock);
%         
     
       subjDataAnalyzed.(subjects{subj})(session).periDS.DS= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periDS.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periDS.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periDS.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurpleMean= periPurpleZMean;


       for trial = 1:size(periBlueZ,3) %for each *event*
           
            periEventTable(tsInd,"subject")= {subjects{subj}};           
            periEventTable(tsInd,'trainStage') = table(currentSubj(session).trainStage);
            periEventTable(tsInd,'fileID') = table(currentSubj(session).fileID);
           
            periEventTable(tsInd,"fitMethod")= structsToCompare(thisStruct);

            periEventTable(tsInd,"refEvent")= eventsToReference(thisReferenceEvent);
            periEventTable(tsInd,"triggerEvent")= eventsToTrigger(thisTriggerEvent);

            periEventTable(tsInd,"eventCondition")= strcat('peri-', eventsToTrigger(thisTriggerEvent),'-',eventsToReference(thisReferenceEvent),'-trials');

            periEventTable(tsInd, 'timeLock')= table(timeLock);
            
            periEventTable(tsInd,'timeLockID')= table(timeLockID);
           
           
           periEventTable(tsInd,'signalPeriEvent')= table(periBlue(:,:,trial));
           periEventTable(tsInd,'referencePeriEvent')= table(periPurple(:,:,trial));
           periEventTable(tsInd,'signalPeriEventZ')= table(periBlueZ(:,:,trial));
           periEventTable(tsInd,'referencePeriEventZ')= table(periPurpleZ(:,:,trial));
                                          
           
           tsInd= tsInd+ periCueFrames; %index for 1 value per timestamp per trial
           timeLockID= timeLockID+1; %index for 1 value per timeLock (for grouping observations)        
           
       end
       
       
       %--compute AUC as well (just 465nm periDS for now)
       %single mean per session
%       signal= periBlueZMean;
%       auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
%         [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(signal);
% 
%         aucTable.auc(sesCount) = auc;
%         aucTable.aucAbs(sesCount)= aucAbs;
% 
%         aucTableTS.aucCum(tsInd)= aucCum;
%         aucTableTS.aucCumAbs(tsInd)= aucCumAbs;
%         aucTableTS.timeLock(tsInd)= [[-preCueFrames:postCueFrames]/fs]';
% 
%         %save labels for these data too (1 per session)
%         aucTable.subject{sesCount}= subjects{subj};
%         aucTable.date{sesCount}= num2str(currentSubj(session).date);
% 
%         aucTable.stage(sesCount)= currentSubj(session).trainStage;
%         aucTable.trainDay(sesCount)= currentSubj(session).trainDay;
%         aucTableTS.subject(tsInd)= cell(periCueFrames+1,1);
%         aucTableTS.subject(tsInd)= {subjects{subj}};
%         aucTableTS.date(tsInd)= cell(periCueFrames+1,1);
%         aucTableTS.date(tsInd)= {num2str(currentSubj(session).date)};
%         aucTableTS.stage(tsInd)= (currentSubj(session).trainStage);
%        
%         sesCount=sesCount+1;
%         tsInd= tsInd + periCueFrames;
%         
              
            end %end trigger event loop
        end %end ref event loop
    end %end signalCol loop
    

    
    
    %%-----GRAMM PLOTS COMPARING PERIEVENT across preprocessing    
    
    
    data= periEventTable;

    %fig- 'raw' unnormalized

    clear i;
    figure();
    
    titleFig= strcat('fp-fit-comparison-','-periEvent-','-raw-','-fileID-',num2str(currentSubj(session).fileID));
     %-- individual trials
    group= data.timeLockID;
    
    i= gramm('x',data.timeLock, 'y', data.signalPeriEvent, 'color', data.fitMethod, 'group', group);
    
    i.facet_grid(data.eventCondition,data.fitMethod);
    
    i.geom_line();
    
    i.draw();
    
    sgtitle(titleFig);
    
    saveFig(gcf, figPath, titleFig, figFormats);

    %--Fig- normalized (Z scored)
    clear i;
    figure();
    
    %-- individual trials
    group= data.timeLockID;
    
    titleFig= strcat('fp-fit-comparison-','-periEvent-','-Zscore-','-fileID-',num2str(currentSubj(session).fileID));
    
    i= gramm('x',data.timeLock, 'y', data.signalPeriEventZ, 'color', data.fitMethod, 'group', group);
    
    i.facet_grid(data.eventCondition,data.fitMethod);
    
    i.geom_line();
    
    i.draw();
    
    sgtitle(titleFig);

    saveFig(gcf, figPath, titleFig, figFormats);

    %DP TODO 8/29/22   
    %-- Save data from all sessions into table
   
    
    end %end ses loop
end %end subj loop



%% TODO: plots from all session table



