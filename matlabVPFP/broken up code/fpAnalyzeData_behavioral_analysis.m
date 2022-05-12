%% ~~~Behavioral Analyses ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

   end %end session loop
   
% %   % %    %visualization
% %    figure(figureCount);
% %    figureCount= figureCount+1;
% %    
% %    for currentBout = 1:numel(currentSubj(session).lickBouts)
% %        hold on;
% %        title('lick bout # over time');
% %        scatter(currentSubj(session).lickBouts{currentBout},ones(size(currentSubj(session).lickBouts{currentBout}))*currentBout);
% %    end
% %    
end %end subject loop


%% Identify PEs and licks occuring during the DS 
%DP updated 3/10/22 no longer shifting timestamps/relying on cutTime as index... just using raw timestamps. Using fp_trialEventID function
 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    
    for session= 1:numel(currentSubjAnalyzed)

        %First, let's establish the cue duration based on training stage
        if currentSubj(session).trainStage == 1
            cueLength= 60;%*fs; %60s on stage 1, multiply by fs to get #frames
        elseif currentSubj(session).trainStage ==2
            cueLength= 30;%*fs;
        elseif currentSubj(session).trainStage ==3
            cueLength= 20;%*fs;
        else %on subsequent stages, cueLength is 10s
            cueLength =10;%*fs; 
        end

        preBaselineTimeS= 0;
        postBaselineTimeS= cueLength;
        
        %--PEs
        baselineEvent= 'currentSubj(session).DS';
        eventTimeLock= 'currentSubj(session).pox';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxDSrel= eventOnsetsRel;
        
        %--PORT EXIT (out)
                
        baselineEvent= 'currentSubj(session).DS';
        eventTimeLock= 'currentSubj(session).out';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.outDS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.outDSrel= eventOnsetsRel;
        
        
        %--LICKS
        baselineEvent= 'currentSubj(session).DS';
        eventTimeLock= 'currentSubj(session).lox';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSrel= eventOnsetsRel;
              
        %--LICK BOUTS
        baselineEvent= 'currentSubj(session).DS';
        eventTimeLock= 'currentSubjAnalyzed(session).behavior.lickBouts';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDSrel= eventOnsetsRel;        
    end 
    
end


%% Identify PEs and licks occuring during the NS 
%DP updated 3/10/22 no longer shifting timestamps/relying on cutTime as index... just using raw timestamps. Using fp_trialEventID function
 
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});

    
    for session= 1:numel(currentSubjAnalyzed)

        %First, let's establish the cue duration based on training stage
        if currentSubj(session).trainStage == 1
            cueLength= 60;%*fs; %60s on stage 1, multiply by fs to get #frames
        elseif currentSubj(session).trainStage ==2
            cueLength= 30;%*fs;
        elseif currentSubj(session).trainStage ==3
            cueLength= 20;%*fs;
        else %on subsequent stages, cueLength is 10s
            cueLength =10;%*fs; 
        end

        preBaselineTimeS= 0;
        postBaselineTimeS= cueLength;
        
        %--PEs
        baselineEvent= 'currentSubj(session).NS';
        eventTimeLock= 'currentSubj(session).pox';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.poxNSrel= eventOnsetsRel;
        
        %--PORT EXIT (out)
                
        baselineEvent= 'currentSubj(session).NS';
        eventTimeLock= 'currentSubj(session).out';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.outNS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.outNSrel= eventOnsetsRel;
        
        
        %--LICKS
        baselineEvent= 'currentSubj(session).NS';
        eventTimeLock= 'currentSubj(session).lox';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxNS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSrel= eventOnsetsRel;
              
        %--LICK BOUTS
        baselineEvent= 'currentSubj(session).NS';
        eventTimeLock= 'currentSubjAnalyzed(session).behavior.lickBouts';
        
        [eventOnsets, eventOnsetsRel] = fp_trialEventID(currentSubj, currentSubjAnalyzed, session, baselineEvent, eventTimeLock, preBaselineTimeS, postBaselineTimeS); 

       
        subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsNS= eventOnsets;
        subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsNSrel= eventOnsetsRel;        
    end 
    
end



% 
% %% Identify PEs and licks occuring during the DS 
% 
% %DP updated 3/10/22 no longer shifting timestamps/relying on cutTime as index... just using raw timestamps
% 
% % Here, we'll loop through every cue in every session, finding the cue
% % onset time and the cue's duration. Then, we'll check for PEs and licks
% % that occur during this duration and assign them to that cue.
% 
% %TODO: for licks, maybe not the best way to see licks for a particular reward
% %since it's only getting licks in the cue duration... May be better to
% %collect all licks between the current cue onset and the next cue's onset
% 
% %Parameters
% preCueTime= 5; %t in seconds to examine before cue
% postCueTime= 10; %t in seconds to examine after cue
% 
% preCueFrames= preCueTime*fs; %shouldn't need 'frames' anymore
% postCueFrames= postCueTime*fs; 
% 
% periCueFrames= preCueFrames+postCueFrames;
%  
% slideTime= 10  %change from using cutTime indexing
% 
% disp('classifying events during cue epoch');
% 
% for subj= 1:numel(subjects) %for each subject
%    currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
%   
%    for session = 1:numel(currentSubj) %for each training session this subject completed    
%   
%         clear cutTime poxDS loxDS outDS %this is cleared between sessions to prevent spillover
% 
%         cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues
% 
%            %initialize cell arrays, so they're all the same size for
%             %convenience
%             currentSubj(session).behavior.poxDS= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.poxDSrel= cell(1, numel(currentSubj(session).DS));
%             currentSubj(session).behavior.outDS= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.outDSrel= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.loxDS= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.loxDSrel= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.lickBoutsDS= cell(1,numel(currentSubj(session).DS));
%             currentSubj(session).behavior.lickBoutsDSrel= cell(1,numel(currentSubj(session).DS));
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
%         for cue=1:length(currentSubj(session).DS) %for each DS cue in this session
% 
%             %each entry in DS is a timestamp of the DS onset, let's get its
%             %corresponding index from cutTime and use that to pull
%             %surrounding data
%            
%             %%FLAG~~~~~DSshifted here may be incorrectly IDing events and calculating outcome!!!
%             
% %             DSonset = find(cutTime==currentSubj(session).DSshifted(cue,1));
% %             DSonset = find(cutTime==currentSubj(session).DS(cue,1));
%             DSonset= currentSubj(session).DS(cue,1);
% 
%                      
%           if DSonset + cueLength < numel(cutTime) %make sure cue isn't too close to the end of session  
%                 %find an save pox during the cue duration
%                 poxDScount= 1; %counter for indexing
% 
%                 for i = 1:numel(currentSubj(session).pox) % for every port entry logged during this session
% %                    if (cutTime(DSonset)<currentSubj(session).pox(i)) && (currentSubj(session).pox(i)<cutTime(DSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
%                    if ((DSonset)<currentSubj(session).pox(i)) && (currentSubj(session).pox(i)<(DSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
%                         currentSubj(session).behavior.poxDS{1,cue}(poxDScount,1)= currentSubj(session).pox(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
%                         %save timestamps of lick relative to cue onset
%                         currentSubj(session).behavior.poxDSrel{1,cue}(poxDScount,1)= currentSubj(session).pox(i)-(DSonset);
%                         poxDScount=poxDScount+1; %iterate the counter
%                    end
%                 end
% 
% 
%                 %find and save port exits during the cue 
%                 outDScount= 1;
%                 for i = 1:numel(currentSubj(session).out) % for every port entry logged during this session
%                    if ((DSonset)<currentSubj(session).out(i)) && (currentSubj(session).out(i)<(DSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
%                         currentSubj(session).behavior.outDS{1,cue}(outDScount,1)= currentSubj(session).out(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
%                         currentSubj(session).behavior.outDSrel{1,cue}(outDScount,1)= currentSubj(session).out(i)-(DSonset);
%                         outDScount=outDScount+1; %iterate the counter
%                    end
%                 end
% 
%                 
%                 %find and save licks during the cue duration
%                 loxDScount= 1; %counter for indexing
% 
%                 for i = 1:numel(currentSubj(session).lox) % for every port entry logged during this session %cue onset + cueLength if within cue ; cueonset + periCueFrames if within the heatplot window
%                    if ((DSonset)<currentSubj(session).lox(i)) && (currentSubj(session).lox(i)<(DSonset+cueLength)) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
%                        %save absolute timestamps  
%                        currentSubj(session).behavior.loxDS{1,cue}(loxDScount,1)= currentSubj(session).lox(i); %cell array containing all pox during the cue, empty [] if no licks during the cue
%                         
%                        %save timestamps of lick relative to cue onset
%                        currentSubj(session).behavior.loxDSrel{1,cue}(loxDScount,1)= currentSubj(session).lox(i)-(DSonset);
%                        
%                        loxDScount=loxDScount+1; %iterate the counter
%                    end
%                 end
%                 
%                 
%                   %find and save lickBouts during the cue duration
%                   %looping a bit different because lickBouts organized in cell array
%                 lickBoutDScount= 1; %counter for indexing
%                     
%                 for i = 1:numel(subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts) % for every port entry logged during this session %cue onset + cueLength if within cue ; cueonset + periCueFrames if within the heatplot window
%                     lickBoutsDS= subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}(subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}>(DSonset)& subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i} < (DSonset+cueLength));
%                     if ((DSonset)<subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}) & subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}<(DSonset+cueLength) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
%                        %save absolute timestamps  
%                        currentSubj(session).behavior.lickBoutsDS{1,cue}= lickBoutsDS; %cell array containing all pox during the cue, empty [] if no licks during the cue
%                         
%                        %save timestamps of lick relative to cue onset
%                        currentSubj(session).behavior.lickBoutsDSrel{1,cue}= subjDataAnalyzed.(subjects{subj})(session).behavior.lickBouts{i}-(DSonset);
%                        
%                        lickBoutDScount=lickBoutDScount+1; %iterate the counter
%                    end
%                 end
%                 
%                                
%           end %end cue too close to end conditional
%         end %end cue loop
%                
%             subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS= currentSubj(session).behavior.poxDS;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.poxDSrel= currentSubj(session).behavior.poxDSrel;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.outDS= currentSubj(session).behavior.outDS;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.outDSrel= currentSubj(session).behavior.outDSrel;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.loxDS= currentSubj(session).behavior.loxDS;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.loxDSrel= currentSubj(session).behavior.loxDSrel;
%             
%             subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDS= currentSubj(session).behavior.lickBoutsDS;
%             subjDataAnalyzed.(subjects{subj})(session).behavior.lickBoutsDSrel= currentSubj(session).behavior.lickBoutsDSrel;
% 
% 
%    end %end session loop
%      
% end %end subject loop
% 
% %% Identify PEs and licks occuring during the NS 
% 
% % Here, we'll loop through every cue in every session, finding the cue
% % onset time and the cue's duration. Then, we'll check for PEs and licks
% % that occur during this duration and assign them to that cue.
% 
% disp('classifying events during NS cue epoch');
% 
% for subj= 1:numel(subjects) %for each subject
%    currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
%   
%    for session = 1:numel(currentSubj) %for each training session this subject completed    
%   
%         clear cutTime poxNS loxNS outNS %this is cleared between sessions to prevent spillover
% 
%         cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues
% 
%            %initialize cell arrays, so they're all the same size for
%             %convenience
%             currentSubj(session).behavior.poxNS= cell(1,numel(currentSubj(session).NS));
%             currentSubj(session).behavior.poxNSrel= cell(1,numel(currentSubj(session).NS));
%             currentSubj(session).behavior.outNS= cell(1,numel(currentSubj(session).NS));
%             currentSubj(session).behavior.outNSrel= cell(1,numel(currentSubj(session).NS));
%             currentSubj(session).behavior.loxNS= cell(1,numel(currentSubj(session).NS));
%             currentSubj(session).behavior.loxNSrel= cell(1,numel(currentSubj(session).NS));
% 
% 
%         %First, let's establish the cue duration based on training stage
%         if currentSubj(session).trainStage == 1
%             cueLength= 60*fs; %60s on stage 1, multiply by fs to get #frames
%         elseif currentSubj(session).trainStage ==2
%             cueLength= 30*fs;
%         elseif currentSubj(session).trainStage ==3
%             cueLength= 20*fs;
%         else %on subsequent stages, cueLength is 10s
%             cueLength =10*fs; 
%         end
%         
%         if ~isnan(currentSubj(session).NS) %can only run if NS data is present in session        
%         
%             for cue=1:length(currentSubj(session).NS) %for each NS cue in this session
% 
%                 %each entry in NS is a timestamp of the NS onset, let's get its
%                 %corresponding index from cutTime and use that to pull
%                 %surrounding data
%                         %~~FLAG NSshifted
%                 NSonset = find(cutTime==currentSubj(session).NSshifted(cue,1));
% 
% 
%                 %find an save pox during the cue duration
%                 poxNScount= 1; %counter for indexing
%                 for i = 1:numel(currentSubj(session).pox) % for every port entry logged during this session
%                    if (cutTime(NSonset)<currentSubj(session).pox(i)) && (currentSubj(session).pox(i)<cutTime(NSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
%                         currentSubj(session).behavior.poxNS{1,cue}(poxNScount,1)= currentSubj(session).pox(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
%                         
%                         %pox timestamp relative to cue onset
%                         currentSubj(session).behavior.poxNSrel{1,cue}(poxNScount,1)= currentSubj(session).pox(i)-cutTime(NSonset);
%                         poxNScount=poxNScount+1; %iterate the counter
%                    end
%                 end
% 
% 
%                 %find and save port exits during the cue
%                 outNScount= 1;
%                 for i = 1:numel(currentSubj(session).out) % for every port entry logged during this session
%                    if (cutTime(NSonset)<currentSubj(session).out(i)) && (currentSubj(session).out(i)<cutTime(NSonset+cueLength)) %if the port entry occurs between this cue's onset and this cue's onset, assign it to this cue 
%                         currentSubj(session).behavior.outNS{1,cue}(outNScount,1)= currentSubj(session).out(i); %cell array containing all pox during the cue, empty [] if no pox during the cue
%                         
%                         %out timestamp relative to cue onset
%                         currentSubj(session).behavior.outNSrel{1,cue}(outNScount,1)= currentSubj(session).out(i)-cutTime(NSonset);
%                         outNScount=outNScount+1; %iterate the counter
%                    end
%                 end
% 
% 
%                 %find and save licks during the cue duration
%                 loxNScount= 1; %counter for indexing
% 
%                 for i = 1:numel(currentSubj(session).lox) % for every port entry logged during this session
%                    if (cutTime(NSonset)<currentSubj(session).lox(i)) && (currentSubj(session).lox(i)<cutTime(NSonset+postCueFrames)) %if the lick occurs between this cue's onset and this cue's onset, assign it to this cue 
%                        %absolute lick timestamps 
%                        currentSubj(session).behavior.loxNS{1,cue}(loxNScount,1)= currentSubj(session).lox(i); %cell array containing all pox during the cue, empty [] if no licks during the cue
%                         
%                        %lick timestamp relative to cue onset
%                        currentSubj(session).behavior.loxNSrel{1,cue}(loxNScount,1)= currentSubj(session).lox(i)-cutTime(NSonset);
%                        loxNScount=loxNScount+1; %iterate the counter
%                    end
%                 end
% 
%             end %end cue loop            
%         end %end NS conditional
% 
%         %save the results
%         subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS= currentSubj(session).behavior.poxNS';
%         subjDataAnalyzed.(subjects{subj})(session).behavior.poxNSrel= currentSubj(session).behavior.poxNSrel;
%         subjDataAnalyzed.(subjects{subj})(session).behavior.outNS= currentSubj(session).behavior.outNS;
%         subjDataAnalyzed.(subjects{subj})(session).behavior.outNSrel= currentSubj(session).behavior.outNSrel;
%         subjDataAnalyzed.(subjects{subj})(session).behavior.loxNS= currentSubj(session).behavior.loxNS;   
%         subjDataAnalyzed.(subjects{subj})(session).behavior.loxNSrel= currentSubj(session).behavior.loxNSrel;
%         
%         %debugging - view these side by side to verify pox during NS epoch
%         %are being assigned
% %         openvar('currentSubj(session).NS')
% %         openvar('currentSubj(session).pox')
% %         openvar('subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS')
% 
%         
%    end %end session loop
%      
% end %end subject loop
% 
% 

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

%% Calculate DS PE latency and if PE was made in first 10 seconds of DS
%relies on previous behavioral analyses sections
%here, we will calculate latency to enter port on every DS trial

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       %First, let's exclude trials where there was 1) no PE in the cue
       %epoch or 2) animal was already in the port at cue onset
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
       
        % initialize tensecDSpe matrix
        currentSubj(session).tensecDSpe=[];
       
       for cue = 1:numel(DSselected)
            
           if ~isnan(DSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch
                DSonset= DSselected(cue);
                firstPox = min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS{cue}); %min of poxDS= first PE after DS onset
                
                currentSubj(session).DSpeLatency(1,cue)= firstPox-DSonset;
                
                 % if pox made in first 10 sec of DS, tag that trial with a 1, if not, tag with 0
                if firstPox - DSonset <= 10
                    currentSubj(session).tensecDSpe(1,cue)= 1;
                else
                    currentSubj(session).tensecDSpe(1,cue) = 0;
                end
                  
%                  if currentSubj(session).DSpeLatency(1,cue)== 0 || currentSubj(session).DSpeLatency(1,cue)<0
%                     disp(currentSubj(session).DSpeLatency(1,cue) ) %Flag abnomal latency values
%                  end
           else %else if we want to skip over this cue, make latency nan
               currentSubj(session).DSpeLatency(1,cue) = nan;
           end 
           
          
       end %end DSselected loop
       
        currentSubj(session).tensecDSpeRatio=sum(currentSubj(session).tensecDSpe)/numel(currentSubj(session).tensecDSpe);
          
       subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency= currentSubj(session).DSpeLatency;
       subjDataAnalyzed.(subjects{subj})(session).behavior.tensecDSpe= currentSubj(session).tensecDSpe;
       subjDataAnalyzed.(subjects{subj})(session).behavior.tensecDSpeRatio= currentSubj(session).tensecDSpeRatio;
   end %end session loop
     
end %end subject loop


%% Calculate NS PE latency and in PE was made in first 10 sec of NS
%relies on previous behavioral analyses sections
%here, we will calculate latency to enter port on every NS trial

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       %First, let's exclude trials where there was 1) no PE in the cue
       %epoch or 2) animal was already in the port at cue onset
        %get the NS cues
        NSselected= currentSubj(session).NS;  

       
        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortNS that
        %have a non-nan value and use these to exclude NS trials from this
        %analysis (we'll make them nan)
                
        NSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS)) = nan;

        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxNS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that NS =
        %nan
        NSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS)) = nan;
        % initialize tensecNSpe matrix
        currentSubj(session).tensecNSpe=[];
       
       for cue = 1:numel(NSselected)
            
           if ~isnan(NSselected(cue)) %skip over trials where animal was in port at cue onset or did not make a PE during cue epoch
                NSonset= NSselected(cue);
                firstPox = min(subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS{cue}); %min of poxNS= first PE after NS onset
                
                currentSubj(session).NSpeLatency(1,cue)= firstPox-NSonset;
                 % if pox made in first 10 sec of NS, tag that trial with a 1, if not, tag with 0 
                
           if firstPox - NSonset <= 10
                    currentSubj(session).tensecNSpe(1,cue)= 1;
                else
                    currentSubj(session).tensecNSpe(1,cue) = 0;
                end
           else %else if we want to skip over this cue, make latency nan
               currentSubj(session).NSpeLatency(1,cue) = nan;
           end
          
       end %end NSselected loop
       currentSubj(session).tensecNSpeRatio=sum(currentSubj(session).tensecNSpe)/numel(currentSubj(session).tensecNSpe);
          
       subjDataAnalyzed.(subjects{subj})(session).behavior.NSpeLatency= currentSubj(session).NSpeLatency;
       subjDataAnalyzed.(subjects{subj})(session).behavior.tensecNSpe= currentSubj(session).tensecNSpe;
       subjDataAnalyzed.(subjects{subj})(session).behavior.tensecNSpeRatio= currentSubj(session).tensecNSpeRatio;
   end %end session loop
     
end %end subject loop

%% Calculate DS PE ratio
%relies on previous behavioral analyses sections
%here, we will calculate DS pe ratio

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
        DSselected= currentSubj(session).DS;  
       
       
        %We could exclude trials where animal was already in port, but
        %won't due this because they still receive a reward and MEDPC still
        %counts it toward the ratio
%         DSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS)) = nan;

        %Let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        DSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS)) = nan;
        
        currentSubj(session).DSpeRatio= numel(DSselected(~isnan(DSselected)))/numel(currentSubj(session).DS);
       subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeRatio= currentSubj(session).DSpeRatio;

   end %end session loop
      
