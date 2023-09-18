%% stage 1-4, 5, 6+ trial DS plots latency sorted


%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

    %initialize/clear arrays between subjects
    currentSubj(1).NSzblueAllTrialsA= [];
    currentSubj(1).NSzpurpleAllTrialsA= [];
    currentSubj(1).NSpeLatencyAllTrialsA= [];

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
               if currentSubj(session).trainStage==5
                   
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
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsD{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsD{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsD{sesCountD}{cue};
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
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsD{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsD{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsD{sesCountD}{cue};
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
               elseif currentSubj(session).trainStage>=8 %more than 8 stages possible, for now just group together
                   
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
                          for cue = 1:numel(currentSubj(1).DSloxAllTrialsD{sesCountD})
                              DSloxAllTrialsD{trialDcount} = currentSubj(1).DSloxAllTrialsD{sesCountD}{cue};
                              trialDcount=trialDcount+1;
                          end           
                                            
                        for cue= 1:numel(currentSubj(1).NSloxAllTrialsD{sesCountD})
                            NSloxAllTrialsD{trialDNScount}= currentSubj(1).NSloxAllTrialsD{sesCountD}{cue};
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
    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data and other behavioralevents(licks)
    
        %cond a
    [DSpeLatencySortedA,DSsortIndA] = sort(currentSubj(1).DSpeLatencyAllTrialsA);       
%     [NSpeLatencySortedA,NSsortIndA] =  %stages before 5 have no ns %sort(currentSubj(1).NSpeLatencyAllTrialsA);

         %cond b
    [DSpeLatencySortedB,DSsortIndB] = sort(currentSubj(1).DSpeLatencyAllTrialsB);       
    [NSpeLatencySortedB,NSsortIndB] = sort(currentSubj(1).NSpeLatencyAllTrialsB);
        %cond c
         if currentSubj(session).trainStage >5
    [DSpeLatencySortedC,DSsortIndC] = sort(currentSubj(1).DSpeLatencyAllTrialsC);       
    [NSpeLatencySortedC,NSsortIndC] = sort(currentSubj(1).NSpeLatencyAllTrialsC);
         end
          %cond d
         if currentSubj(session).trainStage==6
    [DSpeLatencySortedD,DSsortIndD] = sort(currentSubj(1).DSpeLatencyAllTrialsD);       
    [NSpeLatencySortedD,NSsortIndD] = sort(currentSubj(1).NSpeLatencyAllTrialsD);
        
         %cond e
         elseif currentSubj(session).trainStage==7
     
     [DSpeLatencySortedD,DSsortIndD] = sort(currentSubj(1).DSpeLatencyAllTrialsD);       
    [NSpeLatencySortedD,NSsortIndD] = sort(currentSubj(1).NSpeLatencyAllTrialsD);        
             
    [DSpeLatencySortedE,DSsortIndE] = sort(currentSubj(1).DSpeLatencyAllTrialsE);       
    [NSpeLatencySortedE,NSsortIndE] = sort(currentSubj(1).NSpeLatencyAllTrialsE);
        
         elseif currentSubj(session).trainStage==8
             
      [DSpeLatencySortedD,DSsortIndD] = sort(currentSubj(1).DSpeLatencyAllTrialsD);       
    [NSpeLatencySortedD,NSsortIndD] = sort(currentSubj(1).NSpeLatencyAllTrialsD);        
             
    [DSpeLatencySortedE,DSsortIndE] = sort(currentSubj(1).DSpeLatencyAllTrialsE);       
    [NSpeLatencySortedE,NSsortIndE] = sort(currentSubj(1).NSpeLatencyAllTrialsE);        
             
    [DSpeLatencySortedF,DSsortIndF] = sort(currentSubj(1).DSpeLatencyAllTrialsF);       
    [NSpeLatencySortedF,NSsortIndF] = sort(currentSubj(1).NSpeLatencyAllTrialsF);
         end
         
         
    %Sort all trials by PE latency
        %cond a
    currentSubj(1).DSzblueAllTrialsA= currentSubj(1).DSzblueAllTrialsA(:,DSsortIndA);
    currentSubj(1).DSzpurpleAllTrialsA= currentSubj(1).DSzpurpleAllTrialsA(:,DSsortIndA);
%     currentSubj(1).NSzblueAllTrialsA = currentSubj(1).NSzblueAllTrialsA(:,NSsortIndA);
%     currentSubj(1).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA(:,NSsortIndA);

             % sort licks
             currentSubj(1).DSloxAllTrialsA= DSloxAllTrialsA;
             currentSubj(1).DSloxAllTrialsA= currentSubj(1).DSloxAllTrialsA(:,DSsortIndA);


         %cond b
    currentSubj(1).DSzblueAllTrialsB= currentSubj(1).DSzblueAllTrialsB(:,DSsortIndB);
    currentSubj(1).DSzpurpleAllTrialsB= currentSubj(1).DSzpurpleAllTrialsB(:,DSsortIndB);
    currentSubj(1).NSzblueAllTrialsB = currentSubj(1).NSzblueAllTrialsB(:,NSsortIndB);
    currentSubj(1).NSzpurpleAllTrialsB= currentSubj(1).NSzpurpleAllTrialsB(:,NSsortIndB);
    
             % sort licks
             currentSubj(1).DSloxAllTrialsB= DSloxAllTrialsB;
             currentSubj(1).DSloxAllTrialsB= currentSubj(1).DSloxAllTrialsB(:,DSsortIndB);
             
             currentSubj(1).NSloxAllTrialsB= NSloxAllTrialsB;
             currentSubj(1).NSloxAllTrialsB= currentSubj(1).NSloxAllTrialsB(:,NSsortIndB);

          %cond C
           if currentSubj(session).trainStage >5
    currentSubj(1).DSzblueAllTrialsC= currentSubj(1).DSzblueAllTrialsC(:,DSsortIndC);
    currentSubj(1).DSzpurpleAllTrialsC= currentSubj(1).DSzpurpleAllTrialsC(:,DSsortIndC);
    currentSubj(1).NSzblueAllTrialsC = currentSubj(1).NSzblueAllTrialsC(:,NSsortIndC);
    currentSubj(1).NSzpurpleAllTrialsC= currentSubj(1).NSzpurpleAllTrialsC(:,NSsortIndC);
               % sort licks
             currentSubj(1).DSloxAllTrialsC= DSloxAllTrialsC;
             currentSubj(1).DSloxAllTrialsC= currentSubj(1).DSloxAllTrialsC(:,DSsortIndC);
             
             currentSubj(1).NSloxAllTrialsC= NSloxAllTrialsC;
             currentSubj(1).NSloxAllTrialsC= currentSubj(1).NSloxAllTrialsC(:,NSsortIndC);
           end
           
      %cond D
           if currentSubj(session).trainStage ==6
    currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD(:,DSsortIndD);
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD(:,DSsortIndD);
    currentSubj(1).NSzblueAllTrialsD = currentSubj(1).NSzblueAllTrialsD(:,NSsortIndD);
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD(:,NSsortIndD);
               % sort licks
             currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
             currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndD);
             
             currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
             currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndD);
         
            %cond E
           elseif currentSubj(session).trainStage ==7
     currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD(:,DSsortIndD);
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD(:,DSsortIndD);
    currentSubj(1).NSzblueAllTrialsD = currentSubj(1).NSzblueAllTrialsC(:,NSsortIndD);
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsC(:,NSsortIndD);
               % sort licks
             currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
             currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndD);
             
             currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
             currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndD);
                    
               
               
    currentSubj(1).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE(:,DSsortIndE);
    currentSubj(1).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE(:,DSsortIndE);
    currentSubj(1).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE(:,NSsortIndE);
    currentSubj(1).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE(:,NSsortIndE);
               % sort licks
             currentSubj(1).DSloxAllTrialsE= DSloxAllTrialsE;
             currentSubj(1).DSloxAllTrialsE= currentSubj(1).DSloxAllTrialsE(:,DSsortIndE);
             
             currentSubj(1).NSloxAllTrialsE= NSloxAllTrialsE;
             currentSubj(1).NSloxAllTrialsE= currentSubj(1).NSloxAllTrialsE(:,NSsortIndE);
         
           
            %cond F
           elseif currentSubj(session).trainStage ==8
              
     currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD(:,DSsortIndD);
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD(:,DSsortIndD);
    currentSubj(1).NSzblueAllTrialsD = currentSubj(1).NSzblueAllTrialsC(:,NSsortIndD);
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsC(:,NSsortIndD);
               % sort licks
             currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
             currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndD);
             
             currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
             currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndD);
                    
               
               
    currentSubj(1).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE(:,DSsortIndE);
    currentSubj(1).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE(:,DSsortIndE);
    currentSubj(1).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE(:,NSsortIndE);
    currentSubj(1).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE(:,NSsortIndE);
               % sort licks
             currentSubj(1).DSloxAllTrialsE= DSloxAllTrialsE;
             currentSubj(1).DSloxAllTrialsE= currentSubj(1).DSloxAllTrialsE(:,DSsortIndE);
             
             currentSubj(1).NSloxAllTrialsE= NSloxAllTrialsE;
             currentSubj(1).NSloxAllTrialsE= currentSubj(1).NSloxAllTrialsE(:,NSsortIndE);
         
               
    currentSubj(1).DSzblueAllTrialsF= currentSubj(1).DSzblueAllTrialsF(:,DSsortIndF);
    currentSubj(1).DSzpurpleAllTrialsF= currentSubj(1).DSzpurpleAllTrialsF(:,DSsortIndF);
    currentSubj(1).NSzblueAllTrialsF = currentSubj(1).NSzblueAllTrialsF(:,NSsortIndF);
    currentSubj(1).NSzpurpleAllTrialsF= currentSubj(1).NSzpurpleAllTrialsF(:,NSsortIndF);
               % sort licks
             currentSubj(1).DSloxAllTrialsF= DSloxAllTrialsF;
             currentSubj(1).DSloxAllTrialsF= currentSubj(1).DSloxAllTrialsF(:,DSsortIndF);
             
             currentSubj(1).NSloxAllTrialsF= NSloxAllTrialsF;
             currentSubj(1).NSloxAllTrialsF= currentSubj(1).NSloxAllTrialsF(:,NSsortIndF);
           end       

    %Transpose these data for readability
        %cond a
    currentSubj(1).DSzblueAllTrialsA= currentSubj(1).DSzblueAllTrialsA';
    currentSubj(1).DSzpurpleAllTrialsA= currentSubj(1).DSzpurpleAllTrialsA';    
