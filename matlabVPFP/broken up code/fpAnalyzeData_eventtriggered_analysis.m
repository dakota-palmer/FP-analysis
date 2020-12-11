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

slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


% periCueTime = 10;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
% periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  
% 
% slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


%% TIMELOCK TO DS
for subj= 1:numel(subjects) %for each subject

    currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct

    %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or NS)
    %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
    %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  
    
    disp(strcat('running DS-triggered analysis subject_',  subjects{subj}));

        
    for session = 1:numel(currentSubj) %for each training session this subject completed              
        clear cutTime  %this is cleared between sessions to prevent spillover

        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

        DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

        for cue=1:length(currentSubj(session).DS) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset

            %each entry in DS is a timestamp of the DS onset 
            DSonset = find(cutTime==currentSubj(session).DSshifted(cue,1));

            %define the frames (datapoints) around each cue to analyze
            preEventTimeDS = DSonset-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTimeDS = DSonset+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTimeDS< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****DS cue ', num2str(cue), ' too close to beginning, continuing'));
                DSskipped= DSskipped+1;
                continue
            end

            if postEventTimeDS> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                disp(strcat('****DS cue ', num2str(cue), ' too close to end, continuing'));
                DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
                continue %continue out of the loop and move onto the next DS cue
            end

            % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %blueA
            baselineMeanblue=nanmean(currentSubj(session).reblue((DSonset-slideTime):DSonset)); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue=std(currentSubj(session).reblue((DSonset-slideTime):DSonset)); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple=nanmean(currentSubj(session).repurple((DSonset-slideTime):DSonset)); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple=std(currentSubj(session).repurple((DSonset-slideTime):DSonset)); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periDS field

            subjDataAnalyzed.(subjects{subj})(session).periDS.DS(cue) = currentSubj(session).DS(cue); %this way only included cues are saved
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(cue)= DSonset;% DS onset index in cutTime
            subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeDS:postEventTimeDS);
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeDS:postEventTimeDS);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeDS:postEventTimeDS))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeDS:postEventTimeDS))- baselineMeanpurple))/(baselineStdpurple);

            
            %dff - *******Relies upon previous photobleaching/baseline section
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSbluedff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff(preEventTimeDS:postEventTimeDS);
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpledff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff(preEventTimeDS:postEventTimeDS);

            
               
            %lets save the baseline mean and std used for z score calc- so
            %that we can use this same baseline for other analyses
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanblue(1,cue)= baselineMeanblue;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdblue(1,cue)= baselineStdblue;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanpurple(1,cue)= baselineMeanpurple;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdpurple(1,cue)= baselineStdpurple;
                                                                                                                                
            %save timeLock time axis
            subjDataAnalyzed.(subjects{subj})(session).periDS.timeLock= [-preCueFrames:postCueFrames]/fs;
       
        end %end DS cue loop
         %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple, 3);
            
   end %end session loop
end %end subject loop
        
%% TIMELOCK TO NS
for subj= 1:numel(subjects) %for each subject
    %Same approach as above, but for NS; done a bit differently because not every session will have the NS
        disp(strcat('running NS-triggered analysis subject_',  subjects{subj}));


   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct

       clear cutTime  %this is cleared between sessions to prevent spillover
       
       cutTime= currentSubj(session).cutTime; %save this as an array, immensely speeds things up because we have to go through each timestamp to find the closest one to the cues

  
      NSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

