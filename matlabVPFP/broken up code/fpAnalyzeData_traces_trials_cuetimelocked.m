%Here we will plot representative traces of individual trial for each
%animal in each stage

% we will also split up stage 8 trials into their respective pumps


%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

    %initialize/clear arrays between subjects
    currentSubj(1).NSzblueAllTrials= [];
    currentSubj(1).NSzpurpleAllTrials= [];
    currentSubj(1).NSpeLatencyAllTrials= [];

    sesCountA= 1;
    sesCountB= 1;
    sesCountC= 1;
    sesCountD= 1;% D=stage 6
    sesCountE= 1;% E=stage 7
    sesCountF= 1;% F=stage 8 
    
    subjSessA= [];
    subjSessB= [];
    subjSessC= [];
    subjSessD= [];
    subjSessE= [];
    subjSessF= [];
    
    trialAcount= 1;
    trialBcount=1;
    trialCcount=1;
    trialDcount= 1;
    trialEcount=1;
    trialFcount=1;
    
    trialBNScount=1;
    trialCNScount=1;
    trialDNScount=1;
    trialENScount=1;
    trialFNScount=1;
   
    DSloxAllTrialsA = [];
    DSloxAllTrialsB= [];
    DSloxAllTrialsC= [];
    DSloxAllTrialsD = [];
    DSloxAllTrialsE= [];
    DSloxAllTrialsF= [];
    
    NSloxAllTrialsA= [];
    NSloxAllTrialsB= [];
    NSloxAllTrialsC= [];
    NSloxAllTrialsD= [];
    NSloxAllTrialsE= [];
    NSloxAllTrialsF= [];


    for session = 1:numel(currentSubj) %for each training session this subject completed
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= currentSubj(session).periDS.DS;  % all the DS cues

        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
            
        %We have to throw in an extra conditional in case we've excluded
        %cues in our peri cue analysis due to being too close to the
        %beginning or end. Otherwise, we can get an out of range error
        %because the inPortDS array doesn't exclude these cues.
        for inPortTrial = find(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS))
            if inPortTrial < numel(DSselected) 
                DSselected(~isnan(subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS)) = nan;
            end
        end
        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        
        %same here, we need an extra conditional in case cues were excluded
        for noPEtrial = find(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS))
            if noPEtrial < numel(DSselected)
                DSselected(cellfun('isempty', subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS)) = nan;
            end
        end
        
        %this may create some zeros, so let's make those nan as well
        DSselected(DSselected==0) = nan;
        
        %lets convert this to an index of trials with a valid value 
        DSselected= find(~isnan(DSselected));
        
            %Repeat above for NS 
        if ~isempty(currentSubj(session).periNS.NS)
             NSselected= currentSubj(session).periNS.NS;  

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

       
            %lets convert this to an index of trials with a valid value 
            NSselected= find(~isnan(NSselected));
        end %end NS conditional       
            
        
        %gather pump specific data for stage 8
        
        rewardSessionCount= 0; %counter for sessions with valid variable reward data 
                
        if ~isempty(currentSubj(session).reward) %make sure this is a valid stage with multiple rewards
            
            rewardSessionCount= rewardSessionCount+1; %counter for sessions with valid variable reward data 

            
            %first we need to get the z score data surrounding either pump1,
            %pump2, or pump3 DS trials. To do this, we'll use the reward
            %identities (reward.DSreward) as an indidices to get the right DS trials

            indPump1= [];
            indPump2= [];
            indPump3= [];

            
            indPump1= find(currentSubj(session).reward.DSreward==1);
            indPump2= find(currentSubj(session).reward.DSreward==2);
            indPump3= find(currentSubj(session).reward.DSreward==3);

            %collect all z score responses to every single DS across all sessions
            if rewardSessionCount==1 %for first session, initialize 
                
                %now we'll use the reward identity (pump) indices to get only responses to those specific trials 
                currentSubj(1).DSzbluePump1= squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump1)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzbluePump2= squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump2)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzbluePump3= squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump3)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

                currentSubj(1).DSzpurplePump1= squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump1)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpurplePump2= squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump2)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpurplePump3= squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump3)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

                rewardSessionCount= rewardSessionCount+1;
                

            else %add subsequent sessions using cat()
                currentSubj(1).DSzbluePump1 = cat(2, currentSubj(1).DSzbluePump1, squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump1))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzbluePump2 = cat(2, currentSubj(1).DSzbluePump2, squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump2))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzbluePump3 = cat(2, currentSubj(1).DSzbluePump3, squeeze(currentSubj(session).periDS.DSzblue(:,:,indPump3))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)

                currentSubj(1).DSzpurplePump1 = cat(2, currentSubj(1).DSzpurplePump1, squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump1))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpurplePump2 = cat(2, currentSubj(1).DSzpurplePump2, squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump2))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpurplePump3 = cat(2, currentSubj(1).DSzpurplePump3, squeeze(currentSubj(session).periDS.DSzpurple(:,:,indPump3))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                
                rewardSessionCount= rewardSessionCount+1;

% currentSubj(1).DSzpurpleAllTrials = cat(2, currentSubj.DSzpurpleAllTrials, (squeeze(currentSubj(session).periDS.DSzpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
% 
%                 currentSubj(1).NSzblueAllTrials = cat(2, currentSubj.NSzblueAllTrials, (squeeze(currentSubj(session).periNS.NSzblue))); 
%                 currentSubj(1).NSzpurpleAllTrials = cat(2, currentSubj.NSzpurpleAllTrials, (squeeze(currentSubj(session).periNS.NSzpurple))); 

            end
    
        end %end ~isempty reward conditional (alternative to stage conditional)       
        
        
        %Condition A
            if currentSubj(session).trainStage <5
                if sesCountA== 1 
                    currentSubj(1).DSzblueAllTrialsA= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                    currentSubj(1).DSzpurpleAllTrialsA= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                    currentSubj(1).DSpeLatencyAllTrialsA= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                    
%                     currentSubj(1).DSloxAllTrialsA= currentSubj(session).behavior.loxDS{DSselected};
                    if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                        currentSubj(1).NSzblueAllTrialsA= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                        currentSubj(1).NSzpurpleAllTrialsA= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                        currentSubj(1).NSpeLatencyAllTrialsA= currentSubj(session).behavior.NSpeLatency(NSselected); 
                        
                     else
%                        continue %continue if no NS data
                     end
                else %add subsequent sessions using cat()
                    currentSubj(1).DSzblueAllTrialsA = cat(2, currentSubj.DSzblueAllTrialsA, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                    currentSubj(1).DSzpurpleAllTrialsA = cat(2, currentSubj.DSzpurpleAllTrialsA, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                    currentSubj(1).DSpeLatencyAllTrialsA = cat(2,currentSubj(1).DSpeLatencyAllTrialsA,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

%                     currentSubj(1).DSloxAllTrialsA= cat(2,currentSubj(1).DSloxAllTrialsA,currentSubj(session).behavior.loxDS{DSselected});

                    if ~isempty(currentSubj(session).periNS.NS)
                        currentSubj(1).NSzblueAllTrialsA = cat(2, currentSubj.NSzblueAllTrialsA, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                        currentSubj(1).NSzpurpleAllTrialsA = cat(2, currentSubj.NSzpurpleAllTrialsA, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                        currentSubj(1).NSpeLatencyAllTrialsA = cat(2,currentSubj(1).NSpeLatencyAllTrialsA,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                    else
%                         continue %continue if no NS data
                    end
                end %end sesCount conditional

                    % licks
                    currentSubj(1).DSloxAllTrialsA{sesCountA}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset
                
                     %in order to sort licks according to trial by PE latency
                     %later, we need to reshape the lox cell array from nested
                     %{session}{cue} to just {cue}
                      for cue = 1:numel(currentSubj(1).DSloxAllTrialsA{session})
                          DSloxAllTrialsA{trialAcount} = currentSubj(1).DSloxAllTrialsA{session}{cue};
                          trialAcount=trialAcount+1;
                      end           

%                       trialAcount=1; %reset counter
%                       % NS licks
%                     currentSubj(1).NSloxAllTrialsA{session}= currentSubj(session).behavior.loxNSrel(NSselected);
%                     
%                     for cue= 1:numel(currentSubj(1).NSloxAllTrialsA{session})
%                         NSloxAllTrialsA{trialAcount}= currentSubj(1).NSloxAllTrialsA{session}{cue};
%                         trialAcount=trialAcount+1;
%                     end
%               %create structure of all rat trials sorted by latency  
            allSubj(subj).DSzblueAllTrialsA= currentSubj(1).DSzblueAllTrialsA;
            allSubj(subj).DSzpurpleAllTrialsA= currentSubj(1).DSzpurpleAllTrialsA;
            allSubj(subj).DSpeLatencyAllTrialsA= currentSubj(1).DSpeLatencyAllTrialsA;
%             allSubj(subj).NSzblueAllTrialsA= currentSubj(1).NSzblueAllTrialsA;
%             allSubj(subj).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA;
%             allSubj(subj).NSpeLatencyAllTrialsA= currentSubj(1).NSpeLatencyAllTrialsA;

      
                sesCountA= sesCountA+1;
                subjSessA= cat(2, subjSessA, currentSubj(session).trainDay); %day count for y axis

            end %end Cond A
            
            %Condition B
                   if currentSubj(session).trainStage ==5
                        if sesCountB== 1 
                            currentSubj(1).DSzblueAllTrialsB= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                            currentSubj(1).DSzpurpleAllTrialsB= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                            currentSubj(1).DSpeLatencyAllTrialsB= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                             if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                                currentSubj(1).NSzblueAllTrialsB= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                                currentSubj(1).NSzpurpleAllTrialsB= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                                currentSubj(1).NSpeLatencyAllTrialsB= currentSubj(session).behavior.NSpeLatency(NSselected); 
                             else
%                                continue %continue if no NS data
                             end
                        else %add subsequent sessions using cat()
                            currentSubj(1).DSzblueAllTrialsB = cat(2, currentSubj.DSzblueAllTrialsB, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                            currentSubj(1).DSzpurpleAllTrialsB = cat(2, currentSubj.DSzpurpleAllTrialsB, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                            currentSubj(1).DSpeLatencyAllTrialsB = cat(2,currentSubj(1).DSpeLatencyAllTrialsB,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                            if ~isempty(currentSubj(session).periNS.NS)
                                currentSubj(1).NSzblueAllTrialsB = cat(2, currentSubj.NSzblueAllTrialsB, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                                currentSubj(1).NSzpurpleAllTrialsB = cat(2, currentSubj.NSzpurpleAllTrialsB, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                                currentSubj(1).NSpeLatencyAllTrialsB = cat(2,currentSubj(1).NSpeLatencyAllTrialsB,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            else
%                                 continue %continue if nos NS data
                            end
                        end %end sesCount conditional

                        
                         %licks
                        currentSubj(1).DSloxAllTrialsB{sesCountB}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsB{sesCountB}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsB{sesCountB})
                              DSloxAllTrialsB{trialBcount} = currentSubj(1).DSloxAllTrialsB{sesCountB}{cue};
                              trialBcount=trialBcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsB{sesCountB})
                            NSloxAllTrialsB{trialBNScount}= currentSubj(1).NSloxAllTrialsB{sesCountB}{cue};
                            trialBNScount=trialBNScount+1;
                        end

                        
                        sesCountB= sesCountB+1;
                        subjSessB= cat(2, subjSessB, currentSubj(session).trainDay); %day count for y axis
                        
                         allSubj(subj).DSzblueAllTrialsB= currentSubj(1).DSzblueAllTrialsB;
                         allSubj(subj).DSzpurpleAllTrialsB= currentSubj(1).DSzpurpleAllTrialsB;
                         allSubj(subj).DSpeLatencyAllTrialsB= currentSubj(1).DSpeLatencyAllTrialsB;
                         allSubj(subj).NSzblueAllTrialsB= currentSubj(1).NSzblueAllTrialsB;
                         allSubj(subj).NSzpurpleAllTrialsB= currentSubj(1).NSzpurpleAllTrialsB;
                         allSubj(subj).NSpeLatencyAllTrialsB= currentSubj(1).NSpeLatencyAllTrialsB;

                  end %end Cond B
                  
              %Condition C
               if currentSubj(session).trainStage >5
                   
                    if sesCountC== 1 
                        currentSubj(1).DSzblueAllTrialsC= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsC= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsC= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsC= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsC= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsC= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsC = cat(2, currentSubj.DSzblueAllTrialsC, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsC = cat(2, currentSubj.DSzpurpleAllTrialsC, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsC = cat(2, currentSubj(1).DSpeLatencyAllTrialsC, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsC = cat(2, currentSubj.NSzblueAllTrialsC, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsC = cat(2, currentSubj.NSzpurpleAllTrialsC, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsC = cat(2,currentSubj(1).NSpeLatencyAllTrialsC,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsC{sesCountC}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsC{sesCountC}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsC{sesCountC})
                              DSloxAllTrialsC{trialCcount} = currentSubj(1).DSloxAllTrialsC{sesCountC}{cue};
                              trialCcount=trialCcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsC{sesCountC})
                            NSloxAllTrialsC{trialCNScount}= currentSubj(1).NSloxAllTrialsC{sesCountC}{cue};
                            trialCNScount=trialCNScount+1;
                        end

                    sesCountC= sesCountC+1;
                    subjSessC= cat(2, subjSessC, currentSubj(session).trainDay); %day count for y axis

                     allSubj(subj).DSzblueAllTrialsC= currentSubj(1).DSzblueAllTrialsC;
                     allSubj(subj).DSzpurpleAllTrialsC= currentSubj(1).DSzpurpleAllTrialsC;
                     allSubj(subj).DSpeLatencyAllTrialsC= currentSubj(1).DSpeLatencyAllTrialsC;
                     allSubj(subj).NSzblueAllTrialsC= currentSubj(1).NSzblueAllTrialsC;
                     allSubj(subj).NSzpurpleAllTrialsC= currentSubj(1).NSzpurpleAllTrialsC;
                     allSubj(subj).NSpeLatencyAllTrialsC= currentSubj(1).NSpeLatencyAllTrialsC;

                    
                    
              end %end Cond C
              
                %Condition D
               if currentSubj(session).trainStage ==6
                   
                    if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsD= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsD= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsD= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsD= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsD = cat(2, currentSubj.DSzblueAllTrialsD, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsD = cat(2, currentSubj.DSzpurpleAllTrialsD, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsD = cat(2, currentSubj(1).DSpeLatencyAllTrialsD, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsD = cat(2, currentSubj.NSzblueAllTrialsD, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsD = cat(2, currentSubj.NSzpurpleAllTrialsD, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsD = cat(2,currentSubj(1).NSpeLatencyAllTrialsD,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsC{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsC{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsC{sesCountD}{cue};
                            trialDNScount=trialDNScount+1;
                        end

                    sesCountD= sesCountD+1;
                    subjSessD= cat(2, subjSessD, currentSubj(session).trainDay); %day count for y axis
                    
                         allSubj(subj).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD;
                         allSubj(subj).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD;
                         allSubj(subj).DSpeLatencyAllTrialsD= currentSubj(1).DSpeLatencyAllTrialsD;
                         allSubj(subj).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD;
                         allSubj(subj).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD;
                         allSubj(subj).NSpeLatencyAllTrialsD= currentSubj(1).NSpeLatencyAllTrialsD;


               %end Cond D
              
              
                %Condition E
               elseif currentSubj(session).trainStage ==7
                   
                   if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsD= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsD= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsD= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsD= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsD = cat(2, currentSubj.DSzblueAllTrialsD, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsD = cat(2, currentSubj.DSzpurpleAllTrialsD, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsD = cat(2, currentSubj(1).DSpeLatencyAllTrialsD, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsD = cat(2, currentSubj.NSzblueAllTrialsD, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsD = cat(2, currentSubj.NSzpurpleAllTrialsD, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsD = cat(2,currentSubj(1).NSpeLatencyAllTrialsD,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsC{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsC{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsC{sesCountD}{cue};
                            trialDNScount=trialDNScount+1;
                        end

                    sesCountD= sesCountD+1;
                    subjSessD= cat(2, subjSessD, currentSubj(session).trainDay); %day count for y axis
                    
                         allSubj(subj).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD;
                         allSubj(subj).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD;
                         allSubj(subj).DSpeLatencyAllTrialsD= currentSubj(1).DSpeLatencyAllTrialsD;
                         allSubj(subj).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD;
                         allSubj(subj).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD;
                         allSubj(subj).NSpeLatencyAllTrialsD= currentSubj(1).NSpeLatencyAllTrialsD;


               %end Cond D
                   
                   
                    if sesCountE== 1 
                        currentSubj(1).DSzblueAllTrialsE= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsE= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsE= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsE= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsE= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsE= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsE = cat(2, currentSubj.DSzblueAllTrialsE, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsE = cat(2, currentSubj.DSzpurpleAllTrialsE, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsE = cat(2, currentSubj(1).DSpeLatencyAllTrialsE, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsE = cat(2, currentSubj.NSzblueAllTrialsE, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsE = cat(2, currentSubj.NSzpurpleAllTrialsE, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsE = cat(2,currentSubj(1).NSpeLatencyAllTrialsE,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsE{sesCountE}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsE{sesCountE}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsE{sesCountE})
                              DSloxAllTrialsE{trialEcount} = currentSubj(1).DSloxAllTrialsE{sesCountE}{cue};
                              trialEcount=trialEcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsE{sesCountE})
                            NSloxAllTrialsE{trialENScount}= currentSubj(1).NSloxAllTrialsE{sesCountE}{cue};
                            trialENScount=trialENScount+1;
                        end

                    sesCountE= sesCountE+1;
                    subjSessE= cat(2, subjSessE, currentSubj(session).trainDay); %day count for y axis

                          allSubj(subj).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE;
                         allSubj(subj).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE;
                         allSubj(subj).DSpeLatencyAllTrialsE= currentSubj(1).DSpeLatencyAllTrialsE;
                         allSubj(subj).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE;
                         allSubj(subj).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE;
                         allSubj(subj).NSpeLatencyAllTrialsE= currentSubj(1).NSpeLatencyAllTrialsE;
              
               %end Cond E
   
               
                   %Condition F
               elseif currentSubj(session).trainStage ==8
                   
                   if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsD= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsD= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsD= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsD= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsD= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsD = cat(2, currentSubj.DSzblueAllTrialsD, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsD = cat(2, currentSubj.DSzpurpleAllTrialsD, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsD = cat(2, currentSubj(1).DSpeLatencyAllTrialsD, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsD = cat(2, currentSubj.NSzblueAllTrialsD, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsD = cat(2, currentSubj.NSzpurpleAllTrialsD, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsD = cat(2,currentSubj(1).NSpeLatencyAllTrialsD,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
                    % continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsD{sesCountD}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsC{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsC{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsC{sesCountD}{cue};
                            trialDNScount=trialDNScount+1;
                        end

                    sesCountD= sesCountD+1;
                    subjSessD= cat(2, subjSessD, currentSubj(session).trainDay); %day count for y axis
                    
                         allSubj(subj).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD;
                         allSubj(subj).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD;
                         allSubj(subj).DSpeLatencyAllTrialsD= currentSubj(1).DSpeLatencyAllTrialsD;
                         allSubj(subj).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD;
                         allSubj(subj).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD;
                         allSubj(subj).NSpeLatencyAllTrialsD= currentSubj(1).NSpeLatencyAllTrialsD;

               %end Cond D
              
              
                %Condition E
               
                  
                   
                   
                    if sesCountE== 1 
                        currentSubj(1).DSzblueAllTrialsE= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsE= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsE= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsE= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsE= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsE= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsE = cat(2, currentSubj.DSzblueAllTrialsE, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsE = cat(2, currentSubj.DSzpurpleAllTrialsE, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsE = cat(2, currentSubj(1).DSpeLatencyAllTrialsE, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsE = cat(2, currentSubj.NSzblueAllTrialsE, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsE = cat(2, currentSubj.NSzpurpleAllTrialsE, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsE = cat(2,currentSubj(1).NSpeLatencyAllTrialsE,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsE{sesCountE}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsE{sesCountE}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsE{sesCountE})
                              DSloxAllTrialsE{trialEcount} = currentSubj(1).DSloxAllTrialsE{sesCountE}{cue};
                              trialEcount=trialEcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsE{sesCountE})
                            NSloxAllTrialsE{trialENScount}= currentSubj(1).NSloxAllTrialsE{sesCountE}{cue};
                            trialENScount=trialENScount+1;
                        end

                    sesCountE= sesCountE+1;
                    subjSessE= cat(2, subjSessE, currentSubj(session).trainDay); %day count for y axis

                         allSubj(subj).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE;
                         allSubj(subj).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE;
                         allSubj(subj).DSpeLatencyAllTrialsE= currentSubj(1).DSpeLatencyAllTrialsE;
                         allSubj(subj).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE;
                         allSubj(subj).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE;
                         allSubj(subj).NSpeLatencyAllTrialsE= currentSubj(1).NSpeLatencyAllTrialsE;
              
              
               %end Cond E
   
                    if sesCountF== 1 
                        currentSubj(1).DSzblueAllTrialsF= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsF= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsF= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                         if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsF= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsF= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsF= currentSubj(session).behavior.NSpeLatency(NSselected); 
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsF = cat(2, currentSubj.DSzblueAllTrialsF, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsF = cat(2, currentSubj.DSzpurpleAllTrialsF, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsF = cat(2, currentSubj(1).DSpeLatencyAllTrialsF, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions

                        if ~isempty(currentSubj(session).periNS.NS)
                            currentSubj(1).NSzblueAllTrialsF = cat(2, currentSubj.NSzblueAllTrialsF, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsF = cat(2, currentSubj.NSzpurpleAllTrialsF, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsF = cat(2,currentSubj(1).NSpeLatencyAllTrialsF,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                        %licks
                        currentSubj(1).DSloxAllTrialsF{sesCountF}= currentSubj(session).behavior.loxDSrel(DSselected); %note these timestamps are relative to cue onset

                        currentSubj(1).NSloxAllTrialsF{sesCountF}= currentSubj(session).behavior.loxNSrel(NSselected);

                        
                         %in order to sort licks according to trial by PE latency
                         %later, we need to reshape the lox cell array from nested
                         %{session}{cue} to just {cue}
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsF{sesCountF})
                              DSloxAllTrialsF{trialFcount} = currentSubj(1).DSloxAllTrialsF{sesCountF}{cue};
                              trialFcount=trialFcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsF{sesCountF})
                            NSloxAllTrialsF{trialFNScount}= currentSubj(1).NSloxAllTrialsF{sesCountF}{cue};
                            trialFNScount=trialFNScount+1;
                        end

                    sesCountF= sesCountF+1;
                    subjSessF= cat(2, subjSessF, currentSubj(session).trainDay); %day count for y axis

                        allSubj(subj).DSzblueAllTrialsF= currentSubj(1).DSzblueAllTrialsF;
                         allSubj(subj).DSzpurpleAllTrialsF= currentSubj(1).DSzpurpleAllTrialsF;
                         allSubj(subj).DSpeLatencyAllTrialsF= currentSubj(1).DSpeLatencyAllTrialsF;
                         allSubj(subj).NSzblueAllTrialsF= currentSubj(1).NSzblueAllTrialsF;
                         allSubj(subj).NSzpurpleAllTrialsF= currentSubj(1).NSzpurpleAllTrialsF;
                         allSubj(subj).NSpeLatencyAllTrialsF= currentSubj(1).NSpeLatencyAllTrialsF;
              
              
               end %end Cond all
    end %end session loop
    
        if rewardSessionCount ~=0 %if this subject had a session with valid variable reward data

        %Transpose these data for readability
        currentSubj(1).DSzbluePump1= currentSubj(1).DSzbluePump1';
        currentSubj(1).DSzbluePump2= currentSubj(1).DSzbluePump2';
        currentSubj(1).DSzbluePump3= currentSubj(1).DSzbluePump3';


    %     currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';    
    %     currentSubj(1).NSzblueAllTrials= currentSubj(1).NSzblueAllTrials';
    %     currentSubj(1).NSzpurpleAllTrials= currentSubj(1).NSzpurpleAllTrials';
    %       

        %get a trial count to use for the heatplot ytick
        currentSubj(1).DScountPump1= 1:size(currentSubj(1).DSzbluePump1,1); 
        currentSubj(1).DScountPump2= 1:size(currentSubj(1).DSzbluePump2,1); 
        currentSubj(1).DScountPump3= 1:size(currentSubj(1).DSzbluePump3,1); 
    
        end    
    
    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
  
    
%% arrange data into a format that the @gramm package can utilize for plots 
  %this means concating all data of interest into a vector and then having
  %other catagorical vectors that allow for organization of that data
    
  %initialize

  % data vectors (y axis)
    DSzSessionblue=[];
    NSzSessionblue=[];
    DSzSessionpurple=[];
    NSzSessionpurple=[];
    
   % time vectors (x axis)
    timeLocktracesDS=[];
    timeLocktracesNS=[];
    
    %catagorical vectors for choosing data
    idDS=[];
    idNS=[];
    daysDS =[]; 
    daysNS =[]; 
    NSintroDS=[];
    NSintroNS=[];
    CriteriaStage5DS=[];
    CriteriaStage5NS=[];
    stageDS=[];
    stageNS=[];
    pumpDS=[];
    pumpbluesignalDS=[];
    pumppurplesignalDS=[];
    pumpdayTimeLock=[];
    pumptimeLock=[]; 
    pumpsessionDS=[];
    trialsDS=[];
    pumptrialsDS=[];
    pump1alltrials=[];
    pump1all=[];
    pump1bluesignalall=[];
    pump1purplesignalall=[];
    pump1sessionall=[];
    pump2alltrials=[];
    pump2all=[];
    pump2bluesignalall=[];
    pump2purplesignalall=[];
    pump2sessionall=[];
    pump1TimeLock=[];
    pump2TimeLock=[];
    pumptimeLockDS=[];
    
     for day=1:numel(currentSubj); %for every session(training day)
     for trial=1:size(currentSubj(day).periDS.DSzblue,3)
         %need to get ID for each time point, therefore just repeat it the length of
           %the signal we are plotting
    repid= repelem(currentSubj(day).rat,length(timeLock));% every trial is the length of timeLock
    
    %repeat for training days, stages, trials
    days=currentSubj(day).trainDay;
    days=repelem(days,length(timeLock))';
    stage=currentSubj(day).trainStage;
    stage=repelem(stage,length(timeLock))';
    trials=trial;
    trials=repelem(trials,length(timeLock))';
    
    %create vectors for all subjects for the DS
    idDS=vertcat(idDS,repid');
    daysDS=vertcat(daysDS,days);
    stageDS=vertcat(stageDS,stage);
    DSzSessionblue= vertcat(DSzSessionblue,currentSubj(day).periDS.DSzblue(:,:,trial));
    DSzSessionpurple= vertcat(DSzSessionpurple,currentSubj(day).periDS.DSzpurple(:,:,trial));
    timeLocktracesDS= vertcat(timeLocktracesDS,timeLock');
    trialsDS=vertcat(trialsDS,trials);
    
    % for DS signal vector, find the days in which NS was introduced (NSintro=1) and repeat that one for the entire signal for that day for each rat 
    if currentSubj(day).box == 1
             if subjData.(subjectsAnalyzed{subj})(day).box == 1
                 repNSintroDS = repelem(1, length(timeLock));
             else
                 repNSintroDS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box ==2
             if subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1
                repNSintroDS = repelem(1, length(timeLock));
             else 
                repNSintroDS = repelem(0, length(timeLock));
             end     
    end
      NSintroDS = vertcat(NSintroDS, repNSintroDS'); 
    %find non zero days where Stage 5 criteria was met (criteria= 1)and
    %repeat that one for the entire calcium signal for that day for each
    %rat
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1;
                 repCriteriaStage5DS = repelem(1, length(timeLock));
             else
                 repCriteriaStage5DS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1;
                repCriteriaStage5DS = repelem(1, length(timeLock));
             else 
                repCriteriaStage5DS = repelem(0, length(timeLock));
             end
             
       end
     CriteriaStage5DS = vertcat(CriteriaStage5DS, repCriteriaStage5DS');
     
 %NS has different length vector, so need distinct variables for NS   
    if ~isnan(currentSubj(day).periNS.NSzblue(:));
         
%         if subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainStage==8
%          pumpN=repelem(4,length(timeLock))';
%          pumpNS=vertcat(pumpNS,pumpN);% tagging NS trials from stage 8 with '4'
%         else
%         pumpN=nan;
%         pumpN=repelem(pumpN,length(timeLock))';
%         pumpNS=vertcat(pumpNS,pumpN);
%          end
         NSzSessionblue= vertcat(NSzSessionblue,currentSubj(day).periNS.NSzblue(:,:,trial));
         NSzSessionpurple= vertcat(NSzSessionpurple,currentSubj(day).periNS.NSzpurple(:,:,trial));
         stageNS=vertcat(stageNS,stage);
         daysNS=vertcat(daysNS,days);
         timeLocktracesNS= vertcat(timeLocktracesNS,timeLock');
         idNS=vertcat(idNS,repid');
         
          % find the non zero indicies in NSitroduced column 
         if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).NSAintro == 1)
                 repNSintroNS = repelem(1, length(timeLock));
             else
                 repNSintroNS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1)
                repNSintroNS = repelem(1, length(timeLock));
             else 
                repNSintroNS = repelem(0, length(timeLock));
             end
              
         end  
       NSintroNS = vertcat(NSintroNS, repNSintroNS'); 
        %find non zero days where criteria was met (Stage 5)
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1)
                 repCriteriaStage5NS = repelem(1, length(timeLock));
             else
                 repCriteriaStage5NS = repelem(0, length(timeLock));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1)
                repCriteriaStage5NS = repelem(1, length(timeLock));
             else 
                repCriteriaStage5NS = repelem(0, length(timeLock));
             end
             
       end
         CriteriaStage5NS = vertcat(CriteriaStage5NS, repCriteriaStage5NS'); 
    end % end loop specific to NS 
         

    
     %FOR STAGE 8 w/PROBES TRIALS: repeating the pump numbers to align with the length of the signal we
    %are plotting.  Also, the trials need to be split up by pumps so the
    %vectors will be a different length than the vectors created above for
    %all stages so we will make different vectors that contain the signal and the the catagorical organizing 
    %variables for stage 8.
    
    if currentSubj(day).trainStage==8; %stage 8 is where probe trials occur
   
    %pump1    
    for pump1trial=1:size(currentSubj(day).periDS.DSzbluePump1,2);
   
    pump1trials=repelem(pump1trial, length(currentSubj(day).periDS.DSzbluePump1(:,pump1trial)))';
    %overriding so need to vertcat everthing within the loop
    pump1alltrials=vertcat(pump1alltrials,pump1trials);
    %assign pump 1 trials the #1 in a pump1 catagorical vector 
    pump1=repelem(1, length(currentSubj(day).periDS.DSzbluePump1(:,pump1trial)))';
    pump1all=vertcat(pump1all,pump1);
    %obtain all trials blue and purple signals
    pump1bluesignal= currentSubj(day).periDS.DSzbluePump1(:,pump1trial);
    pump1bluesignalall=vertcat(pump1bluesignalall,pump1bluesignal);
    pump1purplesignal= currentSubj(day).periDS.DSzpurplePump1(:,pump1trial);
    pump1purplesignalall=vertcat(pump1purplesignalall,pump1purplesignal);
    %create catagorical vector for the session(day) of each trial
    pump1session=repelem(currentSubj(day).trainDay, length(currentSubj(day).periDS.DSzbluePump1(:,pump1trial)))';
    pump1sessionall=vertcat(pump1sessionall,pump1session);
    %create vector with time points that align with all signals
     pump1trialTimeLock=timeLock';
     pump1TimeLock=vertcat(pump1TimeLock,pump1trialTimeLock);
    end
    
    %pump2
    for pump2trial=1:size(currentSubj(day).periDS.DSzbluePump2,2);
    pump2trials=repelem(pump2trial, length(currentSubj(day).periDS.DSzbluePump2(:,pump2trial)))';
    %overriding so need to vertcat everthing within the loop
    pump2alltrials=vertcat(pump2alltrials,pump2trials);
    %assign pump 2 trials the #2 in a pump2 catagorical vector 
    pump2=repelem(2, length(currentSubj(day).periDS.DSzbluePump2(:,pump2trial)))';
    pump2all=vertcat(pump2all,pump2);
    %obtain all trials blue and purple signals
    pump2bluesignal= currentSubj(day).periDS.DSzbluePump2(:,pump2trial);
    pump2bluesignalall=vertcat(pump2bluesignalall,pump2bluesignal);
    pump2purplesignal= currentSubj(day).periDS.DSzpurplePump2(:,pump2trial);
    pump2purplesignalall=vertcat(pump2purplesignalall,pump2purplesignal);
    %create catagorical vector for the session(day) of each trial
    pump2session=repelem(currentSubj(day).trainDay, length(currentSubj(day).periDS.DSzbluePump2(:,pump2trial)))';
    pump2sessionall=vertcat(pump2sessionall,pump2session);
     %create vector with time points that align with all signals
     pump2trialTimeLock=timeLock';
     pump2TimeLock=vertcat(pump2TimeLock,pump2trialTimeLock);
    end 
    
   %concatenate vectors for all trials of each day for the subj
   pumpsession=vertcat(pump1sessionall,pump2sessionall);
   pumpday=vertcat(pump1all,pump2all);
   pumptrials=vertcat(pump1alltrials,pump2alltrials);
   pumptimeLock=vertcat(pump1TimeLock,pump2TimeLock);
   %concatenate vectors across all session in currentsubj
    pumpDS=vertcat(pumpDS,pumpday);
    pumpsessionDS=vertcat(pumpsessionDS,pumpsession);
    pumptrialsDS=vertcat(pumptrialsDS,pumptrials);
    pumpbluesignalday=vertcat(pump1bluesignalall,pump2bluesignalall);
    pumpbluesignalDS=vertcat(pumpbluesignalDS,pumpbluesignalday);
    pumppurplesignalday=vertcat(pump1purplesignalall,pump2purplesignalall);
    pumppurplesignalDS=vertcat(pumppurplesignalDS,pumppurplesignalday);
    pumptimeLockDS=vertcat(pumptimeLockDS,pumptimeLock);
    end 
     
    
     end % end trial loop
end%end day loop

% Plots of Z score Traces for each animal


%TRACES FROM Stage 6,7,8 on trial 8
figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1;
if find(unique(stageDS)==6)
%Stage 6
   g=gramm('x',timeLocktracesDS,'y', DSzSessionblue,'color',daysDS,'subset',stageDS==6);
   g.facet_grid(trialsDS,[]);
   g.stat_summary();
   g.set_names('x','Time from Cue Onset (sec)','y','Z-Score','color','Training Day','row','Trial')
   g.set_title(' Average DS 465 nm Z Score-Representative Trial-Stage 6')
   g.axe_property('YLim',[-7 15])
   g.set_color_options('map','brewer_dark')
   
   g.draw()
   
 %Stage 7 
 
 figure(figureCount) %one figure with poxCount across sessions for all subjects

figureCount= figureCount+1;

   g=gramm('x',timeLocktracesDS,'y', DSzSessionblue,'color',daysDS,'subset',stageDS==7);
   g.facet_grid(trialsDS,[]);
   g.stat_summary();
   g.set_names('x','Time from Cue Onset (sec)','y','Z-Score','color','Training Day','row','Trial')
   g.set_title(' Average DS 465 nm Z Score-Representative Trial-Stage 7')
   g.axe_property('YLim',[-7 15])
   g.set_color_options('map','brewer_dark')

    g.draw()
 
    
%Stage 8
%pump 1 trials
 
  figure(figureCount) %one figure with poxCount across sessions for all subjects

  figureCount= figureCount+1;
   g=gramm('x',pumptimeLockDS,'y', pumpbluesignalDS,'color',pumpsessionDS,'subset',pumpDS==1);
   g.facet_grid(pumptrialsDS,[]);
   g.stat_summary();
   g.set_names('x','Time from Cue Onset (sec)','y','Z-Score','color','Training Day','row','Trial')
   g.set_title(' Average DS 465 nm Z Score-Representative Trial-Stage 8')
   g.axe_property('YLim',[-7 15])
   g.set_color_options('map','brewer_dark')  
   
   g.draw()
 
 
   %saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'cuelocked_trial8_traces','.fig'));
end %end if loop for later trial traces
end%end subj loop