%     currentSubj(1).NSzblueAllTrialsA= currentSubj(1).NSzblueAllTrialsA';
%     currentSubj(1).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA';
        %cond b
    currentSubj(1).DSzblueAllTrialsB= currentSubj(1).DSzblueAllTrialsB';
    currentSubj(1).DSzpurpleAllTrialsB= currentSubj(1).DSzpurpleAllTrialsB';    
    currentSubj(1).NSzblueAllTrialsB= currentSubj(1).NSzblueAllTrialsB';
    currentSubj(1).NSzpurpleAllTrialsB= currentSubj(1).NSzpurpleAllTrialsB';
        %cond c
         if currentSubj(session).trainStage >5
    currentSubj(1).DSzblueAllTrialsC= currentSubj(1).DSzblueAllTrialsC';
    currentSubj(1).DSzpurpleAllTrialsC= currentSubj(1).DSzpurpleAllTrialsC';    
    currentSubj(1).NSzblueAllTrialsC= currentSubj(1).NSzblueAllTrialsC';
    currentSubj(1).NSzpurpleAllTrialsC= currentSubj(1).NSzpurpleAllTrialsC';
         end
     %cond d
         if currentSubj(session).trainStage ==6
    currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD';
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD';    
    currentSubj(1).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD';
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD';
  
       %cond e
       elseif currentSubj(session).trainStage ==7
     currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD';
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD';    
    currentSubj(1).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD';
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD';       
           
    currentSubj(1).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE';
    currentSubj(1).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE';    
    currentSubj(1).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE';
    currentSubj(1).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE';
         
          
         %cond f
         elseif currentSubj(session).trainStage ==8
     
    currentSubj(1).DSzblueAllTrialsD= currentSubj(1).DSzblueAllTrialsD';
    currentSubj(1).DSzpurpleAllTrialsD= currentSubj(1).DSzpurpleAllTrialsD';    
    currentSubj(1).NSzblueAllTrialsD= currentSubj(1).NSzblueAllTrialsD';
    currentSubj(1).NSzpurpleAllTrialsD= currentSubj(1).NSzpurpleAllTrialsD';       
           
    currentSubj(1).DSzblueAllTrialsE= currentSubj(1).DSzblueAllTrialsE';
    currentSubj(1).DSzpurpleAllTrialsE= currentSubj(1).DSzpurpleAllTrialsE';    
    currentSubj(1).NSzblueAllTrialsE= currentSubj(1).NSzblueAllTrialsE';
    currentSubj(1).NSzpurpleAllTrialsE= currentSubj(1).NSzpurpleAllTrialsE';           
             
    currentSubj(1).DSzblueAllTrialsF= currentSubj(1).DSzblueAllTrialsF';
    currentSubj(1).DSzpurpleAllTrialsF= currentSubj(1).DSzpurpleAllTrialsF';    
    currentSubj(1).NSzblueAllTrialsF= currentSubj(1).NSzblueAllTrialsF';
    currentSubj(1).NSzpurpleAllTrialsF= currentSubj(1).NSzpurpleAllTrialsF';
         end 
         
         
       %get trial count for y axis of heatplot
   currentSubj(1).totalDScountA= 1:size(currentSubj(1).DSzblueAllTrialsA,1); 
   currentSubj(1).totalDScountB= 1:size(currentSubj(1).DSzblueAllTrialsB,1);
    currentSubj(1).totalNScountB= 1:size(currentSubj(1).NSzblueAllTrialsB,1);
    if currentSubj(session).trainStage >5
   currentSubj(1).totalDScountC= 1:size(currentSubj(1).DSzblueAllTrialsC,1);
    currentSubj(1).totalNScountC= 1:size(currentSubj(1).NSzblueAllTrialsC,1);
    end
    
%    currentSubj(1).totalNScountA= 1:size(currentSubj(1).NSzblueAllTrialsA,1); 
  
    if currentSubj(session).trainStage ==6
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsD,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsD,1);
    
    elseif currentSubj(session).trainStage ==7  
        
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsD,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsD,1);
        
    currentSubj(1).totalDScountE= 1:size(currentSubj(1).DSzblueAllTrialsE,1);
    currentSubj(1).totalNScountE= 1:size(currentSubj(1).NSzblueAllTrialsE,1);
    
    elseif currentSubj(session).trainStage ==8  
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsD,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsD,1);
        
    currentSubj(1).totalDScountE= 1:size(currentSubj(1).DSzblueAllTrialsE,1);
    currentSubj(1).totalNScountE= 1:size(currentSubj(1).NSzblueAllTrialsE,1);    
        
    currentSubj(1).totalDScountF= 1:size(currentSubj(1).DSzblueAllTrialsF,1);
    currentSubj(1).totalNScountF= 1:size(currentSubj(1).NSzblueAllTrialsF,1);
    end


    
       %Color axes   
     
     %First, we'll want to establish boundaries for our colormaps based on
     %the std of the z score response. We want to have equidistant
     %color axis max and min so that 0 sits directly in the middle
     
     %TODO: should this be a pooled std calculation (pooled blue & purple)?
    
     %define DS color axes
     %get the avg std in the blue and purple z score responses to all cues,
     %get absolute value and then multiply this by some factor to define a color axis max and min
     
     stdFactor= 4; %multiplicative factor- how many stds away should we set our max & min color value? 
     
     %cond A
     topDSzblueA= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleA= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueA = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleA= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsA, 0, 2))));
     
     %cond B
     topDSzblueB= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleB= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueB = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleB= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsB, 0, 2))));
     
      %cond D
      if currentSubj(session).trainStage ==6
     topDSzblueD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));
      
      %cond E
      elseif currentSubj(session).trainStage ==7
       topDSzblueD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));    
          
     topDSzblueE= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleE= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueE = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleE= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsE, 0, 2))));
      
      %cond F
      elseif currentSubj(session).trainStage >=8 %stage 8 or higher
     
     topDSzblueD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsD, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsD, 0, 2))));    
          
     topDSzblueE= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleE= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueE = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsE, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleE= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsE, 0, 2))));     
          
     topDSzblueF= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsF, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleF= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsF, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueF = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsF, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleF= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsF, 0, 2))));
      end
          %cond c
     if currentSubj(session).trainStage >5
     topDSzblueC= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleC= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueC = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrialsC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleC= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrialsC, 0, 2))));
        
     bottoms= [bottomDSzblueA, bottomDSzblueB, bottomDSzblueC, bottomDSzpurpleA, bottomDSzpurpleB, bottomDSzpurpleC];
     tops= [topDSzblueA, topDSzblueB, topDSzblueC, topDSzpurpleA, topDSzpurpleB, topDSzpurpleC];
     else
     bottoms= [bottomDSzblueA, bottomDSzblueB, bottomDSzpurpleA, bottomDSzpurpleB];
     tops= [topDSzblueA, topDSzblueB, topDSzpurpleA, topDSzpurpleB];
     
          %now choose the one half the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= 2/3*(min(bottoms));
     topAllDS= 2/3*(max(tops));
             bottomMeanShared= bottomAllDS;
        topMeanShared= topAllDS;
   
     end
     

     % create shared axis for stages 6, 7, 8
     
      if currentSubj(session).trainStage==6
        bottoms2= [bottomDSzblueD];
        tops2=[topDSzblueD];
      elseif currentSubj(session).trainStage==7
         bottoms2= [bottomDSzblueD, bottomDSzblueE];
          tops2= [topDSzblueD, topDSzblueE];
      elseif currentSubj(session).trainStage>=8 %if stage 8 or higher
        bottoms2= [bottomDSzblueD, bottomDSzblueE, bottomDSzblueF, bottomDSzpurpleD, bottomDSzpurpleE, bottomDSzpurpleF];
        tops2=[topDSzblueD, topDSzblueE, topDSzblueF, topDSzpurpleD, topDSzpurpleE, topDSzpurpleF];
     
      end
    
  if currentSubj(session).trainStage>5     
      bottomAllDS2= 2/3*(min(bottoms2));
     topAllDS2= 2/3*(max(tops2));
     
     bottomMeanShared2= bottomAllDS2;
        topMeanShared2= topAllDS2;        
  end          
              
              
