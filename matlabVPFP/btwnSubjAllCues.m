%% Between subjects response to ALL CUES on key transition sessions
%avg response timelocked to ALL CUES on key transition sessions
%(e.g. first day of training, first day with NS, last day of stage 5

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

     %replace empty 0s with nans AND identify individual sessions for
     %plotting (instead of plotting them all)
        %the above code filled in blank training dates with 0 for photometry data (e.g. if 1 rat 
        %ran 12 days but others ran 9 days, the 3 days in between were 
        %filled with 0), let's make these = nan instead 
        
            %condA
        allRats(1).subjSessA(allRats(1).subjSessA==0)=nan; %if there's no data for this date just make it nan

        for ses = 1:size(allRats(1).subjSessA,1) %each row is a session
           if ses==1 %retain only the first stage 2 day
               allRats(1).stage2FirstSes(1,subj)= allRats(1).subjSessA(ses,subj); %get corresponding session, will be used to extract photometry data
               
               allRats(1).DSzblueMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDS.DSzblueMean'; %transposing for readability
               allRats(1).DSzpurpleMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDS.DSzpurpleMean';
           end 
        end
        
            %condB
         allRats(1).subjSessB(allRats(1).subjSessB==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessB,1) %each row is a session           
           if ses==1 %retain the first and last stage 5 day
               allRats(1).stage5FirstSes(1,subj)= allRats(1).subjSessB(ses,subj);
               allRats(1).stage5LastSes(1,subj)= max(allRats(1).subjSessB(:,subj));
               
               allRats(1).DSzblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDS.DSzblueMean';
               allRats(1).NSzblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNS.NSzblueMean';
               allRats(1).DSzpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDS.DSzpurpleMean';
               allRats(1).NSzpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNS.NSzpurpleMean';
               
               allRats(1).DSzblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDS.DSzblueMean';
               allRats(1).NSzblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNS.NSzblueMean';
               allRats(1).DSzpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDS.DSzpurpleMean';
               allRats(1).NSzpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
           
         end
         
           %condC
         allRats(1).subjSessC(allRats(1).subjSessC==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessC,1) %each row is a session\     
           if ses==1 %retain the first and last stage 7 day
              allRats(1).stage7FirstSes(1,subj)= allRats(1).subjSessC(ses,subj);
              allRats(1).stage7LastSes(1,subj)=max(allRats(1).subjSessC(:,subj));
              
              allRats(1).DSzblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).DSzblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNS.NSzpurpleMean';
           end
           
         end
           %condD 
        allRats(1).subjSessD(allRats(1).subjSessD==0)=nan; %if there's no data for this date just make it nan
        for ses = 1:size(allRats(1).subjSessD,1) %each row is a session           
           if ses==1 %retain the first and last stage 8 days (last is extinction for vp-vta-fpround2)
              allRats(1).stage8FirstSes(1,subj)= allRats(1).subjSessD(ses,subj);
              allRats(1).stage8LastSes(1,subj)= max(allRats(1).subjSessD(:,subj));
              
              allRats(1).DSzblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).DSzblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
         end
         
               %condE 
         allRats(1).subjSessE(allRats(1).subjSessE==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessE,1) %each row is a session
           if ses==1 %retain the last extinction day
              
               allRats(1).extinctionFirstSes(1,subj)= allRats(1).subjSessE(ses,subj);
               allRats(1).extinctionLastSes(1,subj)= max(allRats(1).subjSessE(:,subj));

              allRats(1).DSzblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).DSzblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).NSzblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).DSzpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).NSzpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
         end
         
end %end subj loop
         


 % now get mean & SEM of all rats for these transition sessions (each column is a training day , each 3d page is a subject)
       
    %stage 2
 allRats.grandMeanDSzblueStage2FirstSes=nanmean(allRats.DSzblueMeanStage2FirstSes,3);
 allRats.grandMeanDSzpurpleStage2FirstSes=nanmean(allRats.DSzpurpleMeanStage2FirstSes,3);
 
    %stage 5
allRats(1).grandMeanDSzblueStage5FirstSes= nanmean(allRats.DSzblueMeanStage5FirstSes,3);
allRats(1).grandMeanNSzblueStage5FirstSes= nanmean(allRats.NSzblueMeanStage5FirstSes,3);
allRats(1).grandMeanDSzpurpleStage5FirstSes= nanmean(allRats.DSzpurpleMeanStage5FirstSes,3);
allRats(1).grandMeanNSzpurpleStage5FirstSes= nanmean(allRats.NSzpurpleMeanStage5FirstSes,3);

allRats(1).grandMeanDSzblueStage5LastSes= nanmean(allRats.DSzblueMeanStage5LastSes,3);
allRats(1).grandMeanNSzblueStage5LastSes= nanmean(allRats.NSzblueMeanStage5LastSes,3);
allRats(1).grandMeanDSzpurpleStage5LastSes= nanmean(allRats.DSzpurpleMeanStage5LastSes,3);
allRats(1).grandMeanNSzpurpleStage5LastSes= nanmean(allRats.NSzpurpleMeanStage5LastSes,3);
    
    %stage 7
