%% ~~~Event-Triggered Analyses ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%In these sections, we will do an event-triggered analyses by extracting data 
%from the photometry traces immediately surrounding relevant behavioral events (e.g. cue onset, port entry, lick)
%To do so, we'll find the onset timestamp for each event (eventTime) and use this
%timestamp to extract photometry data surrounding it
%(preEventTime:postEventTime). This will be saved to the subjDataAnalyzed
%struct. 


%here we are establishing some variables for our event triggered-analysis
periCueTime = 10;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  

slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


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
            preEventTimeDS = DSonset-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTimeDS = DSonset+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

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
            baselineMeanblue=mean(currentSubj(session).reblue((DSonset-slideTime):DSonset)); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue=std(currentSubj(session).reblue((DSonset-slideTime):DSonset)); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple=mean(currentSubj(session).repurple((DSonset-slideTime):DSonset)); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple=std(currentSubj(session).repurple((DSonset-slideTime):DSonset)); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periDS field

            subjDataAnalyzed.(subjects{subj})(session).periDS.DS(cue) = currentSubj(session).DS(cue); %this way only included cues are saved

            subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeDS:postEventTimeDS);
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeDS:postEventTimeDS);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeDS:postEventTimeDS))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeDS:postEventTimeDS))- baselineMeanpurple))/(baselineStdpurple);

            
            %dff - *******Relies upon previous photobleaching/baseline section
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSbluedff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff(preEventTimeDS:postEventTimeDS);
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpledff(:,:,cue)= subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff(preEventTimeDS:postEventTimeDS);

            
                %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple, 3);
            
            %lets save the baseline mean and std used for z score calc- so
            %that we can use this same baseline for other analyses
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanblue(1,cue)= baselineMeanblue;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdblue(1,cue)= baselineStdblue;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineMeanpurple(1,cue)= baselineMeanpurple;
            subjDataAnalyzed.(subjects{subj})(session).periDS.baselineStdpurple(1,cue)= baselineStdpurple;

        end %end DS cue loop
   end %end session loop
end %end subject loop
        
%% TIMELOCK TO NS
    %Same approach as above, but for NS; done a bit differently because not every session will have the NS
        disp(strcat('running NS-triggered analysis subject_',  subjects{subj}));

for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct

       clear cutTime  %this is cleared between sessions to prevent spillover
       
       cutTime= currentSubj(session).cutTime; %save this as an array, immensely speeds things up because we have to go through each timestamp to find the closest one to the cues

  
      NSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

%       disp(strcat('running NS-triggered analysis subject ', num2str(subj), '/', num2str(numel(subjects)), ' session ', num2str(session), '/', num2str(numel(currentSubj))));

      if isnan(currentSubj(session).NS)|currentSubj(session).trainStage  < 5  %If there's no NS present, save data as empty arrays
          
        subjDataAnalyzed.(subjects{subj})(session).periNS.NS = [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.periNSwindow= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue=[]; 
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple=[]; 

        %get the mean response to the DS for this session
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSblueMean=[]; 
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpleMean=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean=[]; 

        subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean= [];
        
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSbluedff= [];
        subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpledff= [];

        subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanblue=[];
        subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanpurple=[];
        
        
      else %if the NS is present on this session, do the analysis and save results

            for cue=1:length(currentSubj(session).NS) %NS CUES %For each NS cue, conduct event-triggered analysis of data surrounding that cue's onset
                
                NSonset = find(cutTime==currentSubj(session).NSshifted(cue,1)); %get the corresponding cutTime index of the NS timestamp


                %define the frames (datapoints) around each cue to analyze
                preEventTimeNS = NSonset-periCueFrames; %earliest timepoint to examine is the shifted NS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
                postEventTimeNS = NSonset+periCueFrames; %latest timepoint to examine is the shifted NS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)

               if preEventTimeNS< 1 %If cue is too close to beginning, skip over it
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
                baselineMeanblue=mean(currentSubj(session).reblue((NSonset-slideTime):NSonset)); %baseline mean blue 10s prior to DS onset for boxA
                baselineStdblue=std(currentSubj(session).reblue((NSonset-slideTime):NSonset)); %baseline stdDev blue 10s prior to DS onset for boxA
                %purpleA
                baselineMeanpurple=mean(currentSubj(session).repurple((NSonset-slideTime):NSonset)); %baseline mean purple 10s prior to DS onset for boxA
                baselineStdpurple=std(currentSubj(session).repurple((NSonset-slideTime):NSonset)); %baseline stdDev purple 10s prior to DS onset for boxA

                %save the data in the subjDataAnalyzed struct under the periNS field
                
                subjDataAnalyzed.(subjects{subj})(session).periNS.NS(cue)= currentSubj(session).NS(cue); %this way only analyzed cues are included
                
                subjDataAnalyzed.(subjects{subj})(session).periNS.periNSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeNS:postEventTimeNS);
                
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeNS:postEventTimeNS);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeNS:postEventTimeNS);
                    %z score calculation
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeNS:postEventTimeNS))-baselineMeanblue))/(baselineStdblue);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeNS:postEventTimeNS))- baselineMeanpurple))/(baselineStdpurple);

                     %dff - *******Relies upon previous photobleaching/baseline section
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSbluedff(:,:,cue)= (subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff(preEventTimeNS:postEventTimeNS));
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpledff(:,:,cue)= (subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff(preEventTimeNS:postEventTimeNS));

                
                    %get the mean response to the DS for this session
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue, 3);
                subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple, 3);
                

                %lets save the baseline mean and std used for z score calc- so
                %that we can use this same baseline for other analyses
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanblue(1,cue)= baselineMeanblue;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdblue(1,cue)= baselineStdblue;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineMeanpurple(1,cue)= baselineMeanpurple;
                subjDataAnalyzed.(subjects{subj})(session).periNS.baselineStdpurple(1,cue)= baselineStdpurple;

             
            end % end NS cue loop
      end %end if NS ~nan conditional 
   end %end session loop