%       disp(strcat('running NS-triggered analysis subject ', num2str(subj), '/', num2str(numel(subjects)), ' session ', num2str(session), '/', num2str(numel(currentSubj))));

      if isnan(currentSubj(session).NS) %If there's no NS present, save data as empty arrays
          
        subjDataAnalyzed.(subjects{subj})(session).periNS.NS = [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.periNSwindow= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue=[]; 
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple=[]; 

        %get the mean response to the NS for this session
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSblueMean=[]; 
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpleMean=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean= [];
        
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSbluedff= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpledff= [];

 
        
      else %if the NS is present on this session, do the analysis and save results

            for cue=1:length(currentSubj(session).NS) %NS CUES %For each NS cue, conduct event-triggered analysis of data surrounding that cue's onset
                
                NSonset = find(cutTime==currentSubj(session).NSshifted(cue,1)); %get the corresponding cutTime index of the NS timestamp


                %define the frames (datapoints) around each cue to analyze
                preEventTimeNS = NSonset-preCueFrames; %earliest timepoint to examine is the shifted NS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
                postEventTimeNS = NSonset+postCueFrames; %latest timepoint to examine is the shifted NS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)

               if NSonset-slideTime< 1 %If cue is too close to beginning, skip over it
                  disp(strcat('****NS cue ', num2str(cue), ' too close to beginning, continuing'));
                  NSskipped= NSskipped+1;%iterate the counter for skipped NS cues
                  continue%continue out of the loop and move onto the next NS cue
                end

               if postEventTimeNS> length(currentSubj(session).cutTime)-slideTime %if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                  disp(strcat('****NS cue ', num2str(cue), ' too close to end, continuing'));
                  NSskipped= NSskipped+1;  %iterate the counter for skipped NS cues
                  continue %continue out of the loop and move onto the next NS cue
               end

                % Calculate average baseline mean&stdDev 10s prior to DS for z-score
                %blueA
                baselineMeanblue=nanmean(currentSubj(session).reblue((NSonset-slideTime):NSonset)); %baseline mean blue 10s prior to DS onset for boxA
                baselineStdblue=std(currentSubj(session).reblue((NSonset-slideTime):NSonset)); %baseline stdDev blue 10s prior to DS onset for boxA
                %purpleA
                baselineMeanpurple=nanmean(currentSubj(session).repurple((NSonset-slideTime):NSonset)); %baseline mean purple 10s prior to DS onset for boxA
                baselineStdpurple=std(currentSubj(session).repurple((NSonset-slideTime):NSonset)); %baseline stdDev purple 10s prior to DS onset for boxA

                %save the data in the subjDataAnalyzed struct under the periNS field
                
                subjDataAnalyzed.(subjects{subj})(session).periNS.NS(cue)= currentSubj(session).NS(cue); %this way only analyzed cues are included
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset(cue)= NSonset;% save index in cutTime
                subjDataAnalyzed.(subjects{subj})(session).periNS.periNSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeNS:postEventTimeNS);
                
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeNS:postEventTimeNS);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeNS:postEventTimeNS);
                    %z score calculation
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeNS:postEventTimeNS))-baselineMeanblue))/(baselineStdblue);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeNS:postEventTimeNS))- baselineMeanpurple))/(baselineStdpurple);

                     %dff - *******Relies upon previous photobleaching/baseline section
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSbluedff(:,:,cue)= (subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff(preEventTimeNS:postEventTimeNS));
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpledff(:,:,cue)= (subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff(preEventTimeNS:postEventTimeNS));

                
                  
                %lets save the baseline mean and std used for z score calc- so
                %that we can use this same baseline for other analyses
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanblue(1,cue)= baselineMeanblue;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdblue(1,cue)= baselineStdblue;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanpurple(1,cue)= baselineMeanpurple;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdpurple(1,cue)= baselineStdpurple;

             
            end % end NS cue loop
      end %end if NS ~nan conditional 
        %get the mean response to the DS for this session
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue, 3);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple, 3);
               
   end %end session loop
end %end subject loop
%% Calculate shifted timestamps for licks relative to PE (for timelocking to PE)
% Since we know the PE latency for each trial and have timestamps for licks
% relative to cue onset, we calculate timestamps for licks relative to PE
% as loxRel-PElatency

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj}); 
    for session= 1:numel(currentSubj)
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
        if DSloxCount >0
                subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSpoxRel= currentSubj(session).behavior.loxDSpoxRel;
        else 
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSpoxRel= [];
        end
        
        if NSloxCount >0
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSpoxRel= currentSubj(session).behavior.loxNSpoxRel;
        else
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSpoxRel=[];
        end
    end % end session loop
end% end subj loop


%% TIMELOCK TO FIRST PE AFTER DS (when sucrose should be dispensed)
%DS trials where animal was in port at cue onset are excluded

disp('conducting peri-DSpox analysis');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed

        %get the DS cues
        DSselected= currentSubj(session).DS;  

       
        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
                
        DSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS)) = nan;

        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        DSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS)) = nan;
        
        clear cutTime %clear between sessions to prevent spillover
        
        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

        DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

       
       for cue = 1:numel(DSselected)
            
           if ~isnan(DSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch
               
               
                 %find the minimum PE timestamp during the cue epoch (this is the 1st pe)
                firstPox=[];
                firstPoxind=[];
                firstPox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS{cue});

                %use interp to find closest timestamp in cutTime to this firstPox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstPox = interp1(cutTime,cutTime, firstPox, 'nearest');

                %get the index of this timestamp in cutTime
                firstPoxind= find(cutTime==firstPox);
                
                
                
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstPoxind-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstPoxind+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)
            
            
            if preEventTime< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****firstPoxdS ', num2str(cue), ' too close to beginning, continueing out'));
                DSskipped= DSskipped+1;
                DSselected(cue)= nan; %remove this trial from the selected list (otherwise later code may try to index it)
                continue
            end

            if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                disp(strcat('****firstPoxDS cue ', num2str(cue), ' too close to end, continueing out'));
                DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
                DSselected(cue)= nan; %remove this trial from the selected list (otherwise later code may try to index it)
                continue %continue out of the loop and move onto the next DS cue
            end

            % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %we'll retrieve the baselines calculated when we timelocked to
            %DS, so our z score is relative to a baseline prior to any
            %cue-related activity
            %blueA
            baselineMeanblue= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanblue(1,cue); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdblue(1,cue); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanpurple(1,cue); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdpurple(1,cue); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periDS field
           
%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue(:,:,cue)= currentSubj(session).reblue(preEventTime:postEventTime);
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple(:,:,cue)= currentSubj(session).repurple(preEventTime:postEventTime);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue(:,:,cue)= (((currentSubj(session).reblue(preEventTime:postEventTime))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTime:postEventTime))- baselineMeanpurple))/(baselineStdpurple);
            
           elseif isnan(DSselected(cue)) %if there are no valid pe this session(e.g. on extinction days), make nan (otherwise might skip & fill in with 0s)
               subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSselected(cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple(1:periCueFrames+1,1,cue)= nan;
           end
           
           %save DSpox data
                if ~isnan(DSselected(cue))
                subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPox(cue,1)= firstPox;
                subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(cue,1)= firstPoxind;%index in cut time
                else
                subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPox(cue,1)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(cue,1)= nan;    
                end
       
                  

       end %end DSselected loop
                   
       %save selected trials for later
       subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSselected= DSselected;

            %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to 1st PE 

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple, 3); 

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple, 3);
           
       
   end %end session loop
end %end subject loop


%% TIMELOCK TO FIRST PE AFTER NS (no sucrose)


disp('conducting peri-NSpox analysis');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed

       if currentSubj(session).trainStage < 5
             subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= [];
             subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPoxind=[];
             subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox=[];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean = [];
       elseif ~isempty(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS) % && currentSubj(session).trainStage >= 5 %can only run for sessions that have NS data
        
                %intialize
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPoxind=[];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox=[];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean = [];
                   
           
           
        %get the NS cues
        NSselected= currentSubj(session).NS;  

       
        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortNS that
        %have a non-nan value and use these to exclude NS trials from this
        %analysis (we'll make them nan)
                
        NSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS)) = nan;

        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        NSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS)) = nan;
        
        clear cutTime %clear between sessions to prevent spillover
        
        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

        NSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

       
       for cue = 1:numel(NSselected)
            
           if isnan(NSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch, but save empty arrays
               
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue(1:periCueFrames+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple(1:periCueFrames+1,1,cue)= nan;

                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue(1:periCueFrames+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple(1:periCueFrames+1,1,cue)= nan;


              
           else %if this is a selected NS
               
                 %find the minimum PE timestamp during the cue epoch (this is the 1st pe)
                firstPox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS{cue});
             
                %use interp to find closest timestamp in cutTime to this firstPox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstPox = interp1(cutTime,cutTime, firstPox, 'nearest');

                %get the index of this timestamp in cutTime
                firstPoxind= find(cutTime==firstPox);
                
               
                
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstPoxind-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstPoxind+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTime< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****firstPoxNS ', num2str(cue), ' too close to beginning, continueing out'));
                NSskipped= NSskipped+1;
            continue
            end

            if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
            disp(strcat('****firstPoxDS cue ', num2str(cue), ' too close to end, continueing out'));
            NSskipped= NSskipped+1;  %iterate the counter for skipped DS cues
            continue %continue out of the loop and move onto the next DS cue
            end

              % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %we'll retrieve the baselines calculated when we timelocked to
            %DS, so our z score is relative to a baseline prior to any
            %cue-related activity
            %blueA
            baselineMeanblue= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanblue(1,cue); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdblue(1,cue); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanpurple(1,cue); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdpurple(1,cue); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periNSpox field

            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= NSselected;
            
%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue(:,:,cue)= currentSubj(session).reblue(preEventTime:postEventTime);
            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple(:,:,cue)= currentSubj(session).repurple(preEventTime:postEventTime);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue(:,:,cue)= (((currentSubj(session).reblue(preEventTime:postEventTime))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTime:postEventTime))- baselineMeanpurple))/(baselineStdpurple);

                %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to 1st PE 

            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple, 3); 

            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple, 3);
           end
           
           %save NSlox data
                if ~isnan(NSselected(cue))
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox(cue,1)= firstPox;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPoxind(cue,1)= firstPoxind;%index in cut time
                elseif isnan(NSselected(cue))
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox(cue,1)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPoxind(cue,1)= nan
                end
                
       end %end cue loop
       end %end stage conditional
   end %end session loop
end %end subject loop

%% TIMELOCK TO FIRST LICK AFTER DS 
%DS trials where animal was in port at cue onset are excluded

disp('conducting peri-DS first lox analysis');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed

        %get the DS cues
        DSselected= currentSubj(session).DS;  

       
        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
                
        DSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS)) = nan;

        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.loxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        DSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS)) = nan;
        
        clear cutTime %clear between sessions to prevent spillover
        
        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

        DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

       
       for cue = 1:numel(DSselected)
            
           if ~isnan(DSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch
               
               
                 %find the minimum PE timestamp during the cue epoch (this is the 1st pe)
                firstLox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS{cue});
             
                %use interp to find closest timestamp in cutTime to this firstLox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstLox = interp1(cutTime,cutTime, firstLox, 'nearest');

                %get the index of this timestamp in cutTime
                firstLoxind= find(cutTime==firstLox);
                
                
               
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstLoxind-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstLoxind+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTime< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****firstLoxdS ', num2str(cue), ' too close to beginning, continueing out'));
                DSskipped= DSskipped+1;
                DSselected(cue)= nan; %remove this trial from the selected list (otherwise later code may try to index it)
                continue
            end

            if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                disp(strcat('****firstLoxDS cue ', num2str(cue), ' too close to end, continueing out'));
                DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
                DSselected(cue)= nan; %remove this trial from the selected list (otherwise later code may try to index it)
                continue %continue out of the loop and move onto the next DS cue
            end

            % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %we'll retrieve the baselines calculated when we timelocked to
            %DS, so our z score is relative to a baseline prior to any
            %cue-related activity
            %blueA
            baselineMeanblue= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanblue(1,cue); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdblue(1,cue); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanpurple(1,cue); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple= subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdpurple(1,cue); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periDS field

%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue(:,:,cue)= currentSubj(session).reblue(preEventTime:postEventTime);
            subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple(:,:,cue)= currentSubj(session).repurple(preEventTime:postEventTime);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue(:,:,cue)= (((currentSubj(session).reblue(preEventTime:postEventTime))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTime:postEventTime))- baselineMeanpurple))/(baselineStdpurple);
             
           
           
           elseif isnan(DSselected(cue)) %if there are no valid licks this session(e.g. on extinction days), make nan (otherwise might skip & fill in with 0s)
               subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSselected(cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue(1:periCueFrames+1,1,cue)= nan;
               subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple(1:periCueFrames+1,1,cue)= nan;
           end
           
           %save first Lox data 
                if ~isnan(DSselected(cue))
                  subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLox(cue,1)= firstLox;
                  subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(cue,1)= firstLoxind;%index in cut time
                  else
                  subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLox(cue,1)= nan;
                  subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(cue,1)= nan;    
                 end
            
        end %end DSselected loop

        %save selected trials for later access
        subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSselected= DSselected;
        
            %get the mean response to the DS for this session
        subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to 1st PE 

        subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSloxpurple, 3); 

        subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxblue, 3);

        subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periDSlox.DSzloxpurple, 3);

       
   end %end session loop
