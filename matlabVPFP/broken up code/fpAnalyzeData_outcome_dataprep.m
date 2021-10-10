
%% Lick bout classification

%In this section, we will loop through all licks for each session and
%define lick bouts based on the parameters below. We will use lickInd as a
%counter to keep track of which lick we should be on as we loop through,
%since bout size differs. We will look for licks within a certain interlick
%interval (ILI) of each lick. If we find any, they'll be saved to the bout
%array. We will then keep looking for licks within the ILI of the final
%lick in the bout until we don't find any more, at which point we'll change
%the boutDone conditional to finish evaluating this bout. If this bout
%meets some criteria (e.g. has at least 3 bouts), we will save it and
%advance onto the next bout.

%first let's define some parameters 
interLickThreshold = 1.0; %threshold in seconds between licks beyond which = new bout
licksPerBoutThreshold= 3; %need this many licks to be called a bout

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
      
   
   for session = 1:numel(currentSubj) %for each training session this subject completed
     
      boutCount=1; %counter for bouts
      lickInd= 1; %counter used to skip over licks in the current bout

      bout= []; %array containing licks for the current bout
      lickBouts= {}; %cell array containing lick bouts
       
      boutDone= 0; %logic gate between bouts
      
       for lick = 1:numel(currentSubj(session).lox)
           
           if lickInd< numel(currentSubj(session).lox) %make sure the index is valid (since we're adding to lickInd)
            
               if boutDone ==0 %if we are still filling the current bout
               
             
                       if isempty(bout) %start assigning licks to this bout if bout is empty
                           boutStart= currentSubj(session).lox(lickInd); %-interBoutThreshold;
                           boutEnd= currentSubj(session).lox(lickInd)+interLickThreshold;

                           %extract licks that occur between the bout start and end
                           %because we are using >= boutStart, there will
                           %always be at least 1 lick (the first one at boutStart)
                           %included in the bout... that is why we'll be
                           %using numel(bout>1) as a logic gate instead of
                           %~isempty
                           bout= currentSubj(session).lox(currentSubj(session).lox >=boutStart & currentSubj(session).lox <boutEnd);
                       end
                       
                       if  numel(bout>1) %if the bout has already been started and licks were found beyond the initial lick, continue filling the bout with licks
                           %now use bout(end) to see if there are more
                           %licks within the desired interlick interval
                           %(ili) threshold of the final lick in the bout
                           boutStart= bout(end);
                           boutEnd= bout(end)+interLickThreshold;
                           
                           bout= cat(1, bout,currentSubj(session).lox(currentSubj(session).lox>boutStart & currentSubj(session).lox<boutEnd)); 
                           lickInd = find(currentSubj(session).lox==bout(end)); %as the loop continues, skip over licks already assigned to a bout


                            %if there are no more licks within the desired
                            %ILI, make the bout complete
                            if isempty(currentSubj(session).lox(currentSubj(session).lox>boutStart & currentSubj(session).lox<boutEnd))
                                boutDone=1; 
                            end
                       end
                       
                       if numel(bout)==1 %if there aren't any licks except for the first one in this bout time window, advance lickInd by 1 and make the bout complete
                           lickInd=lickInd+1;
                           boutDone=1;
                       end                      
               end %end boutDone=0 conditional
               
               if boutDone==1 %if this bout is complete, let's save it and advance the boutCount
                   
                       if numel(bout) > licksPerBoutThreshold %Only if this 'bout' contains at least the number of licks required, call it a bout and save it
                          lickBouts{boutCount}= bout;
                          boutCount=boutCount+1;
                          bout=[];
                       
                       else %if there aren't enough licks to consider this a real bout, make bout empty again for the next loop
                           bout=[];
                       end
                       
                       boutDone=0; %reset the boutDone conditional
               end %end boutDone conditional
           end %end index check conditional
       end %end lick loop
       
       currentSubj(session).lickBouts= lickBouts;
     
       %save the lick bout data
       subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts= currentSubj(session).lickBouts;


%       % %    %visualization -- takes long time bc looping thru cell array
%        figure(figureCount);
%        figureCount= figureCount+1;
% 
%        for currentBout = 1:numel(currentSubj(session).lickBouts)
%            hold on;
%            title('lick bout # over time');
%            scatter(currentSubj(session).lickBouts{currentBout},ones(size(currentSubj(session).lickBouts{currentBout}))*currentBout);
%        end

   end %end session loop

end %end subject loop
%% Identify PEs and licks occuring during the DS 

% Here, we'll loop through every cue in every session, finding the cue
% onset time and the cue's duration. Then, we'll check for PEs and licks
% that occur during this duration and assign them to that cue.

%TODO: for licks, maybe not the best way to see licks for a particular reward
%since it's only getting licks in the cue duration... May be better to
%collect all licks between the current cue onset and the next cue's onset

%Parameters
preCueTime= 2; %t in seconds to examine before cue
postCueTime= 5; %t in seconds to examine after cue

preCueFrames= preCueTime*fs;
postCueFrames= postCueTime*fs;

periCueFrames= preCueFrames+postCueFrames;

slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


disp('classifying events during cue epoch');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
  
   for session = 1:numel(currentSubj) %for each training session this subject completed    
  
        clear cutTime poxDS loxDS outDS %this is cleared between sessions to prevent spillover

        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

           %initialize cell arrays, so they're all the same size for
            %convenience
            currentSubj(session).behavior.poxDS= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.poxDSrel= cell(1, numel(currentSubj(session).DS));
            currentSubj(session).behavior.outDS= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.outDSrel= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.loxDS= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.loxDSrel= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.lickBoutsDS= cell(1,numel(currentSubj(session).DS));
            currentSubj(session).behavior.lickBoutsDSrel= cell(1,numel(currentSubj(session).DS));

        %First, let's establish the cue duration based on training stage
        if currentSubj(session).trainStage == 1
            cueLength= 60*fs; %60s on stage 1, multiply by fs to get #frames
        elseif currentSubj(session).trainStage ==2
            cueLength= 30*fs;
        elseif currentSubj(session).trainStage ==3
            cueLength= 20*fs;
        else %on subsequent stages, cueLength is 10s
            cueLength =10*fs; 
        end
        
        for cue=1:length(currentSubj(session).DS) %for each DS cue in this session

            %each entry in DS is a timestamp of the DS onset, let's get its
            %corresponding index from cutTime and use that to pull
            %surrounding data
            DSonset = find(cutTime==currentSubj(session).DSshifted(cue,1));
                     
          if DSonset + cueLength < numel(cutTime) %make sure cue isn't too close to the end of session  
                %find an save pox during the cue duration
                poxDScount= 1; %counter for indexing

                for i = 1:numel(currentSubj(session).pox) % for every port entry logged during this session
                   if (cutTime(DSonset)<currentSubj(session).pox(i)) && (currentSubj(session).pox(i)<cutTime(DSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
                        currentSubj(session).behavior.poxDS{1,cue}(poxDScount,1)= currentSubj(session).pox(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
                        %save timestamps of lick relative to cue onset
                        currentSubj(session).behavior.poxDSrel{1,cue}(poxDScount,1)= currentSubj(session).pox(i)-cutTime(DSonset);
                        poxDScount=poxDScount+1; %iterate the counter
                   end
                end


                %find and save port exits during the cue 
                outDScount= 1;
                for i = 1:numel(currentSubj(session).out) % for every port entry logged during this session
                   if (cutTime(DSonset)<currentSubj(session).out(i)) && (currentSubj(session).out(i)<cutTime(DSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
                        currentSubj(session).behavior.outDS{1,cue}(outDScount,1)= currentSubj(session).out(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
                        currentSubj(session).behavior.outDSrel{1,cue}(outDScount,1)= currentSubj(session).out(i)-cutTime(DSonset);
                        outDScount=outDScount+1; %iterate the counter
                   end
                end


                %find and save licks during the cue duration
                loxDScount= 1; %counter for indexing

                for i = 1:numel(currentSubj(session).lox) % for every port entry logged during this session %cue onset + cueLength if within cue ; cueonset + periCueFrames if within the heatplot window
                   if (cutTime(DSonset)<currentSubj(session).lox(i)) && (currentSubj(session).lox(i)<cutTime(DSonset+postCueFrames)) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
                       %save absolute timestamps  
                       currentSubj(session).behavior.loxDS{1,cue}(loxDScount,1)= currentSubj(session).lox(i); %cell array containing all pox during the cue, empty [] if no licks during the cue
                        
                       %save timestamps of lick relative to cue onset
                       currentSubj(session).behavior.loxDSrel{1,cue}(loxDScount,1)= currentSubj(session).lox(i)-cutTime(DSonset);
                       
                       loxDScount=loxDScount+1; %iterate the counter
                   end
                end
                
                
                  %find and save lickBouts during the cue duration
                  %looping a bit different because lickBouts organized in cell array
                lickBoutDScount= 1; %counter for indexing
                    
                for i = 1:numel(subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts) % for every port entry logged during this session %cue onset + cueLength if within cue ; cueonset + periCueFrames if within the heatplot window
                    lickBoutsDS= subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}(subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}>cutTime(DSonset)& subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i} < cutTime(DSonset+postCueFrames));
                    if (cutTime(DSonset)<subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}) & subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}<cutTime(DSonset+postCueFrames) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
                       %save absolute timestamps  
                       currentSubj(session).behavior.lickBoutsDS{1,cue}= lickBoutsDS; %cell array containing all pox during the cue, empty [] if no licks during the cue
                        
                       %save timestamps of lick relative to cue onset
                       currentSubj(session).behavior.lickBoutsDSrel{1,cue}= subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}-cutTime(DSonset);
                       
                       lickBoutDScount=lickBoutDScount+1; %iterate the counter
                   end
                end
                
                               
          end %end cue too close to end conditional
        end %end cue loop
               
            subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS= currentSubj(session).behavior.poxDS;
            subjDataAnalyzed.(subjects{subj})(session).behavior.poxDSrel= currentSubj(session).behavior.poxDSrel;
            subjDataAnalyzed.(subjects{subj})(session).behavior.outDS= currentSubj(session).behavior.outDS;
            subjDataAnalyzed.(subjects{subj})(session).behavior.outDSrel= currentSubj(session).behavior.outDSrel;
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS= currentSubj(session).behavior.loxDS;
            subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSrel= currentSubj(session).behavior.loxDSrel;
            
            subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDS= currentSubj(session).behavior.lickBoutsDS;
            subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDSrel= currentSubj(session).behavior.lickBoutsDSrel;


   end %end session loop
     
end %end subject loop


%% Identify PEs and licks occuring during the NS 

% Here, we'll loop through every cue in every session, finding the cue
% onset time and the cue's duration. Then, we'll check for PEs and licks
% that occur during this duration and assign them to that cue.

disp('classifying events during NS cue epoch');

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
  
   for session = 1:numel(currentSubj) %for each training session this subject completed    
  
        clear cutTime poxNS loxNS outNS %this is cleared between sessions to prevent spillover

        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

           %initialize cell arrays, so they're all the same size for
            %convenience
            currentSubj(session).behavior.poxNS= cell(1,numel(currentSubj(session).NS));
            currentSubj(session).behavior.poxNSrel= cell(1,numel(currentSubj(session).NS));
            currentSubj(session).behavior.outNS= cell(1,numel(currentSubj(session).NS));
            currentSubj(session).behavior.outNSrel= cell(1,numel(currentSubj(session).NS));
            currentSubj(session).behavior.loxNS= cell(1,numel(currentSubj(session).NS));
            currentSubj(session).behavior.loxNSrel= cell(1,numel(currentSubj(session).NS));


        %First, let's establish the cue duration based on training stage
        if currentSubj(session).trainStage == 1
            cueLength= 60*fs; %60s on stage 1, multiply by fs to get #frames
        elseif currentSubj(session).trainStage ==2
            cueLength= 30*fs;
        elseif currentSubj(session).trainStage ==3
            cueLength= 20*fs;
        else %on subsequent stages, cueLength is 10s
            cueLength =10*fs; 
        end
        
        if ~isnan(currentSubj(session).NS) %can only run if NS data is present in session        
        
            for cue=1:length(currentSubj(session).NS) %for each NS cue in this session

                %each entry in NS is a timestamp of the NS onset, let's get its
                %corresponding index from cutTime and use that to pull
                %surrounding data
                NSonset = find(cutTime==currentSubj(session).NSshifted(cue,1));


                %find an save pox during the cue duration
                poxNScount= 1; %counter for indexing
                for i = 1:numel(currentSubj(session).pox) % for every port entry logged during this session
                   if (cutTime(NSonset)<currentSubj(session).pox(i)) && (currentSubj(session).pox(i)<cutTime(NSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
                        currentSubj(session).behavior.poxNS{1,cue}(poxNScount,1)= currentSubj(session).pox(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
                        
                        %pox timestamp relative to cue onset
                        currentSubj(session).behavior.poxNSrel{1,cue}(poxNScount,1)= currentSubj(session).pox(i)-cutTime(NSonset);
                        poxNScount=poxNScount+1; %iterate the counter
                   end
                end


                %find and save port exits during the cue
                outNScount= 1;
                for i = 1:numel(currentSubj(session).out) % for every port entry logged during this session
                   if (cutTime(NSonset)<currentSubj(session).out(i)) && (currentSubj(session).out(i)<cutTime(NSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
                        currentSubj(session).behavior.outNS{1,cue}(outNScount,1)= currentSubj(session).out(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
                        
                        %out timestamp relative to cue onset
                        currentSubj(session).behavior.outNSrel{1,cue}(outNScount,1)= currentSubj(session).out(i)-cutTime(NSonset);
                        outNScount=outNScount+1; %iterate the counter
                   end
                end


                %find and save licks during the cue duration
                loxNScount= 1; %counter for indexing

                for i = 1:numel(currentSubj(session).lox) % for every port entry logged during this session
                   if (cutTime(NSonset)<currentSubj(session).lox(i)) && (currentSubj(session).lox(i)<cutTime(NSonset+postCueFrames)) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
                       %absolute lick timestamps 
                       currentSubj(session).behavior.loxNS{1,cue}(loxNScount,1)= currentSubj(session).lox(i); %cell array containing all pox during the cue, empty [] if no licks during the cue
                        
                       %lick timestamp relative to cue onset
                       currentSubj(session).behavior.loxNSrel{1,cue}(loxNScount,1)= currentSubj(session).lox(i)-cutTime(NSonset);
                       loxNScount=loxNScount+1; %iterate the counter
                   end
                end

            end %end cue loop            
        end %end NS conditional

        %save the results
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS= currentSubj(session).behavior.poxNS';
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxNSrel= currentSubj(session).behavior.poxNSrel;
        subjDataAnalyzed.(subjects{subj})(session).behavior.outNS= currentSubj(session).behavior.outNS;
        subjDataAnalyzed.(subjects{subj})(session).behavior.outNSrel= currentSubj(session).behavior.outNSrel;
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxNS= currentSubj(session).behavior.loxNS;   
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSrel= currentSubj(session).behavior.loxNSrel;
        
        %debugging - view these side by side to verify pox during NS epoch
        %are being assigned
%         openvar('currentSubj(session).NS')
%         openvar('currentSubj(session).pox')
%         openvar('subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS')

        
   end %end session loop
     
end %end subject loop


%% Identify trials where animal was waiting in port at cue onset

%here, we'll go through all cues from each session, finding the difference
%between the cue onset time and every logged port entry and port exit
%timestamp. We'll find the port entry and port exit that is closest (minimum difference) to the
%cue onset, then we'll compare these two. We will only look in one
%direction (after the cue onset time) by turning any negative differences
%into large positive differences. If the closest Out pulse is closer to the cue onset
%than the closest port entry pulse, then the animal was already in the port
%on that trial

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       clear poxDiffDS outDiffDS poxDiffNS outDiffNS
       
       %loop through DS cues
        for cue = 1:numel(currentSubj(session).DS) %for each DS
            %for each pox timestamp, get the difference between the pox and this DS cue's onset
            for i = 1:numel(currentSubj(session).pox) 
                poxDiffDS(i) = currentSubj(session).pox(i)- currentSubj(session).DS(cue,1);
            end
            
            %get rid of negative values by making them very large
            %this way we're only looking at TTLs after cue onset
            poxDiffDS(poxDiffDS<0) = 99999; 
            
            [~,minPoxInd] = min(poxDiffDS);
                           
            currentSubj(session).pox(minPoxInd);

            for i= 1:numel(currentSubj(session).out)
                outDiffDS(i)= currentSubj(session).out(i)- currentSubj(session).DS(cue,1);
            end

            outDiffDS(outDiffDS<0)= 99999; %make any negative differences very large
            
            %if the closest TTL pulse to cue onset was an out, the animal was in the port already
            if min(outDiffDS)<min(poxDiffDS)
                
                currentSubj(session).inPortDS(1,cue)= cue; %animal was in port on this trial
%                 disp(strcat(subjects{subj}, 'session', num2str(session), '_DS_', num2str(cue), ' inPortDS '));

            else
                currentSubj(session).inPortDS(1,cue)= NaN; %animal was not in port on this trial
            end
            
       end %end DS loop
       
   %Repeat for NS
   
        for cue = 1:numel(currentSubj(session).NS) %for each NS
            
            %for each pox timestamp, get the difference between the pox and this NS cue's onset
            for i = 1:numel(currentSubj(session).pox) 
                poxDiffNS(i) = currentSubj(session).pox(i)- currentSubj(session).NS(cue,1);
            end
            
            %get rid of negative values by making them very large
            %this way we're only looking at TTLs after cue onset
            poxDiffNS(poxDiffNS<0) = 99999; 
            
            [~,minPoxInd] = min(poxDiffNS);
                           
            currentSubj(session).pox(minPoxInd);

            for i= 1:numel(currentSubj(session).out)
                outDiffNS(i)= currentSubj(session).out(i)- currentSubj(session).NS(cue,1);
            end

            outDiffNS(outDiffNS<0)= 99999; %make any negative differences very large
            
            %if the closest TTL pulse to cue onset was an out, the animal was in the port already
            if min(outDiffNS)<min(poxDiffNS)
                
                currentSubj(session).inPortNS(1,cue)= cue;
%                 disp(strcat(subjects{subj}, 'session', num2str(session), '_NS_', num2str(cue), ' inPortNS '));

            else
                currentSubj(session).inPortNS(1,cue)= NaN;
            end
            
       end %end NS loop
       
       
       subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS= currentSubj(session).inPortDS;
       subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS= currentSubj(session).inPortNS;
       
   end %end session loop
end %end subject loop


%% Classify trials by PE outcome
% There are 3 potential outcomes of a trial during the cue epoch we are interested in: 1) rat
% makes a PE 2) rat does not make a PE 3) rat was already in the port

% An animal who was in the port at cue onset can still make PEs afterward,
% so it would be best to classify each trial based on the outcome ahead of
% time and then use this to to index trials based on their PE outcome
% instead of checking each time we want to do it
for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    
    for session= 1:numel(currentSubj)
        DSinPort= []; DSnoPE= []; DSPE= []; %reset between sessions
        NSinPort= []; NSnoPE= []; NSPE= [];

              %Identify trials where animal was in port at trial start,
              %trials with no PE, and trials with a valid PE. For each
              %trial type, loop through trials and get mean
              %cue-elicited response 

                %First, let's get trials where animal was already in port
                DSinPort= find(~isnan(currentSubj(session).behavior.inPortDS));

                %Then, let's get trials where animal did not make a PE during the cue epoch. (cellfun('isempty'))
                DSnoPE = find(cellfun('isempty', currentSubj(session).behavior.poxDS));
                 %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
                 for inPortTrial= DSinPort
                    DSnoPE(DSnoPE==inPortTrial)=[]; %eliminate trials where animal was in port
                 end
                 
             %lastly, get trials with valid PE
             DSPE= find(~cellfun('isempty', currentSubj(session).behavior.poxDS));
              %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
             for inPortTrial= DSinPort
                 DSPE(DSPE==inPortTrial)=[]; %eliminate trials where animal was in port
             end
             
                %Make sure the trial types are all mutually exclusive to prevent errors (intersect() should return empty because no trials should be the same) 
             if ~isempty(intersect(DSinPort,DSnoPE)) || ~isempty(intersect(DSinPort, DSPE)) || ~isempty(intersect(DSnoPE, DSPE))
                disp('~~~~~~~~error: trial types not mutually exclusive');
             end
             
             %Repeat for NS trials
             
             %only run for stages with NS
             if currentSubj(session).trainStage >=5
                 %First, let's get trials where animal was already in port
                    NSinPort= find(~isnan(currentSubj(session).behavior.inPortNS));

                    %Then, let's get trials where animal did not make a PE during the cue epoch. (cellfun('isempty'))
                    NSnoPE = find(cellfun('isempty', currentSubj(session).behavior.poxNS))'; %transpose ' due to shape
                     %additional check here to make sure animal was not in the
                    %port at trial start even if a valid PE exists
                     for inPortTrial= NSinPort
                        NSnoPE(NSnoPE==inPortTrial)=[]; %eliminate trials where animal was in port
                     end

                 %lastly, get trials with valid PE
                 NSPE= find(~cellfun('isempty', currentSubj(session).behavior.poxNS))'; %transpose ' due to shape
                  %additional check here to make sure animal was not in the
                    %port at trial start even if a valid PE exists
                 for inPortTrial= NSinPort
                     NSPE(NSPE==inPortTrial)=[]; %eliminate trials where animal was in port
                 end

                    %Make sure the trial types are all mutually exclusive to prevent errors (intersect() should return empty because no trials should be the same) 
                 if ~isempty(intersect(NSinPort,NSnoPE)) || ~isempty(intersect(NSinPort, NSPE)) || ~isempty(intersect(NSnoPE, NSPE))
                    disp('~~~~~~~~error: trial types not mutually exclusive');
                 end
             end
             
             
             %now save these into the subjDataAnalzyed struct so we can use them later
             %Outcome code: 1= PE during cue epoch, 2= no PE during cue
             %epoch, 3= in port at cue onset
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSoutcome= nan(size(subjData.(subjects{subj})(session).DS));
             
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSoutcome(DSPE)=1;
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSoutcome(DSnoPE)=2;
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSoutcome(DSinPort)= 3;
             
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSoutcome= nan(size(subjData.(subjects{subj})(session).NS));
             
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSoutcome(NSPE)=1;
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSoutcome(NSnoPE)=2;
             subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSoutcome(NSinPort)= 3;
% 
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSinPort= DSinPort';
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSnoPE= DSnoPE';
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.DSPE= DSPE';
%              
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSinPort= NSinPort';
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSnoPE= NSnoPE';
%              subjDataAnalyzed.(subjects{subj})(session).trialOutcome.NSPE= NSPE';

             
    end %end session loop
end% end subj loop

%% Calculate pump onset times (reward delivery)
% While we don't have TTL pulses for pump on, we know when the animal
% enters the port and we know the delay between PE and pump oon, so we can
% calculate pump onset

%This section relies on coding of subjDataAnalyzed.trialOutcome
%1= PE , 2= no PE, 3= in port at cue onset

%   However, we don't have a TTL for pump on. I think the most simple
    %way to address this is to create a new event type in Matlab for
    %Pump on and calculate it on a trial by trial basis in this script.
    %Then, we can go to the stage 8 data specifically and subtract
    %the artificial delays
    
    
    for subj = 1:numel(subjects)
        currentSubj= subjData.(subjects{subj});
        currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
        
        for session= 1:numel(currentSubj)

            peTrial= []; noPEtrial= []; inPortTrial= []; %clear between sessions
            currentSubjAnalyzed(session).reward.pumpOnTime= nan(size(currentSubj(session).DS));
            
           if currentSubj(session).trainStage<=5 %for stages 1:5, no delay between first PE and pump o     
                PEtrial=find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==1); %if this is a PE trial, reward delivered @ first PE
                for thisTrial= 1:numel(PEtrial) %have to loop through this because subjDataAnalyzed.behavior.poxDS is cell array and there doesn't seem to be an easier way to get the 1st value from each cell vectorized
                    currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1); %pump onset = first port entry during DS
                end
                
                noPEtrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==2);%if there was no PE, make nan
                currentSubjAnalyzed(session).reward.pumpOnTime(noPEtrial)= nan; 
                
                inPortTrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==3); %if rat was in port, pump on = cue onset
                currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial)= currentSubj(session).DS(inPortTrial);           
           end %end stage 1:5 
           
             if currentSubj(session).trainStage==6 %for stage 6, 500ms delay between first PE and pump on     
                PEtrial=find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==1); %if this is a PE trial, reward delivered @ first PE
                for thisTrial= 1:numel(PEtrial) %have to loop through this because subjDataAnalyzed.behavior.poxDS is cell array and there doesn't seem to be an easier way to get the 1st value from each cell vectorized
                    currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1)+0.5; %pump onset = first port entry during DS + 500ms
                end
                
                noPEtrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==2);%if there was no PE, make nan
                currentSubjAnalyzed(session).reward.pumpOnTime(noPEtrial)= nan; 
                
                inPortTrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==3); %if rat was in port, pump on = cue onset
                currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial)= currentSubj(session).DS(inPortTrial)+0.5;           
            end %end stage 6
           
            if currentSubj(session).trainStage==7 %for stage 7, 1s delay between first PE and pump on     
                PEtrial=find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==1); %if this is a PE trial, reward delivered @ first PE
                for thisTrial= 1:numel(PEtrial) %have to loop through this because subjDataAnalyzed.behavior.poxDS is cell array and there doesn't seem to be an easier way to get the 1st value from each cell vectorized
                    currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1)+1; %pump onset = first port entry during DS + 1s
                end
                
                noPEtrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==2);%if there was no PE, make nan
                currentSubjAnalyzed(session).reward.pumpOnTime(noPEtrial)= nan; 
                
                inPortTrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==3); %if rat was in port, pump on = cue onset + 1s
                currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial)= currentSubj(session).DS(inPortTrial)+1;           
           end %end stage 7
           
           %TODO: ADD DATE CONDITIONAL HERE AFTER STAGE 8 CODE FIX
           %For stage 8 sessions with compounding delays due to sequential
           %IF statements, delay between PE and pump on varies by pump
            if currentSubj(session).trainStage>=8 %for stage 8+,     

                PEtrial=find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==1); %if this is a PE trial, reward delivered @ first PE
                for thisTrial= 1:numel(PEtrial) %have to loop through this because subjDataAnalyzed.behavior.poxDS is cell array and there doesn't seem to be an easier way to get the 1st value from each cell vectorized
                    if currentSubjAnalyzed(session).reward.DSreward(PEtrial(thisTrial))==1 %if pump 1 stage 8 w errors, delay was 1s + 100ms
                       currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1)+1+0.1; %pump onset = first port entry during DS + delay
                       
                    elseif currentSubjAnalyzed(session).reward.DSreward(PEtrial(thisTrial))==2 %if pump 2 stage 8 w errors, delay was 1s + 200ms
                           currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1)+1+0.2; %pump onset = first port entry during DS + delay
                    
                    
                    elseif currentSubjAnalyzed(session).reward.DSreward(PEtrial(thisTrial))==3 %if pump 1 stage 8 w errors, delay was 1s + 300ms
                           currentSubjAnalyzed(session).reward.pumpOnTime(PEtrial(thisTrial))= currentSubjAnalyzed(session).behavior.poxDS{PEtrial(thisTrial)}(1)+1+0.3; %pump onset = first port entry during DS + delay
                    end
                   
                end
                
                
                noPEtrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==2);%if there was no PE, make nan
                currentSubjAnalyzed(session).reward.pumpOnTime(noPEtrial)= nan; 
                    
                    %Again, stage 8 with errors here pump on will be cue
                    %onset+delay depending on pump
                    
               inPortTrial= find(currentSubjAnalyzed(session).trialOutcome.DSoutcome==3); %if rat was in port, pump on = cue onset + delay
               for thisTrial= 1:numel(inPortTrial) %have to loop through this because subjDataAnalyzed.behavior.poxDS is cell array and there doesn't seem to be an easier way to get the 1st value from each cell vectorized
                    if currentSubjAnalyzed(session).reward.DSreward(inPortTrial(thisTrial))==1 %if pump 1 stage 8 w errors, delay was 1s + 100ms
                       currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial(thisTrial))= currentSubj(session).DS(inPortTrial(thisTrial))+1+0.1; %pump onset = first port entry during DS + delay
                    
                    elseif currentSubjAnalyzed(session).reward.DSreward(inPortTrial(thisTrial))==2 %if pump 2 stage 8 w errors, delay was 1s + 200ms
                           currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial(thisTrial))= currentSubj(session).DS(inPortTrial(thisTrial))+1+0.2; %pump onset = first port entry during DS + delay
                    
                    
                    elseif currentSubjAnalyzed(session).reward.DSreward(inPortTrial(thisTrial))==3 %if pump 1 stage 8 w errors, delay was 1s + 300ms
                           currentSubjAnalyzed(session).reward.pumpOnTime(inPortTrial(thisTrial))= currentSubj(session).DS(inPortTrial(thisTrial))+1+0.3; %pump onset = first port entry during DS + delay
                    end
                   
               end                
           end %end stage 8+
           %Now, let's calculate pump onset relative to cue onset and first PE for each trial (so we can easily plot it later)
           for cue= 1:numel(currentSubj(session).DS)
               currentSubjAnalyzed(session).reward.pumpOnDSrel(cue,1)= currentSubjAnalyzed(session).reward.pumpOnTime(cue)-currentSubj(session).DS(cue);
               if ~isempty(currentSubjAnalyzed(session).behavior.poxDS{cue})
                  currentSubjAnalyzed(session).reward.pumpOnFirstPErel(cue,1)= currentSubjAnalyzed(session).reward.pumpOnTime(cue)-currentSubjAnalyzed(session).behavior.poxDS{cue}(1);
               else 
                   currentSubjAnalyzed(session).reward.pumpOnFirstPErel(cue,1)= nan;
               end
           end %end DS loop
           
           %now save these calculations into subjDataAnalyzed struct
           subjDataAnalyzed.(subjects{subj})(session).reward.pumpOnTime= currentSubjAnalyzed(session).reward.pumpOnTime;
           subjDataAnalyzed.(subjects{subj})(session).reward.pumpOnDSrel= currentSubjAnalyzed(session).reward.pumpOnDSrel;
           subjDataAnalyzed.(subjects{subj})(session).reward.pumpOnFirstPErel= currentSubjAnalyzed(session).reward.pumpOnFirstPErel;
           
        end %end session loop
    end %end subj loop
    