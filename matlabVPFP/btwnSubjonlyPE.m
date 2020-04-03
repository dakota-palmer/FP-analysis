%% Between subj response to cue - only TRIALS WITH PE

%avg response timelocked to ONLY CUES WITH A VALID PE on key transition sessions
%(e.g. first day of training, first day with NS, last day of stage 5)

%excludes trials where animal was already in port at cue onset as well as
%trials with no valid PE

clear allRats.poxOnly; %reset between analyses

for subj= 1:numel(subjIncluded) %for each subject
       currentSubj= subjDataAnalyzed.(subjIncluded{subj}); %use this for easy indexing into the current subject within the struct

      %First, need to identify sessions that meet these conditions
       
%       %counter for sessions that meet each condition, reset between subjs
      sesCountA= 1;
      sesCountB= 1;
      sesCountC= 1;
      sesCountD= 1;
      sesCountE= 1;
      
       for session = 1:numel(currentSubj) %for each training session this subject completed
            
           %cond A
           if currentSubj(session).trainStage==2 %condA= stage 2 sessions (rat13 missing stage1 data)
               %save training day label for this data 
                allRats(1).subjSessA(sesCountA,subj)=currentSubj(session).trainDay; 
               %iterate the counter for sessions that meet this condition
                sesCountA= sesCountA+1;
           end %end conditional A

             %cond B
           if currentSubj(session).trainStage ==5 %condB= stage 5 sessions
               %save training day label for this data 
                allRats(1).subjSessB(sesCountB,subj)=currentSubj(session).trainDay; 
               %iterate the counter for sessions that meet this condition
                sesCountB= sesCountB+1;
           end %end conditional B
           
               %cond C
           if currentSubj(session).trainStage==7 %condC = stage 7 sessions (full 1s delay between PE and pump on)
               %save training day label for this data 
                allRats(1).subjSessC(sesCountC,subj)=currentSubj(session).trainDay; 
               %iterate the counter for sessions that meet this condition
                sesCountC= sesCountC+1;
           end %end conditional C
           
                %cond D
           if currentSubj(session).trainStage ==8 %condD = stage 8 sessions (variable 10%, 5%, 20% sucrose)
               %save training day label for this data 
                allRats(1).subjSessD(sesCountD,subj)=currentSubj(session).trainDay; 
               %iterate the counter for sessions that meet this condition
                sesCountD= sesCountD+1;
           end %end conditional D        
        
                %cond E
           if currentSubj(session).trainStage ==12 %condE = Extinction (stage 12)
               %save training day label for this data 
                allRats(1).subjSessE(sesCountE,subj)=currentSubj(session).trainDay; 
               %iterate the counter for sessions that meet this condition
                sesCountE= sesCountE+1;
           end %end conditional E
        end %end session loop
        

     %Translate the training days saved above into an index based on the
     %file order (critical step- if a subject is missing a file then the
     %training day can't be used as an index bc it will pull incorrect
     %data)
     
        for transitionSession= 1:size(allRats.subjSessA,1)
             if allRats(1).subjSessA(transitionSession,subj) ~= 0 && ~isnan(allRats(1).subjSessA(transitionSession,subj))
                 %search the trainDay field by vectorizing it [] and get its index using find() 
                 allRats(1).subjSessA(transitionSession,subj)= find([currentSubj.trainDay]==allRats(1).subjSessA(transitionSession,subj));
             end
         end
     
        for transitionSession= 1:size(allRats.subjSessB,1)
             if allRats(1).subjSessB(transitionSession,subj) ~= 0 && ~isnan(allRats(1).subjSessB(transitionSession,subj))
                 %search the trainDay field by vectorizing it [] and get its index using find() 
                 allRats(1).subjSessB(transitionSession,subj)= find([currentSubj.trainDay]==allRats(1).subjSessB(transitionSession,subj));
             end
         end
     
        for transitionSession= 1:size(allRats.subjSessC,1)
             if allRats(1).subjSessC(transitionSession,subj) ~= 0 && ~isnan(allRats(1).subjSessC(transitionSession,subj))
                 %search the trainDay field by vectorizing it [] and get its index using find() 
                 allRats(1).subjSessC(transitionSession,subj)= find([currentSubj.trainDay]==allRats(1).subjSessC(transitionSession,subj));
             end
         end
     
        for transitionSession= 1:size(allRats.subjSessD,1)
             if allRats(1).subjSessD(transitionSession,subj) ~= 0 && ~isnan(allRats(1).subjSessD(transitionSession,subj))
                 %search the trainDay field by vectorizing it [] and get its index using find() 
                 allRats(1).subjSessD(transitionSession,subj)= find([currentSubj.trainDay]==allRats(1).subjSessD(transitionSession,subj));
             end
         end
     
         for transitionSession= 1:size(allRats.subjSessE,1)
             if allRats(1).subjSessE(transitionSession,subj) ~= 0 && ~isnan(allRats(1).subjSessE(transitionSession,subj))
                 %search the trainDay field by vectorizing it [] and get its index using find() 
                 allRats(1).subjSessE(transitionSession,subj)= find([currentSubj.trainDay]==allRats(1).subjSessE(transitionSession,subj));
             end
         end

     %replace empty 0s with nans AND identify data from individual sessions for
     %plotting (instead of plotting them all)
        %the above code filled in blank training dates with 0 for photometry data (e.g. if 1 rat 
        %ran 12 days but others ran 9 days, the 3 days in between were 
        %filled with 0), let's make these = nan instead 
        
        %Now, we only want to include trials that have a valid PE during
        %the cue epoch in the means we calculate
        
            %condA
        allRats(1).subjSessA(allRats(1).subjSessA==0)=nan; %if there's no data for this date just make it nan

        for ses = 1:size(allRats(1).subjSessA,1) %each row is a session
           if ses==1 %retain only the first stage 2 day
               allRats(1).stage2FirstSes(1,subj)= allRats(1).subjSessA(ses,subj); %get corresponding session, will be used to extract photometry data
               
               firstSessionIndex= allRats(1).stage2FirstSes(1,subj); %this is the index for the specific transition day of interest
              
               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselectedFirstSes= currentSubj(firstSessionIndex).periDS.DS;  % all the DS cues

                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedFirstSes) 
                        DSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                %Now, use the DSselected as an index to get only mean
                %response on trials without PE
               allRats(1).poxOnly.DSzblueMeanStage2FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage2FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedFirstSes)),3)';
           end 
        end
       
        
            %condB
         allRats(1).subjSessB(allRats(1).subjSessB==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessB,1) %each row is a session           
           if ses==1 %retain the first and last stage 5 day
               allRats(1).stage5FirstSes(1,subj)= allRats(1).subjSessB(ses,subj); %get corresponding session, will be used to extract photometry data
               allRats(1).stage5LastSes(1,subj)= max(allRats(1).subjSessB(:,subj));
               
               firstSessionIndex= allRats(1).stage5FirstSes(1,subj); %this is the index for the specific transition day of interest
               lastSessionIndex= allRats(1).stage5LastSes(1,subj);

               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselectedFirstSes= currentSubj(firstSessionIndex).periDS.DS;  % all the DS cues
                DSselectedLastSes = currentSubj(lastSessionIndex).periDS.DS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedFirstSes) 
                        DSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedLastSes) 
                        DSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                %Repeat for NS
                %Exclude trials where animal was in port or did not make a PE
                %first get the NS cues for this session
                NSselectedFirstSes= currentSubj(firstSessionIndex).periNS.NS;  % all the NS cues
                NSselectedLastSes= currentSubj(lastSessionIndex).periNS.NS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedFirstSes) 
                        NSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedLastSes) 
                        NSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS)) = nan;
                    end
                end
                
                 for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS)) = nan;
                    end
                 end
                
                %Now, use the DSselected & NSSelected as an indexes to get only mean
                %response on trials without PE
               allRats(1).poxOnly.DSzblueMeanStage5FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage5FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedFirstSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage5FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage5FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedFirstSes)),3)'; 
               
               allRats(1).poxOnly.DSzblueMeanStage5LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage5LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedLastSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage5LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage5LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedLastSes)),3)'; 
           end          
         end %end cond B       
         
           %condC
         allRats(1).subjSessC(allRats(1).subjSessC==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessC,1) %each row is a session           
           if ses==1 %retain the first and last stage 7 day
               allRats(1).stage7FirstSes(1,subj)= allRats(1).subjSessC(ses,subj); %get corresponding session, will be used to extract photometry data
               allRats(1).stage7LastSes(1,subj)= max(allRats(1).subjSessC(:,subj));
               
               firstSessionIndex= allRats(1).stage7FirstSes(1,subj); %this is the index for the specific transition day of interest
               lastSessionIndex= allRats(1).stage7LastSes(1,subj);

               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselectedFirstSes= currentSubj(firstSessionIndex).periDS.DS;  % all the DS cues
                DSselectedLastSes = currentSubj(lastSessionIndex).periDS.DS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedFirstSes) 
                        DSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedLastSes) 
                        DSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                %Repeat for NS
                %Exclude trials where animal was in port or did not make a PE
                %first get the NS cues for this session
                NSselectedFirstSes= currentSubj(firstSessionIndex).periNS.NS;  % all the NS cues
                NSselectedLastSes= currentSubj(lastSessionIndex).periNS.NS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedFirstSes) 
                        NSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedLastSes) 
                        NSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS)) = nan;
                    end
                end
                
                 for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS)) = nan;
                    end
                 end
                
                %Now, use the DSselected & NSSelected as an indexes to get only mean
                %response on trials without PE
               allRats(1).poxOnly.DSzblueMeanStage7FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage7FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedFirstSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage7FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage7FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedFirstSes)),3)'; 
               
               allRats(1).poxOnly.DSzblueMeanStage7LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage7LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedLastSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage7LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage7LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedLastSes)),3)'; 
           end          
         end %end cond C
         
           %condD 
       allRats(1).subjSessD(allRats(1).subjSessD==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessD,1) %each row is a session           
           if ses==1 %retain the first and last stage 8 day
               allRats(1).stage8FirstSes(1,subj)= allRats(1).subjSessD(ses,subj); %get corresponding session, will be used to extract photometry data
               allRats(1).stage8LastSes(1,subj)= max(allRats(1).subjSessD(:,subj));
               
               firstSessionIndex= allRats(1).stage8FirstSes(1,subj); %this is the index for the specific transition day of interest
               lastSessionIndex= allRats(1).stage8LastSes(1,subj);

               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselectedFirstSes= currentSubj(firstSessionIndex).periDS.DS;  % all the DS cues
                DSselectedLastSes = currentSubj(lastSessionIndex).periDS.DS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedFirstSes) 
                        DSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedLastSes) 
                        DSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                %Repeat for NS
                %Exclude trials where animal was in port or did not make a PE
                %first get the NS cues for this session
                NSselectedFirstSes= currentSubj(firstSessionIndex).periNS.NS;  % all the NS cues
                NSselectedLastSes= currentSubj(lastSessionIndex).periNS.NS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedFirstSes) 
                        NSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedLastSes) 
                        NSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS)) = nan;
                    end
                end
                
                 for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS)) = nan;
                    end
                 end
                
                %Now, use the DSselected & NSSelected as an indexes to get only mean
                %response on trials without PE
               allRats(1).poxOnly.DSzblueMeanStage8FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage8FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedFirstSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage8FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage8FirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedFirstSes)),3)'; 
               
               allRats(1).poxOnly.DSzblueMeanStage8LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanStage8LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedLastSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanStage8LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanStage8LastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedLastSes)),3)'; 
           end          
         end %end cond D
         
               %condE 
         allRats(1).subjSessE(allRats(1).subjSessE==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessE,1) %each row is a session           
           if ses==1 %retain the first and last stage 12 (extinction) day
               allRats(1).extinctionFirstSes(1,subj)= allRats(1).subjSessE(ses,subj); %get corresponding session, will be used to extract photometry data
               allRats(1).extinctionLastSes(1,subj)= max(allRats(1).subjSessE(:,subj));
               
               firstSessionIndex= allRats(1).extinctionFirstSes(1,subj); %this is the index for the specific transition day of interest
               lastSessionIndex= allRats(1).extinctionLastSes(1,subj);

               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselectedFirstSes= currentSubj(firstSessionIndex).periDS.DS;  % all the DS cues
                DSselectedLastSes = currentSubj(lastSessionIndex).periDS.DS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedFirstSes) 
                        DSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS))
                    if inPortTrial < numel(DSselectedLastSes) 
                        DSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS))
                    if PEtrial < numel(DSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        DSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxDS)) = nan;
                    end
                end
                
                %Repeat for NS
                %Exclude trials where animal was in port or did not make a PE
                %first get the NS cues for this session
                NSselectedFirstSes= currentSubj(firstSessionIndex).periNS.NS;  % all the NS cues
                NSselectedLastSes= currentSubj(lastSessionIndex).periNS.NS;
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedFirstSes) 
                        NSselectedFirstSes(~isnan(currentSubj(firstSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                
                 for inPortTrial = find(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS))
                    if inPortTrial < numel(NSselectedLastSes) 
                        NSselectedLastSes(~isnan(currentSubj(lastSessionIndex).behavior.inPortNS)) = nan;
                    end
                end
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedFirstSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedFirstSes(cellfun('isempty', currentSubj(firstSessionIndex).behavior.poxNS)) = nan;
                    end
                end
                
                 for PEtrial = find(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS))
                    if PEtrial < numel(NSselectedLastSes)  %same here, we need an extra conditional in case cues were excluded
                        NSselectedLastSes(cellfun('isempty', currentSubj(lastSessionIndex).behavior.poxNS)) = nan;
                    end
                 end
                
                %Now, use the DSselected & NSSelected as an indexes to get only mean
                %response on trials without PE
               allRats(1).poxOnly.DSzblueMeanExtinctionFirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanExtinctionFirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedFirstSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanExtinctionFirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedFirstSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanExtinctionFirstSes(1,:,subj)= mean(currentSubj(firstSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedFirstSes)),3)'; 
               
               allRats(1).poxOnly.DSzblueMeanExtinctionLastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzblue(:,:,~isnan(DSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.DSzpurpleMeanExtinctionLastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periDS.DSzpurple(:,:,~isnan(DSselectedLastSes)),3)';            
               allRats(1).poxOnly.NSzblueMeanExtinctionLastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzblue(:,:,~isnan(NSselectedLastSes)),3)'; %transposing for readability
               allRats(1).poxOnly.NSzpurpleMeanExtinctionLastSes(1,:,subj)= mean(currentSubj(lastSessionIndex).periNS.NSzpurple(:,:,~isnan(NSselectedLastSes)),3)'; 
           end          
         end %end cond E
         
