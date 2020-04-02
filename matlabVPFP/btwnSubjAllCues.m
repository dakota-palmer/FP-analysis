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
               
               allRats(1).allCues.DSzblueMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDS.DSzblueMean'; %transposing for readability
               allRats(1).allCues.DSzpurpleMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDS.DSzpurpleMean';
           end 
        end
        
            %condB
         allRats(1).subjSessB(allRats(1).subjSessB==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessB,1) %each row is a session           
           if ses==1 %retain the first and last stage 5 day
               allRats(1).stage5FirstSes(1,subj)= allRats(1).subjSessB(ses,subj);
               allRats(1).stage5LastSes(1,subj)= max(allRats(1).subjSessB(:,subj));
               
               allRats(1).allCues.DSzblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDS.DSzblueMean';
               allRats(1).allCues.NSzblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNS.NSzblueMean';
               allRats(1).allCues.DSzpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDS.DSzpurpleMean';
               allRats(1).allCues.NSzpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNS.NSzpurpleMean';
               
               allRats(1).allCues.DSzblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDS.DSzblueMean';
               allRats(1).allCues.NSzblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNS.NSzblueMean';
               allRats(1).allCues.DSzpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDS.DSzpurpleMean';
               allRats(1).allCues.NSzpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
           
         end
         
           %condC
         allRats(1).subjSessC(allRats(1).subjSessC==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessC,1) %each row is a session\     
           if ses==1 %retain the first and last stage 7 day
              allRats(1).stage7FirstSes(1,subj)= allRats(1).subjSessC(ses,subj);
              allRats(1).stage7LastSes(1,subj)=max(allRats(1).subjSessC(:,subj));
              
              allRats(1).allCues.DSzblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).allCues.DSzblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNS.NSzpurpleMean';
           end
           
         end
           %condD 
        allRats(1).subjSessD(allRats(1).subjSessD==0)=nan; %if there's no data for this date just make it nan
        for ses = 1:size(allRats(1).subjSessD,1) %each row is a session           
           if ses==1 %retain the first and last stage 8 days (last is extinction for vp-vta-fpround2)
              allRats(1).stage8FirstSes(1,subj)= allRats(1).subjSessD(ses,subj);
              allRats(1).stage8LastSes(1,subj)= max(allRats(1).subjSessD(:,subj));
              
              allRats(1).allCues.DSzblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).allCues.DSzblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
         end
         
               %condE 
         allRats(1).subjSessE(allRats(1).subjSessE==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessE,1) %each row is a session
           if ses==1 %retain the last extinction day
              
               allRats(1).extinctionFirstSes(1,subj)= allRats(1).subjSessE(ses,subj);
               allRats(1).extinctionLastSes(1,subj)= max(allRats(1).subjSessE(:,subj));

              allRats(1).allCues.DSzblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNS.NSzpurpleMean';
              
              allRats(1).allCues.DSzblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDS.DSzblueMean';
              allRats(1).allCues.NSzblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNS.NSzblueMean';
              allRats(1).allCues.DSzpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDS.DSzpurpleMean';
              allRats(1).allCues.NSzpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNS.NSzpurpleMean';
               
           end
         end
         
end %end subj loop
         


 % now get mean & SEM of all rats for these transition sessions (each column is a training day , each 3d page is a subject)
       
    %stage 2
 allRats(1).allCues.grandMeanDSzblueStage2FirstSes=nanmean(allRats(1).allCues.DSzblueMeanStage2FirstSes,3);
 allRats(1).allCues.grandMeanDSzpurpleStage2FirstSes=nanmean(allRats(1).allCues.DSzpurpleMeanStage2FirstSes,3);
 
    %stage 5
allRats(1).allCues.grandMeanDSzblueStage5FirstSes= nanmean(allRats(1).allCues.DSzblueMeanStage5FirstSes,3);
allRats(1).allCues.grandMeanNSzblueStage5FirstSes= nanmean(allRats(1).allCues.NSzblueMeanStage5FirstSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage5FirstSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage5FirstSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage5FirstSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage5FirstSes,3);

allRats(1).allCues.grandMeanDSzblueStage5LastSes= nanmean(allRats(1).allCues.DSzblueMeanStage5LastSes,3);
allRats(1).allCues.grandMeanNSzblueStage5LastSes= nanmean(allRats(1).allCues.NSzblueMeanStage5LastSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage5LastSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage5LastSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage5LastSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage5LastSes,3);
    
    %stage 7
allRats(1).allCues.grandMeanDSzblueStage7FirstSes= nanmean(allRats(1).allCues.DSzblueMeanStage7FirstSes,3);
allRats(1).allCues.grandMeanNSzblueStage7FirstSes= nanmean(allRats(1).allCues.NSzblueMeanStage7FirstSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage7FirstSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage7FirstSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage7FirstSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage7FirstSes,3);

allRats(1).allCues.grandMeanDSzblueStage7LastSes= nanmean(allRats(1).allCues.DSzblueMeanStage7LastSes,3);
allRats(1).allCues.grandMeanNSzblueStage7LastSes= nanmean(allRats(1).allCues.NSzblueMeanStage7LastSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage7LastSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage7LastSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage7LastSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage7LastSes,3);    
 
    %stage 8
allRats(1).allCues.grandMeanDSzblueStage8FirstSes= nanmean(allRats(1).allCues.DSzblueMeanStage8FirstSes,3);
allRats(1).allCues.grandMeanNSzblueStage8FirstSes= nanmean(allRats(1).allCues.NSzblueMeanStage8FirstSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage8FirstSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage8FirstSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage8FirstSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage8FirstSes,3);

