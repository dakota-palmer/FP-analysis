%generalizing peri event to fxn

%% define function

%RUN FUNCTION WITHIN A SUBJ, SESSION loop, assigning output to struct
%fields corresponding to specific sessions 
function [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock, periBlueMean, periPurpleMean, periBlueZMean, periPurpleZMean] = fp_periEvent(currentSubj, currentSubjAnalyzed, session, baselineEvent, timeLockEvent, baselineTimeS, preEventTimeS, postEventTimeS) 

    %--INPUTS:
    %currentSubj= subj # in subj loop
    %currentSession= session # in subjData loop

    %baseLineEvent= STRING of struct field corresponding to event to use as baseline (DS or NS)
         %e.g. 'currentSubj(session).DS'
    %timeLockEvent= STRING of struct field corresponding to event to timeLock to
         % e.g. 'currentSubjAnalyzed(session).behavior.loxDS'

    %--OUTPUTS: one per session
    %-assign these outputs to the appropriate subjDataAnalyzed struct fields 

    %baselineOnset = trials, cues which are used as baseline
    %tRange= peri-event window surrounding event

    %periBlue= 465nm reblue in tRange
    %periPurple= 405nm repurple in tRange

    %periBlueZ= 465nm z scored reblue in tRange relative to baseline
    %periBlueZ= 405nm z scored repurple in tRange relative to baseline

    %tRangeBaseline= time window used for baseline 
    %baselineBlue= 465nm baseline in pre-cue window used for z score
    %baselineBlue= 405nm baseline in pre-cue window used for z score

    % timeLock= normalized time of peri-event window (relative to timeLockEvent onset)

    %--FXN:
    % 
    % currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
    % 
    % currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the curret subject within the struct


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



    %         cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeDS things up because we have to go through each timestamp to find the closest one to the cues

    trialsSkipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

    for trial=1:length(eval(eventTimelock)) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset

        preEventTime=[]; postEventTime= []; trialEvents=[];

        trialEvents= eval(eventTimelock);      

        trialBaselineEvents= eval(eventBaseline);

        eventOnset= trialEvents(trial);
        baselineOnset= trialBaselineEvents(trial);

        if iscell(eventOnset) %if cell with multiple events, get the first event only
           eventOnset= eventOnset{:};
           if ~isempty(eventOnset)
                eventOnset= eventOnset(1);  
           else
                eventOnset= nan;  

           end
        end

        tBins= round((postEventTimeS+preEventTimeS)*fs)+1; %plus one for t=0


        %define the frames (datapoints) around each cue to analyze
        preEventTime = eventOnset-preEventTimeS; %-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
        postEventTime = eventOnset+postEventTimeS; %postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

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
        baselineStart= baselineOnset-baselineTimeS;
        baselineEnd= baselineOnset;

        tBinsBaseline= round((baselineEnd-baselineStart)*fs);

        tRangeBaseline=linspace(baselineStart,baselineEnd,tBinsBaseline)';  %time range over which to interp() fp signal (pre:post)

        %use interp() to get fp during this baseline range 
        baselineBlue= interp1(currentSubj(session).cutTime, currentSubj(session).reblue, tRangeBaseline)';
        baselinePurple= interp1(currentSubj(session).cutTime, currentSubj(session).repurple, tRangeBaseline)';

        %get mean and std during baseline for Z score
        baselineMeanBlue= nanmean(baselineBlue); %baseline mean blue 10s prior to DS onset
        baselineStdBlue= nanstd(baselineBlue); %baseline std blue 10s prior to DS onset 
        baselineMeanPurple= nanmean(baselinePurple); %baseline mean blue 10s prior to DS onset
        baselineStdPurple= nanstd(baselinePurple); %baseline std blue 10s prior to DS onset 

        %define time range surrounding event over which to interp fp signal            
        tRange=linspace(preEventTime,postEventTime,tBins)';  %time range over which to interp() fp signal (pre:post)

        %interp() fp signals over our time range for this trial
        periBlue= interp1(currentSubj(session).cutTime,currentSubj(session).reblue, tRange);

        periPurple=  interp1(currentSubj(session).cutTime,currentSubj(session).repurple, tRange);


    %             %TODO: dff - *******Relies upon previous photobleaching/baseline section %interp has not been implemented here
    %             subjDataAnalyzed.(subjects{subj})(session).periDS.DSbluedff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff(preEventTimeDS:postEventTimeDS);
    %             subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpledff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff(preEventTimeDS:postEventTimeDS);

       if isnan(eventOnset)
            %~~~~~~if no event on this trial, make nan
            tRange= [preEventTimeS:postEventTimeS]*fs;

            currentSubjAnalyzed(session).periEvent.baselineOnset(trial)= nan;
            currentSubjAnalyzed(session).periEvent.tRange(:,:,trial)= nan(tBins,1);
            currentSubjAnalyzed(session).periEvent.periBlue(:,:,trial)= nan(tBins,1);
            currentSubjAnalyzed(session).periEvent.periPurple(:,:,trial)= nan(tBins,1);
            currentSubjAnalyzed(session).periEvent.periBlueZ(:,:,trial)= nan(tBins,1);
            currentSubjAnalyzed(session).periEvent.periPurpleZ(:,:,trial)= nan(tBins,1);
            
            tBinsBaseline= baselineTimeS*fs;
            currentSubjAnalyzed(session).periEvent.tRangeBaseline(:,:,trial)= nan(tBinsBaseline,1);
            
            currentSubjAnalyzed(session).periEvent.baselineMeanBlue(1,trial)= nan;
            currentSubjAnalyzed(session).periEvent.baselineMeanPurple(1,trial)= nan;
            currentSubjAnalyzed(session).periEvent.baselineStdBlue(1,trial)= nan;
            currentSubjAnalyzed(session).periEvent.baselineStdPurple(1,trial)= nan;
            
            currentSubjAnalyzed(session).periEvent.timeLock= nan(size(tRange));

       elseif ~isnan(eventOnset)
            %~~~~ SAVE DATA INTO STRUCT- CHANGE THESE FIELDNAMES BASED ON EVENTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            %save all of the following data in the subjDataAnalyzed struct under the peri Event field            
            currentSubjAnalyzed(session).periEvent.baselineOnset(trial) = baselineOnset; %this way only included cues are saved
            currentSubjAnalyzed(session).periEvent.tRange(:,:,trial)= tRange;


            currentSubjAnalyzed(session).periEvent.periBlue(:,:,trial)= periBlue;
            currentSubjAnalyzed(session).periEvent.periPurple(:,:,trial)= periPurple;

                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
                %same interp approach for baseline                
            currentSubjAnalyzed(session).periEvent.periBlueZ(:,:,trial)= ((periBlue-baselineMeanBlue))/(baselineStdBlue); 
            currentSubjAnalyzed(session).periEvent.periPurpleZ(:,:,trial)= ((periPurple- baselineMeanPurple))/(baselineStdPurple);


            %save the time window for baseline calculations
           currentSubjAnalyzed(session).periEvent.tRangeBaseline(:,:,trial)= tRangeBaseline; %eventOnset-slideTime:eventOnset; 


            %lets save the baseline mean and std used for z score calc- so
            %that we can use this same baseline for other analyses
             currentSubjAnalyzed(session).periEvent.baselineMeanBlue(1,trial)= baselineMeanBlue;
             currentSubjAnalyzed(session).periEvent.baselineStdBlue(1,trial)= baselineStdBlue;
             currentSubjAnalyzed(session).periEvent.baselineMeanPurple(1,trial)= baselineMeanPurple;
            currentSubjAnalyzed(session).periEvent.baselineStdPurple(1,trial)= baselineStdPurple;

            %save timeLock time axis- 'normalized' relative time from event (instead
            %of absolute time)
            currentSubjAnalyzed(session).periEvent.timeLock= tRange/fs;
       end

    end %end trial loop

    baselineOnset = currentSubjAnalyzed(session).periEvent.baselineOnset;
    tRange= currentSubjAnalyzed(session).periEvent.tRange;
    periBlue= currentSubjAnalyzed(session).periEvent.periBlue;
    periPurple= currentSubjAnalyzed(session).periEvent.periPurple;

    periBlueZ= currentSubjAnalyzed(session).periEvent.periBlueZ;
    periPurpleZ= currentSubjAnalyzed(session).periEvent.periPurpleZ;

    tRangeBaseline= currentSubjAnalyzed(session).periEvent.tRangeBaseline; 
    baselineBlue=  currentSubjAnalyzed(session).periEvent.baselineMeanBlue;
    baselinePurple=  currentSubjAnalyzed(session).periEvent.baselineMeanPurple;

    timeLock= currentSubjAnalyzed(session).periEvent.timeLock;

    periBlueMean = nanmean(periBlue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
    periPurpleMean = nanmean(periBlue, 3);
    periBlueZMean = nanmean(periBlueZ, 3);
    periPurpleZMean = nanmean(periBlueZ, 3);
    

    %matlab actually seems smart enough to autofill empty fields with nans where
    %     %appropriate, but rest of code logic assumes empty (e.g. checks for
    %     %isempty(periNS) in case of early stages without NS)
    %     
    %     %so if nan, replace fields with [];
    
    %rest of code checks specifically for empty NS so exclusively make empty NS
    %(leaves DS nan)
    
    if contains(baselineEvent, 'NS')
        if ~isempty(currentSubjAnalyzed(session).periEvent.baselineOnset)
            if isnan(currentSubjAnalyzed(session).periEvent.baselineOnset)
               baselineOnset= [];
               tRangeBaseline= [];

               periBlue=[]; 
               periPurple=[]; 
               periBlueZ= [];
               periPurpleZ= [];

            %         subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple(1:periCueFrames+1,1,cue)= nan;

                baselineBlue=[]; 
                baselinePurple=[]; 
                timeLock=[];


                 %technically possible that there are no events at all (e.g. no
                 %licks during extinction session), make manual exception mean= all nan (otherwise plotting code will throw errors)


                periBlueMean = nan(tBins,1);
                periPurpleMean = nan(tBins,1);
                periBlueZMean = nan(tBins,1);
                periPurpleZMean = nan(tBins,1);

            end
        end
    end
    
    
 %% EXAMPLE: 

% %Timelock to first DS Lick
% for subj= 1:numel(subjects)
%     
%     currentSubj= subjData.(subjects{subj});
%     currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
% 
%     
%     for session= 1:numel(currentSubjAnalyzed)
% 
% %         function [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock] = fp_periEvent(subj, session, baselineEvent, timeLockEvent) 
% 
% 
%          [baselineOnset, tRange, periBlue, periPurple, periBlueZ, periPurpleZ, tRangeBaseline, timeLock]= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubjAnalyzed(session).behavior.loxDS', slideTime, preCueTime, postCueTime)
% %          subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSselected,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.periEventWindow,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.baselineWindow,
% %                subjDataAnalyzed.(subjects{subj})(session).periDSlox.timeLock= fp_periEvent(currentSubj, currentSubjAnalyzed, session, 'currentSubj(session).DS', 'currentSubjAnalyzed(session).behavior.loxDS', slideTime, preCueTime, postCueTime)
%                    
% 
% 
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSselected= baselineOnset;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.periEventWindow= tRange;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue= periBlue;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple= periPurple;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue= periBlueZ;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple= periPurpleZ;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.baselineWindow= tRangeBaseline;
%                subjDataAnalyzed.(subjects{subj})(session).periDSlox.timeLock= timeLock;
%         
%               
%     end 
%     
% end
% 

   