end %end subj loop
         


 % now get mean & SEM of all rats for these transition sessions (each column is a training day , each 3d page is a subject)
       
    %stage 2
 allRats(1).poxOnly.grandMeanDSzblueStage2FirstSes=nanmean(allRats(1).poxOnly.DSzblueMeanStage2FirstSes,3);
 allRats(1).poxOnly.grandMeanDSzpurpleStage2FirstSes=nanmean(allRats(1).poxOnly.DSzpurpleMeanStage2FirstSes,3);
 
    %stage 5
allRats(1).poxOnly.grandMeanDSzblueStage5FirstSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage5FirstSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage5FirstSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage5FirstSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage5FirstSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage5FirstSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage5FirstSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage5FirstSes,3);

allRats(1).poxOnly.grandMeanDSzblueStage5LastSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage5LastSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage5LastSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage5LastSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage5LastSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage5LastSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage5LastSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage5LastSes,3);
    
    %stage 7
allRats(1).poxOnly.grandMeanDSzblueStage7FirstSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage7FirstSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage7FirstSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage7FirstSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage7FirstSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage7FirstSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage7FirstSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage7FirstSes,3);

allRats(1).poxOnly.grandMeanDSzblueStage7LastSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage7LastSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage7LastSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage7LastSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage7LastSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage7LastSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage7LastSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage7LastSes,3); 
 
    %stage 8