end %end subject loop

%% TIMELOCK TO FIRST LICK AFTER NS (no sucrose)


disp('conducting peri-NS lox analysis');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed

         if currentSubj(session).trainStage < 5
             subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSselected= [];
             subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLoxind=[];
             subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurpleMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurpleMean = [];
       elseif ~isempty(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS) % && currentSubj(session).trainStage >= 5 %can only run for sessions that have NS data
        
                %intialize
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSselected= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLoxind=[];
                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurpleMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurpleMean = [];
     
        NSselected= currentSubj(session).NS;  

       
        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortNS that
        %have a non-nan value and use these to exclude NS trials from this
        %analysis (we'll make them nan)
                
        NSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS)) = nan;

        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.loxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        NSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.loxNS)) = nan;
        
        clear cutTime %clear between sessions to prevent spillover
        
        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

        NSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

       
       for cue = 1:numel(NSselected)
            
           if isnan(NSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch, but save empty arrays
               
                
                
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue(1:periCueFrames+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple(1:periCueFrames+1,1,cue)= nan;

                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue(1:periCueFrames+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple(1:periCueFrames+1,1,cue)= nan;
% 
%                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSselected= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblueMean(1:periCueFrames+1,1,cue) = nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurpleMean(1:periCueFrames+1,1,cue) = nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblueMean(1:periCueFrames+1,1,cue) = nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurpleMean(1:periCueFrames+1,1,cue) = nan;
                
           else %if this is a selected NS
               
                 %find the minimum PE timestamp during the cue epoch (this is the 1st pe)
                firstLox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.loxNS{cue});
             
                %use interp to find closest timestamp in cutTime to this firstLox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstLox = interp1(cutTime,cutTime, firstLox, 'nearest');

                %get the index of this timestamp in cutTime
                firstLoxind= find(cutTime==firstLox);
                 
                
                
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstLoxind-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstLoxind+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTime< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****firstLoxNS ', num2str(cue), ' too close to beginning, continueing out'));
                NSskipped= NSskipped+1;
            continue
            end

            if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
            disp(strcat('****firstLoxDS cue ', num2str(cue), ' too close to end, continueing out'));
            NSskipped= NSskipped+1;  %iterate the counter for skipped DS cues
            continue %continue out of the loop and move onto the next DS cue
            end

              % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %we'll retrieve the baselines calculated when we timelocked to
            %DS, so our z score is relative to a baseline prior to any
            %cue-related activity
            %blueA
            baselineMeanblue= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanblue(1,cue); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdblue(1,cue); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanpurple(1,cue); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple= subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdpurple(1,cue); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periNS field

            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSselected= NSselected;

%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue(:,:,cue)= currentSubj(session).reblue(preEventTime:postEventTime);
            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple(:,:,cue)= currentSubj(session).repurple(preEventTime:postEventTime);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue(:,:,cue)= (((currentSubj(session).reblue(preEventTime:postEventTime))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTime:postEventTime))- baselineMeanpurple))/(baselineStdpurple);
 
           end
           
           %save
                if ~isnan(NSselected(cue))
                  subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox(cue,1)= firstLox;
                  subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLoxind(cue,1)= firstLoxind;%index in cut time
                elseif isnan(NSselected(cue))
                  subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox(cue,1)= nan;
                  subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLoxind(cue,1)= NaN;    
                end
                
       end %end DSselected loop
       end %end NS conditional
       
                 %get the mean response to the NS for this session
            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to 1st PE 

            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSloxpurple, 3); 

            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblueMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurpleMean = nanmean(subjDataAnalyzed.(subjects{subj})(session).periNSlox.NSzloxpurple, 3);
       
   end %end session loop
end %end subject loop




subjectsAnalyzed = fieldnames(subjDataAnalyzed); %now, let's save an array containing all of the analyzed subject IDs (may be useful later if we decide to exclude subjects from analysis)