end %end subject loop

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
                firstPox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS{cue});
             
                %use interp to find closest timestamp in cutTime to this firstPox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstPox = interp1(cutTime,cutTime, firstPox, 'nearest');

                %get the index of this timestamp in cutTime
                firstPoxind= find(cutTime==firstPox);
                
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstPoxind-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstPoxind+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTime< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****firstPoxdS ', num2str(cue), ' too close to beginning, continueing out'));
                DSskipped= DSskipped+1;
                continue
            end

            if postEventTime> length(currentSubj(session).cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                disp(strcat('****firstPoxDS cue ', num2str(cue), ' too close to end, continueing out'));
                DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
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

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSselected= DSselected;

%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue(:,:,cue)= currentSubj(session).reblue(preEventTime:postEventTime);
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple(:,:,cue)= currentSubj(session).repurple(preEventTime:postEventTime);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue(:,:,cue)= (((currentSubj(session).reblue(preEventTime:postEventTime))-baselineMeanblue))/(baselineStdblue); 
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTime:postEventTime))- baselineMeanpurple))/(baselineStdpurple);

                %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to 1st PE 

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSpoxpurple, 3); 

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblueMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurpleMean = mean(subjDataAnalyzed.(subjects{subj})(session).periDSpox.DSzpoxpurple, 3);
           end
       
       end %end DSselected loop
       
   end %end session loop
end %end subject loop


%% TIMELOCK TO FIRST PE AFTER NS (no sucrose)


disp('conducting peri-NSpox analysis');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed

       if currentSubj(session).trainStage < 5
             subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple= [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean = [];
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean = [];
       elseif ~isempty(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS) % && currentSubj(session).trainStage >= 5 %can only run for sessions that have NS data
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
               
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue(1:periCueFrames*2+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple(1:periCueFrames*2+1,1,cue)= nan;

                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue(1:periCueFrames*2+1,1,cue)= nan;
                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple(1:periCueFrames*2+1,1,cue)= nan;

%                subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSselected= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblue= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurple= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblue= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurple= [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxblueMean = [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSpoxpurpleMean = [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxblueMean = [];
%                 subjDataAnalyzed.(subjects{subj})(session).periNSpox.NSzpoxpurpleMean = [];
%                 
              
           else %if this is a selected NS
               
                 %find the minimum PE timestamp during the cue epoch (this is the 1st pe)
                firstPox= min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS{cue});
             
                %use interp to find closest timestamp in cutTime to this firstPox ( TODO: or we could add a timestamp and interp the photometry values?)
                firstPox = interp1(cutTime,cutTime, firstPox, 'nearest');

                %get the index of this timestamp in cutTime
                firstPoxind= find(cutTime==firstPox);
                
            %define the frames (datapoints) around each cue to analyze
            preEventTime = firstPoxind-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTime = firstPoxind+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

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

            %save all of the following data in the subjDataAnalyzed struct under the periNS field

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
       
       end %end DSselected loop
       end %end NS conditional
   end %end session loop
end %end subject loop





subjectsAnalyzed = fieldnames(subjDataAnalyzed); %now, let's save an array containing all of the analyzed subject IDs (may be useful later if we decide to exclude subjects from analysis)