allRats(1).poxOnly.grandMeanDSzblueStage8FirstSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage8FirstSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage8FirstSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage8FirstSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage8FirstSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage8FirstSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage8FirstSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage8FirstSes,3);

allRats(1).poxOnly.grandMeanDSzblueStage8LastSes= nanmean(allRats(1).poxOnly.DSzblueMeanStage8LastSes,3);
allRats(1).poxOnly.grandMeanNSzblueStage8LastSes= nanmean(allRats(1).poxOnly.NSzblueMeanStage8LastSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleStage8LastSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanStage8LastSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleStage8LastSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanStage8LastSes,3);

    %stage 12 (extinction)
allRats(1).poxOnly.grandMeanDSzblueExtinctionFirstSes= nanmean(allRats(1).poxOnly.DSzblueMeanExtinctionFirstSes,3);
allRats(1).poxOnly.grandMeanNSzblueExtinctionFirstSes= nanmean(allRats(1).poxOnly.NSzblueMeanExtinctionFirstSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleExtinctionFirstSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanExtinctionFirstSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleExtinctionFirstSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanExtinctionFirstSes,3);

allRats(1).poxOnly.grandMeanDSzblueExtinctionLastSes= nanmean(allRats(1).poxOnly.DSzblueMeanExtinctionLastSes,3);
allRats(1).poxOnly.grandMeanNSzblueExtinctionLastSes= nanmean(allRats(1).poxOnly.NSzblueMeanExtinctionLastSes,3);
allRats(1).poxOnly.grandMeanDSzpurpleExtinctionLastSes= nanmean(allRats(1).poxOnly.DSzpurpleMeanExtinctionLastSes,3);
allRats(1).poxOnly.grandMeanNSzpurpleExtinctionLastSes= nanmean(allRats(1).poxOnly.NSzpurpleMeanExtinctionLastSes,3);


 %Calculate standard error of the mean(SEM)
  %treat each animal's avg as an obesrvation and calculate their std from
  %the grand mean across all animals
    %stage 2
allRats(1).poxOnly.grandStdDSzblueStage2FirstSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage2FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage2FirstSes= allRats(1).poxOnly.grandStdDSzblueStage2FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage2FirstSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage2FirstSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage2FirstSes= allRats(1).poxOnly.grandStdDSzpurpleStage2FirstSes/sqrt(numel(subjIncluded));

   %stage 5
allRats(1).poxOnly.grandStdDSzblueStage5FirstSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage5FirstSes= allRats(1).poxOnly.grandStdDSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage5FirstSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage5FirstSes= allRats(1).poxOnly.grandStdDSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdDSzblueStage5LastSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage5LastSes= allRats(1).poxOnly.grandStdDSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage5LastSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage5LastSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage5LastSes= allRats(1).poxOnly.grandStdDSzpurpleStage5LastSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage5FirstSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage5FirstSes= allRats(1).poxOnly.grandStdNSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage5FirstSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage5FirstSes= allRats(1).poxOnly.grandStdNSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage5LastSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage5LastSes= allRats(1).poxOnly.grandStdNSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage5LastSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage5LastSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage5LastSes= allRats(1).poxOnly.grandStdNSzpurpleStage5LastSes/sqrt(numel(subjIncluded));


    %stage 7
