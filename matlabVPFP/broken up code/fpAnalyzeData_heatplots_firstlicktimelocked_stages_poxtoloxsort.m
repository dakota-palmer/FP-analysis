%% stage 1-4, 5, 6+ trial DS plots loxrelpox sorted


%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

    %initialize/clear arrays between subjects

    currentSubj(1).NSzblueAllTrialsBlox =[];
    currentSubj(1).NSzpurpleAllTrialsBlox=[];
    currentSubj(1).NSpeLatencyAllTrialsBlox = [];
    currentSubj(1).NSloxrelpoxAllTrialsBlox=[];
    
     currentSubj(1).NSzblueAllTrialsClox =[];
    currentSubj(1).NSzpurpleAllTrialsClox=[];
    currentSubj(1).NSpeLatencyAllTrialsClox = [];
    currentSubj(1).NSloxrelpoxAllTrialsClox=[];
    
    currentSubj(1).NSzblueAllTrialsDlox =[];
    currentSubj(1).NSzpurpleAllTrialsDlox=[];
    currentSubj(1).NSpeLatencyAllTrialsDlox = [];
    currentSubj(1).NSloxrelpoxAllTrialsDlox=[];
    
    currentSubj(1).NSzblueAllTrialsElox =[];
    currentSubj(1).NSzpurpleAllTrialsElox=[];
    currentSubj(1).NSpeLatencyAllTrialsElox = [];
    currentSubj(1).NSloxrelpoxAllTrialsElox=[];
    
    currentSubj(1).NSzblueAllTrialsFlox =[];
    currentSubj(1).NSzpurpleAllTrialsFlox=[];
    currentSubj(1).NSpeLatencyAllTrialsFlox = [];
    currentSubj(1).NSloxrelpoxAllTrialsFlox=[];
            
            

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
        DSselected= currentSubj(session).periDSlox.DSselected;  % all the DS cues

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
        if ~isempty(currentSubj(session).periNSlox.NSselected)
             NSselected= currentSubj(session).periNSlox.NSselected;  

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
                    currentSubj(1).DSzblueAllTrialsAlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                    currentSubj(1).DSzpurpleAllTrialsAlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                    currentSubj(1).DSpeLatencyAllTrialsAlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                    currentSubj(1).DSloxrelpoxAllTrialsAlox=currentSubj(session).behavior.loxDSpoxRel(DSselected);

%                     currentSubj(1).DSloxAllTrialsA= currentSubj(session).behavior.loxDS{DSselected};
                    if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                        currentSubj(1).NSzblueAllTrialsAlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                        currentSubj(1).NSzpurpleAllTrialsAlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected));
                        currentSubj(1).NSpeLatencyAllTrialsAlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                        currentSubj(1).NSloxrelpoxAllTrialsAlox=currentSubj(session).behavior.loxNSpoxRel(NSselected);

                     else