%     %same, but defining color axes for NS
%     if ~isempty(currentSubj(1).NSzblueSessionMean) %only run this if there's NS data
%         topNSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%         topNSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%         bottomNSzblue= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueSessionMean, 0, 2))));
%         bottomNSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleSessionMean, 0, 2))));
% 
%         bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
%         topAllNS= max(topNSzblue, topNSzpurple);
%     end
%     %Establish a shared bottom and top for shared color axis of DS & NS
%     if ~isempty(currentSubj(1).NSzblueSessionMean) %if there is an NS
%         bottomMeanShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
%         topMeanShared= max(topAllDS, topAllNS); %find the absolute min value
%     else

%     end
  

    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    %Plots!
    
        figure(figureCount);
        figureCount= figureCount+1;

           sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to DS across training stages- trials sorted by PE latency')); %add big title above all subplots


        subplot(2,3,1) %plot of stage 1-4 blue (cond A blue)
        
            imagesc(timeLock,currentSubj(1).totalDScountA,currentSubj(1).DSzblueAllTrialsA) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 1-4 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,2) %plot of stage 5 blue (cond B blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountB,currentSubj(1).DSzblueAllTrialsB) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 5 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
      if currentSubj(session).trainStage >5   
        subplot(2,3,3) %plot of stage 6-8 blue (cond C blue)
            imagesc(timeLock,currentSubj(1).totalDScountC,currentSubj(1).DSzblueAllTrialsC) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6-8 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end      

      subplot(2,3,4) %plot of stage 1-4 purple (cond A purple)
        
            imagesc(timeLock,currentSubj(1).totalDScountA,currentSubj(1).DSzpurpleAllTrialsA) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 1-4 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,5) %plot of stage 5 purple (cond B purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountB,currentSubj(1).DSzpurpleAllTrialsB) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat('Stage 5 DS response (405nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
       if currentSubj(session).trainStage >5  
        subplot(2,3,6) %plot of stage 6-8 purple (cond C purple)
            imagesc(timeLock,currentSubj(1).totalDScountC,currentSubj(1).DSzpurpleAllTrialsC) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat(' Stage 6-8 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
       end   

  %Overlay scatter of PE latency
   subplot(2,3,1) %condA DS blue 
   hold on
   scatter(DSpeLatencySortedA,currentSubj(1).totalDScountA', 'm.');
   
   subplot(2,3,2) %condB DS blue 
   hold on
   scatter(DSpeLatencySortedB,currentSubj(1).totalDScountB', 'm.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC DS blue 
   hold on
   scatter(DSpeLatencySortedC,currentSubj(1).totalDScountC', 'm.');
   end
   
   subplot(2,3,4) %cond A DS purple
   hold on
   scatter(DSpeLatencySortedA,currentSubj(1).totalDScountA', 'm.');
   
   subplot(2,3,5) %cond B DS purple
   hold on
   scatter(DSpeLatencySortedB,currentSubj(1).totalDScountB', 'm.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C DS purple
   hold on
   scatter(DSpeLatencySortedC,currentSubj(1).totalDScountC', 'm.');
   end
   
%   %overlay scatter of Licks- 
%        licksToPlot= 10;
%        lickAlpha= 0.15;
%     
%        subplot(2,3,1) %condA DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountA)
% %            scatter all licks
% %                s= scatter(currentSubj(1).DSloxAllTrialsA{trial},ones(numel(currentSubj(1).DSloxAllTrialsA{trial}),1)*currentSubj(1).totalDScountA(trial), 'k.');
% %            scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsA{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsA{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountA(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%     
%        subplot(2,3,2) %condB DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountB)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsB{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsB{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountB(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%   if currentSubj(session).trainStage >5     
%        subplot(2,3,3) %condC DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountC)
%                 %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsC{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsC{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountC(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%   end
%        subplot(2,3,4) %condA DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountA)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsA{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsA{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountA(trial), 'k.');
%                 s.MarkerEdgeAlpha= 0.3; %make transparent
%            end
%        end
%        
%        subplot(2,3,5) %condB DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountB)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsB{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsB{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountB(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%  if currentSubj(session).trainStage >5      
%        subplot(2,3,6) %condC DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountC)
%               %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsC{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsC{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountC(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%  end  



    %worked for nested structure
    
%    trialCount= 1;
%     
%    subplot(2,3,1) %condA DS blue 
%    hold on
%    for ses= 1:numel(currentSubj(1).DSloxAllTrialsA)
%        for cue= 1:numel(currentSubj(1).DSloxAllTrialsA{ses})
%            scatter(currentSubj(1).DSloxAllTrialsA{ses}{cue},ones(numel(currentSubj(1).DSloxAllTrialsA{ses}{cue}),1)*currentSubj(1).totalDScountA(trialCount), 'k.');
%            trialCount=trialCount+1;
%        end
%    end
   
   
   set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
   saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'allstages_DScuelocked_sorted','.fig')); %save the current figure in fig format
       
    
    
    %NS plots!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

       figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE latency')); %add big title above all subplots


        subplot(2,3,1) %plot of stage 1-4 blue (cond A blue)
        
%             imagesc(timeLock,currentSubj(1).totalNScountA,currentSubj(1).NSzblueAllTrialsA) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
%             title(strcat('Stage 1-4 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
%             xlabel('seconds from cue onset');
%             ylabel('trial (latency sorted)');
% %             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
%             caxis manual;
%             caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values
% 
%             c= colorbar; %colorbar legend
%             c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,2) %plot of stage 5 blue (cond B blue)
            
            imagesc(timeLock,currentSubj(1).totalNScountB,currentSubj(1).NSzblueAllTrialsB) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 5 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
  if currentSubj(session).trainStage >5       
        subplot(2,3,3) %plot of stage 6-8 blue (cond C blue)
            imagesc(timeLock,currentSubj(1).totalNScountC,currentSubj(1).NSzblueAllTrialsC) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6-8 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  end           

      subplot(2,3,4) %plot of stage 1-4 purple (cond A purple)
%         
%             imagesc(timeLock,currentSubj(1).totalNScountA,currentSubj(1).NSzpurpleAllTrialsA) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
%             title(strcat('Stage 1-4 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
%             xlabel('seconds from cue onset');
%             ylabel('trial (latency sorted)');
% %             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
%             caxis manual;
%             caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values
% 
%             c= colorbar; %colorbar legend
%             c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
%               
            
            
        subplot(2,3,5) %plot of stage 5 purple (cond B purple)
            
            imagesc(timeLock,currentSubj(1).totalNScountB,currentSubj(1).NSzpurpleAllTrialsB) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat('Stage 5 NS response (405nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
      if currentSubj(session).trainStage >5   
        subplot(2,3,6) %plot of stage 6-8 purple (cond C purple)
            imagesc(timeLock,currentSubj(1).totalNScountC,currentSubj(1).NSzpurpleAllTrialsC) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat(' Stage 6-8 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end
            
            
            %Overlay scatter of PE latency
   subplot(2,3,1) %condA NS blue 
   hold on
%    scatter(NSpeLatencySortedA,currentSubj(1).totalNScountA', 'm.');
   
   subplot(2,3,2) %condB NS blue 
   hold on
   scatter(NSpeLatencySortedB,currentSubj(1).totalNScountB', 'm.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC NS blue 
   hold on
   scatter(NSpeLatencySortedC,currentSubj(1).totalNScountC', 'm.');
   end
   
   subplot(2,3,4) %cond A NS purple
   hold on
%    scatter(NSpeLatencySortedA,currentSubj(1).totalNScountA', 'm.');
   
   subplot(2,3,5) %cond B NS purple
   hold on
   scatter(NSpeLatencySortedB,currentSubj(1).totalNScountB', 'm.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C NS purple
   hold on
   scatter(NSpeLatencySortedC,currentSubj(1).totalNScountC', 'm.');
   end
            
%      %overlay scatter of Licks- 
%        licksToPlot= 10;
%       lickAlpha= 0.35;
% 
%     
%        subplot(2,3,1) %condA NS blue 
%        hold on
% %       for trial= (currentSubj(1).totalNScountA)
% %            scatter all licks
% %                s= scatter(currentSubj(1).NSloxAllTrialsA{trial},ones(numel(currentSubj(1).NSloxAllTrialsA{trial}),1)*currentSubj(1).totalNScountA(trial), 'k.');
% %            scatter # of licksToPlot
% %            if numel(currentSubj(1).NSloxAllTrialsA{trial}) >= licksToPlot
% %                 s= scatter(currentSubj(1).NSloxAllTrialsA{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountA(trial), 'k.');
% %                 s.MarkerEdgeAlpha= 0.3; %make transparent
% %       end
% %       end
%     
%        subplot(2,3,2) %condB NS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountB)
%              % scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsB{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsB{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountB(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
% if currentSubj(session).trainStage >5       
%        subplot(2,3,3) %condC NS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountC)
%                % scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsC{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsC{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountC(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
% end   
% %        subplot(2,3,4) %condA NS purple 
% %        hold on
% %        for trial= (currentSubj(1).totalNScountA)
% %                %scatter # of licksToPlot
% %            if numel(currentSubj(1).NSloxAllTrialsA{trial}) >= licksToPlot
% %                 s= scatter(currentSubj(1).NSloxAllTrialsA{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountA(trial), 'k.');
% %                 s.MarkerEdgeAlpha= 0.3; %make transparent
% %            end
% %        end
%        subplot(2,3,5) %condB NS purple 
%        hold on
%        for trial= (currentSubj(1).totalNScountB)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsB{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsB{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountB(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
% if currentSubj(session).trainStage >5       
%        subplot(2,3,6) %condC NS purple 
%        hold on
%        for trial= (currentSubj(1).totalNScountC)
%               %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsC{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsC{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountC(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
% end           
%             
            set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
            saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'allstages_NScuelocked_sorted','.fig')); %save the current figure in fig format
       
  
  %% plots for stage 6,7,8 seperately   

   
   figure(figureCount);
  figureCount= figureCount+1;

    sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to DS across training stages- trials sorted by PE latency')); %add big title above all subplots
if currentSubj(session).trainStage ==6 
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
  elseif currentSubj(session).trainStage ==7
  
   subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
                
    subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzblueAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 7 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('7 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
         
         
  elseif currentSubj(session).trainStage ==8
      
      subplot(2,3,1) %plot of stage 6 blue (cond D blue)
       imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
                
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzblueAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 7 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('7 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
         
      
        subplot(2,3,3) %plot of stage 8 blue (cond F blue)
            imagesc(timeLock,currentSubj(1).totalDScountF,currentSubj(1).DSzblueAllTrialsF) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 8 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('8 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
          end

     if currentSubj(session).trainStage ==6
      subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     
            
     elseif currentSubj(session).trainStage ==7    
         
         subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     
         
        subplot(2,3,5) %plot of stage 7 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzpurpleAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat('Stage 7 DS response (405nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      elseif currentSubj(session).trainStage ==8 
          
           subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     
         
        subplot(2,3,5) %plot of stage 7 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzpurpleAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat('Stage 7 DS response (405nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
          
        subplot(2,3,6) %plot of stage 8 purple (cond F purple)
            imagesc(timeLock,currentSubj(1).totalDScountF,currentSubj(1).DSzpurpleAllTrialsF) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat(' Stage 8 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
       end   
 
  %Overlay scatter of PE latency
   if currentSubj(session).trainStage ==6
   subplot(2,3,1) %condD DS blue 
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');
   elseif currentSubj(session).trainStage==7  
   
   subplot(2,3,1) %condD DS blue 
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');    
       
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(DSpeLatencySortedE,currentSubj(1).totalDScountE', 'm.');
   
   elseif currentSubj(session).trainStage==8   
       
   subplot(2,3,1) %condD DS blue 
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');    
       
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(DSpeLatencySortedE,currentSubj(1).totalDScountE', 'm.');    
       
   subplot(2,3,3) %condF DS blue 
   hold on
   scatter(DSpeLatencySortedF,currentSubj(1).totalDScountF', 'm.');
   end
   
   if currentSubj(session).trainStage ==6
   subplot(2,3,4) %cond D DS purple
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');
   elseif currentSubj(session).trainStage==7  
       
    subplot(2,3,4) %cond D DS purple
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');    
   
   subplot(2,3,5) %cond E DS purple
   hold on
   scatter(DSpeLatencySortedE,currentSubj(1).totalDScountE', 'm.');
   elseif currentSubj(session).trainStage ==8
       
   subplot(2,3,4) %cond D DS purple
   hold on
   scatter(DSpeLatencySortedD,currentSubj(1).totalDScountD', 'm.');    
   
   subplot(2,3,5) %cond E DS purple
   hold on
   scatter(DSpeLatencySortedE,currentSubj(1).totalDScountE', 'm.');    
       
   subplot(2,3,6) %cond F DS purple
   hold on
   scatter(DSpeLatencySortedF,currentSubj(1).totalDScountF', 'm.');
   end
    
 %overlay scatter of Licks-DS BLUE
       licksToPlot= 10;
       lickAlpha= 0.15;
 
   if currentSubj(session).trainStage ==6    
       subplot(2,3,1) %condA DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==7
        subplot(2,3,1) %condD DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,2) %condE DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==8      
               subplot(2,3,1) %condD DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,2) %condE DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,3) %condF DS blue 
       hold on
       for trial= (currentSubj(1).totalDScountF)
                %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsF{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountF(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   end
   
   
 %overlay scatter of Licks-DS PURPLE
       licksToPlot= 10;
       lickAlpha= 0.15;
 
   if currentSubj(session).trainStage ==6    
       subplot(2,3,4) %condA DS purple 
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==7
        subplot(2,3,4) %condD DS purple
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,5) %condE DS purple 
       hold on
       for trial= (currentSubj(1).totalDScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==8      
               subplot(2,3,4) %condD DS purple
       hold on
       for trial= (currentSubj(1).totalDScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,5) %condE DS purple
       hold on
       for trial= (currentSubj(1).totalDScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,6) %condF DS purple 
       hold on
       for trial= (currentSubj(1).totalDScountF)
                %scatter # of licksToPlot
           if numel(currentSubj(1).DSloxAllTrialsF{trial}) >= licksToPlot
                s= scatter(currentSubj(1).DSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountF(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   end
    
    %worked for nested structure
    
   trialCount= 1;
    
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'latestages_DScuelocked_sorted','.fig')); %save the current figure in fig format
 
    
    %NS plots!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if currentSubj(session).trainStage==6   
       figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE latency')); %add big title above all subplots
   
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
 
  elseif currentSubj(session).trainStage==7  
      
       figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE latency')); %add big title above all subplots
   
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
 
      
      
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzblueAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 7 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
  
  elseif currentSubj(session).trainStage==8    
      
        figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE latency')); %add big title above all subplots
   
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
 
      
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzblueAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 7 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
      
        subplot(2,3,3) %plot of stage 6-8 blue (cond F blue)
            imagesc(timeLock,currentSubj(1).totalNScountF,currentSubj(1).NSzblueAllTrialsF) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 8 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat(' 6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  end           

  
  if currentSubj(session).trainStage ==6   
      subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  elseif currentSubj(session).trainStage ==7 
      
       subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,5) %plot of stage 5 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzpurpleAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat('Stage 7 NS response (405nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  elseif currentSubj(session).trainStage==8 
      
       subplot(2,3,4) %plot of stage 6 purple (cond D purple)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsD) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,5) %plot of stage 5 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzpurpleAllTrialsE) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat('Stage 7 NS response (405nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,6) %plot of stage 6-8 purple (cond C purple)
            imagesc(timeLock,currentSubj(1).totalNScountF,currentSubj(1).NSzpurpleAllTrialsF) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat(' Stage 8 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end
            
            
            %Overlay scatter of PE latency
            
   if currentSubj(session).trainStage==6  
   subplot(2,3,1) %condD NS blue 
   hold on
   scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');
   elseif currentSubj(session).trainStage==7 
       
   subplot(2,3,1) %condD NS blue 
   hold on
   scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');    
       
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(NSpeLatencySortedE,currentSubj(1).totalNScountE', 'm.');
   
   
   elseif currentSubj(session).trainStage==8
       
   subplot(2,3,1) %condD NS blue 
   hold on
   scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');    
       
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(NSpeLatencySortedE,currentSubj(1).totalNScountE', 'm.');
    
       
   subplot(2,3,3) %condF NS blue 
   hold on
   scatter(NSpeLatencySortedF,currentSubj(1).totalNScountF', 'm.');
   end
   
   if currentSubj(session).trainStage==6 
   subplot(2,3,4) %cond D NS purple
   hold on
  scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');
   
   elseif currentSubj(session).trainStage==7
   
   subplot(2,3,4) %cond D NS purple
   hold on
  scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');
       
   subplot(2,3,5) %cond E NS purple
   hold on
   scatter(NSpeLatencySortedE,currentSubj(1).totalNScountE', 'm.');
   
   elseif currentSubj(session).trainStage ==8
       
   subplot(2,3,4) %cond D NS purple
   hold on
  scatter(NSpeLatencySortedD,currentSubj(1).totalNScountD', 'm.');
       
   subplot(2,3,5) %cond E NS purple
   hold on
   scatter(NSpeLatencySortedE,currentSubj(1).totalNScountE', 'm.');    
       
   subplot(2,3,6) %cond F NS purple
   hold on
   scatter(NSpeLatencySortedF,currentSubj(1).totalNScountF', 'm.');
   end
            
 %overlay scatter of Licks-NS BLUE
       licksToPlot= 10;
       lickAlpha= 0.15;
 
   if currentSubj(session).trainStage ==6    
       subplot(2,3,1) %condA DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==7
        subplot(2,3,1) %condD DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,2) %condE DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==8      
               subplot(2,3,1) %condD DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,2) %condE DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,3) %condF DS blue 
       hold on
       for trial= (currentSubj(1).totalNScountF)
                %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsF{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountF(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   end
   
   
 %overlay scatter of Licks-NS PURPLE
       licksToPlot= 10;
       lickAlpha= 0.15;
 
   if currentSubj(session).trainStage ==6    
       subplot(2,3,4) %condA DS purple 
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==7
        subplot(2,3,4) %condD DS purple
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,5) %condE DS purple 
       hold on
       for trial= (currentSubj(1).totalNScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   elseif currentSubj(session).trainStage ==8      
               subplot(2,3,4) %condD DS purple
       hold on
       for trial= (currentSubj(1).totalNScountD)
           %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,5) %condE DS purple
       hold on
       for trial= (currentSubj(1).totalNScountE)
               %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
       
       subplot(2,3,6) %condF DS purple 
       hold on
       for trial= (currentSubj(1).totalNScountF)
                %scatter # of licksToPlot
           if numel(currentSubj(1).NSloxAllTrialsF{trial}) >= licksToPlot
                s= scatter(currentSubj(1).NSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountF(trial), 'k.');
                s.MarkerEdgeAlpha= lickAlpha; %make transparent
           end
       end
   end
    
            
            
            set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    
            saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'latestages_NScuelocked_sorted','.fig')); %save the current figure in fig format
       
           
end%end subj loop



%% ~~~ End~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