allRats(1).poxOnly.grandStdDSzblueStage7FirstSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage7FirstSes= allRats(1).poxOnly.grandStdDSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage7FirstSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage7FirstSes= allRats(1).poxOnly.grandStdDSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdDSzblueStage7LastSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage7LastSes= allRats(1).poxOnly.grandStdDSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage7LastSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage7LastSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage7LastSes= allRats(1).poxOnly.grandStdDSzpurpleStage7LastSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage7FirstSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage7FirstSes= allRats(1).poxOnly.grandStdNSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage7FirstSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage7FirstSes= allRats(1).poxOnly.grandStdNSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage7LastSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage7LastSes= allRats(1).poxOnly.grandStdNSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage7LastSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage7LastSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage7LastSes= allRats(1).poxOnly.grandStdNSzpurpleStage7LastSes/sqrt(numel(subjIncluded));

    %stage 8
allRats(1).poxOnly.grandStdDSzblueStage8FirstSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage8FirstSes= allRats(1).poxOnly.grandStdDSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage8FirstSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage8FirstSes= allRats(1).poxOnly.grandStdDSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdDSzblueStage8LastSes= nanstd(allRats(1).poxOnly.DSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueStage8LastSes= allRats(1).poxOnly.grandStdDSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleStage8LastSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanStage8LastSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleStage8LastSes= allRats(1).poxOnly.grandStdDSzpurpleStage8LastSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage8FirstSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage8FirstSes= allRats(1).poxOnly.grandStdNSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage8FirstSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage8FirstSes= allRats(1).poxOnly.grandStdNSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueStage8LastSes= nanstd(allRats(1).poxOnly.NSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueStage8LastSes= allRats(1).poxOnly.grandStdNSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleStage8LastSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanStage8LastSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleStage8LastSes= allRats(1).poxOnly.grandStdNSzpurpleStage8LastSes/sqrt(numel(subjIncluded));


    %stage 12 (extinction)
allRats(1).poxOnly.grandStdDSzblueExtinctionFirstSes= nanstd(allRats(1).poxOnly.DSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueExtinctionFirstSes= allRats(1).poxOnly.grandStdDSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleExtinctionFirstSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleExtinctionFirstSes= allRats(1).poxOnly.grandStdDSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdDSzblueExtinctionLastSes= nanstd(allRats(1).poxOnly.DSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMDSzblueExtinctionLastSes= allRats(1).poxOnly.grandStdDSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdDSzpurpleExtinctionLastSes= nanstd(allRats(1).poxOnly.DSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).poxOnly.grandSEMDSzpurpleExtinctionLastSes= allRats(1).poxOnly.grandStdDSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueExtinctionFirstSes= nanstd(allRats(1).poxOnly.NSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueExtinctionFirstSes= allRats(1).poxOnly.grandStdNSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleExtinctionFirstSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleExtinctionFirstSes= allRats(1).poxOnly.grandStdNSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).poxOnly.grandStdNSzblueExtinctionLastSes= nanstd(allRats(1).poxOnly.NSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).poxOnly.grandSEMNSzblueExtinctionLastSes= allRats(1).poxOnly.grandStdNSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).poxOnly.grandStdNSzpurpleExtinctionLastSes= nanstd(allRats(1).poxOnly.NSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).poxOnly.grandSEMNSzpurpleExtinctionLastSes= allRats(1).poxOnly.grandStdNSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));


% Now, 2d plots 
figure(figureCount);
figureCount= figureCount+1;

sgtitle('Between subjects (n=5) avg response to CUE- ONLY TRIALS WITH VALID PE- on transition days')

subplot(2,9,1);
title('DS stage 2 first day');
hold on;
plot(timeLock,allRats(1).poxOnly.grandMeanDSzblueStage2FirstSes, 'b');
plot(timeLock,allRats(1).poxOnly.grandMeanDSzpurpleStage2FirstSes, 'm');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage2FirstSes+allRats(1).poxOnly.grandSEMDSzblueStage2FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage2FirstSes-allRats(1).poxOnly.grandSEMDSzblueStage2FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage2FirstSes+allRats(1).poxOnly.grandSEMDSzpurpleStage2FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage2FirstSes-allRats(1).poxOnly.grandSEMDSzpurpleStage2FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,2);
title('DS stage 5 first day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage5FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage5FirstSes+allRats(1).poxOnly.grandSEMDSzblueStage5FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage5FirstSes-allRats(1).poxOnly.grandSEMDSzblueStage5FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage5FirstSes+allRats(1).poxOnly.grandSEMDSzpurpleStage5FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage5FirstSes-allRats(1).poxOnly.grandSEMDSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,3);
title('DS stage 5 last day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage5LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage5LastSes+allRats(1).poxOnly.grandSEMDSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage5LastSes-allRats(1).poxOnly.grandSEMDSzblueStage5LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage5LastSes+allRats(1).poxOnly.grandSEMDSzpurpleStage5LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage5LastSes-allRats(1).poxOnly.grandSEMDSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,4);
title('DS stage 7 first day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage7FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage7FirstSes+allRats(1).poxOnly.grandSEMDSzblueStage7FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage7FirstSes-allRats(1).poxOnly.grandSEMDSzblueStage7FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage7FirstSes+allRats(1).poxOnly.grandSEMDSzpurpleStage7FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage7FirstSes-allRats(1).poxOnly.grandSEMDSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,5);
title('DS stage 7 last day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage7LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage7LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage7LastSes+allRats(1).poxOnly.grandSEMDSzblueStage7LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage7LastSes-allRats(1).poxOnly.grandSEMDSzblueStage7LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage7LastSes+allRats(1).poxOnly.grandSEMDSzpurpleStage7LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage7LastSes-allRats(1).poxOnly.grandSEMDSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,6);
title('DS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage8FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage8FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage8FirstSes+allRats(1).poxOnly.grandSEMDSzblueStage8FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage8FirstSes-allRats(1).poxOnly.grandSEMDSzblueStage8FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage8FirstSes+allRats(1).poxOnly.grandSEMDSzpurpleStage8FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage8FirstSes-allRats(1).poxOnly.grandSEMDSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,7);
title('DS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueStage8LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleStage8LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueStage8LastSes+allRats(1).poxOnly.grandSEMDSzblueStage8LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueStage8LastSes-allRats(1).poxOnly.grandSEMDSzblueStage8LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleStage8LastSes+allRats(1).poxOnly.grandSEMDSzpurpleStage8LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleStage8LastSes-allRats(1).poxOnly.grandSEMDSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,8);
title('DS extinction first day');
hold on;

plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueExtinctionFirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleExtinctionFirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueExtinctionFirstSes+allRats(1).poxOnly.grandSEMDSzblueExtinctionFirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueExtinctionFirstSes-allRats(1).poxOnly.grandSEMDSzblueExtinctionFirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleExtinctionFirstSes+allRats(1).poxOnly.grandSEMDSzpurpleExtinctionFirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleExtinctionFirstSes-allRats(1).poxOnly.grandSEMDSzpurpleExtinctionFirstSes;


patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,9);
title('DS extinction last day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanDSzblueExtinctionLastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanDSzpurpleExtinctionLastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanDSzblueExtinctionLastSes+allRats(1).poxOnly.grandSEMDSzblueExtinctionLastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanDSzblueExtinctionLastSes-allRats(1).poxOnly.grandSEMDSzblueExtinctionLastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanDSzpurpleExtinctionLastSes+allRats(1).poxOnly.grandSEMDSzpurpleExtinctionLastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanDSzpurpleExtinctionLastSes-allRats(1).poxOnly.grandSEMDSzpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);



subplot(2,9,10);
title('No NS on stage 2');


subplot(2,9,11);
title('NS stage 5 first day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage5FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage5FirstSes+allRats(1).poxOnly.grandSEMNSzblueStage5FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage5FirstSes-allRats(1).poxOnly.grandSEMNSzblueStage5FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage5FirstSes+allRats(1).poxOnly.grandSEMNSzpurpleStage5FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage5FirstSes-allRats(1).poxOnly.grandSEMNSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,12);
title('NS stage 5 last day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage5LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage5LastSes+allRats(1).poxOnly.grandSEMNSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage5LastSes-allRats(1).poxOnly.grandSEMNSzblueStage5LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage5LastSes+allRats(1).poxOnly.grandSEMNSzpurpleStage5LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage5LastSes-allRats(1).poxOnly.grandSEMNSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,13);
title('NS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage7FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage7FirstSes+allRats(1).poxOnly.grandSEMNSzblueStage7FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage7FirstSes-allRats(1).poxOnly.grandSEMNSzblueStage7FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage7FirstSes+allRats(1).poxOnly.grandSEMNSzpurpleStage7FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage7FirstSes-allRats(1).poxOnly.grandSEMNSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,14);
title('NS stage 7 last day');
hold on;

plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage7LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage7LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage7LastSes+allRats(1).poxOnly.grandSEMNSzblueStage7LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage7LastSes-allRats(1).poxOnly.grandSEMNSzblueStage7LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage7LastSes+allRats(1).poxOnly.grandSEMNSzpurpleStage7LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage7LastSes-allRats(1).poxOnly.grandSEMNSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,15);
title('NS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage8FirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage8FirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage8FirstSes+allRats(1).poxOnly.grandSEMNSzblueStage8FirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage8FirstSes-allRats(1).poxOnly.grandSEMNSzblueStage8FirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage8FirstSes+allRats(1).poxOnly.grandSEMNSzpurpleStage8FirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage8FirstSes-allRats(1).poxOnly.grandSEMNSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,16);
title('NS 10%,5%,20% last day');
hold on;

plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueStage8LastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleStage8LastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueStage8LastSes+allRats(1).poxOnly.grandSEMNSzblueStage8LastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueStage8LastSes-allRats(1).poxOnly.grandSEMNSzblueStage8LastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleStage8LastSes+allRats(1).poxOnly.grandSEMNSzpurpleStage8LastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleStage8LastSes-allRats(1).poxOnly.grandSEMNSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,17);
title('NS extinction first day');
hold on;

plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueExtinctionFirstSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleExtinctionFirstSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueExtinctionFirstSes+allRats(1).poxOnly.grandSEMNSzblueExtinctionFirstSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueExtinctionFirstSes-allRats(1).poxOnly.grandSEMNSzblueExtinctionFirstSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleExtinctionFirstSes+allRats(1).poxOnly.grandSEMNSzpurpleExtinctionFirstSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleExtinctionFirstSes-allRats(1).poxOnly.grandSEMNSzpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,18);
title('NS extinction last day');
hold on;

plot(timeLock, allRats(1).poxOnly.grandMeanNSzblueExtinctionLastSes,'b');
plot(timeLock, allRats(1).poxOnly.grandMeanNSzpurpleExtinctionLastSes,'m');

grandSemBluePos= allRats(1).poxOnly.grandMeanNSzblueExtinctionLastSes+allRats(1).poxOnly.grandSEMNSzblueExtinctionLastSes;
grandSemBlueNeg= allRats(1).poxOnly.grandMeanNSzblueExtinctionLastSes-allRats(1).poxOnly.grandSEMNSzblueExtinctionLastSes;

grandSemPurplePos= allRats(1).poxOnly.grandMeanNSzpurpleExtinctionLastSes+allRats(1).poxOnly.grandSEMNSzpurpleExtinctionLastSes;
grandSemPurpleNeg= allRats(1).poxOnly.grandMeanNSzpurpleExtinctionLastSes-allRats(1).poxOnly.grandSEMNSzpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

%equalize the axes and link them together for examination
linkaxes;

set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen


% Overlay mean cue onset/PE and lick
for subj = 1:numel(subjIncluded)
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj});
    
    %keep count of valid sessions for easy indexing of last day mean PElatency
    sesCountA= 0;
    sesCountB= 0;
    sesCountC= 0;
    sesCountD= 0;
    sesCountE= 0;
    
        %stage2 (condA)
    for transitionSession= 1:size(allRats(1).subjSessA,1)
        session= allRats(1).subjSessA(transitionSession,subj);
                
        if ~isnan(session)
               %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselected= currentSubj(session).periDS.DS;  % all the DS cues
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(session).behavior.inPortDS))
                    if inPortTrial < numel(DSselected) 
                        DSselected(~isnan(currentSubj(session).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(session).behavior.poxDS))
                    if PEtrial < numel(DSselected)  %same here, we need an extra conditional in case cues were excluded
                        DSselected(cellfun('isempty', currentSubj(session).behavior.poxDS)) = nan;
                    end
                end
            
            allRats(1).poxOnly.meanDSPElatencyStage2(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency(~isnan(DSselected))); %take the mean of all the PE latencies for this session

                
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            
            %looping through lick cell array is a bit more complicated-
            %need to get indexes cues to loop through using (find) 
       for cue = find(~isnan(DSselected)) %loop through each selected trial and retrieve licks %1:numel(currentSubj(session).behavior.loxDSrel) 
                if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSrel{cue}(1);
                   lastLox(cue)=currentSubj(session).behavior.loxDSrel{cue}(end);
                   
               elseif isempty(currentSubj(session).behavior.loxDSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
                end            
                firstLox(firstLox==0)= nan; %replace empty 0s with nan
                lastLox(lastLox==0)=nan;
       end %end cue loop
        
               allRats(1).poxOnly.meanFirstloxDSstage2(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxDSstage2(transitionSession,subj)= nanmean(lastLox);

             if transitionSession==1
                allRats(1).poxOnly.meanDSPElatencyStage2FirstDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage2(1,subj);
             end
            sesCountA= sesCountA+1;
        end
    end
    
    allRats(1).poxOnly.meanFirstloxDSstage2FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage2(1,subj);
    allRats(1).poxOnly.meanLastloxDSstage2FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage2(1,subj);
  
    
       %stage5 (condB)
    for transitionSession= 1:size(allRats(1).subjSessB,1)
        session= allRats(1).subjSessB(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            %Exclude trials where animal was in port or did not make a PE
                %first get the DS cues for this session
                DSselected= currentSubj(session).periDS.DS;  % all the DS cues
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(session).behavior.inPortDS))
                    if inPortTrial < numel(DSselected) 
                        DSselected(~isnan(currentSubj(session).behavior.inPortDS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(session).behavior.poxDS))
                    if PEtrial < numel(DSselected)  %same here, we need an extra conditional in case cues were excluded
                        DSselected(cellfun('isempty', currentSubj(session).behavior.poxDS)) = nan;
                    end
                end
            
                     %Exclude trials where animal was in port or did not make a PE
                %first get the NS cues for this session
                NSselected= currentSubj(session).periNS.NS;  % all the NS cues
                
                %First, let's exclude trials where animal was already in port

                %We have to throw in an extra conditional in case we've excluded
                %cues in our peri cue analysis due to being too close to the
                %beginning or end.
                for inPortTrial = find(~isnan(currentSubj(session).behavior.inPortNS))
                    if inPortTrial < numel(NSselected) 
                        NSselected(~isnan(currentSubj(session).behavior.inPortNS)) = nan;
                    end
                end
                
                %Then, let's exclude trials where animal did not make a PE during
                %the cue epoch. (cellfun('isempty'))
                for PEtrial = find(cellfun('isempty', currentSubj(session).behavior.poxNS))
                    if PEtrial < numel(NSselected)  %same here, we need an extra conditional in case cues were excluded
                        NSselected(cellfun('isempty', currentSubj(session).behavior.poxNS)) = nan;
                    end
                end
            allRats(1).poxOnly.meanDSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency(~isnan(DSselected))); %take the mean of all the PE latencies for this session
            allRats(1).poxOnly.meanNSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency(~isnan(NSselected))); %take the mean of all the PE latencies for this session

            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
              for cue = find(~isnan(DSselected)) %loop through each selected trial and retrieve licks %1:numel(currentSubj(session).behavior.loxDSrel) 
                if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSrel{cue}(1);
                   lastLox(cue)=currentSubj(session).behavior.loxDSrel{cue}(end);
                   
               elseif isempty(currentSubj(session).behavior.loxDSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
                end            
                firstLox(firstLox==0)= nan; %replace empty 0s with nan
                lastLox(lastLox==0)=nan;
              end %end cue loop
        
               allRats(1).poxOnly.meanFirstloxDSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxDSstage5(transitionSession,subj)= nanmean(lastLox);

             for cue = find(~isnan(NSselected)) %loop through each selected trial and retrieve licks %1:numel(currentSubj(session).behavior.loxNSrel) 
                if ~isempty(currentSubj(session).behavior.loxNSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxNSrel{cue}(1);
                   lastLox(cue)=currentSubj(session).behavior.loxNSrel{cue}(end);
                   
               elseif isempty(currentSubj(session).behavior.loxNSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
                end            
                firstLox(firstLox==0)= nan; %replace empty 0s with nan
                lastLox(lastLox==0)=nan;
              end %end cue loop
        
               allRats(1).poxOnly.meanFirstloxNSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxNSstage5(transitionSession,subj)= nanmean(lastLox);

            if transitionSession==1
                allRats(1).poxOnly.meanDSPElatencyStage5FirstDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage5(1,subj);
                allRats(1).poxOnly.meanNSPElatencyStage5FirstDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage5(1,subj);
            end            
             sesCountB= sesCountB+1; %only add to count if not nan
        end
    end
        
        %TODO: keep in mind that as we go through here by subj, empty 0s may be added to
        %meanDSPElatencyStage5 if one animal has more sessions meeting
        %criteria than the others... not a big deal if looking at specific
        %days but if you took a mean or something across days you'd want to
        % make them nan
    allRats(1).poxOnly.meanDSPElatencyStage5LastDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage5(sesCountB,subj); 
    allRats(1).poxOnly.meanNSPElatencyStage5LastDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage5(sesCountB,subj); 
    
    allRats(1).poxOnly.meanFirstloxDSstage5FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage5(1,subj);
    allRats(1).poxOnly.meanFirstloxDSstage5LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage5(sesCountB,subj);
    allRats(1).poxOnly.meanLastloxDSstage5FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage5(1,subj);
    allRats(1).poxOnly.meanLastloxDSstage5LastDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage5(sesCountB,subj);
    
    
    allRats(1).poxOnly.meanFirstloxNSstage5FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage5(1,subj);
    allRats(1).poxOnly.meanFirstloxNSstage5LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage5(sesCountB,subj);
    allRats(1).poxOnly.meanLastloxNSstage5FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage5(1,subj);
    allRats(1).poxOnly.meanLastloxNSstage5LastDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage5(sesCountB,subj);
    
    %end stage 7 (cond C)
%stage7 (condC)
    for transitionSession= 1:size(allRats(1).subjSessC,1)
        session= allRats(1).subjSessC(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).poxOnly.meanDSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).poxOnly.meanNSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            for cue = 1:numel(currentSubj(session).behavior.loxDSrel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).poxOnly.meanFirstloxDSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxDSstage7(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSrel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSrel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).poxOnly.meanFirstloxNSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxNSstage7(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).poxOnly.meanDSPElatencyStage7FirstDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage7(1,subj);
                allRats(1).poxOnly.meanNSPElatencyStage7FirstDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage7(1,subj);
            end            
             sesCountC= sesCountC+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).poxOnly.meanDSPElatencyStage7LastDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage7(sesCountC,subj);
    allRats(1).poxOnly.meanNSPElatencyStage7LastDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage7(sesCountC,subj);
    
    allRats(1).poxOnly.meanFirstloxDSstage7FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage7(1,subj);
    allRats(1).poxOnly.meanFirstloxDSstage7LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage7(sesCountC,subj);
    allRats(1).poxOnly.meanLastloxDSstage7FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage7(1,subj);
    allRats(1).poxOnly.meanLastloxDSstage7LastDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage7(sesCountC,subj);
    
    
    allRats(1).poxOnly.meanFirstloxNSstage7FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage7(1,subj);
    allRats(1).poxOnly.meanFirstloxNSstage7LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage7(sesCountC,subj);
    allRats(1).poxOnly.meanLastloxNSstage7FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage7(1,subj);
    allRats(1).poxOnly.meanLastloxNSstage7LastDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage7(sesCountC,subj);
    
    %end stage 7 (cond C)
    
%stage8 (condD)
    for transitionSession= 1:size(allRats(1).subjSessD,1)
        session= allRats(1).subjSessD(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).poxOnly.meanDSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).poxOnly.meanNSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
               firstLox= []; %reset between sessions/subjs to prevent carryover of values
         lastLox= [];
           for cue = 1:numel(currentSubj(session).behavior.loxDSrel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).poxOnly.meanFirstloxDSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxDSstage8(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSrel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSrel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).poxOnly.meanFirstloxNSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxNSstage8(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).poxOnly.meanDSPElatencyStage8FirstDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage8(1,subj);
                allRats(1).poxOnly.meanNSPElatencyStage8FirstDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage8(1,subj);
            end            
             sesCountD= sesCountD+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).poxOnly.meanDSPElatencyStage8LastDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyStage8(sesCountD,subj);
    allRats(1).poxOnly.meanNSPElatencyStage8LastDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyStage8(sesCountD,subj);
    
    allRats(1).poxOnly.meanFirstloxDSstage8FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage8(1,subj);
    allRats(1).poxOnly.meanFirstloxDSstage8LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSstage8(sesCountD,subj);
    allRats(1).poxOnly.meanLastloxDSstage8FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage8(1,subj);
    allRats(1).poxOnly.meanLastloxDSstage8LastDay(1,subj)= allRats(1).poxOnly.meanLastloxDSstage8(sesCountD,subj);
    
    
    allRats(1).poxOnly.meanFirstloxNSstage8FirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage8(1,subj);
    allRats(1).poxOnly.meanFirstloxNSstage8LastDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSstage8(sesCountD,subj);
    allRats(1).poxOnly.meanLastloxNSstage8FirstDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage8(1,subj);
    allRats(1).poxOnly.meanLastloxNSstage8LastDay(1,subj)= allRats(1).poxOnly.meanLastloxNSstage8(sesCountD,subj);
    
    %end stage 8 (cond D)
    
%stage12 extinction (condE)
    for transitionSession= 1:size(allRats(1).subjSessE,1)
        session= allRats(1).subjSessE(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).poxOnly.meanDSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).poxOnly.meanNSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            for cue = 1:numel(currentSubj(session).behavior.loxDSrel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSrel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).poxOnly.meanFirstloxDSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxDSExtinction(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSrel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSrel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSrel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSrel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSrel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).poxOnly.meanFirstloxNSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).poxOnly.meanLastloxNSExtinction(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).poxOnly.meanDSPElatencyExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyExtinction(1,subj);
                allRats(1).poxOnly.meanNSPElatencyExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyExtinction(1,subj);
            end            
             sesCountE= sesCountE+1; %only add to count if not nan
        end
    end
         
    allRats(1).poxOnly.meanDSPElatencyExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanDSPElatencyExtinction(sesCountE,subj);
    allRats(1).poxOnly.meanNSPElatencyExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanNSPElatencyExtinction(sesCountE,subj);
    
    allRats(1).poxOnly.meanFirstloxDSExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSExtinction(1,subj);
    allRats(1).poxOnly.meanFirstloxDSExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanFirstloxDSExtinction(sesCountE,subj);
    allRats(1).poxOnly.meanLastloxDSExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanLastloxDSExtinction(1,subj);
    allRats(1).poxOnly.meanLastloxDSExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanLastloxDSExtinction(sesCountE,subj);
    
    allRats(1).poxOnly.meanFirstloxNSExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSExtinction(1,subj);
    allRats(1).poxOnly.meanFirstloxNSExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanFirstloxNSExtinction(sesCountE,subj);
    allRats(1).poxOnly.meanLastloxNSExtinctionFirstDay(1,subj)= allRats(1).poxOnly.meanLastloxNSExtinction(1,subj);
    allRats(1).poxOnly.meanLastloxNSExtinctionLastDay(1,subj)= allRats(1).poxOnly.meanLastloxNSExtinction(sesCountE,subj);
    
    %end stage 12 extinction (cond E)
 