allRats(1).grandMeanDSzblueStage7FirstSes= nanmean(allRats.DSzblueMeanStage7FirstSes,3);
allRats(1).grandMeanNSzblueStage7FirstSes= nanmean(allRats.NSzblueMeanStage7FirstSes,3);
allRats(1).grandMeanDSzpurpleStage7FirstSes= nanmean(allRats.DSzpurpleMeanStage7FirstSes,3);
allRats(1).grandMeanNSzpurpleStage7FirstSes= nanmean(allRats.NSzpurpleMeanStage7FirstSes,3);

allRats(1).grandMeanDSzblueStage7LastSes= nanmean(allRats.DSzblueMeanStage7LastSes,3);
allRats(1).grandMeanNSzblueStage7LastSes= nanmean(allRats.NSzblueMeanStage7LastSes,3);
allRats(1).grandMeanDSzpurpleStage7LastSes= nanmean(allRats.DSzpurpleMeanStage7LastSes,3);
allRats(1).grandMeanNSzpurpleStage7LastSes= nanmean(allRats.NSzpurpleMeanStage7LastSes,3);    
 
    %stage 8
allRats(1).grandMeanDSzblueStage8FirstSes= nanmean(allRats.DSzblueMeanStage8FirstSes,3);
allRats(1).grandMeanNSzblueStage8FirstSes= nanmean(allRats.NSzblueMeanStage8FirstSes,3);
allRats(1).grandMeanDSzpurpleStage8FirstSes= nanmean(allRats.DSzpurpleMeanStage8FirstSes,3);
allRats(1).grandMeanNSzpurpleStage8FirstSes= nanmean(allRats.NSzpurpleMeanStage8FirstSes,3);

allRats(1).grandMeanDSzblueStage8LastSes= nanmean(allRats.DSzblueMeanStage8LastSes,3);
allRats(1).grandMeanNSzblueStage8LastSes= nanmean(allRats.NSzblueMeanStage8LastSes,3);
allRats(1).grandMeanDSzpurpleStage8LastSes= nanmean(allRats.DSzpurpleMeanStage8LastSes,3);
allRats(1).grandMeanNSzpurpleStage8LastSes= nanmean(allRats.NSzpurpleMeanStage8LastSes,3);    

    %stage 12 (extinction)
allRats(1).grandMeanDSzblueExtinctionFirstSes= nanmean(allRats.DSzblueMeanExtinctionFirstSes,3);
allRats(1).grandMeanNSzblueExtinctionFirstSes= nanmean(allRats.NSzblueMeanExtinctionFirstSes,3);
allRats(1).grandMeanDSzpurpleExtinctionFirstSes= nanmean(allRats.DSzpurpleMeanExtinctionFirstSes,3);
allRats(1).grandMeanNSzpurpleExtinctionFirstSes= nanmean(allRats.NSzpurpleMeanExtinctionFirstSes,3);  
    
allRats(1).grandMeanDSzblueExtinctionLastSes= nanmean(allRats.DSzblueMeanExtinctionLastSes,3);
allRats(1).grandMeanNSzblueExtinctionLastSes= nanmean(allRats.NSzblueMeanExtinctionLastSes,3);
allRats(1).grandMeanDSzpurpleExtinctionLastSes= nanmean(allRats.DSzpurpleMeanExtinctionLastSes,3);
allRats(1).grandMeanNSzpurpleExtinctionLastSes= nanmean(allRats.NSzpurpleMeanExtinctionLastSes,3);  


 %Calculate standard error of the mean(SEM)
  %treat each animal's avg as an obesrvation and calculate their std from
  %the grand mean across all animals
    %stage 2
allRats(1).grandStdDSzblueStage2FirstSes= nanstd(allRats.DSzblueMeanStage2FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage2FirstSes= allRats(1).grandStdDSzblueStage2FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage2FirstSes= nanstd(allRats.DSzpurpleMeanStage2FirstSes,0,3); 
allRats(1).grandSEMDSzpurpleStage2FirstSes= allRats(1).grandStdDSzpurpleStage2FirstSes/sqrt(numel(subjIncluded));

   %stage 5
allRats(1).grandStdDSzblueStage5FirstSes= nanstd(allRats.DSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage5FirstSes= allRats(1).grandStdDSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage5FirstSes= nanstd(allRats.DSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).grandSEMDSzpurpleStage5FirstSes= allRats(1).grandStdDSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdDSzblueStage5LastSes= nanstd(allRats.DSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage5LastSes= allRats(1).grandStdDSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage5LastSes= nanstd(allRats.DSzpurpleMeanStage5LastSes,0,3); 
allRats(1).grandSEMDSzpurpleStage5LastSes= allRats(1).grandStdDSzpurpleStage5LastSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage5FirstSes= nanstd(allRats.NSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage5FirstSes= allRats(1).grandStdNSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage5FirstSes= nanstd(allRats.NSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).grandSEMNSzpurpleStage5FirstSes= allRats(1).grandStdNSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage5LastSes= nanstd(allRats.NSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage5LastSes= allRats(1).grandStdNSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage5LastSes= nanstd(allRats.NSzpurpleMeanStage5LastSes,0,3); 
allRats(1).grandSEMNSzpurpleStage5LastSes= allRats(1).grandStdNSzpurpleStage5LastSes/sqrt(numel(subjIncluded));


    %stage 7
allRats(1).grandStdDSzblueStage7FirstSes= nanstd(allRats.DSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage7FirstSes= allRats(1).grandStdDSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage7FirstSes= nanstd(allRats.DSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).grandSEMDSzpurpleStage7FirstSes= allRats(1).grandStdDSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdDSzblueStage7LastSes= nanstd(allRats.DSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage7LastSes= allRats(1).grandStdDSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage7LastSes= nanstd(allRats.DSzpurpleMeanStage7LastSes,0,3); 
allRats(1).grandSEMDSzpurpleStage7LastSes= allRats(1).grandStdDSzpurpleStage7LastSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage7FirstSes= nanstd(allRats.NSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage7FirstSes= allRats(1).grandStdNSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage7FirstSes= nanstd(allRats.NSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).grandSEMNSzpurpleStage7FirstSes= allRats(1).grandStdNSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage7LastSes= nanstd(allRats.NSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage7LastSes= allRats(1).grandStdNSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage7LastSes= nanstd(allRats.NSzpurpleMeanStage7LastSes,0,3); 
allRats(1).grandSEMNSzpurpleStage7LastSes= allRats(1).grandStdNSzpurpleStage7LastSes/sqrt(numel(subjIncluded));
    
    %stage 8
allRats(1).grandStdDSzblueStage8FirstSes= nanstd(allRats.DSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage8FirstSes= allRats(1).grandStdDSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage8FirstSes= nanstd(allRats.DSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).grandSEMDSzpurpleStage8FirstSes= allRats(1).grandStdDSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdDSzblueStage8LastSes= nanstd(allRats.DSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueStage8LastSes= allRats(1).grandStdDSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleStage8LastSes= nanstd(allRats.DSzpurpleMeanStage8LastSes,0,3); 
allRats(1).grandSEMDSzpurpleStage8LastSes= allRats(1).grandStdDSzpurpleStage8LastSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage8FirstSes= nanstd(allRats.NSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage8FirstSes= allRats(1).grandStdNSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage8FirstSes= nanstd(allRats.NSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).grandSEMNSzpurpleStage8FirstSes= allRats(1).grandStdNSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueStage8LastSes= nanstd(allRats.NSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueStage8LastSes= allRats(1).grandStdNSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleStage8LastSes= nanstd(allRats.NSzpurpleMeanStage8LastSes,0,3); 
allRats(1).grandSEMNSzpurpleStage8LastSes= allRats(1).grandStdNSzpurpleStage8LastSes/sqrt(numel(subjIncluded));

    %stage 12 (extinction)
allRats(1).grandStdDSzblueExtinctionFirstSes= nanstd(allRats.DSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueExtinctionFirstSes= allRats(1).grandStdDSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleExtinctionFirstSes= nanstd(allRats.DSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).grandSEMDSzpurpleExtinctionFirstSes= allRats(1).grandStdDSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdDSzblueExtinctionLastSes= nanstd(allRats.DSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMDSzblueExtinctionLastSes= allRats(1).grandStdDSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdDSzpurpleExtinctionLastSes= nanstd(allRats.DSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).grandSEMDSzpurpleExtinctionLastSes= allRats(1).grandStdDSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueExtinctionFirstSes= nanstd(allRats.NSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueExtinctionFirstSes= allRats(1).grandStdNSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleExtinctionFirstSes= nanstd(allRats.NSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).grandSEMNSzpurpleExtinctionFirstSes= allRats(1).grandStdNSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).grandStdNSzblueExtinctionLastSes= nanstd(allRats.NSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).grandSEMNSzblueExtinctionLastSes= allRats(1).grandStdNSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).grandStdNSzpurpleExtinctionLastSes= nanstd(allRats.NSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).grandSEMNSzpurpleExtinctionLastSes= allRats(1).grandStdNSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

% Now, 2d plots 
figure(figureCount);
figureCount= figureCount+1;

sgtitle('Between subjects (n=5) avg response to CUE- ALL TRIALS- on transition days')

subplot(2,9,1);
title('DS stage 2 first day');
hold on;
plot(timeLock,allRats(1).grandMeanDSzblueStage2FirstSes, 'b');
plot(timeLock,allRats(1).grandMeanDSzpurpleStage2FirstSes, 'm');

grandSemBluePos= allRats(1).grandMeanDSzblueStage2FirstSes+allRats(1).grandSEMDSzblueStage2FirstSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage2FirstSes-allRats(1).grandSEMDSzblueStage2FirstSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage2FirstSes+allRats(1).grandSEMDSzpurpleStage2FirstSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage2FirstSes-allRats(1).grandSEMDSzpurpleStage2FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,2);
title('DS stage 5 first day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage5FirstSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage5FirstSes+allRats(1).grandSEMDSzblueStage5FirstSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage5FirstSes-allRats(1).grandSEMDSzblueStage5FirstSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage5FirstSes+allRats(1).grandSEMDSzpurpleStage5FirstSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage5FirstSes-allRats(1).grandSEMDSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,3);
title('DS stage 5 last day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage5LastSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage5LastSes+allRats(1).grandSEMDSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage5LastSes-allRats(1).grandSEMDSzblueStage5LastSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage5LastSes+allRats(1).grandSEMDSzpurpleStage5LastSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage5LastSes-allRats(1).grandSEMDSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,4);
title('DS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage7FirstSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage7FirstSes+allRats(1).grandSEMDSzblueStage7FirstSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage7FirstSes-allRats(1).grandSEMDSzblueStage7FirstSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage7FirstSes+allRats(1).grandSEMDSzpurpleStage7FirstSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage7FirstSes-allRats(1).grandSEMDSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,5);
title('DS stage 7 last day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage7LastSes, 'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage7LastSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage7LastSes+allRats(1).grandSEMDSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage7LastSes-allRats(1).grandSEMDSzblueStage5LastSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage7LastSes+allRats(1).grandSEMDSzpurpleStage7LastSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage7LastSes-allRats(1).grandSEMDSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,6);
title('DS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage8FirstSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage8FirstSes+allRats(1).grandSEMDSzblueStage8FirstSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage8FirstSes-allRats(1).grandSEMDSzblueStage8FirstSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage8FirstSes+allRats(1).grandSEMDSzpurpleStage8FirstSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage8FirstSes-allRats(1).grandSEMDSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,7);
title('DS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueStage8LastSes, 'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleStage8LastSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueStage8LastSes+allRats(1).grandSEMDSzblueStage8LastSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueStage8LastSes-allRats(1).grandSEMDSzblueStage8LastSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleStage8LastSes+allRats(1).grandSEMDSzpurpleStage8LastSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleStage8LastSes-allRats(1).grandSEMDSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,8);
title('DS extinction first day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleExtinctionFirstSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueExtinctionFirstSes+allRats(1).grandSEMDSzblueExtinctionFirstSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueExtinctionFirstSes-allRats(1).grandSEMDSzblueExtinctionFirstSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleExtinctionFirstSes+allRats(1).grandSEMDSzpurpleExtinctionFirstSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleExtinctionFirstSes-allRats(1).grandSEMDSzpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,9);
title('DS extinction last day');
hold on;
plot(timeLock, allRats(1).grandMeanDSzblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).grandMeanDSzpurpleExtinctionLastSes,'m');

grandSemBluePos= allRats(1).grandMeanDSzblueExtinctionLastSes+allRats(1).grandSEMDSzblueExtinctionLastSes;
grandSemBlueNeg= allRats(1).grandMeanDSzblueExtinctionLastSes-allRats(1).grandSEMDSzblueExtinctionLastSes;

grandSemPurplePos= allRats(1).grandMeanDSzpurpleExtinctionLastSes+allRats(1).grandSEMDSzpurpleExtinctionLastSes;
grandSemPurpleNeg= allRats(1).grandMeanDSzpurpleExtinctionLastSes-allRats(1).grandSEMDSzpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);



subplot(2,9,10);
title('No NS on stage 2');


subplot(2,9,11);
title('NS stage 5 first day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage5FirstSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage5FirstSes+allRats(1).grandSEMNSzblueStage5FirstSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage5FirstSes-allRats(1).grandSEMNSzblueStage5FirstSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage5FirstSes+allRats(1).grandSEMNSzpurpleStage5FirstSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage5FirstSes-allRats(1).grandSEMNSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,12);
title('NS stage 5 last day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage5LastSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage5LastSes+allRats(1).grandSEMNSzblueStage5LastSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage5LastSes-allRats(1).grandSEMNSzblueStage5LastSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage5LastSes+allRats(1).grandSEMNSzpurpleStage5LastSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage5LastSes-allRats(1).grandSEMNSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,13);
title('NS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage7FirstSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage7FirstSes+allRats(1).grandSEMNSzblueStage7FirstSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage7FirstSes-allRats(1).grandSEMNSzblueStage7FirstSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage7FirstSes+allRats(1).grandSEMNSzpurpleStage7FirstSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage7FirstSes-allRats(1).grandSEMNSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,14);
title('NS stage 7 last day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage7LastSes, 'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage7LastSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage7LastSes+allRats(1).grandSEMNSzblueStage5LastSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage7LastSes-allRats(1).grandSEMNSzblueStage5LastSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage7LastSes+allRats(1).grandSEMNSzpurpleStage7LastSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage7LastSes-allRats(1).grandSEMNSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,15);
title('NS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage8FirstSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage8FirstSes+allRats(1).grandSEMNSzblueStage8FirstSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage8FirstSes-allRats(1).grandSEMNSzblueStage8FirstSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage8FirstSes+allRats(1).grandSEMNSzpurpleStage8FirstSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage8FirstSes-allRats(1).grandSEMNSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,16);
title('NS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueStage8LastSes, 'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleStage8LastSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueStage8LastSes+allRats(1).grandSEMNSzblueStage8LastSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueStage8LastSes-allRats(1).grandSEMNSzblueStage8LastSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleStage8LastSes+allRats(1).grandSEMNSzpurpleStage8LastSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleStage8LastSes-allRats(1).grandSEMNSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,17);
title('NS extinction first day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleExtinctionFirstSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueExtinctionFirstSes+allRats(1).grandSEMNSzblueExtinctionFirstSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueExtinctionFirstSes-allRats(1).grandSEMNSzblueExtinctionFirstSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleExtinctionFirstSes+allRats(1).grandSEMNSzpurpleExtinctionFirstSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleExtinctionFirstSes-allRats(1).grandSEMNSzpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,18);
title('NS extinction last day');
hold on;
plot(timeLock, allRats(1).grandMeanNSzblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).grandMeanNSzpurpleExtinctionLastSes,'m');

grandNSemBluePos= allRats(1).grandMeanNSzblueExtinctionLastSes+allRats(1).grandSEMNSzblueExtinctionLastSes;
grandNSemBlueNeg= allRats(1).grandMeanNSzblueExtinctionLastSes-allRats(1).grandSEMNSzblueExtinctionLastSes;

grandNSemPurplePos= allRats(1).grandMeanNSzpurpleExtinctionLastSes+allRats(1).grandSEMNSzpurpleExtinctionLastSes;
grandNSemPurpleNeg= allRats(1).grandMeanNSzpurpleExtinctionLastSes-allRats(1).grandSEMNSzpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

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
            allRats(1).meanDSPElatencyStage2(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session

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
               allRats(1).meanFirstloxDSstage2(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxDSstage2(transitionSession,subj)= nanmean(lastLox);
        end

           
             if transitionSession==1
                allRats(1).meanDSPElatencyStage2FirstDay(1,subj)= allRats(1).meanDSPElatencyStage2(1,subj);
             end
            sesCountA= sesCountA+1;
        end
    end
    
    allRats(1).meanFirstloxDSstage2FirstDay(1,subj)= allRats(1).meanFirstloxDSstage2(1,subj);
    allRats(1).meanLastloxDSstage2FirstDay(1,subj)= allRats(1).meanLastloxDSstage2(1,subj);
  
    
       %stage5 (condB)
    for transitionSession= 1:size(allRats(1).subjSessB,1)
        session= allRats(1).subjSessB(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).meanDSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).meanNSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).meanFirstloxDSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxDSstage5(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).meanFirstloxNSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxNSstage5(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).meanDSPElatencyStage5FirstDay(1,subj)= allRats(1).meanDSPElatencyStage5(1,subj);
                allRats(1).meanNSPElatencyStage5FirstDay(1,subj)= allRats(1).meanNSPElatencyStage5(1,subj);
            end            
             sesCountB= sesCountB+1; %only add to count if not nan
        end
    end
        
        %TODO: keep in mind that as we go through here by subj, empty 0s may be added to
        %meanDSPElatencyStage5 if one animal has more sessions meeting
        %criteria than the others... not a big deal if looking at specific
        %days but if you took a mean or something across days you'd want to
        % make them nan
    allRats(1).meanDSPElatencyStage5LastDay(1,subj)= allRats(1).meanDSPElatencyStage5(sesCountB,subj); 
    allRats(1).meanNSPElatencyStage5LastDay(1,subj)= allRats(1).meanNSPElatencyStage5(sesCountB,subj); 
    
    allRats(1).meanFirstloxDSstage5FirstDay(1,subj)= allRats(1).meanFirstloxDSstage5(1,subj);
    allRats(1).meanFirstloxDSstage5LastDay(1,subj)= allRats(1).meanFirstloxDSstage5(sesCountB,subj);
    allRats(1).meanLastloxDSstage5FirstDay(1,subj)= allRats(1).meanLastloxDSstage5(1,subj);
    allRats(1).meanLastloxDSstage5LastDay(1,subj)= allRats(1).meanLastloxDSstage5(sesCountB,subj);
    
    
    allRats(1).meanFirstloxNSstage5FirstDay(1,subj)= allRats(1).meanFirstloxNSstage5(1,subj);
    allRats(1).meanFirstloxNSstage5LastDay(1,subj)= allRats(1).meanFirstloxNSstage5(sesCountB,subj);
    allRats(1).meanLastloxNSstage5FirstDay(1,subj)= allRats(1).meanLastloxNSstage5(1,subj);
    allRats(1).meanLastloxNSstage5LastDay(1,subj)= allRats(1).meanLastloxNSstage5(sesCountB,subj);
    
    %end stage 7 (cond C)
%stage7 (condC)
    for transitionSession= 1:size(allRats(1).subjSessC,1)
        session= allRats(1).subjSessC(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).meanDSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).meanNSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).meanFirstloxDSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxDSstage7(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).meanFirstloxNSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxNSstage7(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).meanDSPElatencyStage7FirstDay(1,subj)= allRats(1).meanDSPElatencyStage7(1,subj);
                allRats(1).meanNSPElatencyStage7FirstDay(1,subj)= allRats(1).meanNSPElatencyStage7(1,subj);
            end            
             sesCountC= sesCountC+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).meanDSPElatencyStage7LastDay(1,subj)= allRats(1).meanDSPElatencyStage7(sesCountC,subj);
    allRats(1).meanNSPElatencyStage7LastDay(1,subj)= allRats(1).meanNSPElatencyStage7(sesCountC,subj);
    
    allRats(1).meanFirstloxDSstage7FirstDay(1,subj)= allRats(1).meanFirstloxDSstage7(1,subj);
    allRats(1).meanFirstloxDSstage7LastDay(1,subj)= allRats(1).meanFirstloxDSstage7(sesCountC,subj);
    allRats(1).meanLastloxDSstage7FirstDay(1,subj)= allRats(1).meanLastloxDSstage7(1,subj);
    allRats(1).meanLastloxDSstage7LastDay(1,subj)= allRats(1).meanLastloxDSstage7(sesCountC,subj);
    
    
    allRats(1).meanFirstloxNSstage7FirstDay(1,subj)= allRats(1).meanFirstloxNSstage7(1,subj);
    allRats(1).meanFirstloxNSstage7LastDay(1,subj)= allRats(1).meanFirstloxNSstage7(sesCountC,subj);
    allRats(1).meanLastloxNSstage7FirstDay(1,subj)= allRats(1).meanLastloxNSstage7(1,subj);
    allRats(1).meanLastloxNSstage7LastDay(1,subj)= allRats(1).meanLastloxNSstage7(sesCountC,subj);
    
    %end stage 7 (cond C)
    
%stage8 (condD)
    for transitionSession= 1:size(allRats(1).subjSessD,1)
        session= allRats(1).subjSessD(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).meanDSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).meanNSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).meanFirstloxDSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxDSstage8(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).meanFirstloxNSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxNSstage8(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).meanDSPElatencyStage8FirstDay(1,subj)= allRats(1).meanDSPElatencyStage8(1,subj);
                allRats(1).meanNSPElatencyStage8FirstDay(1,subj)= allRats(1).meanNSPElatencyStage8(1,subj);
            end            
             sesCountD= sesCountD+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).meanDSPElatencyStage8LastDay(1,subj)= allRats(1).meanDSPElatencyStage8(sesCountD,subj);
    allRats(1).meanNSPElatencyStage8LastDay(1,subj)= allRats(1).meanNSPElatencyStage8(sesCountD,subj);
    
    allRats(1).meanFirstloxDSstage8FirstDay(1,subj)= allRats(1).meanFirstloxDSstage8(1,subj);
    allRats(1).meanFirstloxDSstage8LastDay(1,subj)= allRats(1).meanFirstloxDSstage8(sesCountD,subj);
    allRats(1).meanLastloxDSstage8FirstDay(1,subj)= allRats(1).meanLastloxDSstage8(1,subj);
    allRats(1).meanLastloxDSstage8LastDay(1,subj)= allRats(1).meanLastloxDSstage8(sesCountD,subj);
    
    
    allRats(1).meanFirstloxNSstage8FirstDay(1,subj)= allRats(1).meanFirstloxNSstage8(1,subj);
    allRats(1).meanFirstloxNSstage8LastDay(1,subj)= allRats(1).meanFirstloxNSstage8(sesCountD,subj);
    allRats(1).meanLastloxNSstage8FirstDay(1,subj)= allRats(1).meanLastloxNSstage8(1,subj);
    allRats(1).meanLastloxNSstage8LastDay(1,subj)= allRats(1).meanLastloxNSstage8(sesCountD,subj);
    
    %end stage 8 (cond D)
    
%stage12 extinction (condE)
    for transitionSession= 1:size(allRats(1).subjSessE,1)
        session= allRats(1).subjSessE(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).meanDSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).meanNSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).meanFirstloxDSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxDSExtinction(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).meanFirstloxNSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).meanLastloxNSExtinction(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).meanDSPElatencyExtinctionFirstDay(1,subj)= allRats(1).meanDSPElatencyExtinction(1,subj);
                allRats(1).meanNSPElatencyExtinctionFirstDay(1,subj)= allRats(1).meanNSPElatencyExtinction(1,subj);
            end            
             sesCountE= sesCountE+1; %only add to count if not nan
        end
    end
         
    allRats(1).meanDSPElatencyExtinctionLastDay(1,subj)= allRats(1).meanDSPElatencyExtinction(sesCountE,subj);
    allRats(1).meanNSPElatencyExtinctionLastDay(1,subj)= allRats(1).meanNSPElatencyExtinction(sesCountE,subj);
    
    allRats(1).meanFirstloxDSExtinctionFirstDay(1,subj)= allRats(1).meanFirstloxDSExtinction(1,subj);
    allRats(1).meanFirstloxDSExtinctionLastDay(1,subj)= allRats(1).meanFirstloxDSExtinction(sesCountE,subj);
    allRats(1).meanLastloxDSExtinctionFirstDay(1,subj)= allRats(1).meanLastloxDSExtinction(1,subj);
    allRats(1).meanLastloxDSExtinctionLastDay(1,subj)= allRats(1).meanLastloxDSExtinction(sesCountE,subj);
    
    allRats(1).meanFirstloxNSExtinctionFirstDay(1,subj)= allRats(1).meanFirstloxNSExtinction(1,subj);
    allRats(1).meanFirstloxNSExtinctionLastDay(1,subj)= allRats(1).meanFirstloxNSExtinction(sesCountE,subj);
    allRats(1).meanLastloxNSExtinctionFirstDay(1,subj)= allRats(1).meanLastloxNSExtinction(1,subj);
    allRats(1).meanLastloxNSExtinctionLastDay(1,subj)= allRats(1).meanLastloxNSExtinction(sesCountE,subj);
    
    %end stage 12 extinction (cond E)
 
end %end subj loop


    %get a grand mean across all subjects for these events
    %stage 2 
allRats(1).grandMeanDSPElatencyStage2FirstDay= nanmean(allRats(1).meanDSPElatencyStage2FirstDay);
allRats(1).grandMeanfirstLoxDSstage2FirstDay= nanmean(allRats(1).meanFirstloxDSstage2FirstDay);
allRats(1).grandMeanlastLoxDSstage2FirstDay= nanmean(allRats(1).meanLastloxDSstage2FirstDay);
    %stage 5
allRats(1).grandMeanDSPElatencyStage5FirstDay= nanmean(allRats(1).meanDSPElatencyStage5FirstDay);
allRats(1).grandMeanfirstLoxDSstage5FirstDay= nanmean(allRats(1).meanFirstloxDSstage5FirstDay);
allRats(1).grandMeanlastLoxDSstage5FirstDay= nanmean(allRats(1).meanLastloxDSstage5FirstDay);

allRats(1).grandMeanDSPElatencyStage5LastDay= nanmean(allRats(1).meanDSPElatencyStage5LastDay);
allRats(1).grandMeanfirstLoxDSstage5LastDay= nanmean(allRats(1).meanFirstloxDSstage5LastDay);
allRats(1).grandMeanlastLoxDSstage5LastDay= nanmean(allRats(1).meanLastloxDSstage5LastDay);

allRats(1).grandMeanNSPElatencyStage5FirstDay= nanmean(allRats(1).meanNSPElatencyStage5FirstDay);
allRats(1).grandMeanfirstLoxNSstage5FirstDay= nanmean(allRats(1).meanFirstloxNSstage5FirstDay);
allRats(1).grandMeanlastLoxNSstage5FirstDay= nanmean(allRats(1).meanLastloxNSstage5FirstDay);

allRats(1).grandMeanNSPElatencyStage5LastDay= nanmean(allRats(1).meanNSPElatencyStage5LastDay);
allRats(1).grandMeanfirstLoxNSstage5LastDay= nanmean(allRats(1).meanFirstloxNSstage5LastDay);
allRats(1).grandMeanlastLoxNSstage5LastDay= nanmean(allRats(1).meanLastloxNSstage5LastDay);
    %stage 7
allRats(1).grandMeanDSPElatencyStage7FirstDay= nanmean(allRats(1).meanDSPElatencyStage7FirstDay);
allRats(1).grandMeanfirstLoxDSstage7FirstDay= nanmean(allRats(1).meanFirstloxDSstage7FirstDay);
allRats(1).grandMeanlastLoxDSstage7FirstDay= nanmean(allRats(1).meanLastloxDSstage7FirstDay);

allRats(1).grandMeanDSPElatencyStage7LastDay= nanmean(allRats(1).meanDSPElatencyStage7LastDay);
allRats(1).grandMeanfirstLoxDSstage7LastDay= nanmean(allRats(1).meanFirstloxDSstage7LastDay);
allRats(1).grandMeanlastLoxDSstage7LastDay= nanmean(allRats(1).meanLastloxDSstage7LastDay);

allRats(1).grandMeanNSPElatencyStage7FirstDay= nanmean(allRats(1).meanNSPElatencyStage7FirstDay);
allRats(1).grandMeanfirstLoxNSstage7FirstDay= nanmean(allRats(1).meanFirstloxNSstage7FirstDay);
allRats(1).grandMeanlastLoxNSstage7FirstDay= nanmean(allRats(1).meanLastloxNSstage7FirstDay);

allRats(1).grandMeanNSPElatencyStage7LastDay= nanmean(allRats(1).meanNSPElatencyStage7LastDay);
allRats(1).grandMeanfirstLoxNSstage7LastDay= nanmean(allRats(1).meanFirstloxNSstage7LastDay);
allRats(1).grandMeanlastLoxNSstage7LastDay= nanmean(allRats(1).meanLastloxNSstage7LastDay);
    %stage 8
allRats(1).grandMeanDSPElatencyStage8FirstDay= nanmean(allRats(1).meanDSPElatencyStage8FirstDay);
allRats(1).grandMeanfirstLoxDSstage8FirstDay= nanmean(allRats(1).meanFirstloxDSstage8FirstDay);
allRats(1).grandMeanlastLoxDSstage8FirstDay= nanmean(allRats(1).meanLastloxDSstage8FirstDay);

allRats(1).grandMeanDSPElatencyStage8LastDay= nanmean(allRats(1).meanDSPElatencyStage8LastDay);
allRats(1).grandMeanfirstLoxDSstage8LastDay= nanmean(allRats(1).meanFirstloxDSstage8LastDay);
allRats(1).grandMeanlastLoxDSstage8LastDay= nanmean(allRats(1).meanLastloxDSstage8LastDay);

allRats(1).grandMeanNSPElatencyStage8FirstDay= nanmean(allRats(1).meanNSPElatencyStage8FirstDay);
allRats(1).grandMeanfirstLoxNSstage8FirstDay= nanmean(allRats(1).meanFirstloxNSstage8FirstDay);
allRats(1).grandMeanlastLoxNSstage8FirstDay= nanmean(allRats(1).meanLastloxNSstage8FirstDay);

allRats(1).grandMeanNSPElatencyStage8LastDay= nanmean(allRats(1).meanNSPElatencyStage8LastDay);
allRats(1).grandMeanfirstLoxNSstage8LastDay= nanmean(allRats(1).meanFirstloxNSstage8LastDay);
allRats(1).grandMeanlastLoxNSstage8LastDay= nanmean(allRats(1).meanLastloxNSstage8LastDay);
    %stage 12 (extinction)
allRats(1).grandMeanDSPElatencyExtinctionFirstDay= nanmean(allRats(1).meanDSPElatencyExtinctionFirstDay);
allRats(1).grandMeanfirstLoxDSExtinctionFirstDay= nanmean(allRats(1).meanFirstloxDSExtinctionFirstDay);
allRats(1).grandMeanlastLoxDSExtinctionFirstDay= nanmean(allRats(1).meanLastloxDSExtinctionFirstDay);

allRats(1).grandMeanDSPElatencyExtinctionLastDay= nanmean(allRats(1).meanDSPElatencyExtinctionLastDay);
allRats(1).grandMeanfirstLoxDSExtinctionLastDay= nanmean(allRats(1).meanFirstloxDSExtinctionLastDay);
allRats(1).grandMeanlastLoxDSExtinctionLastDay= nanmean(allRats(1).meanLastloxDSExtinctionLastDay);

allRats(1).grandMeanNSPElatencyExtinctionFirstDay= nanmean(allRats(1).meanNSPElatencyExtinctionFirstDay);
allRats(1).grandMeanfirstLoxNSExtinctionFirstDay= nanmean(allRats(1).meanFirstloxNSExtinctionFirstDay);
allRats(1).grandMeanlastLoxNSExtinctionFirstDay= nanmean(allRats(1).meanLastloxNSExtinctionFirstDay);

allRats(1).grandMeanNSPElatencyExtinctionLastDay= nanmean(allRats(1).meanNSPElatencyExtinctionLastDay);
allRats(1).grandMeanfirstLoxNSExtinctionLastDay= nanmean(allRats(1).meanFirstloxNSExtinctionLastDay);
allRats(1).grandMeanlastLoxNSExtinctionLastDay= nanmean(allRats(1).meanLastloxNSExtinctionLastDay);

subplot(2,9,1)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage2FirstDay,allRats(1).grandMeanDSPElatencyStage2FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage2FirstDay,allRats(1).grandMeanfirstLoxDSstage2FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage2FirstDay,allRats(1).grandMeanlastLoxDSstage2FirstDay], ylim, 'g--');%plot vertical line for last lick

hLegend= legend('465nm', '405nm', '465nm SEM','405nm SEM', 'cue onset', 'mean PE latency', 'mean first & last lick'); %add rats to legend, location outside of plot

legendPosition = [.94 0.7 0.03 0.1];
set(hLegend,'Position', legendPosition,'Units', 'normalized');

subplot(2,9,2)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage5FirstDay,allRats(1).grandMeanDSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage5FirstDay,allRats(1).grandMeanfirstLoxDSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage5FirstDay,allRats(1).grandMeanlastLoxDSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,3)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage5LastDay,allRats(1).grandMeanDSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage5LastDay,allRats(1).grandMeanfirstLoxDSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage5LastDay,allRats(1).grandMeanlastLoxDSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,4)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage7FirstDay,allRats(1).grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage7FirstDay,allRats(1).grandMeanfirstLoxDSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage7FirstDay,allRats(1).grandMeanlastLoxDSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,5)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage7LastDay,allRats(1).grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage7LastDay,allRats(1).grandMeanfirstLoxDSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage7LastDay,allRats(1).grandMeanlastLoxDSstage7LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,6)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage8FirstDay,allRats(1).grandMeanDSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage8FirstDay,allRats(1).grandMeanfirstLoxDSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage8FirstDay,allRats(1).grandMeanlastLoxDSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,7)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyStage8LastDay,allRats(1).grandMeanDSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSstage8LastDay,allRats(1).grandMeanfirstLoxDSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSstage8LastDay,allRats(1).grandMeanlastLoxDSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,8)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyExtinctionFirstDay,allRats(1).grandMeanDSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSExtinctionFirstDay,allRats(1).grandMeanfirstLoxDSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSExtinctionFirstDay,allRats(1).grandMeanlastLoxDSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,9)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanDSPElatencyExtinctionLastDay,allRats(1).grandMeanDSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxDSExtinctionLastDay,allRats(1).grandMeanfirstLoxDSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxDSExtinctionLastDay,allRats(1).grandMeanlastLoxDSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick



subplot(2,9,10) %no NS on stage 2


subplot(2,9,11)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage5FirstDay,allRats(1).grandMeanNSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage5FirstDay,allRats(1).grandMeanfirstLoxNSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage5FirstDay,allRats(1).grandMeanlastLoxNSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,12)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage5LastDay,allRats(1).grandMeanNSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage5LastDay,allRats(1).grandMeanfirstLoxNSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage5LastDay,allRats(1).grandMeanlastLoxNSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,13)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage7FirstDay,allRats(1).grandMeanNSPElatencyStage7FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage7FirstDay,allRats(1).grandMeanfirstLoxNSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage7FirstDay,allRats(1).grandMeanlastLoxNSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,14)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage7LastDay,allRats(1).grandMeanNSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage7LastDay,allRats(1).grandMeanfirstLoxNSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage7LastDay,allRats(1).grandMeanlastLoxNSstage7LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,15)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage8FirstDay,allRats(1).grandMeanNSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage8FirstDay,allRats(1).grandMeanfirstLoxNSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage8FirstDay,allRats(1).grandMeanlastLoxNSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,16)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyStage8LastDay,allRats(1).grandMeanNSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSstage8LastDay,allRats(1).grandMeanfirstLoxNSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSstage8LastDay,allRats(1).grandMeanlastLoxNSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,17)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for PE
plot([allRats(1).grandMeanNSPElatencyExtinctionFirstDay,allRats(1).grandMeanNSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSExtinctionFirstDay,allRats(1).grandMeanfirstLoxNSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSExtinctionFirstDay,allRats(1).grandMeanlastLoxNSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,18)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for cue onset
plot([allRats(1).grandMeanNSPElatencyExtinctionLastDay,allRats(1).grandMeanNSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).grandMeanfirstLoxNSExtinctionLastDay,allRats(1).grandMeanfirstLoxNSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).grandMeanlastLoxNSExtinctionLastDay,allRats(1).grandMeanlastLoxNSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick
