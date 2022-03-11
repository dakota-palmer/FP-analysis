%generalizing peri event to fxn

%% define function

%RUN FUNCTION WITHIN A SUBJ, SESSION loop, assigning output to struct
%fields corresponding to specific sessions 
function [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, timeLockEvent, preBaselineTimeS, postBaselineTimeS) 

    %--INPUTS:
    %currentSubj= subj # in subj loop
    %currentSession= session # in subjData loop

    %baseLineEvent= STRING of struct field corresponding to event to use as baseline (DS or NS)
         %e.g. 'currentSubj(session).DS'
    %timeLockEvent= STRING of struct field corresponding to event to timeLock to
         % e.g. 'currentSubj(session).loxDS'
    %preBaselineTimeS= time before baselineEvent to search for events (should be 0 for defining events only after cue)
    %postBaselineTimeS= time after baselineEvent to search for events(should be cue duration if limiting to cue)

    %--OUTPUTS: one per session
    %-assign these outputs to the appropriate subjDataAnalyzed struct fields 

    %eventOnsets= raw timestamps of events during tRangeBaseline
    %eventOnsetsRel= timestamps of events within tRangeBaseline relative to baseline event onset (@ time 0)

    %--FXN:
    % 
    % currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
    % 
    % currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the curret subject within the struct

    
    
%     %First, let's establish the cue duration based on training stage
%     if currentSubj(session).trainStage == 1
%         cueLength= 60;%*fs; %60s on stage 1, multiply by fs to get #frames
%     elseif currentSubj(session).trainStage ==2
%         cueLength= 30;%*fs;
%     elseif currentSubj(session).trainStage ==3
%         cueLength= 20;%*fs;
%     else %on subsequent stages, cueLength is 10s
%         cueLength =10;%*fs; 
%     end

    %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or DS)
    %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
    %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  

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
        
        cutTime= currentSubj(session).cutTime;

        eventOnsets= sesEvents; 
        baselineOnset= sesBaselineEvents(trial);

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

%             currentSubjAnalyzed(session).behavior.baselineOnset(trial)= nan;
%             currentSubjAnalyzed(session).behavior.tRange(:,:,trial)= nan(tBins,1);
%             currentSubjAnalyzed(session).behavior.periBlue(:,:,trial)= nan(tBins,1);
%             currentSubjAnalyzed(session).behavior.periPurple(:,:,trial)= nan(tBins,1);
%             currentSubjAnalyzed(session).behavior.periBlueZ(:,:,trial)= nan(tBins,1);
%             currentSubjAnalyzed(session).behavior.periPurpleZ(:,:,trial)= nan(tBins,1);
%             
%             tBinsBaseline= baselineTimeS*fs;
%             currentSubjAnalyzed(session).behavior.tRangeBaseline(:,:,trial)= nan(tBinsBaseline,1);
%             
%             currentSubjAnalyzed(session).behavior.baselineMeanBlue(1,trial)= nan;
%             currentSubjAnalyzed(session).behavior.baselineMeanPurple(1,trial)= nan;
%             currentSubjAnalyzed(session).behavior.baselineStdBlue(1,trial)= nan;
%             currentSubjAnalyzed(session).behavior.baselineStdPurple(1,trial)= nan;
%             
%             currentSubjAnalyzed(session).behavior.timeLock= nan(size(tRange));
            
            currentSubjAnalyzed(session).behavior.eventOnsets{trial}= [];
            currentSubjAnalyzed(session).behavior.eventOnsetsRel{trial}= [];

            

       elseif ~isnan(eventOnsets)
%             currentSubjAnalyzed(session).behavior.eventOnsets(trial)= eventOnsets;
%             currentSubjAnalyzed(session).behavior.eventOnsetsRel(trial)= eventOnsetsRel;
       end

    end %end trial loop currentSubjAnalyzed(session).behavior.eventOnsets

    
    eventOnsets= currentSubjAnalyzed(session).behavior.eventOnsets;
    eventOnsetsRel= currentSubjAnalyzed(session).behavior.eventOnsetsRel;

    
%     if contains(baselineEvent, 'NS')
%         if ~isempty(currentSubjAnalyzed(session).behavior.baselineOnset)
%             if isnan(currentSubjAnalyzed(session).behavior.baselineOnset)
%                 %exception for empty NS?
% %                eventOnsets= %
%         
% 
%             end
%         end
%     end
    
    
    
 
    
 %% EXAMPLE: 
%  
% for subj= 1:numel(subjects)
%     
%     currentSubj= subjData.(subjects{subj});
%     currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
% 
%     
%     for session= 1:numel(currentSubjAnalyzed)
% 
%         %First, let's establish the cue duration based on training stage
%         if currentSubj(session).trainStage == 1
%             cueLength= 60;%*fs; %60s on stage 1, multiply by fs to get #frames
%         elseif currentSubj(session).trainStage ==2
%             cueLength= 30;%*fs;
%         elseif currentSubj(session).trainStage ==3
%             cueLength= 20;%*fs;
%         else %on subsequent stages, cueLength is 10s
%             cueLength =10;%*fs; 
%         end
% 
%         preBaselineTimeS= 0;
%         postBaselineTimeS= cueLength;
% 
%         baselineEvent= 'currentSubj(session).DS';
%         timeLockEvent= 'currentSubj(session).lox';
%         
%         [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, timeLockEvent, preBaselineTimeS, postBaselineTimeS); 
% 
%        
%         subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS= eventOnsets;
%         subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSRel= eventOnsetsRel;
%               
%     end 
%     
% end


   
