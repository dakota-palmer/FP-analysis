%% ~~~Event-Triggered Analyses ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%In these sections, we will do an event-triggered analyses by extracting data 
%from the photometry traces immediately surrounding relevant behavioral events (e.g. cue onset, port entry, lick)
%To do so, we'll find the onset timestamp for each event (eventTime) and use this
%timestamp to extract photometry data surrounding it
%(preEventTime:postEventTime). This will be saved to the subjDataAnalyzed
%struct. 


%here we are establishing some variables for our event triggered-analysis
preCueTime= 5; %t in seconds to examine before cue
postCueTime=10; %t in seconds to examine after cue

preCueFrames= preCueTime*fs;
postCueFrames= postCueTime*fs;

periCueFrames= preCueFrames+postCueFrames;

slideTime = 10; %time in seconds pre-cue for baseline  %400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


% periCueTime = 10;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
% periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  
% 
% slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


%% AUC data
%dp just creating a new AUC table variable for now

%preallocate table with #rows equal to total session count
sesCount= 0;
for subj= 1:numel(subjects) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjects{subj});

    for session = 1:numel(currentSubj) 
       sesCount=sesCount+1;
    end %end session loop
   
end
%single AUC values per session)
aucTable= table();
aucTable.auc = (nan(sesCount,1));
aucTable.aucAbs= (nan(sesCount,1));
aucTable.subject= cell(sesCount,1); %(nan(sesCount,1));
aucTable.date= cell(sesCount,1); %(nan(sesCount,1));
aucTable.stage= (nan(sesCount,1));
aucTable.trainDay= nan(sesCount,1);


%TODO: separate for timeseries (cumulative AUCs over timeLock)
%will require different indexing
aucTableTS= table();
aucTableTS.auc = (nan(sesCount*periCueFrames+1,1));
aucTableTS.aucAbs= (nan(sesCount*periCueFrames+1,1)); %(nan(sesCount,1));
aucTableTS.aucCum= nan(sesCount*periCueFrames+1,1); %(nan(sesCount,1));
aucTableTS.aucCumAbs= nan(sesCount*periCueFrames+1,1); %(nan(sesCount,1));
aucTableTS.timeLock= nan(sesCount*periCueFrames+1,1); 
aucTableTS.subject= cell(sesCount*periCueFrames+1,1); %(nan(sesCount,1));
aucTableTS.date= cell(sesCount*periCueFrames+1,1); %(nan(sesCount,1));
aucTableTS.stage= nan(sesCount*periCueFrames+1,1); %(nan(sesCount,1));

% aucTable.date = (nan(sesCount,1));
% aucTable.stage= (nan(sesCount,1));


%% TimeLock to DS 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    sesCount= 1; %cumulative session counter for aucTable
    tsInd= 1:periCueFrames+1; %cumulative timestamp index for aucTableTS
    
    for session= 1:numel(currentSubjAnalyzed)
        
              
        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubj(session).DS', slideTime, preCueTime, postCueTime);                   


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


              
       
       %--compute AUC as well (just 465nm periDS for now)
      signal= periBlueZMean;
      auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
        [auc, aucAbs, aucCum, aucCumAbs] = fp_AUC(signal);

        aucTable.auc(sesCount) = auc;
        aucTable.aucAbs(sesCount)= aucAbs;

        aucTableTS.aucCum(tsInd)= aucCum;
        aucTableTS.aucCumAbs(tsInd)= aucCumAbs;
        aucTableTS.timeLock(tsInd)= [[-preCueFrames:postCueFrames]/fs]';

        %save labels for these data too (1 per session)
        aucTable.subject{sesCount}= subjects{subj};
        aucTable.date{sesCount}= num2str(currentSubj(session).date);

        aucTable.stage(sesCount)= currentSubj(session).trainStage;
        aucTable.trainDay(sesCount)= currentSubj(session).trainDay;
        aucTableTS.subject(tsInd)= cell(periCueFrames+1,1);
        aucTableTS.subject(tsInd)= {subjects{subj}};
        aucTableTS.date(tsInd)= cell(periCueFrames+1,1);
        aucTableTS.date(tsInd)= {num2str(currentSubj(session).date)};
        aucTableTS.stage(tsInd)= (currentSubj(session).trainStage);
       
        sesCount=sesCount+1;
        tsInd= tsInd + periCueFrames;

    end 
    
end

%% TimeLock to first DS port entry 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    for session= 1:numel(currentSubjAnalyzed)

       
        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubjAnalyzed(session).behavior.poxDS', slideTime, preCueTime, postCueTime);                   


       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSselected= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurpleMean= periPurpleZMean;
    end 
    
end


%% TimeLock to first DS Lick
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    for session= 1:numel(currentSubjAnalyzed)

        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubjAnalyzed(session).behavior.loxDS', slideTime, preCueTime, postCueTime);                   


       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSselected= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurpleMean= periPurpleZMean;
              
    end 
    
end


%% TimeLock to NS 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    sesCount= 1; %cumulative session counter for aucTable
    tsInd= 1:periCueFrames+1; %cumulative timestamp index for aucTableTS
    
    for session= 1:numel(currentSubjAnalyzed)
        
              
        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).NS', 'currentSubj(session).NS', slideTime, preCueTime, postCueTime);                   


       subjDataAnalyzed.(subjects{subj})(session).periNS.NS= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periNS.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periNS.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periNS.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean= periPurpleZMean;

    end 
    
end

%% TimeLock to first NS port entry 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    for session= 1:numel(currentSubjAnalyzed)

       
        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).NS', 'currentSubjAnalyzed(session).behavior.poxNS', slideTime, preCueTime, postCueTime);                   


       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean= periPurpleZMean;
    end 
    
end


%% TimeLock to first NS Lick
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    for session= 1:numel(currentSubjAnalyzed)

        %--run peri-event fxn to get fp signal
     [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).NS', 'currentSubjAnalyzed(session).behavior.loxNS', slideTime, preCueTime, postCueTime);                   


       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSselected= baselineOnset;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.periEventWindow= tRange;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue= periBlue;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple= periPurple;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue= periBlueZ;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple= periPurpleZ;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.baselineWindow= tRangeBaseline;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.timeLock= timeLock;
       
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblueMean= periBlueMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurpleMean= periPurpleMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblueMean= periBlueZMean;
       subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurpleMean= periPurpleZMean;
              
    end 
    
end





%% Calculate shifted timestamps for licks relative to PE (for timelocking to PE)
% Since we know the PE latency for each trial and have timestamps for licks
% relative to cue onset, we calculate timestamps for licks relative to PE
% as loxRel-PElatency

%dp changed 10/10/2021 to correct for empty values
for subj= 1:numel(subjects)
      currentSubj= subjDataAnalyzed.(subjects{subj}); 
    for session= 1:numel(currentSubj)
        currentSubj(session).behavior.loxDSpoxRel= cell(1,numel(currentSubj(session).periDS.DS)); %initialize
        currentSubj(session).behavior.loxNSpoxRel= cell(1,numel(currentSubj(session).periNS.NS));

        
        DSloxCount=0; %counter to tell if licks happened during any cues- if not, make empty
        NSloxCount= 0;

        
        for cue = 1:numel(currentSubj(session).behavior.loxDSrel) %for each DS trial in this session
                       
            if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only run if valid data present
               currentSubj(session).behavior.loxDSpoxRel{cue}= currentSubj(session).behavior.loxDSrel{cue}-currentSubj(session).behavior.DSpeLatency(cue); %loxDSpoxRel = timestamp of lick relative to PE 
               DSloxCount=DSloxCount+1;
            end
        end
    
        for cue = 1:numel(currentSubj(session).behavior.loxNSrel) %for each NS trial in this session
            if ~isempty(currentSubj(session).behavior.loxNSrel{cue}) %only run if valid data present
               currentSubj(session).behavior.loxNSpoxRel{cue}= currentSubj(session).behavior.loxNSrel{cue}-currentSubj(session).behavior.NSpeLatency(cue); %loxNSpoxRel = timestamp of lick relative to PE 
               NSloxCount= NSloxCount+1;
            end
        end
        
        %save the data
%         if DSloxCount >0
                subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSpoxRel= currentSubj(session).behavior.loxDSpoxRel;
%         else 
%             subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSpoxRel= [];
%         end
        
%         if NSloxCount >0
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSpoxRel= currentSubj(session).behavior.loxNSpoxRel;
%         else
%             subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSpoxRel=[];
%         end
    end % end session loop
end% end subj loop

%% save the subjects included
subjectsAnalyzed = fieldnames(subjDataAnalyzed); %now, let's save an array containing all of the analyzed subject IDs (may be useful later if we decide to exclude subjects from analysis)