end %end subj loop


    %get a grand mean across all subjects for these events
    %stage 2 
allRats(1).poxOnly.grandMeanDSPElatencyStage2FirstDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage2FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage2FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage2FirstDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage2FirstDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage2FirstDay);
    %stage 5
allRats(1).poxOnly.grandMeanDSPElatencyStage5FirstDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage5FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage5FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage5FirstDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage5FirstDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage5FirstDay);

allRats(1).poxOnly.grandMeanDSPElatencyStage5LastDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage5LastDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage5LastDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage5LastDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage5LastDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage5LastDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage5FirstDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage5FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage5FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage5FirstDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage5FirstDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage5FirstDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage5LastDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage5LastDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage5LastDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage5LastDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage5LastDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage5LastDay);
    %stage 7
allRats(1).poxOnly.grandMeanDSPElatencyStage7FirstDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage7FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage7FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage7FirstDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage7FirstDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage7FirstDay);

allRats(1).poxOnly.grandMeanDSPElatencyStage7LastDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage7LastDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage7LastDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage7LastDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage7LastDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage7LastDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage7FirstDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage7FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage7FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage7FirstDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage7FirstDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage7FirstDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage7LastDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage7LastDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage7LastDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage7LastDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage7LastDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage7LastDay);
    %stage 8