%                        continue %continue if no NS data
                     end
                else %add subsequent sessions using cat()
                    currentSubj(1).DSzblueAllTrialsAlox = cat(2, currentSubj.DSzblueAllTrialsAlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                    currentSubj(1).DSzpurpleAllTrialsAlox = cat(2, currentSubj.DSzpurpleAllTrialsAlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                    currentSubj(1).DSpeLatencyAllTrialsAlox = cat(2,currentSubj(1).DSpeLatencyAllTrialsAlox,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                    currentSubj(1).DSloxrelpoxAllTrialsAlox=cat(2,currentSubj(1).DSloxrelpoxAllTrialsAlox,currentSubj(session).behavior.loxDSpoxRel(DSselected));
            
%                     currentSubj(1).DSloxAllTrialsA= cat(2,currentSubj(1).DSloxAllTrialsA,currentSubj(session).behavior.loxDS{DSselected});

                    if ~isempty(currentSubj(session).periNSlox.NSselected)
                        currentSubj(1).NSzblueAllTrialsAlox = cat(2, currentSubj.NSzblueAllTrialsAlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                        currentSubj(1).NSzpurpleAllTrialsAlox = cat(2, currentSubj.NSzpurpleAllTrialsAlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                        currentSubj(1).NSpeLatencyAllTrialsAlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsAlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                        currentSubj(1).NSloxrelpoxAllTrialsAlox=cat(2,currentSubj(1).NSloxrelpoxAllTrialslox,currentSubj(session).behavior.loxNSpoxRel(NSselected));
            
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
            allSubj(subj).DSzblueAllTrialsAlox= currentSubj(1).DSzblueAllTrialsAlox;
            allSubj(subj).DSzpurpleAllTrialsAlox= currentSubj(1).DSzpurpleAllTrialsAlox;
            allSubj(subj).DSpeLatencyAllTrialsAlox= currentSubj(1).DSpeLatencyAllTrialsAlox;
            allSubj(subj).DSloxrelpoxAllTrialsAlox=currentSubj(1).DSloxrelpoxAllTrialsAlox;
            
%             allSubj(subj).NSzblueAllTrialsA= currentSubj(1).NSzblueAllTrialsA;
%             allSubj(subj).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA;
%             allSubj(subj).NSpeLatencyAllTrialsA= currentSubj(1).NSpeLatencyAllTrialsA;

      
                sesCountA= sesCountA+1;
                subjSessA= cat(2, subjSessA, currentSubj(session).trainDay); %day count for y axis

            end %end Cond A
            
            %Condition B
                   if currentSubj(session).trainStage ==5
                        if sesCountB== 1 
                            currentSubj(1).DSzblueAllTrialsBlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                            currentSubj(1).DSzpurpleAllTrialsBlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                            currentSubj(1).DSpeLatencyAllTrialsBlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                            currentSubj(1).DSloxrelpoxAllTrialsBlox=currentSubj(session).behavior.loxDSpoxRel(DSselected);
 
                            if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                                currentSubj(1).NSzblueAllTrialsBlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                                currentSubj(1).NSzpurpleAllTrialsBlox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                                currentSubj(1).NSpeLatencyAllTrialsBlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                                currentSubj(1).NSloxrelpoxAllTrialsBlox=currentSubj(session).behavior.loxNSpoxRel(NSselected);
 
                            else
%                                continue %continue if no NS data
                             end
                        else %add subsequent sessions using cat()
                            currentSubj(1).DSzblueAllTrialsBlox = cat(2, currentSubj.DSzblueAllTrialsBlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                            currentSubj(1).DSzpurpleAllTrialsBlox = cat(2, currentSubj.DSzpurpleAllTrialsBlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                            currentSubj(1).DSpeLatencyAllTrialsBlox = cat(2,currentSubj(1).DSpeLatencyAllTrialsBlox,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                            currentSubj(1).DSloxrelpoxAllTrialsBlox=cat(2,currentSubj(1).DSloxrelpoxAllTrialsBlox,currentSubj(session).behavior.loxDSpoxRel(DSselected));
            
                            if ~isempty(currentSubj(session).periNSlox.NSselected)
                                currentSubj(1).NSzblueAllTrialsBlox = cat(2, currentSubj.NSzblueAllTrialsBlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                                currentSubj(1).NSzpurpleAllTrialsBlox = cat(2, currentSubj.NSzpurpleAllTrialsBlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                                currentSubj(1).NSpeLatencyAllTrialsBlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsBlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                                currentSubj(1).NSloxrelpoxAllTrialsBlox=cat(2,currentSubj(1).NSloxrelpoxAllTrialsBlox,currentSubj(session).behavior.loxNSpoxRel(NSselected));
            
                            else
%                                 continue %continue if nos NS data
                            end
                        end %end sesCount conditional

                       
                         %licks
                         if ~isempty(currentSubj(session).periNSlox.NSselected)  
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

                         end
                        
                        sesCountB= sesCountB+1;
                        subjSessB= cat(2, subjSessB, currentSubj(session).trainDay); %day count for y axis
                        
                         allSubj(subj).DSzblueAllTrialsBlox= currentSubj(1).DSzblueAllTrialsBlox;
                         allSubj(subj).DSzpurpleAllTrialsBlox= currentSubj(1).DSzpurpleAllTrialsBlox;
                         allSubj(subj).DSpeLatencyAllTrialsBlox= currentSubj(1).DSpeLatencyAllTrialsBlox;
                         allSubj(subj).DSloxrelpoxAllTrialsBlox=currentSubj(1).DSloxrelpoxAllTrialsBlox;
            
                         if ~isempty(currentSubj(session).periNSlox.NSselected)  
                         allSubj(subj).NSzblueAllTrialsBlox= currentSubj(1).NSzblueAllTrialsBlox;
                         allSubj(subj).NSzpurpleAllTrialsBlox= currentSubj(1).NSzpurpleAllTrialsBlox;
                         allSubj(subj).NSpeLatencyAllTrialsBlox= currentSubj(1).NSpeLatencyAllTrialsBlox;
                         allSubj(subj).NSloxrelpoxAllTrialsBlox=currentSubj(1).NSloxrelpoxAllTrialsBlox;
                         end
                  end %end Cond B
                  
              %Condition C
               if currentSubj(session).trainStage >5
                   
                    if sesCountC== 1 
                        currentSubj(1).DSzblueAllTrialsClox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsClox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsClox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsClox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsClox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsClox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsClox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsClox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsClox = cat(2, currentSubj.DSzblueAllTrialsClox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsClox = cat(2, currentSubj.DSzpurpleAllTrialsClox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsClox = cat(2, currentSubj(1).DSpeLatencyAllTrialsClox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsClox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsClox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsClox = cat(2, currentSubj.NSzblueAllTrialsClox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsClox = cat(2, currentSubj.NSzpurpleAllTrialsClox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsClox = cat(2,currentSubj(1).NSpeLatencyAllTrialsClox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsClox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsClox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                    if ~isempty(currentSubj(session).periNSlox.NSselected)   
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
                    end
                    sesCountC= sesCountC+1;
                    subjSessC= cat(2, subjSessC, currentSubj(session).trainDay); %day count for y axis

                     allSubj(subj).DSzblueAllTrialsClox= currentSubj(1).DSzblueAllTrialsClox;
                     allSubj(subj).DSzpurpleAllTrialsClox= currentSubj(1).DSzpurpleAllTrialsClox;
                     allSubj(subj).DSpeLatencyAllTrialsClox= currentSubj(1).DSpeLatencyAllTrialsClox;
                     allSubj(subj).DSloxrelpoxAllTrialsClox=currentSubj(1).DSloxrelpoxAllTrialsClox;
                     
                     allSubj(subj).NSzblueAllTrialsClox= currentSubj(1).NSzblueAllTrialsClox;
                     allSubj(subj).NSzpurpleAllTrialsClox= currentSubj(1).NSzpurpleAllTrialsClox;
                     allSubj(subj).NSpeLatencyAllTrialsClox= currentSubj(1).NSpeLatencyAllTrialsClox;
                     allSubj(subj).NSloxrelpoxAllTrialsClox=currentSubj(1).NSloxrelpoxAllTrialsClox;

                    
                    
              end %end Cond C
              
         %Condition D
               if currentSubj(session).trainStage ==6
                   
                         if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsDlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsDlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsDlox = cat(2, currentSubj.DSzblueAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsDlox = cat(2, currentSubj.DSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsDlox = cat(2, currentSubj(1).DSpeLatencyAllTrialsDlox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsDlox = cat(2, currentSubj.NSzblueAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsDlox = cat(2, currentSubj.NSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsDlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsDlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
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

                     allSubj(subj).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox;
                     allSubj(subj).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox;
                     allSubj(subj).DSpeLatencyAllTrialsDlox= currentSubj(1).DSpeLatencyAllTrialsDlox;
                     allSubj(subj).DSloxrelpoxAllTrialsDlox=currentSubj(1).DSloxrelpoxAllTrialsDlox;
                     
                     allSubj(subj).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox;
                     allSubj(subj).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox;
                     allSubj(subj).NSpeLatencyAllTrialsDlox= currentSubj(1).NSpeLatencyAllTrialsDlox;
                     allSubj(subj).NSloxrelpoxAllTrialsDlox=currentSubj(1).NSloxrelpoxAllTrialsDlox;
               
                     %end Cond D
              
              
        %Condition E
               elseif currentSubj(session).trainStage ==7
           
            %Condition D
            
                    if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsDlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsDlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsDlox = cat(2, currentSubj.DSzblueAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsDlox = cat(2, currentSubj.DSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsDlox = cat(2, currentSubj(1).DSpeLatencyAllTrialsDlox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsDlox = cat(2, currentSubj.NSzblueAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsDlox = cat(2, currentSubj.NSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsDlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsDlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional

                    
                    if ~isempty(currentSubj(session).periNSlox.NSselected)
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
                    end
                    sesCountD= sesCountD+1;
                    subjSessD= cat(2, subjSessD, currentSubj(session).trainDay); %day count for y axis

                     allSubj(subj).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox;
                     allSubj(subj).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox;
                     allSubj(subj).DSpeLatencyAllTrialsDlox= currentSubj(1).DSpeLatencyAllTrialsDlox;
                     allSubj(subj).DSloxrelpoxAllTrialsDlox=currentSubj(1).DSloxrelpoxAllTrialsDlox;
                     
                     allSubj(subj).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox;
                     allSubj(subj).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox;
                     allSubj(subj).NSpeLatencyAllTrialsDlox= currentSubj(1).NSpeLatencyAllTrialsDlox;
                     allSubj(subj).NSloxrelpoxAllTrialsDlox=currentSubj(1).NSloxrelpoxAllTrialsDlox;
               
                     %end Cond D 

                   %Condition E
                   if sesCountE== 1 
                        currentSubj(1).DSzblueAllTrialsElox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsElox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsElox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsElox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsElox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsElox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsElox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsElox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsElox = cat(2, currentSubj.DSzblueAllTrialsElox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsElox = cat(2, currentSubj.DSzpurpleAllTrialsElox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsElox = cat(2, currentSubj(1).DSpeLatencyAllTrialsElox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsElox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsElox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsElox = cat(2, currentSubj.NSzblueAllTrialsElox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsElox = cat(2, currentSubj.NSzpurpleAllTrialsElox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsElox = cat(2,currentSubj(1).NSpeLatencyAllTrialsElox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsElox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsElox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
                        else
%                             continue %continue if nos NS data
                        end
                    end %end sesCount conditional
                    
                    if ~isempty(currentSubj(session).periNSlox.NSselected)
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
                    end
                    
                    sesCountE= sesCountE+1;
                    subjSessE= cat(2, subjSessE, currentSubj(session).trainDay); %day count for y axis

                     allSubj(subj).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox;
                     allSubj(subj).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox;
                     allSubj(subj).DSpeLatencyAllTrialsElox= currentSubj(1).DSpeLatencyAllTrialsElox;
                     allSubj(subj).DSloxrelpoxAllTrialsElox=currentSubj(1).DSloxrelpoxAllTrialsElox;
                     
                     allSubj(subj).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox;
                     allSubj(subj).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox;
                     allSubj(subj).NSpeLatencyAllTrialsElox= currentSubj(1).NSpeLatencyAllTrialsElox;
                     allSubj(subj).NSloxrelpoxAllTrialsElox=currentSubj(1).NSloxrelpoxAllTrialsElox;
               
                   
               %end Cond E
   
               
                   %Condition F
               elseif currentSubj(session).trainStage ==8
                   
                   %Condition D
            
                    if sesCountD== 1 
                        currentSubj(1).DSzblueAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsDlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsDlox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsDlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsDlox = cat(2, currentSubj.DSzblueAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsDlox = cat(2, currentSubj.DSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsDlox = cat(2, currentSubj(1).DSpeLatencyAllTrialsDlox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsDlox = cat(2, currentSubj.NSzblueAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsDlox = cat(2, currentSubj.NSzpurpleAllTrialsDlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsDlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsDlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsDlox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsDlox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
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

                     allSubj(subj).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox;
                     allSubj(subj).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox;
                     allSubj(subj).DSpeLatencyAllTrialsDlox= currentSubj(1).DSpeLatencyAllTrialsDlox;
                     allSubj(subj).DSloxrelpoxAllTrialsDlox=currentSubj(1).DSloxrelpoxAllTrialsDlox;
                     
                     allSubj(subj).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox;
                     allSubj(subj).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox;
                     allSubj(subj).NSpeLatencyAllTrialsDlox= currentSubj(1).NSpeLatencyAllTrialsDlox;
                     allSubj(subj).NSloxrelpoxAllTrialsDlox=currentSubj(1).NSloxrelpoxAllTrialsDlox;
               
                     %end Cond D 

                   %Condition E
                   if sesCountE== 1 
                        currentSubj(1).DSzblueAllTrialsElox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsElox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsElox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsElox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsElox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsElox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsElox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsElox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsElox = cat(2, currentSubj.DSzblueAllTrialsElox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsElox = cat(2, currentSubj.DSzpurpleAllTrialsElox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsElox = cat(2, currentSubj(1).DSpeLatencyAllTrialsElox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsElox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsElox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsElox = cat(2, currentSubj.NSzblueAllTrialsElox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsElox = cat(2, currentSubj.NSzpurpleAllTrialsElox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsElox = cat(2,currentSubj(1).NSpeLatencyAllTrialsElox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsElox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsElox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
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

                     allSubj(subj).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox;
                     allSubj(subj).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox;
                     allSubj(subj).DSpeLatencyAllTrialsElox= currentSubj(1).DSpeLatencyAllTrialsElox;
                     allSubj(subj).DSloxrelpoxAllTrialsElox=currentSubj(1).DSloxrelpoxAllTrialsElox;
                     
                     allSubj(subj).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox;
                     allSubj(subj).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox;
                     allSubj(subj).NSpeLatencyAllTrialsElox= currentSubj(1).NSpeLatencyAllTrialsElox;
                     allSubj(subj).NSloxrelpoxAllTrialsElox=currentSubj(1).NSloxrelpoxAllTrialsElox;
               
                   
               %end Cond E
               
               
                % Cond F
                       if sesCountF== 1 
                        currentSubj(1).DSzblueAllTrialsFlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSzpurpleAllTrialsFlox= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected));
                        currentSubj(1).DSpeLatencyAllTrialsFlox= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
                        currentSubj(1).DSloxrelpoxAllTrialsFlox=currentSubj(session).behavior.loxDSpoxRel(DSselected); 
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                            currentSubj(1).NSzblueAllTrialsFlox= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                            currentSubj(1).NSzpurpleAllTrialsFlox= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                            currentSubj(1).NSpeLatencyAllTrialsFlox= currentSubj(session).behavior.NSpeLatency(NSselected); 
                            currentSubj(1).NSloxrelpoxAllTrialsFlox=currentSubj(session).behavior.loxNSpoxRel(NSselected); 
          
                         else
%                            continue %continue if no NS data
                         end
                    else %add subsequent sessions using cat()
                        currentSubj(1).DSzblueAllTrialsFlox = cat(2, currentSubj.DSzblueAllTrialsFlox, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSzpurpleAllTrialsFlox = cat(2, currentSubj.DSzpurpleAllTrialsFlox, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                        currentSubj(1).DSpeLatencyAllTrialsFlox = cat(2, currentSubj(1).DSpeLatencyAllTrialsFlox, currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
                        currentSubj(1).DSloxrelpoxAllTrialsFlox=cat(2, currentSubj(1).DSloxrelpoxAllTrialsFlox,currentSubj(session).behavior.loxDSpoxRel(DSselected)); 
          
                        
                        if ~isempty(currentSubj(session).periNSlox.NSselected)
                            currentSubj(1).NSzblueAllTrialsFlox = cat(2, currentSubj.NSzblueAllTrialsFlox, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                            currentSubj(1).NSzpurpleAllTrialsFlox = cat(2, currentSubj.NSzpurpleAllTrialsFlox, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                            currentSubj(1).NSpeLatencyAllTrialsFlox = cat(2,currentSubj(1).NSpeLatencyAllTrialsFlox,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                            currentSubj(1).NSloxrelpoxAllTrialsFlox=cat(2, currentSubj(1).NSloxrelpoxAllTrialsFlox,currentSubj(session).behavior.loxNSpoxRel(NSselected)); 
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

                     allSubj(subj).DSzblueAllTrialsFlox= currentSubj(1).DSzblueAllTrialsFlox;
                     allSubj(subj).DSzpurpleAllTrialsFlox= currentSubj(1).DSzpurpleAllTrialsFlox;
                     allSubj(subj).DSpeLatencyAllTrialsFlox= currentSubj(1).DSpeLatencyAllTrialsFlox;
                     allSubj(subj).DSloxrelpoxAllTrialsFlox=currentSubj(1).DSloxrelpoxAllTrialsFlox;
                     
                     allSubj(subj).NSzblueAllTrialsFlox= currentSubj(1).NSzblueAllTrialsFlox;
                     allSubj(subj).NSzpurpleAllTrialsFlox= currentSubj(1).NSzpurpleAllTrialsFlox;
                     allSubj(subj).NSpeLatencyAllTrialsFlox= currentSubj(1).NSpeLatencyAllTrialsFlox;
                     allSubj(subj).NSloxrelpoxAllTrialsFlox=currentSubj(1).NSloxrelpoxAllTrialsFlox;
               
              
               end %end Cond all late stages
    end %end session loop
    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data and other behavioralevents(licks)
    
    %cond a
    %get first timestamp that represents  the time from the first lick to PE     
    DSloxrelpoxAllTrialsAlox=[];
 
    
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsAlox)
    DSloxrelpoxAllTrialsAlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsAlox{1,trial}(1,1);
    end   
    [DSloxrelpoxSortedAlox,DSsortIndAlox] = sort(DSloxrelpoxAllTrialsAlox);       

    %cond b
      % sort time between lox and pox

    
    DSloxrelpoxAllTrialsBlox=[];
    NSloxrelpoxAllTrialsBlox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsBlox)
    DSloxrelpoxAllTrialsBlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsBlox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsBlox)
    NSloxrelpoxAllTrialsBlox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsBlox{1,trial}(1,1);
    end        
  
     [DSloxrelpoxSortedBlox,DSsortIndBlox] = sort(DSloxrelpoxAllTrialsBlox);      
     [NSloxrelpoxSortedBlox,NSsortIndBlox] = sort(NSloxrelpoxAllTrialsBlox);
     
     
    %cond c
         if currentSubj(session).trainStage >5
             
    DSloxrelpoxAllTrialsClox=[];
    NSloxrelpoxAllTrialsClox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsClox)
    DSloxrelpoxAllTrialsClox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsClox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsClox)
    NSloxrelpoxAllTrialsClox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsClox{1,trial}(1,1);
    end           
             
     [DSloxrelpoxSortedClox,DSsortIndClox] = sort(DSloxrelpoxAllTrialsClox);      
     [NSloxrelpoxSortedClox,NSsortIndClox] = sort(NSloxrelpoxAllTrialsClox);
      end
    %cond d
    if currentSubj(session).trainStage==6
             
    DSloxrelpoxAllTrialsDlox=[];
    NSloxrelpoxAllTrialsDlox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsDlox)
    DSloxrelpoxAllTrialsDlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsDlox)
    NSloxrelpoxAllTrialsDlox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end          
             
     [DSloxrelpoxSortedDlox,DSsortIndDlox] = sort(DSloxrelpoxAllTrialsDlox);      
     [NSloxrelpoxSortedDlox,NSsortIndDlox] = sort(DSloxrelpoxAllTrialsDlox);

   %cond e
   elseif currentSubj(session).trainStage==7
               
    DSloxrelpoxAllTrialsDlox=[];
    NSloxrelpoxAllTrialsDlox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsDlox)
    DSloxrelpoxAllTrialsDlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsDlox)
    NSloxrelpoxAllTrialsDlox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end             
                               
   [DSloxrelpoxSortedDlox,DSsortIndDlox] = sort(DSloxrelpoxAllTrialsDlox);      
   [NSloxrelpoxSortedDlox,NSsortIndDlox] = sort(NSloxrelpoxAllTrialsDlox);     
    
    DSloxrelpoxAllTrialsElox=[];
    NSloxrelpoxAllTrialsElox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsElox)
    DSloxrelpoxAllTrialsElox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsElox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsElox)
    NSloxrelpoxAllTrialsElox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsElox{1,trial}(1,1);
    end
   
   [DSloxrelpoxSortedElox,DSsortIndElox] = sort(DSloxrelpoxAllTrialsElox);      
   [NSloxrelpoxSortedElox,NSsortIndElox] = sort(NSloxrelpoxAllTrialsElox);
   
   
%cond f    
    elseif currentSubj(session).trainStage==8
             
                  
    DSloxrelpoxAllTrialsDlox=[];
    NSloxrelpoxAllTrialsDlox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsDlox)
    DSloxrelpoxAllTrialsDlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsDlox)
    NSloxrelpoxAllTrialsDlox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsDlox{1,trial}(1,1);
    end             
                               
   [DSloxrelpoxSortedDlox,DSsortIndDlox] = sort(DSloxrelpoxAllTrialsDlox);      
   [NSloxrelpoxSortedDlox,NSsortIndDlox] = sort(NSloxrelpoxAllTrialsDlox);     
    
    DSloxrelpoxAllTrialsElox=[];
    NSloxrelpoxAllTrialsElox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsElox)
    DSloxrelpoxAllTrialsElox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsElox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsElox)
    NSloxrelpoxAllTrialsElox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsElox{1,trial}(1,1);
    end
   
   [DSloxrelpoxSortedElox,DSsortIndElox] = sort(DSloxrelpoxAllTrialsElox);      
   [NSloxrelpoxSortedElox,NSsortIndElox] = sort(NSloxrelpoxAllTrialsElox);
    
    DSloxrelpoxAllTrialsFlox=[];
    NSloxrelpoxAllTrialsFlox=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrialsFlox)
    DSloxrelpoxAllTrialsFlox(1,trial)= currentSubj(1).DSloxrelpoxAllTrialsFlox{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrialsFlox)
    NSloxrelpoxAllTrialsFlox(1,trial)=currentSubj(1).NSloxrelpoxAllTrialsFlox{1,trial}(1,1);
    end
   
     [DSloxrelpoxSortedFlox,DSsortIndFlox] = sort(DSloxrelpoxAllTrialsFlox);      
     [NSloxrelpoxSortedFlox,NSsortIndFlox] = sort(NSloxrelpoxAllTrialsFlox);  
         
    end
    
    
  %Sort PE latencies by time between PE and first lick
        %cond a
    DSpeLatencySortedAlox = currentSubj(1).DSpeLatencyAllTrialsAlox(:,DSsortIndAlox);       
%     [NSpeLatencySortedA,NSsortIndA] =  %stages before 5 have no ns %sort(currentSubj(1).NSpeLatencyAllTrialsA);

         %cond b
    DSpeLatencySortedBlox = currentSubj(1).DSpeLatencyAllTrialsBlox(:,DSsortIndBlox);       
    NSpeLatencySortedBlox = currentSubj(1).NSpeLatencyAllTrialsBlox(:,NSsortIndBlox);
        %cond c
         if currentSubj(session).trainStage >5
    DSpeLatencySortedClox = currentSubj(1).DSpeLatencyAllTrialsClox(:,DSsortIndClox);       
    NSpeLatencySortedClox = currentSubj(1).NSpeLatencyAllTrialsClox(:,NSsortIndClox);
         end
          %cond d
         if currentSubj(session).trainStage==6
    DSpeLatencySortedDlox = currentSubj(1).DSpeLatencyAllTrialsDlox(:,DSsortIndDlox);       
    NSpeLatencySortedDlox = currentSubj(1).NSpeLatencyAllTrialsDlox(:,NSsortIndDlox);
        
         %cond e
         elseif currentSubj(session).trainStage==7
     
    DSpeLatencySortedDlox = currentSubj(1).DSpeLatencyAllTrialsDlox(:,DSsortIndDlox);       
    NSpeLatencySortedDlox = currentSubj(1).NSpeLatencyAllTrialsDlox(:,NSsortIndDlox);      
             
    DSpeLatencySortedElox = currentSubj(1).DSpeLatencyAllTrialsElox(:,DSsortIndElox);       
    NSpeLatencySortedElox = currentSubj(1).NSpeLatencyAllTrialsElox(:,NSsortIndElox);
        
         elseif currentSubj(session).trainStage==8
             
    DSpeLatencySortedDlox = currentSubj(1).DSpeLatencyAllTrialsDlox(:,DSsortIndDlox);       
    NSpeLatencySortedDlox = currentSubj(1).NSpeLatencyAllTrialsDlox(:,NSsortIndDlox);      
             
    DSpeLatencySortedElox = currentSubj(1).DSpeLatencyAllTrialsElox(:,DSsortIndElox);       
    NSpeLatencySortedElox = currentSubj(1).NSpeLatencyAllTrialsElox(:,NSsortIndElox); 
             
    DSpeLatencySortedFlox = currentSubj(1).DSpeLatencyAllTrialsFlox(:,DSsortIndFlox);       
    NSpeLatencySortedFlox = currentSubj(1).NSpeLatencyAllTrialsFlox(:,NSsortIndFlox);
         end

         
         
    %Sort all trials by time between PE and first lick
        %cond a
    currentSubj(1).DSzblueAllTrialsAlox= currentSubj(1).DSzblueAllTrialsAlox(:,DSsortIndAlox);
    currentSubj(1).DSzpurpleAllTrialsAlox= currentSubj(1).DSzpurpleAllTrialsAlox(:,DSsortIndAlox);
%     currentSubj(1).NSzblueAllTrialsA = currentSubj(1).NSzblueAllTrialsA(:,NSsortIndA);
%     currentSubj(1).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA(:,NSsortIndA);

%              % sort licks
%              currentSubj(1).DSloxAllTrialsA= DSloxAllTrialsA;
%              currentSubj(1).DSloxAllTrialsA= currentSubj(1).DSloxAllTrialsA(:,DSsortIndAlox);


         %cond b
    currentSubj(1).DSzblueAllTrialsBlox= currentSubj(1).DSzblueAllTrialsBlox(:,DSsortIndBlox);
    currentSubj(1).DSzpurpleAllTrialsBlox= currentSubj(1).DSzpurpleAllTrialsBlox(:,DSsortIndBlox);
    currentSubj(1).NSzblueAllTrialsBlox = currentSubj(1).NSzblueAllTrialsBlox(:,NSsortIndBlox);
    currentSubj(1).NSzpurpleAllTrialsBlox= currentSubj(1).NSzpurpleAllTrialsBlox(:,NSsortIndBlox);
    
%              % sort licks
%              currentSubj(1).DSloxAllTrialsB= DSloxAllTrialsB;
%              currentSubj(1).DSloxAllTrialsB= currentSubj(1).DSloxAllTrialsB(:,DSsortIndBlox);
%              
%              currentSubj(1).NSloxAllTrialsB= NSloxAllTrialsB;
%              currentSubj(1).NSloxAllTrialsB= currentSubj(1).NSloxAllTrialsB(:,NSsortIndBlox);


    %cond C
           if currentSubj(session).trainStage >5
    currentSubj(1).DSzblueAllTrialsClox= currentSubj(1).DSzblueAllTrialsClox(:,DSsortIndClox);
    currentSubj(1).DSzpurpleAllTrialsClox= currentSubj(1).DSzpurpleAllTrialsClox(:,DSsortIndClox);
    currentSubj(1).NSzblueAllTrialsClox = currentSubj(1).NSzblueAllTrialsClox(:,NSsortIndClox);
    currentSubj(1).NSzpurpleAllTrialsClox= currentSubj(1).NSzpurpleAllTrialsClox(:,NSsortIndClox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsC= DSloxAllTrialsC;
%              currentSubj(1).DSloxAllTrialsC= currentSubj(1).DSloxAllTrialsC(:,DSsortIndClox);
%              
%              currentSubj(1).NSloxAllTrialsC= NSloxAllTrialsC;
%              currentSubj(1).NSloxAllTrialsC= currentSubj(1).NSloxAllTrialsC(:,NSsortIndClox);
%              
              % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsClox= currentSubj(1).DSloxrelpoxAllTrialsClox(:,DSsortIndClox);
    currentSubj(1).NSloxrelpoxAllTrialsClox= currentSubj(1).NSloxrelpoxAllTrialsClox(:,NSsortIndClox);

           end
           
      %cond D
           if currentSubj(session).trainStage ==6
    currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSzblueAllTrialsDlox = currentSubj(1).NSzblueAllTrialsDlox(:,NSsortIndDlox);
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox(:,NSsortIndDlox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
%              currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndDlox);
%              
%              currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
%              currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndDlox);
             
              % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsDlox= currentSubj(1).DSloxrelpoxAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSloxrelpoxAllTrialsDlox= currentSubj(1).NSloxrelpoxAllTrialsDlox(:,NSsortIndDlox);

            %cond E
           elseif currentSubj(session).trainStage ==7
     currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSzblueAllTrialsDlox = currentSubj(1).NSzblueAllTrialsDlox(:,NSsortIndDlox);
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox(:,NSsortIndDlox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
%              currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndDlox);
%              
%              currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
%              currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndDlox);
                     % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsDlox= currentSubj(1).DSloxrelpoxAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSloxrelpoxAllTrialsDlox= currentSubj(1).NSloxrelpoxAllTrialsDlox(:,NSsortIndDlox);
    
               
    currentSubj(1).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox(:,NSsortIndElox);
    currentSubj(1).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox(:,NSsortIndElox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsE= DSloxAllTrialsE;
%              currentSubj(1).DSloxAllTrialsE= currentSubj(1).DSloxAllTrialsE(:,DSsortIndElox);
%              
%              currentSubj(1).NSloxAllTrialsE= NSloxAllTrialsElox;
%              currentSubj(1).NSloxAllTrialsE= currentSubj(1).NSloxAllTrialsE(:,NSsortIndElox);
                 % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsElox= currentSubj(1).DSloxrelpoxAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).NSloxrelpoxAllTrialsElox= currentSubj(1).NSloxrelpoxAllTrialsElox(:,NSsortIndElox);
     
 
            %cond F
           elseif currentSubj(session).trainStage ==8
              
     currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSzblueAllTrialsDlox = currentSubj(1).NSzblueAllTrialsDlox(:,NSsortIndDlox);
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox(:,NSsortIndDlox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsD= DSloxAllTrialsD;
%              currentSubj(1).DSloxAllTrialsD= currentSubj(1).DSloxAllTrialsD(:,DSsortIndDlox);
%              
%              currentSubj(1).NSloxAllTrialsD= NSloxAllTrialsD;
%              currentSubj(1).NSloxAllTrialsD= currentSubj(1).NSloxAllTrialsD(:,NSsortIndDlox);
                    % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsDlox= currentSubj(1).DSloxrelpoxAllTrialsDlox(:,DSsortIndDlox);
    currentSubj(1).NSloxrelpoxAllTrialsDlox= currentSubj(1).NSloxrelpoxAllTrialsDlox(:,NSsortIndDlox);
    
         
    currentSubj(1).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox(:,NSsortIndElox);
    currentSubj(1).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox(:,NSsortIndElox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsE= DSloxAllTrialsE;
%              currentSubj(1).DSloxAllTrialsE= currentSubj(1).DSloxAllTrialsE(:,DSsortIndElox);
%              
%              currentSubj(1).NSloxAllTrialsE= NSloxAllTrialsE;
%              currentSubj(1).NSloxAllTrialsE= currentSubj(1).NSloxAllTrialsE(:,NSsortIndElox);
                        % sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsElox= currentSubj(1).DSloxrelpoxAllTrialsElox(:,DSsortIndElox);
    currentSubj(1).NSloxrelpoxAllTrialsElox= currentSubj(1).NSloxrelpoxAllTrialsElox(:,NSsortIndElox);

               
    currentSubj(1).DSzblueAllTrialsFlox= currentSubj(1).DSzblueAllTrialsFlox(:,DSsortIndFlox);
    currentSubj(1).DSzpurpleAllTrialsFlox= currentSubj(1).DSzpurpleAllTrialsFlox(:,DSsortIndFlox);
    currentSubj(1).NSzblueAllTrialsFlox = currentSubj(1).NSzblueAllTrialsFlox(:,NSsortIndFlox);
    currentSubj(1).NSzpurpleAllTrialsFlox= currentSubj(1).NSzpurpleAllTrialsFlox(:,NSsortIndFlox);
%                % sort licks
%              currentSubj(1).DSloxAllTrialsF= DSloxAllTrialsF;
%              currentSubj(1).DSloxAllTrialsF= currentSubj(1).DSloxAllTrialsF(:,DSsortIndFlox);
%              
%              currentSubj(1).NSloxAllTrialsF= NSloxAllTrialsF;
%              currentSubj(1).NSloxAllTrialsF= currentSubj(1).NSloxAllTrialsF(:,NSsortIndFlox);
    
% sort time between lox and pox
    currentSubj(1).DSloxrelpoxAllTrialsFlox= currentSubj(1).DSloxrelpoxAllTrialsFlox(:,DSsortIndFlox);
    currentSubj(1).NSloxrelpoxAllTrialsFlox= currentSubj(1).NSloxrelpoxAllTrialsFlox(:,NSsortIndFlox);
 
     end       

    %Transpose these data for readability
        %cond a
    currentSubj(1).DSzblueAllTrialsAlox= currentSubj(1).DSzblueAllTrialsAlox';
    currentSubj(1).DSzpurpleAllTrialsAlox= currentSubj(1).DSzpurpleAllTrialsAlox'; 

   
%     currentSubj(1).NSzblueAllTrialsA= currentSubj(1).NSzblueAllTrialsA';
%     currentSubj(1).NSzpurpleAllTrialsA= currentSubj(1).NSzpurpleAllTrialsA';
        %cond b
    currentSubj(1).DSzblueAllTrialsBlox= currentSubj(1).DSzblueAllTrialsBlox';
    currentSubj(1).DSzpurpleAllTrialsBlox= currentSubj(1).DSzpurpleAllTrialsBlox';    
    currentSubj(1).NSzblueAllTrialsBlox= currentSubj(1).NSzblueAllTrialsBlox';
    currentSubj(1).NSzpurpleAllTrialsBlox= currentSubj(1).NSzpurpleAllTrialsBlox';

 
        %cond c
         if currentSubj(session).trainStage >5
    currentSubj(1).DSzblueAllTrialsClox= currentSubj(1).DSzblueAllTrialsClox';
    currentSubj(1).DSzpurpleAllTrialsClox= currentSubj(1).DSzpurpleAllTrialsClox';    
    currentSubj(1).NSzblueAllTrialsClox= currentSubj(1).NSzblueAllTrialsClox';
    currentSubj(1).NSzpurpleAllTrialsClox= currentSubj(1).NSzpurpleAllTrialsClox';

    
         end
     %cond d
         if currentSubj(session).trainStage ==6
    currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox';
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox';    
    currentSubj(1).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox';
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox';

 
  
       %cond e
       elseif currentSubj(session).trainStage ==7
     currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox';
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox';    
    currentSubj(1).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox';
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox';

           
    currentSubj(1).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox';
    currentSubj(1).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox';    
    currentSubj(1).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox';
    currentSubj(1).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox';

     
          
         %cond f
         elseif currentSubj(session).trainStage ==8
     
    currentSubj(1).DSzblueAllTrialsDlox= currentSubj(1).DSzblueAllTrialsDlox';
    currentSubj(1).DSzpurpleAllTrialsDlox= currentSubj(1).DSzpurpleAllTrialsDlox';    
    currentSubj(1).NSzblueAllTrialsDlox= currentSubj(1).NSzblueAllTrialsDlox';
    currentSubj(1).NSzpurpleAllTrialsDlox= currentSubj(1).NSzpurpleAllTrialsDlox';

           
    currentSubj(1).DSzblueAllTrialsElox= currentSubj(1).DSzblueAllTrialsElox';
    currentSubj(1).DSzpurpleAllTrialsElox= currentSubj(1).DSzpurpleAllTrialsElox';    
    currentSubj(1).NSzblueAllTrialsElox= currentSubj(1).NSzblueAllTrialsElox';
    currentSubj(1).NSzpurpleAllTrialsElox= currentSubj(1).NSzpurpleAllTrialsElox';

     
             
    currentSubj(1).DSzblueAllTrialsFlox= currentSubj(1).DSzblueAllTrialsFlox';
    currentSubj(1).DSzpurpleAllTrialsFlox= currentSubj(1).DSzpurpleAllTrialsFlox';    
    currentSubj(1).NSzblueAllTrialsFlox= currentSubj(1).NSzblueAllTrialsFlox';
    currentSubj(1).NSzpurpleAllTrialsFlox= currentSubj(1).NSzpurpleAllTrialsFlox';

     
         end 
         
         
       %get trial count for y axis of heatplot
   currentSubj(1).totalDScountA= 1:size(currentSubj(1).DSzblueAllTrialsAlox,1); 
   currentSubj(1).totalDScountB= 1:size(currentSubj(1).DSzblueAllTrialsBlox,1);
    currentSubj(1).totalNScountB= 1:size(currentSubj(1).NSzblueAllTrialsBlox,1);
    if currentSubj(session).trainStage >5
   currentSubj(1).totalDScountC= 1:size(currentSubj(1).DSzblueAllTrialsClox,1);
    currentSubj(1).totalNScountC= 1:size(currentSubj(1).NSzblueAllTrialsClox,1);
    end
    
%    currentSubj(1).totalNScountA= 1:size(currentSubj(1).NSzblueAllTrialsA,1); 
  
    if currentSubj(session).trainStage ==6
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsDlox,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsDlox,1);
    
    elseif currentSubj(session).trainStage ==7  
        
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsDlox,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsDlox,1);
        
    currentSubj(1).totalDScountE= 1:size(currentSubj(1).DSzblueAllTrialsElox,1);
    currentSubj(1).totalNScountE= 1:size(currentSubj(1).NSzblueAllTrialsElox,1);
    
    elseif currentSubj(session).trainStage ==8  
    currentSubj(1).totalDScountD= 1:size(currentSubj(1).DSzblueAllTrialsDlox,1);
    currentSubj(1).totalNScountD= 1:size(currentSubj(1).NSzblueAllTrialsDlox,1);
        
    currentSubj(1).totalDScountE= 1:size(currentSubj(1).DSzblueAllTrialsElox,1);
    currentSubj(1).totalNScountE= 1:size(currentSubj(1).NSzblueAllTrialsElox,1);    
        
    currentSubj(1).totalDScountF= 1:size(currentSubj(1).DSzblueAllTrialsFlox,1);
    currentSubj(1).totalNScountF= 1:size(currentSubj(1).NSzblueAllTrialsFlox,1);
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
     topDSzblueA= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsAlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleA= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsAlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueA = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsAlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleA= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsAlox, 0, 2))));
     
     %cond B
     topDSzblueB= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsBlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleB= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsBlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueB = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsBlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleB= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsBlox, 0, 2))));
     
      %cond D
      if currentSubj(session).trainStage ==6
     topDSzblueD= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));
      
      %cond E
      elseif currentSubj(session).trainStage ==7
       topDSzblueD= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));    
          
     topDSzblueE= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleE= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueE = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleE= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsElox, 0, 2))));
      
      %cond F
      elseif currentSubj(session).trainStage ==8
     
     topDSzblueD= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleD= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueD = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsDlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleD= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsDlox, 0, 2))));    
          
     topDSzblueE= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleE= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueE = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsElox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleE= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsElox, 0, 2))));     
          
     topDSzblueF= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsFlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleF= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsFlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueF = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsFlox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleF= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsFlox, 0, 2))));
      end
          %cond c
     if currentSubj(session).trainStage >5
     topDSzblueC= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsClox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleC= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsClox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueC = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrialsClox, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleC= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrialsClox, 0, 2))));
        
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
      elseif currentSubj(session).trainStage==8
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
%         topNSzblue= stdFactor*abs(nanmean((std(currentSubj(1).NSzblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%         topNSzpurple= stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%         bottomNSzblue= -stdFactor*abs(nanmean((std(currentSubj(1).NSzblueSessionMean, 0, 2))));
%         bottomNSzpurple= -stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleSessionMean, 0, 2))));
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

           sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to DS across training stages- trials sorted by PE to First Lick')); %add big title above all subplots


        subplot(2,3,1) %plot of stage 1-4 blue (cond A blue)
        
            imagesc(timeLock,currentSubj(1).totalDScountA,currentSubj(1).DSzblueAllTrialsAlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 1-4 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,2) %plot of stage 5 blue (cond B blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountB,currentSubj(1).DSzblueAllTrialsBlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
            imagesc(timeLock,currentSubj(1).totalDScountC,currentSubj(1).DSzblueAllTrialsClox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalDScountA,currentSubj(1).DSzpurpleAllTrialsAlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 1-4 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,5) %plot of stage 5 purple (cond B purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountB,currentSubj(1).DSzpurpleAllTrialsBlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
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
            imagesc(timeLock,currentSubj(1).totalDScountC,currentSubj(1).DSzpurpleAllTrialsClox) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat(' Stage 6-8 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
       end   

    %Overlay scatter of Cue Onset
    
   subplot(2,3,1) %condA DS blue 
   hold on
   scatter(-DSpeLatencySortedAlox-DSloxrelpoxAllTrialsAlox,currentSubj(1).totalDScountA', 'k.');
   
   subplot(2,3,2) %condB DS blue 
   hold on
   scatter(-DSpeLatencySortedBlox-DSloxrelpoxAllTrialsBlox,currentSubj(1).totalDScountB', 'k.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC DS blue 
   hold on
   scatter(-DSpeLatencySortedClox-DSloxrelpoxAllTrialsClox,currentSubj(1).totalDScountC', 'k.');
   end
   
   subplot(2,3,4) %cond A DS purple
   hold on
   scatter(-DSpeLatencySortedAlox-DSloxrelpoxAllTrialsAlox,currentSubj(1).totalDScountA', 'k.');
   
   subplot(2,3,5) %cond B DS purple
   hold on
   scatter(-DSpeLatencySortedBlox-DSloxrelpoxAllTrialsBlox,currentSubj(1).totalDScountB', 'k.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C DS purple
   hold on
   scatter(-DSpeLatencySortedClox-DSloxrelpoxAllTrialsClox,currentSubj(1).totalDScountC', 'k.');
   end
   
   
   %Overlay scatter of PE 
   subplot(2,3,1) %condB DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsAlox,currentSubj(1).totalDScountA', 'm.');
   
   subplot(2,3,2) %condB DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsBlox,currentSubj(1).totalDScountB', 'm.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsClox,currentSubj(1).totalDScountC', 'm.');
   end
   
   subplot(2,3,4) %cond A NS purple
   hold on
   scatter(-DSloxrelpoxAllTrialsAlox,currentSubj(1).totalDScountA', 'm.');
      
   subplot(2,3,5) %cond B NS purple
   hold on
   scatter(-DSloxrelpoxAllTrialsBlox,currentSubj(1).totalDScountB', 'm.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C NS purple
   hold on
   scatter(-DSloxrelpoxAllTrialsClox,currentSubj(1).totalDScountC', 'm.');
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
   saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'allstages_DSfirstLOXlocked_loxsorted','.fig')); %save the current figure in fig format
       
    
    
    %NS plots!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

       figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE to First Lick')); %add big title above all subplots


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
            
            imagesc(timeLock,currentSubj(1).totalNScountB,currentSubj(1).NSzblueAllTrialsBlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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
            imagesc(timeLock,currentSubj(1).totalNScountC,currentSubj(1).NSzblueAllTrialsClox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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
            
            imagesc(timeLock,currentSubj(1).totalNScountB,currentSubj(1).NSzpurpleAllTrialsBlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
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
            imagesc(timeLock,currentSubj(1).totalNScountC,currentSubj(1).NSzpurpleAllTrialsClox) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat(' Stage 6-8 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end
            
            
   %Overlay scatter of Cue Onset 
   
   subplot(2,3,2) %condB NS blue 
   hold on
   scatter(-NSpeLatencySortedBlox-NSloxrelpoxAllTrialsBlox,currentSubj(1).totalNScountB', 'k.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC NS blue 
   hold on
   scatter(-NSpeLatencySortedClox-NSloxrelpoxAllTrialsClox,currentSubj(1).totalNScountC', 'k.');
   end
   
   subplot(2,3,4) %cond A NS purple
   hold on
%    scatter(NSpeLatencySortedA,currentSubj(1).totalNScountA', 'm.');
   
   subplot(2,3,5) %cond B NS purple
   hold on
   scatter(-NSpeLatencySortedBlox-NSloxrelpoxAllTrialsBlox,currentSubj(1).totalNScountB', 'k.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C NS purple
   hold on
   scatter(-NSpeLatencySortedClox-NSloxrelpoxAllTrialsClox,currentSubj(1).totalNScountC', 'k.');
   end
   
   
   %Overlay scatter of PE 
   
   subplot(2,3,2) %condB NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsBlox,currentSubj(1).totalNScountB', 'm.');
   
   if currentSubj(session).trainStage >5   
   subplot(2,3,3) %condC NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsClox,currentSubj(1).totalNScountC', 'm.');
   end
   
   subplot(2,3,4) %cond A NS purple
   hold on
%    scatter(NSpeLatencySortedA,currentSubj(1).totalNScountA', 'm.');
   
   subplot(2,3,5) %cond B NS purple
   hold on
   scatter(-NSloxrelpoxAllTrialsBlox,currentSubj(1).totalNScountB', 'm.');
   
   if currentSubj(session).trainStage >5
   subplot(2,3,6) %cond C NS purple
   hold on
   scatter(-NSloxrelpoxAllTrialsClox,currentSubj(1).totalNScountC', 'm.');
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
            saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'allstages_NSfirstLOXlocked_loxsorted','.fig')); %save the current figure in fig format
       
  
  %% plots for stage 6,7,8 seperately   

   
   figure(figureCount);
  figureCount= figureCount+1;

    sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to DS across training stages- trials sorted by PE to First Lick')); %add big title above all subplots
if currentSubj(session).trainStage ==6 
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
                
    subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzblueAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
       imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
                
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzblueAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 7 DS response (465nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('7 DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
         
      
        subplot(2,3,3) %plot of stage 8 blue (cond F blue)
            imagesc(timeLock,currentSubj(1).totalDScountF,currentSubj(1).DSzblueAllTrialsFlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     
         
        subplot(2,3,5) %plot of stage 7 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzpurpleAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalDScountD,currentSubj(1).DSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('Stage 6 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     
         
        subplot(2,3,5) %plot of stage 7 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalDScountE,currentSubj(1).DSzpurpleAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat('Stage 7 DS response (405nm) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
          
        subplot(2,3,6) %plot of stage 8 purple (cond F purple)
            imagesc(timeLock,currentSubj(1).totalDScountF,currentSubj(1).DSzpurpleAllTrialsFlox) %, 'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean));
            title(strcat(' Stage 8 DS response (405nm)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalDScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
       end   
 
  %Overlay scatter of Cue Onset (Blue)
   if currentSubj(session).trainStage ==6
   subplot(2,3,1) %condD DS blue 
   hold on
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,1) %condD DS blue 
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedElox-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'k.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,1) %condD DS blue 
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedElox-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'k.');
       
   subplot(2,3,3) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedFlox-DSloxrelpoxAllTrialsFlox,currentSubj(1).totalDScountF', 'k.');    
   end
   
   
 %Overlay scatter of Cue Onset (Purple)
   if currentSubj(session).trainStage ==6
   subplot(2,3,4) %condD DS blue 
   hold on
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,4) %condD DS blue 
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   subplot(2,3,5) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedElox-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'k.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,4) %condD DS blue 
   hold on
   scatter(-DSpeLatencySortedDlox-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'k.');
   
   subplot(2,3,5) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedElox-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'k.');
       
   subplot(2,3,6) %condE DS blue 
   hold on
   scatter(-DSpeLatencySortedFlox-DSloxrelpoxAllTrialsFlox,currentSubj(1).totalDScountF', 'k.');    
   end
 

   
  
  %Overlay scatter of PE (Blue)
   if currentSubj(session).trainStage ==6
   subplot(2,3,1) %condD DS blue 
   hold on
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,1) %condD DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'm.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,1) %condD DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   subplot(2,3,2) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'm.');
       
   subplot(2,3,3) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsFlox,currentSubj(1).totalDScountF', 'm.');    
   end
   
   
 %Overlay scatter of PE (Purple)
   if currentSubj(session).trainStage ==6
   subplot(2,3,4) %condD DS blue 
   hold on
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,4) %condD DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   subplot(2,3,5) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'm.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,4) %condD DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsDlox,currentSubj(1).totalDScountD', 'm.');
   
   subplot(2,3,5) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsElox,currentSubj(1).totalDScountE', 'm.');
       
   subplot(2,3,6) %condE DS blue 
   hold on
   scatter(-DSloxrelpoxAllTrialsFlox,currentSubj(1).totalDScountF', 'm.');    
   end
   
   
%    
%  %overlay scatter of Licks-DS BLUE
%        licksToPlot= 10;
%        lickAlpha= 0.15;
%  
%    if currentSubj(session).trainStage ==6    
%        subplot(2,3,1) %condA DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==7
%         subplot(2,3,1) %condD DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,2) %condE DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==8      
%                subplot(2,3,1) %condD DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,2) %condE DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,3) %condF DS blue 
%        hold on
%        for trial= (currentSubj(1).totalDScountF)
%                 %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsF{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountF(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    end
%    
%    
%  %overlay scatter of Licks-DS PURPLE
%        licksToPlot= 10;
%        lickAlpha= 0.15;
%  
%    if currentSubj(session).trainStage ==6    
%        subplot(2,3,4) %condA DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==7
%         subplot(2,3,4) %condD DS purple
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,5) %condE DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==8      
%                subplot(2,3,4) %condD DS purple
%        hold on
%        for trial= (currentSubj(1).totalDScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,5) %condE DS purple
%        hold on
%        for trial= (currentSubj(1).totalDScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,6) %condF DS purple 
%        hold on
%        for trial= (currentSubj(1).totalDScountF)
%                 %scatter # of licksToPlot
%            if numel(currentSubj(1).DSloxAllTrialsF{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).DSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalDScountF(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    end
%     
%     %worked for nested structure
    
   trialCount= 1;
    
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'latestages_DSLOXlocked_loxsorted','.fig')); %save the current figure in fig format
 
    
    %NS plots!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if currentSubj(session).trainStage==6   
       figure(figureCount);
       figureCount= figureCount+1;

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE to First Lick')); %add big title above all subplots
   
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
 
      
      
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzblueAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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

       sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, ' response to NS across training stages- trials sorted by PE to First Lick')); %add big title above all subplots
   
        subplot(2,3,1) %plot of stage 6 blue (cond D blue)
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzblueAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
 
      
        subplot(2,3,2) %plot of stage 7 blue (cond E blue)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzblueAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 7 NS response (465nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
  
      
        subplot(2,3,3) %plot of stage 6-8 blue (cond F blue)
            imagesc(timeLock,currentSubj(1).totalNScountF,currentSubj(1).NSzblueAllTrialsFlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,5) %plot of stage 5 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzpurpleAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
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
        
            imagesc(timeLock,currentSubj(1).totalNScountD,currentSubj(1).NSzpurpleAllTrialsDlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
            title(strcat('Stage 6 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,5) %plot of stage 5 purple (cond E purple)
            
            imagesc(timeLock,currentSubj(1).totalNScountE,currentSubj(1).NSzpurpleAllTrialsElox) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat('Stage 7 NS response (405nm) ')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      
      
        subplot(2,3,6) %plot of stage 6-8 purple (cond C purple)
            imagesc(timeLock,currentSubj(1).totalNScountF,currentSubj(1).NSzpurpleAllTrialsFlox) %, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean));
            title(strcat(' Stage 8 NS response (405nm)')); %'(n= ', num2str(unique(trialNSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('trial (latency sorted)');
%             set(gca, 'ytick', currentSubj(1).totalNScountC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared2 topMeanShared2]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('6-8 NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end
            
            
%Overlay scatter of Cue Onset (Blue)
   if currentSubj(session).trainStage ==6
   subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedElox-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'k.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedElox-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'k.');
       
   subplot(2,3,3) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedFlox-NSloxrelpoxAllTrialsFlox,currentSubj(1).totalNScountF', 'k.');    
   end
   
   
 %Overlay scatter of Cue Onset (Purple)
   if currentSubj(session).trainStage ==6
   subplot(2,3,4) %condD DS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,4) %condD NS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   subplot(2,3,5) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedElox-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'k.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,4) %condD NS blue 
   hold on
   scatter(-NSpeLatencySortedDlox-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'k.');
   
   subplot(2,3,5) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedElox-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'k.');
       
   subplot(2,3,6) %condE NS blue 
   hold on
   scatter(-NSpeLatencySortedFlox-NSloxrelpoxAllTrialsFlox,currentSubj(1).totalNScountF', 'k.');    
   end
 

   
  
  %Overlay scatter of PE (Blue)
   if currentSubj(session).trainStage ==6
   subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'm.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,1) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   subplot(2,3,2) %condE NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'm.');
       
   subplot(2,3,3) %condE DS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsFlox,currentSubj(1).totalNScountF', 'm.');    
   end
   
   
 %Overlay scatter of PE (Purple)
   if currentSubj(session).trainStage ==6
   subplot(2,3,4) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   elseif currentSubj(session).trainStage==7  
   
  subplot(2,3,4) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   subplot(2,3,5) %condE NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'm.');
   
   elseif currentSubj(session).trainStage==8   
       
  subplot(2,3,4) %condD NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsDlox,currentSubj(1).totalNScountD', 'm.');
   
   subplot(2,3,5) %condE NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsElox,currentSubj(1).totalNScountE', 'm.');
       
   subplot(2,3,6) %condE NS blue 
   hold on
   scatter(-NSloxrelpoxAllTrialsFlox,currentSubj(1).totalNScountF', 'm.');    
   end
   
   
            
%  %overlay scatter of Licks-NS BLUE
%        licksToPlot= 10;
%        lickAlpha= 0.15;
%  
%    if currentSubj(session).trainStage ==6    
%        subplot(2,3,1) %condA DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==7
%         subplot(2,3,1) %condD DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,2) %condE DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==8      
%                subplot(2,3,1) %condD DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,2) %condE DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,3) %condF DS blue 
%        hold on
%        for trial= (currentSubj(1).totalNScountF)
%                 %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsF{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountF(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    end
%    
%    
%  %overlay scatter of Licks-NS PURPLE
%        licksToPlot= 10;
%        lickAlpha= 0.15;
%  
%    if currentSubj(session).trainStage ==6    
%        subplot(2,3,4) %condA DS purple 
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==7
%         subplot(2,3,4) %condD DS purple
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,5) %condE DS purple 
%        hold on
%        for trial= (currentSubj(1).totalNScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    elseif currentSubj(session).trainStage ==8      
%                subplot(2,3,4) %condD DS purple
%        hold on
%        for trial= (currentSubj(1).totalNScountD)
%            %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsD{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsD{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountD(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,5) %condE DS purple
%        hold on
%        for trial= (currentSubj(1).totalNScountE)
%                %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsE{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsE{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountE(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%        
%        subplot(2,3,6) %condF DS purple 
%        hold on
%        for trial= (currentSubj(1).totalNScountF)
%                 %scatter # of licksToPlot
%            if numel(currentSubj(1).NSloxAllTrialsF{trial}) >= licksToPlot
%                 s= scatter(currentSubj(1).NSloxAllTrialsF{trial}(1:licksToPlot), ones(licksToPlot,1)*currentSubj(1).totalNScountF(trial), 'k.');
%                 s.MarkerEdgeAlpha= lickAlpha; %make transparent
%            end
%        end
%    end
%     
            
            
            set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    
            saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'latestages_NSLOXlocked_loxsorted','.fig')); %save the current figure in fig format
       
           
end%end subj loop



%% ~~~ End~~~~~~~