end %end subj loop

%% Calculate NS PE ratio
%relies on previous behavioral analyses sections
%here, we will calculate NS pe ratio

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
        NSselected= currentSubj(session).NS;  
       
        %We could exclude trials where animal was already in port, but
        %won't due this because they still receive a reward and MEDPC still
        %counts it toward the ratio
%         NSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS)) = nan;

        %Let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxNS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that NS =
        %nan
        NSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS)) = nan;
        
   if ~isnan(currentSubj(session).NS) %if there's NS data present, calculate ratio
            currentSubj(session).NSpeRatio= numel(NSselected(~isnan(NSselected)))/numel(currentSubj(session).NS);
        else % if no NS data present, make ratio nan
            currentSubj(session).NSpeRatio= nan;
        end %end ns conditional
        
       subjDataAnalyzed.(subjects{subj})(session).behavior.NSpeRatio= currentSubj(session).NSpeRatio;
       disp(currentSubj(session).NSpeRatio);
        
   end %end session loop
      
end %end subj loop


%% Determine if behavioral criteria met for each session

criteriaDS= 0.6;
criteriaNS= 0.5;

for subj= 1:numel(subjects)
    
 currentSubj= subjDataAnalyzed.(subjects{subj});
    
    for session= 1:numel(currentSubj)
        
        currentSubj(session).behavior.criteriaSes= 0;
            
        
        %if meet criteria, make 1. else, 0
        if currentSubj(session).trainStage<5
            
            if currentSubj(session).behavior.DSpeRatio >= criteriaDS
                currentSubj(session).behavior.criteriaSes= 1;
            end
            
            
        elseif currentSubj(session).trainStage>=5
            
            if currentSubj(session).behavior.DSpeRatio >= criteriaDS & currentSubj(session).behavior.NSpeRatio <= criteriaNS
                currentSubj(session).behavior.criteriaSes= 1;
            end
        end
        
        subjDataAnalyzed.(subjects{subj})(session).behavior.criteriaSes= currentSubj(session).behavior.criteriaSes;

        
    end %end ses loop
   
    
end %end subj loop

            