allRats(1).allCues.grandMeanDSzblueStage8LastSes= nanmean(allRats(1).allCues.DSzblueMeanStage8LastSes,3);
allRats(1).allCues.grandMeanNSzblueStage8LastSes= nanmean(allRats(1).allCues.NSzblueMeanStage8LastSes,3);
allRats(1).allCues.grandMeanDSzpurpleStage8LastSes= nanmean(allRats(1).allCues.DSzpurpleMeanStage8LastSes,3);
allRats(1).allCues.grandMeanNSzpurpleStage8LastSes= nanmean(allRats(1).allCues.NSzpurpleMeanStage8LastSes,3);    

    %stage 12 (extinction)
allRats(1).allCues.grandMeanDSzblueExtinctionFirstSes= nanmean(allRats(1).allCues.DSzblueMeanExtinctionFirstSes,3);
allRats(1).allCues.grandMeanNSzblueExtinctionFirstSes= nanmean(allRats(1).allCues.NSzblueMeanExtinctionFirstSes,3);
allRats(1).allCues.grandMeanDSzpurpleExtinctionFirstSes= nanmean(allRats(1).allCues.DSzpurpleMeanExtinctionFirstSes,3);
allRats(1).allCues.grandMeanNSzpurpleExtinctionFirstSes= nanmean(allRats(1).allCues.NSzpurpleMeanExtinctionFirstSes,3);  
    
allRats(1).allCues.grandMeanDSzblueExtinctionLastSes= nanmean(allRats(1).allCues.DSzblueMeanExtinctionLastSes,3);
allRats(1).allCues.grandMeanNSzblueExtinctionLastSes= nanmean(allRats(1).allCues.NSzblueMeanExtinctionLastSes,3);
allRats(1).allCues.grandMeanDSzpurpleExtinctionLastSes= nanmean(allRats(1).allCues.DSzpurpleMeanExtinctionLastSes,3);
allRats(1).allCues.grandMeanNSzpurpleExtinctionLastSes= nanmean(allRats(1).allCues.NSzpurpleMeanExtinctionLastSes,3);  


 %Calculate standard error of the mean(SEM)
  %treat each animal's avg as an obesrvation and calculate their std from
  %the grand mean across all animals
    %stage 2
allRats(1).allCues.grandStdDSzblueStage2FirstSes= nanstd(allRats(1).allCues.DSzblueMeanStage2FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage2FirstSes= allRats(1).allCues.grandStdDSzblueStage2FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage2FirstSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage2FirstSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage2FirstSes= allRats(1).allCues.grandStdDSzpurpleStage2FirstSes/sqrt(numel(subjIncluded));

   %stage 5
allRats(1).allCues.grandStdDSzblueStage5FirstSes= nanstd(allRats(1).allCues.DSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage5FirstSes= allRats(1).allCues.grandStdDSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage5FirstSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage5FirstSes= allRats(1).allCues.grandStdDSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdDSzblueStage5LastSes= nanstd(allRats(1).allCues.DSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage5LastSes= allRats(1).allCues.grandStdDSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage5LastSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage5LastSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage5LastSes= allRats(1).allCues.grandStdDSzpurpleStage5LastSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage5FirstSes= nanstd(allRats(1).allCues.NSzblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage5FirstSes= allRats(1).allCues.grandStdNSzblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage5FirstSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage5FirstSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage5FirstSes= allRats(1).allCues.grandStdNSzpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage5LastSes= nanstd(allRats(1).allCues.NSzblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage5LastSes= allRats(1).allCues.grandStdNSzblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage5LastSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage5LastSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage5LastSes= allRats(1).allCues.grandStdNSzpurpleStage5LastSes/sqrt(numel(subjIncluded));


    %stage 7
allRats(1).allCues.grandStdDSzblueStage7FirstSes= nanstd(allRats(1).allCues.DSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage7FirstSes= allRats(1).allCues.grandStdDSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage7FirstSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage7FirstSes= allRats(1).allCues.grandStdDSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdDSzblueStage7LastSes= nanstd(allRats(1).allCues.DSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage7LastSes= allRats(1).allCues.grandStdDSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage7LastSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage7LastSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage7LastSes= allRats(1).allCues.grandStdDSzpurpleStage7LastSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage7FirstSes= nanstd(allRats(1).allCues.NSzblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage7FirstSes= allRats(1).allCues.grandStdNSzblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage7FirstSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage7FirstSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage7FirstSes= allRats(1).allCues.grandStdNSzpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage7LastSes= nanstd(allRats(1).allCues.NSzblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage7LastSes= allRats(1).allCues.grandStdNSzblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage7LastSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage7LastSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage7LastSes= allRats(1).allCues.grandStdNSzpurpleStage7LastSes/sqrt(numel(subjIncluded));
    
    %stage 8
allRats(1).allCues.grandStdDSzblueStage8FirstSes= nanstd(allRats(1).allCues.DSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage8FirstSes= allRats(1).allCues.grandStdDSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage8FirstSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage8FirstSes= allRats(1).allCues.grandStdDSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdDSzblueStage8LastSes= nanstd(allRats(1).allCues.DSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueStage8LastSes= allRats(1).allCues.grandStdDSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleStage8LastSes= nanstd(allRats(1).allCues.DSzpurpleMeanStage8LastSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleStage8LastSes= allRats(1).allCues.grandStdDSzpurpleStage8LastSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage8FirstSes= nanstd(allRats(1).allCues.NSzblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage8FirstSes= allRats(1).allCues.grandStdNSzblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage8FirstSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage8FirstSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage8FirstSes= allRats(1).allCues.grandStdNSzpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueStage8LastSes= nanstd(allRats(1).allCues.NSzblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueStage8LastSes= allRats(1).allCues.grandStdNSzblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleStage8LastSes= nanstd(allRats(1).allCues.NSzpurpleMeanStage8LastSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleStage8LastSes= allRats(1).allCues.grandStdNSzpurpleStage8LastSes/sqrt(numel(subjIncluded));

    %stage 12 (extinction)
allRats(1).allCues.grandStdDSzblueExtinctionFirstSes= nanstd(allRats(1).allCues.DSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueExtinctionFirstSes= allRats(1).allCues.grandStdDSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleExtinctionFirstSes= nanstd(allRats(1).allCues.DSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleExtinctionFirstSes= allRats(1).allCues.grandStdDSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdDSzblueExtinctionLastSes= nanstd(allRats(1).allCues.DSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMDSzblueExtinctionLastSes= allRats(1).allCues.grandStdDSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdDSzpurpleExtinctionLastSes= nanstd(allRats(1).allCues.DSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).allCues.grandSEMDSzpurpleExtinctionLastSes= allRats(1).allCues.grandStdDSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueExtinctionFirstSes= nanstd(allRats(1).allCues.NSzblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueExtinctionFirstSes= allRats(1).allCues.grandStdNSzblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleExtinctionFirstSes= nanstd(allRats(1).allCues.NSzpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleExtinctionFirstSes= allRats(1).allCues.grandStdNSzpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).allCues.grandStdNSzblueExtinctionLastSes= nanstd(allRats(1).allCues.NSzblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).allCues.grandSEMNSzblueExtinctionLastSes= allRats(1).allCues.grandStdNSzblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).allCues.grandStdNSzpurpleExtinctionLastSes= nanstd(allRats(1).allCues.NSzpurpleMeanExtinctionLastSes,0,3); 
allRats(1).allCues.grandSEMNSzpurpleExtinctionLastSes= allRats(1).allCues.grandStdNSzpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

% Now, 2d plots 
figure(figureCount);
figureCount= figureCount+1;

sgtitle('Between subjects (n=5) avg response to CUE- ALL TRIALS- on transition days')

subplot(2,9,1);
title('DS stage 2 first day');
hold on;
plot(timeLock,allRats(1).allCues.grandMeanDSzblueStage2FirstSes, 'b');
plot(timeLock,allRats(1).allCues.grandMeanDSzpurpleStage2FirstSes, 'm');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage2FirstSes+allRats(1).allCues.grandSEMDSzblueStage2FirstSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage2FirstSes-allRats(1).allCues.grandSEMDSzblueStage2FirstSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage2FirstSes+allRats(1).allCues.grandSEMDSzpurpleStage2FirstSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage2FirstSes-allRats(1).allCues.grandSEMDSzpurpleStage2FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,2);
title('DS stage 5 first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage5FirstSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage5FirstSes+allRats(1).allCues.grandSEMDSzblueStage5FirstSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage5FirstSes-allRats(1).allCues.grandSEMDSzblueStage5FirstSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage5FirstSes+allRats(1).allCues.grandSEMDSzpurpleStage5FirstSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage5FirstSes-allRats(1).allCues.grandSEMDSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,3);
title('DS stage 5 last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage5LastSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage5LastSes+allRats(1).allCues.grandSEMDSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage5LastSes-allRats(1).allCues.grandSEMDSzblueStage5LastSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage5LastSes+allRats(1).allCues.grandSEMDSzpurpleStage5LastSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage5LastSes-allRats(1).allCues.grandSEMDSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,4);
title('DS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage7FirstSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage7FirstSes+allRats(1).allCues.grandSEMDSzblueStage7FirstSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage7FirstSes-allRats(1).allCues.grandSEMDSzblueStage7FirstSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage7FirstSes+allRats(1).allCues.grandSEMDSzpurpleStage7FirstSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage7FirstSes-allRats(1).allCues.grandSEMDSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,5);
title('DS stage 7 last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage7LastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage7LastSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage7LastSes+allRats(1).allCues.grandSEMDSzblueStage5LastSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage7LastSes-allRats(1).allCues.grandSEMDSzblueStage5LastSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage7LastSes+allRats(1).allCues.grandSEMDSzpurpleStage7LastSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage7LastSes-allRats(1).allCues.grandSEMDSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,6);
title('DS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage8FirstSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage8FirstSes+allRats(1).allCues.grandSEMDSzblueStage8FirstSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage8FirstSes-allRats(1).allCues.grandSEMDSzblueStage8FirstSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage8FirstSes+allRats(1).allCues.grandSEMDSzpurpleStage8FirstSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage8FirstSes-allRats(1).allCues.grandSEMDSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,7);
title('DS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueStage8LastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleStage8LastSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueStage8LastSes+allRats(1).allCues.grandSEMDSzblueStage8LastSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueStage8LastSes-allRats(1).allCues.grandSEMDSzblueStage8LastSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleStage8LastSes+allRats(1).allCues.grandSEMDSzpurpleStage8LastSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleStage8LastSes-allRats(1).allCues.grandSEMDSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,8);
title('DS extinction first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleExtinctionFirstSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueExtinctionFirstSes+allRats(1).allCues.grandSEMDSzblueExtinctionFirstSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueExtinctionFirstSes-allRats(1).allCues.grandSEMDSzblueExtinctionFirstSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleExtinctionFirstSes+allRats(1).allCues.grandSEMDSzpurpleExtinctionFirstSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleExtinctionFirstSes-allRats(1).allCues.grandSEMDSzpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,9);
title('DS extinction last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanDSzblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanDSzpurpleExtinctionLastSes,'m');

grandSemBluePos= allRats(1).allCues.grandMeanDSzblueExtinctionLastSes+allRats(1).allCues.grandSEMDSzblueExtinctionLastSes;
grandSemBlueNeg= allRats(1).allCues.grandMeanDSzblueExtinctionLastSes-allRats(1).allCues.grandSEMDSzblueExtinctionLastSes;

grandSemPurplePos= allRats(1).allCues.grandMeanDSzpurpleExtinctionLastSes+allRats(1).allCues.grandSEMDSzpurpleExtinctionLastSes;
grandSemPurpleNeg= allRats(1).allCues.grandMeanDSzpurpleExtinctionLastSes-allRats(1).allCues.grandSEMDSzpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);



subplot(2,9,10);
title('No NS on stage 2');


subplot(2,9,11);
title('NS stage 5 first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage5FirstSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage5FirstSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage5FirstSes+allRats(1).allCues.grandSEMNSzblueStage5FirstSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage5FirstSes-allRats(1).allCues.grandSEMNSzblueStage5FirstSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage5FirstSes+allRats(1).allCues.grandSEMNSzpurpleStage5FirstSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage5FirstSes-allRats(1).allCues.grandSEMNSzpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,12);
title('NS stage 5 last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage5LastSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage5LastSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage5LastSes+allRats(1).allCues.grandSEMNSzblueStage5LastSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage5LastSes-allRats(1).allCues.grandSEMNSzblueStage5LastSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage5LastSes+allRats(1).allCues.grandSEMNSzpurpleStage5LastSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage5LastSes-allRats(1).allCues.grandSEMNSzpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,13);
title('NS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage7FirstSes,'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage7FirstSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage7FirstSes+allRats(1).allCues.grandSEMNSzblueStage7FirstSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage7FirstSes-allRats(1).allCues.grandSEMNSzblueStage7FirstSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage7FirstSes+allRats(1).allCues.grandSEMNSzpurpleStage7FirstSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage7FirstSes-allRats(1).allCues.grandSEMNSzpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,14);
title('NS stage 7 last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage7LastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage7LastSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage7LastSes+allRats(1).allCues.grandSEMNSzblueStage5LastSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage7LastSes-allRats(1).allCues.grandSEMNSzblueStage5LastSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage7LastSes+allRats(1).allCues.grandSEMNSzpurpleStage7LastSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage7LastSes-allRats(1).allCues.grandSEMNSzpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,15);
title('NS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage8FirstSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage8FirstSes+allRats(1).allCues.grandSEMNSzblueStage8FirstSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage8FirstSes-allRats(1).allCues.grandSEMNSzblueStage8FirstSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage8FirstSes+allRats(1).allCues.grandSEMNSzpurpleStage8FirstSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage8FirstSes-allRats(1).allCues.grandSEMNSzpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,16);
title('NS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueStage8LastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleStage8LastSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueStage8LastSes+allRats(1).allCues.grandSEMNSzblueStage8LastSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueStage8LastSes-allRats(1).allCues.grandSEMNSzblueStage8LastSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleStage8LastSes+allRats(1).allCues.grandSEMNSzpurpleStage8LastSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleStage8LastSes-allRats(1).allCues.grandSEMNSzpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,17);
title('NS extinction first day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleExtinctionFirstSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueExtinctionFirstSes+allRats(1).allCues.grandSEMNSzblueExtinctionFirstSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueExtinctionFirstSes-allRats(1).allCues.grandSEMNSzblueExtinctionFirstSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleExtinctionFirstSes+allRats(1).allCues.grandSEMNSzpurpleExtinctionFirstSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleExtinctionFirstSes-allRats(1).allCues.grandSEMNSzpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,18);
title('NS extinction last day');
hold on;
plot(timeLock, allRats(1).allCues.grandMeanNSzblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).allCues.grandMeanNSzpurpleExtinctionLastSes,'m');

grandNSemBluePos= allRats(1).allCues.grandMeanNSzblueExtinctionLastSes+allRats(1).allCues.grandSEMNSzblueExtinctionLastSes;
grandNSemBlueNeg= allRats(1).allCues.grandMeanNSzblueExtinctionLastSes-allRats(1).allCues.grandSEMNSzblueExtinctionLastSes;

grandNSemPurplePos= allRats(1).allCues.grandMeanNSzpurpleExtinctionLastSes+allRats(1).allCues.grandSEMNSzpurpleExtinctionLastSes;
grandNSemPurpleNeg= allRats(1).allCues.grandMeanNSzpurpleExtinctionLastSes-allRats(1).allCues.grandSEMNSzpurpleExtinctionLastSes;

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
            allRats(1).allCues.meanDSPElatencyStage2(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session

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
               allRats(1).allCues.meanFirstloxDSstage2(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxDSstage2(transitionSession,subj)= nanmean(lastLox);
        end

           
             if transitionSession==1
                allRats(1).allCues.meanDSPElatencyStage2FirstDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage2(1,subj);
             end
            sesCountA= sesCountA+1;
        end
    end
    
    allRats(1).allCues.meanFirstloxDSstage2FirstDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage2(1,subj);
    allRats(1).allCues.meanLastloxDSstage2FirstDay(1,subj)= allRats(1).allCues.meanLastloxDSstage2(1,subj);
  
    
       %stage5 (condB)
    for transitionSession= 1:size(allRats(1).subjSessB,1)
        session= allRats(1).subjSessB(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).allCues.meanDSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).allCues.meanNSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).allCues.meanFirstloxDSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxDSstage5(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).allCues.meanFirstloxNSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxNSstage5(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).allCues.meanDSPElatencyStage5FirstDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage5(1,subj);
                allRats(1).allCues.meanNSPElatencyStage5FirstDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage5(1,subj);
            end            
             sesCountB= sesCountB+1; %only add to count if not nan
        end
    end
        
        %TODO: keep in mind that as we go through here by subj, empty 0s may be added to
        %meanDSPElatencyStage5 if one animal has more sessions meeting
        %criteria than the others... not a big deal if looking at specific
        %days but if you took a mean or something across days you'd want to
        % make them nan
    allRats(1).allCues.meanDSPElatencyStage5LastDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage5(sesCountB,subj); 
    allRats(1).allCues.meanNSPElatencyStage5LastDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage5(sesCountB,subj); 
    
    allRats(1).allCues.meanFirstloxDSstage5FirstDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage5(1,subj);
    allRats(1).allCues.meanFirstloxDSstage5LastDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage5(sesCountB,subj);
    allRats(1).allCues.meanLastloxDSstage5FirstDay(1,subj)= allRats(1).allCues.meanLastloxDSstage5(1,subj);
    allRats(1).allCues.meanLastloxDSstage5LastDay(1,subj)= allRats(1).allCues.meanLastloxDSstage5(sesCountB,subj);
    
    
    allRats(1).allCues.meanFirstloxNSstage5FirstDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage5(1,subj);
    allRats(1).allCues.meanFirstloxNSstage5LastDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage5(sesCountB,subj);
    allRats(1).allCues.meanLastloxNSstage5FirstDay(1,subj)= allRats(1).allCues.meanLastloxNSstage5(1,subj);
    allRats(1).allCues.meanLastloxNSstage5LastDay(1,subj)= allRats(1).allCues.meanLastloxNSstage5(sesCountB,subj);
    
    %end stage 7 (cond C)
%stage7 (condC)
    for transitionSession= 1:size(allRats(1).subjSessC,1)
        session= allRats(1).subjSessC(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).allCues.meanDSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).allCues.meanNSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).allCues.meanFirstloxDSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxDSstage7(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).allCues.meanFirstloxNSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxNSstage7(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).allCues.meanDSPElatencyStage7FirstDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage7(1,subj);
                allRats(1).allCues.meanNSPElatencyStage7FirstDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage7(1,subj);
            end            
             sesCountC= sesCountC+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).allCues.meanDSPElatencyStage7LastDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage7(sesCountC,subj);
    allRats(1).allCues.meanNSPElatencyStage7LastDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage7(sesCountC,subj);
    
    allRats(1).allCues.meanFirstloxDSstage7FirstDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage7(1,subj);
    allRats(1).allCues.meanFirstloxDSstage7LastDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage7(sesCountC,subj);
    allRats(1).allCues.meanLastloxDSstage7FirstDay(1,subj)= allRats(1).allCues.meanLastloxDSstage7(1,subj);
    allRats(1).allCues.meanLastloxDSstage7LastDay(1,subj)= allRats(1).allCues.meanLastloxDSstage7(sesCountC,subj);
    
    
    allRats(1).allCues.meanFirstloxNSstage7FirstDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage7(1,subj);
    allRats(1).allCues.meanFirstloxNSstage7LastDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage7(sesCountC,subj);
    allRats(1).allCues.meanLastloxNSstage7FirstDay(1,subj)= allRats(1).allCues.meanLastloxNSstage7(1,subj);
    allRats(1).allCues.meanLastloxNSstage7LastDay(1,subj)= allRats(1).allCues.meanLastloxNSstage7(sesCountC,subj);
    
    %end stage 7 (cond C)
    
%stage8 (condD)
    for transitionSession= 1:size(allRats(1).subjSessD,1)
        session= allRats(1).subjSessD(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).allCues.meanDSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).allCues.meanNSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).allCues.meanFirstloxDSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxDSstage8(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).allCues.meanFirstloxNSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxNSstage8(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).allCues.meanDSPElatencyStage8FirstDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage8(1,subj);
                allRats(1).allCues.meanNSPElatencyStage8FirstDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage8(1,subj);
            end            
             sesCountD= sesCountD+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).allCues.meanDSPElatencyStage8LastDay(1,subj)= allRats(1).allCues.meanDSPElatencyStage8(sesCountD,subj);
    allRats(1).allCues.meanNSPElatencyStage8LastDay(1,subj)= allRats(1).allCues.meanNSPElatencyStage8(sesCountD,subj);
    
    allRats(1).allCues.meanFirstloxDSstage8FirstDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage8(1,subj);
    allRats(1).allCues.meanFirstloxDSstage8LastDay(1,subj)= allRats(1).allCues.meanFirstloxDSstage8(sesCountD,subj);
    allRats(1).allCues.meanLastloxDSstage8FirstDay(1,subj)= allRats(1).allCues.meanLastloxDSstage8(1,subj);
    allRats(1).allCues.meanLastloxDSstage8LastDay(1,subj)= allRats(1).allCues.meanLastloxDSstage8(sesCountD,subj);
    
    
    allRats(1).allCues.meanFirstloxNSstage8FirstDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage8(1,subj);
    allRats(1).allCues.meanFirstloxNSstage8LastDay(1,subj)= allRats(1).allCues.meanFirstloxNSstage8(sesCountD,subj);
    allRats(1).allCues.meanLastloxNSstage8FirstDay(1,subj)= allRats(1).allCues.meanLastloxNSstage8(1,subj);
    allRats(1).allCues.meanLastloxNSstage8LastDay(1,subj)= allRats(1).allCues.meanLastloxNSstage8(sesCountD,subj);
    
    %end stage 8 (cond D)
    
%stage12 extinction (condE)
    for transitionSession= 1:size(allRats(1).subjSessE,1)
        session= allRats(1).subjSessE(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).allCues.meanDSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).allCues.meanNSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
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
               allRats(1).allCues.meanFirstloxDSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxDSExtinction(transitionSession,subj)= nanmean(lastLox);
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
               
               allRats(1).allCues.meanFirstloxNSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).allCues.meanLastloxNSExtinction(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).allCues.meanDSPElatencyExtinctionFirstDay(1,subj)= allRats(1).allCues.meanDSPElatencyExtinction(1,subj);
                allRats(1).allCues.meanNSPElatencyExtinctionFirstDay(1,subj)= allRats(1).allCues.meanNSPElatencyExtinction(1,subj);
            end            
             sesCountE= sesCountE+1; %only add to count if not nan
        end
    end
         
    allRats(1).allCues.meanDSPElatencyExtinctionLastDay(1,subj)= allRats(1).allCues.meanDSPElatencyExtinction(sesCountE,subj);
    allRats(1).allCues.meanNSPElatencyExtinctionLastDay(1,subj)= allRats(1).allCues.meanNSPElatencyExtinction(sesCountE,subj);
    
    allRats(1).allCues.meanFirstloxDSExtinctionFirstDay(1,subj)= allRats(1).allCues.meanFirstloxDSExtinction(1,subj);
    allRats(1).allCues.meanFirstloxDSExtinctionLastDay(1,subj)= allRats(1).allCues.meanFirstloxDSExtinction(sesCountE,subj);
    allRats(1).allCues.meanLastloxDSExtinctionFirstDay(1,subj)= allRats(1).allCues.meanLastloxDSExtinction(1,subj);
    allRats(1).allCues.meanLastloxDSExtinctionLastDay(1,subj)= allRats(1).allCues.meanLastloxDSExtinction(sesCountE,subj);
    
    allRats(1).allCues.meanFirstloxNSExtinctionFirstDay(1,subj)= allRats(1).allCues.meanFirstloxNSExtinction(1,subj);
    allRats(1).allCues.meanFirstloxNSExtinctionLastDay(1,subj)= allRats(1).allCues.meanFirstloxNSExtinction(sesCountE,subj);
    allRats(1).allCues.meanLastloxNSExtinctionFirstDay(1,subj)= allRats(1).allCues.meanLastloxNSExtinction(1,subj);
    allRats(1).allCues.meanLastloxNSExtinctionLastDay(1,subj)= allRats(1).allCues.meanLastloxNSExtinction(sesCountE,subj);
    
    %end stage 12 extinction (cond E)
 
end %end subj loop


    %get a grand mean across all subjects for these events
    %stage 2 
allRats(1).allCues.grandMeanDSPElatencyStage2FirstDay= nanmean(allRats(1).allCues.meanDSPElatencyStage2FirstDay);
allRats(1).allCues.grandMeanfirstLoxDSstage2FirstDay= nanmean(allRats(1).allCues.meanFirstloxDSstage2FirstDay);
allRats(1).allCues.grandMeanlastLoxDSstage2FirstDay= nanmean(allRats(1).allCues.meanLastloxDSstage2FirstDay);
    %stage 5
allRats(1).allCues.grandMeanDSPElatencyStage5FirstDay= nanmean(allRats(1).allCues.meanDSPElatencyStage5FirstDay);
allRats(1).allCues.grandMeanfirstLoxDSstage5FirstDay= nanmean(allRats(1).allCues.meanFirstloxDSstage5FirstDay);
allRats(1).allCues.grandMeanlastLoxDSstage5FirstDay= nanmean(allRats(1).allCues.meanLastloxDSstage5FirstDay);

allRats(1).allCues.grandMeanDSPElatencyStage5LastDay= nanmean(allRats(1).allCues.meanDSPElatencyStage5LastDay);
allRats(1).allCues.grandMeanfirstLoxDSstage5LastDay= nanmean(allRats(1).allCues.meanFirstloxDSstage5LastDay);
allRats(1).allCues.grandMeanlastLoxDSstage5LastDay= nanmean(allRats(1).allCues.meanLastloxDSstage5LastDay);

allRats(1).allCues.grandMeanNSPElatencyStage5FirstDay= nanmean(allRats(1).allCues.meanNSPElatencyStage5FirstDay);
allRats(1).allCues.grandMeanfirstLoxNSstage5FirstDay= nanmean(allRats(1).allCues.meanFirstloxNSstage5FirstDay);
allRats(1).allCues.grandMeanlastLoxNSstage5FirstDay= nanmean(allRats(1).allCues.meanLastloxNSstage5FirstDay);

allRats(1).allCues.grandMeanNSPElatencyStage5LastDay= nanmean(allRats(1).allCues.meanNSPElatencyStage5LastDay);
allRats(1).allCues.grandMeanfirstLoxNSstage5LastDay= nanmean(allRats(1).allCues.meanFirstloxNSstage5LastDay);
allRats(1).allCues.grandMeanlastLoxNSstage5LastDay= nanmean(allRats(1).allCues.meanLastloxNSstage5LastDay);
    %stage 7
allRats(1).allCues.grandMeanDSPElatencyStage7FirstDay= nanmean(allRats(1).allCues.meanDSPElatencyStage7FirstDay);
allRats(1).allCues.grandMeanfirstLoxDSstage7FirstDay= nanmean(allRats(1).allCues.meanFirstloxDSstage7FirstDay);
allRats(1).allCues.grandMeanlastLoxDSstage7FirstDay= nanmean(allRats(1).allCues.meanLastloxDSstage7FirstDay);

allRats(1).allCues.grandMeanDSPElatencyStage7LastDay= nanmean(allRats(1).allCues.meanDSPElatencyStage7LastDay);
allRats(1).allCues.grandMeanfirstLoxDSstage7LastDay= nanmean(allRats(1).allCues.meanFirstloxDSstage7LastDay);
allRats(1).allCues.grandMeanlastLoxDSstage7LastDay= nanmean(allRats(1).allCues.meanLastloxDSstage7LastDay);

allRats(1).allCues.grandMeanNSPElatencyStage7FirstDay= nanmean(allRats(1).allCues.meanNSPElatencyStage7FirstDay);
allRats(1).allCues.grandMeanfirstLoxNSstage7FirstDay= nanmean(allRats(1).allCues.meanFirstloxNSstage7FirstDay);
allRats(1).allCues.grandMeanlastLoxNSstage7FirstDay= nanmean(allRats(1).allCues.meanLastloxNSstage7FirstDay);

allRats(1).allCues.grandMeanNSPElatencyStage7LastDay= nanmean(allRats(1).allCues.meanNSPElatencyStage7LastDay);
allRats(1).allCues.grandMeanfirstLoxNSstage7LastDay= nanmean(allRats(1).allCues.meanFirstloxNSstage7LastDay);
allRats(1).allCues.grandMeanlastLoxNSstage7LastDay= nanmean(allRats(1).allCues.meanLastloxNSstage7LastDay);
    %stage 8
allRats(1).allCues.grandMeanDSPElatencyStage8FirstDay= nanmean(allRats(1).allCues.meanDSPElatencyStage8FirstDay);
allRats(1).allCues.grandMeanfirstLoxDSstage8FirstDay= nanmean(allRats(1).allCues.meanFirstloxDSstage8FirstDay);
allRats(1).allCues.grandMeanlastLoxDSstage8FirstDay= nanmean(allRats(1).allCues.meanLastloxDSstage8FirstDay);

allRats(1).allCues.grandMeanDSPElatencyStage8LastDay= nanmean(allRats(1).allCues.meanDSPElatencyStage8LastDay);
allRats(1).allCues.grandMeanfirstLoxDSstage8LastDay= nanmean(allRats(1).allCues.meanFirstloxDSstage8LastDay);
allRats(1).allCues.grandMeanlastLoxDSstage8LastDay= nanmean(allRats(1).allCues.meanLastloxDSstage8LastDay);

allRats(1).allCues.grandMeanNSPElatencyStage8FirstDay= nanmean(allRats(1).allCues.meanNSPElatencyStage8FirstDay);
allRats(1).allCues.grandMeanfirstLoxNSstage8FirstDay= nanmean(allRats(1).allCues.meanFirstloxNSstage8FirstDay);
allRats(1).allCues.grandMeanlastLoxNSstage8FirstDay= nanmean(allRats(1).allCues.meanLastloxNSstage8FirstDay);

allRats(1).allCues.grandMeanNSPElatencyStage8LastDay= nanmean(allRats(1).allCues.meanNSPElatencyStage8LastDay);
allRats(1).allCues.grandMeanfirstLoxNSstage8LastDay= nanmean(allRats(1).allCues.meanFirstloxNSstage8LastDay);
allRats(1).allCues.grandMeanlastLoxNSstage8LastDay= nanmean(allRats(1).allCues.meanLastloxNSstage8LastDay);
    %stage 12 (extinction)
allRats(1).allCues.grandMeanDSPElatencyExtinctionFirstDay= nanmean(allRats(1).allCues.meanDSPElatencyExtinctionFirstDay);
allRats(1).allCues.grandMeanfirstLoxDSExtinctionFirstDay= nanmean(allRats(1).allCues.meanFirstloxDSExtinctionFirstDay);
allRats(1).allCues.grandMeanlastLoxDSExtinctionFirstDay= nanmean(allRats(1).allCues.meanLastloxDSExtinctionFirstDay);

allRats(1).allCues.grandMeanDSPElatencyExtinctionLastDay= nanmean(allRats(1).allCues.meanDSPElatencyExtinctionLastDay);
allRats(1).allCues.grandMeanfirstLoxDSExtinctionLastDay= nanmean(allRats(1).allCues.meanFirstloxDSExtinctionLastDay);
allRats(1).allCues.grandMeanlastLoxDSExtinctionLastDay= nanmean(allRats(1).allCues.meanLastloxDSExtinctionLastDay);

allRats(1).allCues.grandMeanNSPElatencyExtinctionFirstDay= nanmean(allRats(1).allCues.meanNSPElatencyExtinctionFirstDay);
allRats(1).allCues.grandMeanfirstLoxNSExtinctionFirstDay= nanmean(allRats(1).allCues.meanFirstloxNSExtinctionFirstDay);
allRats(1).allCues.grandMeanlastLoxNSExtinctionFirstDay= nanmean(allRats(1).allCues.meanLastloxNSExtinctionFirstDay);

allRats(1).allCues.grandMeanNSPElatencyExtinctionLastDay= nanmean(allRats(1).allCues.meanNSPElatencyExtinctionLastDay);
allRats(1).allCues.grandMeanfirstLoxNSExtinctionLastDay= nanmean(allRats(1).allCues.meanFirstloxNSExtinctionLastDay);
allRats(1).allCues.grandMeanlastLoxNSExtinctionLastDay= nanmean(allRats(1).allCues.meanLastloxNSExtinctionLastDay);

subplot(2,9,1)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage2FirstDay,allRats(1).allCues.grandMeanDSPElatencyStage2FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage2FirstDay,allRats(1).allCues.grandMeanfirstLoxDSstage2FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage2FirstDay,allRats(1).allCues.grandMeanlastLoxDSstage2FirstDay], ylim, 'g--');%plot vertical line for last lick

hLegend= legend('465nm', '405nm', '465nm SEM','405nm SEM', 'cue onset', 'mean PE latency', 'mean first & last lick'); %add rats to legend, location outside of plot

legendPosition = [.94 0.7 0.03 0.1];
set(hLegend,'Position', legendPosition,'Units', 'normalized');

subplot(2,9,2)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage5FirstDay,allRats(1).allCues.grandMeanDSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage5FirstDay,allRats(1).allCues.grandMeanfirstLoxDSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage5FirstDay,allRats(1).allCues.grandMeanlastLoxDSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,3)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage5LastDay,allRats(1).allCues.grandMeanDSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage5LastDay,allRats(1).allCues.grandMeanfirstLoxDSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage5LastDay,allRats(1).allCues.grandMeanlastLoxDSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,4)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage7FirstDay,allRats(1).allCues.grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage7FirstDay,allRats(1).allCues.grandMeanfirstLoxDSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage7FirstDay,allRats(1).allCues.grandMeanlastLoxDSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,5)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage7LastDay,allRats(1).allCues.grandMeanDSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage7LastDay,allRats(1).allCues.grandMeanfirstLoxDSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage7LastDay,allRats(1).allCues.grandMeanlastLoxDSstage7LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,6)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage8FirstDay,allRats(1).allCues.grandMeanDSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage8FirstDay,allRats(1).allCues.grandMeanfirstLoxDSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage8FirstDay,allRats(1).allCues.grandMeanlastLoxDSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,7)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyStage8LastDay,allRats(1).allCues.grandMeanDSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSstage8LastDay,allRats(1).allCues.grandMeanfirstLoxDSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSstage8LastDay,allRats(1).allCues.grandMeanlastLoxDSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,8)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyExtinctionFirstDay,allRats(1).allCues.grandMeanDSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSExtinctionFirstDay,allRats(1).allCues.grandMeanfirstLoxDSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSExtinctionFirstDay,allRats(1).allCues.grandMeanlastLoxDSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,9)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanDSPElatencyExtinctionLastDay,allRats(1).allCues.grandMeanDSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxDSExtinctionLastDay,allRats(1).allCues.grandMeanfirstLoxDSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxDSExtinctionLastDay,allRats(1).allCues.grandMeanlastLoxDSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick



subplot(2,9,10) %no NS on stage 2


subplot(2,9,11)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage5FirstDay,allRats(1).allCues.grandMeanNSPElatencyStage5FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage5FirstDay,allRats(1).allCues.grandMeanfirstLoxNSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage5FirstDay,allRats(1).allCues.grandMeanlastLoxNSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,12)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage5LastDay,allRats(1).allCues.grandMeanNSPElatencyStage5LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage5LastDay,allRats(1).allCues.grandMeanfirstLoxNSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage5LastDay,allRats(1).allCues.grandMeanlastLoxNSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,13)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage7FirstDay,allRats(1).allCues.grandMeanNSPElatencyStage7FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage7FirstDay,allRats(1).allCues.grandMeanfirstLoxNSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage7FirstDay,allRats(1).allCues.grandMeanlastLoxNSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,14)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage7LastDay,allRats(1).allCues.grandMeanNSPElatencyStage7LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage7LastDay,allRats(1).allCues.grandMeanfirstLoxNSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage7LastDay,allRats(1).allCues.grandMeanlastLoxNSstage7LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,15)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage8FirstDay,allRats(1).allCues.grandMeanNSPElatencyStage8FirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage8FirstDay,allRats(1).allCues.grandMeanfirstLoxNSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage8FirstDay,allRats(1).allCues.grandMeanlastLoxNSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,16)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyStage8LastDay,allRats(1).allCues.grandMeanNSPElatencyStage8LastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSstage8LastDay,allRats(1).allCues.grandMeanfirstLoxNSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSstage8LastDay,allRats(1).allCues.grandMeanlastLoxNSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,17)
hold on;
plot([0,0], ylim, 'r--'); %plot vertical line for PE
plot([allRats(1).allCues.grandMeanNSPElatencyExtinctionFirstDay,allRats(1).allCues.grandMeanNSPElatencyExtinctionFirstDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSExtinctionFirstDay,allRats(1).allCues.grandMeanfirstLoxNSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSExtinctionFirstDay,allRats(1).allCues.grandMeanlastLoxNSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,18)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for cue onset
plot([allRats(1).allCues.grandMeanNSPElatencyExtinctionLastDay,allRats(1).allCues.grandMeanNSPElatencyExtinctionLastDay], ylim, 'k--'); %plot vertical line for PE latency
plot([allRats(1).allCues.grandMeanfirstLoxNSExtinctionLastDay,allRats(1).allCues.grandMeanfirstLoxNSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).allCues.grandMeanlastLoxNSExtinctionLastDay,allRats(1).allCues.grandMeanlastLoxNSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick
