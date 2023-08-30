%% 2023-08-29 count licks per trial, defined within fixed time window post-PE

% copy code from fpAnalyzeData_behavioral_analysis

% find licks within post-DS window.

%% Parameters

preBaselineTimeS= 0;
postBaselineTimeS= 10; %10s post-event window

%% 
% % 
% % for subj= 1:numel(subjects) %for each subject
% % %    currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
% %     currentSubj= subjDataAnalyzed.(subjects{subj});
% %     for session = 1:numel(currentSubj) %for each training session this subject completed
% %        
% %        %First, let's exclude trials where there was 1) no PE in the cue
% %        %epoch or 2) animal was already in the port at cue onset
% %         %get the DS cues
% %         DSselected= currentSubj(session).periDS.DS;  
% % 
% %        
% %         %First, let's exclude trials where animal was already in port
% %         %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
% %         %have a non-nan value and use these to exclude DS trials from this
% %         %analysis (we'll make them nan)
% %                 
% %         DSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS)) = nan;
% % 
% %         %Then, let's exclude trials where animal didn't make a PE during
% %         %the cue epoch. To do so, get indices of empty cells in
% %         %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
% %         %happened during the cue epoch) and then use these to set that DS =
% %         %nan
% %         DSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS)) = nan;
% %        
% %         % initialize tensecDSpe matrix
% %         currentSubj(session).tensecDSpe=[];
% %        
% %        for cue = 1:numel(DSselected)
% %             
% %            if ~isnan(DSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch
% %                 DSonset= DSselected(cue);
% %                 firstPox = min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS{cue}); %min of poxDS= first PE after DS onset
% %                 
% %                 currentSubj(session).DSpeLatency(1,cue)= firstPox-DSonset;
% %                 
% %                  % if pox made in first 10 sec of DS, tag that trial with a 1, if not, tag with 0
% %                 if firstPox - DSonset <= 10
% %                     currentSubj(session).tensecDSpe(1,cue)= 1;
% %                 else
% %                     currentSubj(session).tensecDSpe(1,cue) = 0;
% %                 end
% %                   
% % %                  if currentSubj(session).DSpeLatency(1,cue)== 0 || currentSubj(session).DSpeLatency(1,cue)<0
% % %                     disp(currentSubj(session).DSpeLatency(1,cue) ) %Flag abnomal latency values
% % %                  end
% %            else %else if we want to skip over this cue, make latency nan
% %                currentSubj(session).DSpeLatency(1,cue) = nan;
% %            end 
% %            
          
           %% 
%         

subjects= fieldnames(subjDataAnalyzed);
for subj= 1:numel(subjects)
    
%     currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    
    for session= 1:numel(currentSubjAnalyzed)

    %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or DS)
    %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
    %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  
    baselineEvent= 'currentSubjAnalyzed(session).behavior.poxDS';
    
    timeLockEvent= 'currentSubjAnalyzed(session).raw.lox';
    
    %strings here will be evaluated with eval() to get the values
    %what cue type should baseline be timelocked to?
    eventBaseline= baselineEvent;

    %what event are you timelocking to?
    eventTimelock= timeLockEvent;

    fs= 40; %40hz time bins
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % disp(strcat('running-', eventBaseline,'-', eventTimelock,'-triggered analysis subject_',  subjects{subj}));

    trialsSkipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)


    sesEvents= eval(eventTimelock);      

    sesBaselineEvents= eval(eventBaseline);
    
    %inititalize struct fields for later assignment
    currentSubjAnalyzed(session).behavior.eventOnsets= cell(1,numel(sesBaselineEvents));
    currentSubjAnalyzed(session).behavior.eventOnsetsRel= cell(1,numel(sesBaselineEvents));

    
    for trial=1:length(eval(eventBaseline))%for each baseline cue, search for events occuring within tRangeBaseline

        cutTime= []; 
        
        cutTime= currentSubjAnalyzed(session).raw.cutTime;

        eventOnsets= sesEvents; 
        baselineOnset= sesBaselineEvents(trial);

       %if >1 baseline event, computing for first baseline event (PE) only
       if iscell(sesBaselineEvents(trial)) 
           if ~isempty(sesBaselineEvents{trial})
                baselineOnset= sesBaselineEvents{trial}(1);
            else
                 baselineOnset= nan;
           end
       end
       
        if iscell(eventOnsets) %if cell with multiple events, keep all events (so long as not empty)
           eventOnsets= vertcat(eventOnsets{:});
           if ~isempty(eventOnsets)
                eventOnsets= eventOnsets; %(1);  
           else
                eventOnsets= nan;  

           end
        end


%         tBins= round((postEventTimeS+preEventTimeS)*fs)+1; %plus one for t=0


%         %define the frames (datapoints) around each cue to analyze
%         preEventTime = eventOnset-preEventTimeS; %-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
%         postEventTime = eventOnset+postEventTimeS; %postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

    %             if preEventTime< 1 %if event onset is too close to the beginning to extract preceding frames, skip this cue
    %                 disp(strcat(eventTimeLock, num2str(trial), ' too close to beginning, continuing'));
    %                 trialsSkipped= trialsSkipped+1;
    %                 continue
    %             end
    % 
    %             if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
    %                 disp(strcat(eventTimeLock, num2str(trial), ' too close to end, continuing'));
    %                 trialsSkipped= trialsSkipped+1;  %iterate the counter for skipped DS cues
    %                 continue %continue out of the loop and move onto the next DS cue
    %             end

        %instead of indexing with %cutTime(preEventTimeDS:postEventTimeDS), create a custom %time range with linspace() then interp() fp signal %throughout this time range

        
        baselineStart= baselineOnset-preBaselineTimeS;
        baselineEnd= baselineOnset+postBaselineTimeS;

%         tBinsBaseline= round((baselineEnd-baselineStart)*fs);

%         tRangeBaseline=linspace(baselineStart,baselineEnd,tBinsBaseline)';  %time range over which to interp() fp signal (pre:post)

        
                
                       
          if baselineEnd < cutTime(end) %max(cutTime) %make sure cue isn't too close to the end of session  
                eventCount= 1; %counter for indexing

                for i = 1:numel(eventOnsets) % for every event logged in this session
                   if (((baselineOnset)<eventOnsets(i)) && ((eventOnsets(i)<baselineEnd))) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
                        currentSubjAnalyzed(session).behavior.eventOnsets{1,trial}(eventCount,1)= eventOnsets(i); %cell array containing all events during the cue, empty [] if no pox during the cue
                        %save timestamps of lick relative to cue onset
                        currentSubjAnalyzed(session).behavior.eventOnsetsRel{1,trial}(eventCount,1)= eventOnsets(i)-(baselineStart);
                        eventCount=eventCount+1; %iterate the counter
                   end
                end
          end

                
        
        
        
       if isnan(eventOnsets)
            %~~~~~~if no event on this trial, make empty
%             tRange= [preEventTimeS:postEventTimeS]*fs;

            currentSubjAnalyzed(session).behavior.eventOnsets{trial}= [];
            currentSubjAnalyzed(session).behavior.eventOnsetsRel{trial}= [];

            

       elseif ~isnan(eventOnsets)
%             currentSubjAnalyzed(session).behavior.eventOnsets(trial)= eventOnsets;
%             currentSubjAnalyzed(session).behavior.eventOnsetsRel(trial)= eventOnsetsRel;
       end

    end %end trial loop currentSubjAnalyzed(session).behavior.eventOnsets

    
    eventOnsets= currentSubjAnalyzed(session).behavior.eventOnsets;
    eventOnsetsRel= currentSubjAnalyzed(session).behavior.eventOnsetsRel;

           
        %Assign data back to struct. 
    subjDataAnalyzed.(subjects{subj})(session).periDSpox.loxPostPE= eventOnsets;
    subjDataAnalyzed.(subjects{subj})(session).periDSpox.loxPostPErel= eventOnsetsRel;      
           
           
       
   end %end session loop
     
end %end subject loop


% 
%    end 
% end