allRats(1).poxOnly.grandMeanDSPElatencyStage8FirstDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage8FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage8FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage8FirstDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage8FirstDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage8FirstDay);

allRats(1).poxOnly.grandMeanDSPElatencyStage8LastDay= nanmean(allRats(1).poxOnly.meanDSPElatencyStage8LastDay);
allRats(1).poxOnly.grandMeanfirstLoxDSstage8LastDay= nanmean(allRats(1).poxOnly.meanFirstloxDSstage8LastDay);
allRats(1).poxOnly.grandMeanlastLoxDSstage8LastDay= nanmean(allRats(1).poxOnly.meanLastloxDSstage8LastDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage8FirstDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage8FirstDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage8FirstDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage8FirstDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage8FirstDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage8FirstDay);

allRats(1).poxOnly.grandMeanNSPElatencyStage8LastDay= nanmean(allRats(1).poxOnly.meanNSPElatencyStage8LastDay);
allRats(1).poxOnly.grandMeanfirstLoxNSstage8LastDay= nanmean(allRats(1).poxOnly.meanFirstloxNSstage8LastDay);
allRats(1).poxOnly.grandMeanlastLoxNSstage8LastDay= nanmean(allRats(1).poxOnly.meanLastloxNSstage8LastDay);
    %stage 12 (extinction)
allRats(1).poxOnly.grandMeanDSPElatencyExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanDSPElatencyExtinctionFirstDay);
allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanFirstloxDSExtinctionFirstDay);
allRats(1).poxOnly.grandMeanlastLoxDSExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanLastloxDSExtinctionFirstDay);

allRats(1).poxOnly.grandMeanDSPElatencyExtinctionLastDay= nanmean(allRats(1).poxOnly.meanDSPElatencyExtinctionLastDay);
allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionLastDay= nanmean(allRats(1).poxOnly.meanFirstloxDSExtinctionLastDay);
allRats(1).poxOnly.grandMeanlastLoxDSExtinctionLastDay= nanmean(allRats(1).poxOnly.meanLastloxDSExtinctionLastDay);

allRats(1).poxOnly.grandMeanNSPElatencyExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanNSPElatencyExtinctionFirstDay);
allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanFirstloxNSExtinctionFirstDay);
allRats(1).poxOnly.grandMeanlastLoxNSExtinctionFirstDay= nanmean(allRats(1).poxOnly.meanLastloxNSExtinctionFirstDay);

allRats(1).poxOnly.grandMeanNSPElatencyExtinctionLastDay= nanmean(allRats(1).poxOnly.meanNSPElatencyExtinctionLastDay);
allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionLastDay= nanmean(allRats(1).poxOnly.meanFirstloxNSExtinctionLastDay);
allRats(1).poxOnly.grandMeanlastLoxNSExtinctionLastDay= nanmean(allRats(1).poxOnly.meanLastloxNSExtinctionLastDay);


%these should be plotted after the axes are equalized (or else the ylim
%plotting of vertical lines won't fill the axis)
subplot(2,9,1)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).poxOnly.grandMeanDSPElatencyStage2FirstDay,allRats(1).poxOnly.grandMeanDSPElatencyStage2FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage2FirstDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage2FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).poxOnly.grandMeanlastLoxDSstage2FirstDay,allRats(1).poxOnly.grandMeanlastLoxDSstage2FirstDay], ylim, 'g--');%plot vertical line for last lick

hLegend= legend('465nm', '405nm', '465nm SEM','405nm SEM', 'cue onset', 'mean PE latency', 'mean first & last lick'); %add rats to legend, location outside of plot

legendPosition = [.94 0.7 0.03 0.1];
set(hLegend,'Position', legendPosition,'Units', 'normalized');

subplot(2,9,2)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).poxOnly.grandMeanDSPElatencyStage5FirstDay,allRats(1).poxOnly.grandMeanDSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage5FirstDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).poxOnly.grandMeanlastLoxDSstage5FirstDay,allRats(1).poxOnly.grandMeanlastLoxDSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,3)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).poxOnly.grandMeanDSPElatencyStage5LastDay,allRats(1).poxOnly.grandMeanDSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage5LastDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).poxOnly.grandMeanlastLoxDSstage5LastDay,allRats(1).poxOnly.grandMeanlastLoxDSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,4)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyStage7FirstDay,allRats(1).poxOnly.grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage7FirstDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSstage7FirstDay,allRats(1).poxOnly.grandMeanlastLoxDSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,5)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyStage7LastDay,allRats(1).poxOnly.grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage7LastDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSstage7LastDay,allRats(1).poxOnly.grandMeanlastLoxDSstage7LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,6)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyStage8FirstDay,allRats(1).poxOnly.grandMeanDSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage8FirstDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSstage8FirstDay,allRats(1).poxOnly.grandMeanlastLoxDSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,7)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyStage8LastDay,allRats(1).poxOnly.grandMeanDSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSstage8LastDay,allRats(1).poxOnly.grandMeanfirstLoxDSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSstage8LastDay,allRats(1).poxOnly.grandMeanlastLoxDSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,8)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyExtinctionFirstDay,allRats(1).poxOnly.grandMeanDSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionFirstDay,allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSExtinctionFirstDay,allRats(1).poxOnly.grandMeanlastLoxDSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,9)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanDSPElatencyExtinctionLastDay,allRats(1).poxOnly.grandMeanDSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionLastDay,allRats(1).poxOnly.grandMeanfirstLoxDSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxDSExtinctionLastDay,allRats(1).poxOnly.grandMeanlastLoxDSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick



subplot(2,9,10) %no NS on stage 2


subplot(2,9,11)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage5FirstDay,allRats(1).poxOnly.grandMeanNSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage5FirstDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage5FirstDay,allRats(1).poxOnly.grandMeanlastLoxNSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,12)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage5LastDay,allRats(1).poxOnly.grandMeanNSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage5LastDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage5LastDay,allRats(1).poxOnly.grandMeanlastLoxNSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,13)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage7FirstDay,allRats(1).poxOnly.grandMeanNSPElatencyStage7FirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage7FirstDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage7FirstDay,allRats(1).poxOnly.grandMeanlastLoxNSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,14)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage7LastDay,allRats(1).poxOnly.grandMeanNSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage7LastDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage7LastDay,allRats(1).poxOnly.grandMeanlastLoxNSstage7LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,15)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage8FirstDay,allRats(1).poxOnly.grandMeanNSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage8FirstDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage8FirstDay,allRats(1).poxOnly.grandMeanlastLoxNSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,16)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyStage8LastDay,allRats(1).poxOnly.grandMeanNSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSstage8LastDay,allRats(1).poxOnly.grandMeanfirstLoxNSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSstage8LastDay,allRats(1).poxOnly.grandMeanlastLoxNSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,17)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyExtinctionFirstDay,allRats(1).poxOnly.grandMeanNSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionFirstDay,allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSExtinctionFirstDay,allRats(1).poxOnly.grandMeanlastLoxNSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,18)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
% plot([allRats(1).poxOnly.grandMeanNSPElatencyExtinctionLastDay,allRats(1).poxOnly.grandMeanNSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
% plot([allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionLastDay,allRats(1).poxOnly.grandMeanfirstLoxNSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
% plot([allRats(1).poxOnly.grandMeanlastLoxNSExtinctionLastDay,allRats(1).poxOnly.grandMeanlastLoxNSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick


