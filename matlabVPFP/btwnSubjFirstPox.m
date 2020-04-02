%% Between subjects response to FIRST PE after cue on key transition sessions
%avg response timelocked to FIRST PE on key transition sessions
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
               
               allRats(1).firstPox.DSzpoxblueMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDSpox.DSzpoxblueMean'; %transposing for readability
               allRats(1).firstPox.DSzpoxpurpleMeanStage2FirstSes(1,:,subj)= currentSubj(allRats(1).stage2FirstSes(1,subj)).periDSpox.DSzpoxpurpleMean';
           end 
        end
        
            %condB
         allRats(1).subjSessB(allRats(1).subjSessB==0)=nan; %if there's no data for this date just make it nan
         
         for ses = 1:size(allRats(1).subjSessB,1) %each row is a session           
           if ses==1 %retain the first and last stage 5 day
               allRats(1).stage5FirstSes(1,subj)= allRats(1).subjSessB(ses,subj);
               allRats(1).stage5LastSes(1,subj)= max(allRats(1).subjSessB(:,subj));
               
               allRats(1).firstPox.DSzpoxblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDSpox.DSzpoxblueMean';
               allRats(1).firstPox.NSzpoxblueMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNSpox.NSzpoxblueMean';
               allRats(1).firstPox.DSzpoxpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periDSpox.DSzpoxpurpleMean';
               allRats(1).firstPox.NSzpoxpurpleMeanStage5FirstSes(1,:,subj)= currentSubj(allRats(1).stage5FirstSes(1,subj)).periNSpox.NSzpoxpurpleMean';
               
               allRats(1).firstPox.DSzpoxblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDSpox.DSzpoxblueMean';
               allRats(1).firstPox.NSzpoxblueMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNSpox.NSzpoxblueMean';
               allRats(1).firstPox.DSzpoxpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periDSpox.DSzpoxpurpleMean';
               allRats(1).firstPox.NSzpoxpurpleMeanStage5LastSes(1,:,subj)= currentSubj(allRats(1).stage5LastSes(1,subj)).periNSpox.NSzpoxpurpleMean';
               
           end
           
         end
         
           %condC
         allRats(1).subjSessC(allRats(1).subjSessC==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessC,1) %each row is a session\     
           if ses==1 %retain the first and last stage 7 day
              allRats(1).stage7FirstSes(1,subj)= allRats(1).subjSessC(ses,subj);
              allRats(1).stage7LastSes(1,subj)=max(allRats(1).subjSessC(:,subj));
              
              allRats(1).firstPox.DSzpoxblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanStage7FirstSes(1,:,subj)= currentSubj(allRats(1).stage7FirstSes(1,subj)).periNSpox.NSzpoxpurpleMean';
              
              allRats(1).firstPox.DSzpoxblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanStage7LastSes(1,:,subj)= currentSubj(allRats(1).stage7LastSes(1,subj)).periNSpox.NSzpoxpurpleMean';
           end
           
         end
           %condD 
        allRats(1).subjSessD(allRats(1).subjSessD==0)=nan; %if there's no data for this date just make it nan
        for ses = 1:size(allRats(1).subjSessD,1) %each row is a session           
           if ses==1 %retain the first and last stage 8 days (last is extinction for vp-vta-fpround2)
              allRats(1).stage8FirstSes(1,subj)= allRats(1).subjSessD(ses,subj);
              allRats(1).stage8LastSes(1,subj)= max(allRats(1).subjSessD(:,subj));
              
              allRats(1).firstPox.DSzpoxblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanStage8FirstSes(1,:,subj)= currentSubj(allRats(1).stage8FirstSes(1,subj)).periNSpox.NSzpoxpurpleMean';
              
              allRats(1).firstPox.DSzpoxblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanStage8LastSes(1,:,subj)= currentSubj(allRats(1).stage8LastSes(1,subj)).periNSpox.NSzpoxpurpleMean';
               
           end
         end
         
               %condE 
         allRats(1).subjSessE(allRats(1).subjSessE==0)=nan; %if there's no data for this date just make it nan
         for ses = 1:size(allRats(1).subjSessE,1) %each row is a session
           if ses==1 %retain the last extinction day
              
               allRats(1).extinctionFirstSes(1,subj)= allRats(1).subjSessE(ses,subj);
               allRats(1).extinctionLastSes(1,subj)= max(allRats(1).subjSessE(:,subj));

              allRats(1).firstPox.DSzpoxblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanExtinctionFirstSes(1,:,subj)= currentSubj(allRats(1).extinctionFirstSes(1,subj)).periNSpox.NSzpoxpurpleMean';
              
              allRats(1).firstPox.DSzpoxblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDSpox.DSzpoxblueMean';
              allRats(1).firstPox.NSzpoxblueMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNSpox.NSzpoxblueMean';
              allRats(1).firstPox.DSzpoxpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periDSpox.DSzpoxpurpleMean';
              allRats(1).firstPox.NSzpoxpurpleMeanExtinctionLastSes(1,:,subj)= currentSubj(allRats(1).extinctionLastSes(1,subj)).periNSpox.NSzpoxpurpleMean';
               
           end
         end
         
end %end subj loop
         


 % now get mean & SEM of all rats for these transition sessions (each column is a training day , each 3d page is a subject)
       
    %stage 2
 allRats(1).firstPox.grandMeanDSzpoxblueStage2FirstSes=nanmean(allRats(1).firstPox.DSzpoxblueMeanStage2FirstSes,3);
 allRats(1).firstPox.grandMeanDSzpoxpurpleStage2FirstSes=nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage2FirstSes,3);
 
    %stage 5
allRats(1).firstPox.grandMeanDSzpoxblueStage5FirstSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage5FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage5FirstSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage5FirstSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage5FirstSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage5FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage5FirstSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage5FirstSes,3);

allRats(1).firstPox.grandMeanDSzpoxblueStage5LastSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage5LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage5LastSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage5LastSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage5LastSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage5LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage5LastSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage5LastSes,3);
    
    %stage 7
allRats(1).firstPox.grandMeanDSzpoxblueStage7FirstSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage7FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage7FirstSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage7FirstSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage7FirstSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage7FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage7FirstSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage7FirstSes,3);

allRats(1).firstPox.grandMeanDSzpoxblueStage7LastSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage7LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage7LastSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage7LastSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage7LastSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage7LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage7LastSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage7LastSes,3);    
 
    %stage 8
allRats(1).firstPox.grandMeanDSzpoxblueStage8FirstSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage8FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage8FirstSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage8FirstSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage8FirstSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage8FirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage8FirstSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage8FirstSes,3);

allRats(1).firstPox.grandMeanDSzpoxblueStage8LastSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanStage8LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueStage8LastSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanStage8LastSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleStage8LastSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanStage8LastSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleStage8LastSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanStage8LastSes,3);    

    %stage 12 (extinction)
allRats(1).firstPox.grandMeanDSzpoxblueExtinctionFirstSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanExtinctionFirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueExtinctionFirstSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanExtinctionFirstSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionFirstSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanExtinctionFirstSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionFirstSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanExtinctionFirstSes,3);  
    
allRats(1).firstPox.grandMeanDSzpoxblueExtinctionLastSes= nanmean(allRats(1).firstPox.DSzpoxblueMeanExtinctionLastSes,3);
allRats(1).firstPox.grandMeanNSzpoxblueExtinctionLastSes= nanmean(allRats(1).firstPox.NSzpoxblueMeanExtinctionLastSes,3);
allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionLastSes= nanmean(allRats(1).firstPox.DSzpoxpurpleMeanExtinctionLastSes,3);
allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionLastSes= nanmean(allRats(1).firstPox.NSzpoxpurpleMeanExtinctionLastSes,3);  


 %Calculate standard error of the mean(SEM)
  %treat each animal's avg as an obesrvation and calculate their std from
  %the grand mean across all animals
    %stage 2
allRats(1).firstPox.grandStdDSzpoxblueStage2FirstSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage2FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage2FirstSes= allRats(1).firstPox.grandStdDSzpoxblueStage2FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage2FirstSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage2FirstSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage2FirstSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage2FirstSes/sqrt(numel(subjIncluded));

   %stage 5
allRats(1).firstPox.grandStdDSzpoxblueStage5FirstSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage5FirstSes= allRats(1).firstPox.grandStdDSzpoxblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage5FirstSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage5FirstSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage5FirstSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdDSzpoxblueStage5LastSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage5LastSes= allRats(1).firstPox.grandStdDSzpoxblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage5LastSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage5LastSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage5LastSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage5LastSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage5FirstSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage5FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage5FirstSes= allRats(1).firstPox.grandStdNSzpoxblueStage5FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage5FirstSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage5FirstSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage5FirstSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage5FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage5LastSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage5LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage5LastSes= allRats(1).firstPox.grandStdNSzpoxblueStage5LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage5LastSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage5LastSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage5LastSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage5LastSes/sqrt(numel(subjIncluded));


    %stage 7
allRats(1).firstPox.grandStdDSzpoxblueStage7FirstSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage7FirstSes= allRats(1).firstPox.grandStdDSzpoxblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage7FirstSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage7FirstSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage7FirstSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdDSzpoxblueStage7LastSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage7LastSes= allRats(1).firstPox.grandStdDSzpoxblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage7LastSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage7LastSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage7LastSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage7LastSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage7FirstSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage7FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage7FirstSes= allRats(1).firstPox.grandStdNSzpoxblueStage7FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage7FirstSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage7FirstSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage7FirstSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage7FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage7LastSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage7LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage7LastSes= allRats(1).firstPox.grandStdNSzpoxblueStage7LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage7LastSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage7LastSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage7LastSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage7LastSes/sqrt(numel(subjIncluded));
    
    %stage 8
allRats(1).firstPox.grandStdDSzpoxblueStage8FirstSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage8FirstSes= allRats(1).firstPox.grandStdDSzpoxblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage8FirstSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage8FirstSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage8FirstSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdDSzpoxblueStage8LastSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueStage8LastSes= allRats(1).firstPox.grandStdDSzpoxblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleStage8LastSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanStage8LastSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleStage8LastSes= allRats(1).firstPox.grandStdDSzpoxpurpleStage8LastSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage8FirstSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage8FirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage8FirstSes= allRats(1).firstPox.grandStdNSzpoxblueStage8FirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage8FirstSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage8FirstSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage8FirstSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage8FirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueStage8LastSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanStage8LastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueStage8LastSes= allRats(1).firstPox.grandStdNSzpoxblueStage8LastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleStage8LastSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanStage8LastSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleStage8LastSes= allRats(1).firstPox.grandStdNSzpoxpurpleStage8LastSes/sqrt(numel(subjIncluded));

    %stage 12 (extinction)
allRats(1).firstPox.grandStdDSzpoxblueExtinctionFirstSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueExtinctionFirstSes= allRats(1).firstPox.grandStdDSzpoxblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleExtinctionFirstSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionFirstSes= allRats(1).firstPox.grandStdDSzpoxpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdDSzpoxblueExtinctionLastSes= nanstd(allRats(1).firstPox.DSzpoxblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMDSzpoxblueExtinctionLastSes= allRats(1).firstPox.grandStdDSzpoxblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdDSzpoxpurpleExtinctionLastSes= nanstd(allRats(1).firstPox.DSzpoxpurpleMeanExtinctionLastSes,0,3); 
allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionLastSes= allRats(1).firstPox.grandStdDSzpoxpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueExtinctionFirstSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanExtinctionFirstSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueExtinctionFirstSes= allRats(1).firstPox.grandStdNSzpoxblueExtinctionFirstSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleExtinctionFirstSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanExtinctionFirstSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionFirstSes= allRats(1).firstPox.grandStdNSzpoxpurpleExtinctionFirstSes/sqrt(numel(subjIncluded));

allRats(1).firstPox.grandStdNSzpoxblueExtinctionLastSes= nanstd(allRats(1).firstPox.NSzpoxblueMeanExtinctionLastSes,0,3); %first get the std for each timepoint
allRats(1).firstPox.grandSEMNSzpoxblueExtinctionLastSes= allRats(1).firstPox.grandStdNSzpoxblueExtinctionLastSes/sqrt(numel(subjIncluded)); %now calculate SEM for each timepoint
allRats(1).firstPox.grandStdNSzpoxpurpleExtinctionLastSes= nanstd(allRats(1).firstPox.NSzpoxpurpleMeanExtinctionLastSes,0,3); 
allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionLastSes= allRats(1).firstPox.grandStdNSzpoxpurpleExtinctionLastSes/sqrt(numel(subjIncluded));

% Now, 2d plots 
figure(figureCount);
figureCount= figureCount+1;

sgtitle('Between subjects (n=5) avg response to FIRST PE after cue on transition days')

subplot(2,9,1);
title('DS stage 2 first day');
hold on;
plot(timeLock,allRats(1).firstPox.grandMeanDSzpoxblueStage2FirstSes, 'b');
plot(timeLock,allRats(1).firstPox.grandMeanDSzpoxpurpleStage2FirstSes, 'm');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage2FirstSes+allRats(1).firstPox.grandSEMDSzpoxblueStage2FirstSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage2FirstSes-allRats(1).firstPox.grandSEMDSzpoxblueStage2FirstSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage2FirstSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage2FirstSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage2FirstSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage2FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,2);
title('DS stage 5 first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage5FirstSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage5FirstSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage5FirstSes+allRats(1).firstPox.grandSEMDSzpoxblueStage5FirstSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage5FirstSes-allRats(1).firstPox.grandSEMDSzpoxblueStage5FirstSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage5FirstSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage5FirstSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage5FirstSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,3);
title('DS stage 5 last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage5LastSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage5LastSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage5LastSes+allRats(1).firstPox.grandSEMDSzpoxblueStage5LastSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage5LastSes-allRats(1).firstPox.grandSEMDSzpoxblueStage5LastSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage5LastSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage5LastSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage5LastSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,4);
title('DS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage7FirstSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage7FirstSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage7FirstSes+allRats(1).firstPox.grandSEMDSzpoxblueStage7FirstSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage7FirstSes-allRats(1).firstPox.grandSEMDSzpoxblueStage7FirstSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage7FirstSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage7FirstSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage7FirstSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,5);
title('DS stage 7 last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage7LastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage7LastSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage7LastSes+allRats(1).firstPox.grandSEMDSzpoxblueStage5LastSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage7LastSes-allRats(1).firstPox.grandSEMDSzpoxblueStage5LastSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage7LastSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage7LastSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage7LastSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,6);
title('DS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage8FirstSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage8FirstSes+allRats(1).firstPox.grandSEMDSzpoxblueStage8FirstSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage8FirstSes-allRats(1).firstPox.grandSEMDSzpoxblueStage8FirstSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage8FirstSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage8FirstSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage8FirstSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,7);
title('DS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueStage8LastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleStage8LastSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueStage8LastSes+allRats(1).firstPox.grandSEMDSzpoxblueStage8LastSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueStage8LastSes-allRats(1).firstPox.grandSEMDSzpoxblueStage8LastSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleStage8LastSes+allRats(1).firstPox.grandSEMDSzpoxpurpleStage8LastSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleStage8LastSes-allRats(1).firstPox.grandSEMDSzpoxpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,8);
title('DS extinction first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionFirstSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueExtinctionFirstSes+allRats(1).firstPox.grandSEMDSzpoxblueExtinctionFirstSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueExtinctionFirstSes-allRats(1).firstPox.grandSEMDSzpoxblueExtinctionFirstSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionFirstSes+allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionFirstSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionFirstSes-allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,9);
title('DS extinction last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionLastSes,'m');

grandSemBluePos= allRats(1).firstPox.grandMeanDSzpoxblueExtinctionLastSes+allRats(1).firstPox.grandSEMDSzpoxblueExtinctionLastSes;
grandSemBlueNeg= allRats(1).firstPox.grandMeanDSzpoxblueExtinctionLastSes-allRats(1).firstPox.grandSEMDSzpoxblueExtinctionLastSes;

grandSemPurplePos= allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionLastSes+allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionLastSes;
grandSemPurpleNeg= allRats(1).firstPox.grandMeanDSzpoxpurpleExtinctionLastSes-allRats(1).firstPox.grandSEMDSzpoxpurpleExtinctionLastSes;

patch([timeLock,timeLock(end:-1:1)],[grandSemBluePos,grandSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandSemPurplePos,grandSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);



subplot(2,9,10);
title('No NS on stage 2');


subplot(2,9,11);
title('NS stage 5 first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage5FirstSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage5FirstSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage5FirstSes+allRats(1).firstPox.grandSEMNSzpoxblueStage5FirstSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage5FirstSes-allRats(1).firstPox.grandSEMNSzpoxblueStage5FirstSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage5FirstSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage5FirstSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage5FirstSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage5FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,12);
title('NS stage 5 last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage5LastSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage5LastSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage5LastSes+allRats(1).firstPox.grandSEMNSzpoxblueStage5LastSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage5LastSes-allRats(1).firstPox.grandSEMNSzpoxblueStage5LastSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage5LastSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage5LastSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage5LastSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage5LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,13);
title('NS stage 7 first day (1s delay)');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage7FirstSes,'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage7FirstSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage7FirstSes+allRats(1).firstPox.grandSEMNSzpoxblueStage7FirstSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage7FirstSes-allRats(1).firstPox.grandSEMNSzpoxblueStage7FirstSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage7FirstSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage7FirstSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage7FirstSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage7FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,14);
title('NS stage 7 last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage7LastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage7LastSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage7LastSes+allRats(1).firstPox.grandSEMNSzpoxblueStage5LastSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage7LastSes-allRats(1).firstPox.grandSEMNSzpoxblueStage5LastSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage7LastSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage7LastSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage7LastSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage7LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,15);
title('NS 10%,5%,20% first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage8FirstSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage8FirstSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage8FirstSes+allRats(1).firstPox.grandSEMNSzpoxblueStage8FirstSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage8FirstSes-allRats(1).firstPox.grandSEMNSzpoxblueStage8FirstSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage8FirstSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage8FirstSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage8FirstSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage8FirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,16);
title('NS 10%,5%,20% last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueStage8LastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleStage8LastSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueStage8LastSes+allRats(1).firstPox.grandSEMNSzpoxblueStage8LastSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueStage8LastSes-allRats(1).firstPox.grandSEMNSzpoxblueStage8LastSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleStage8LastSes+allRats(1).firstPox.grandSEMNSzpoxpurpleStage8LastSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleStage8LastSes-allRats(1).firstPox.grandSEMNSzpoxpurpleStage8LastSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);


subplot(2,9,17);
title('NS extinction first day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueExtinctionFirstSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionFirstSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueExtinctionFirstSes+allRats(1).firstPox.grandSEMNSzpoxblueExtinctionFirstSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueExtinctionFirstSes-allRats(1).firstPox.grandSEMNSzpoxblueExtinctionFirstSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionFirstSes+allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionFirstSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionFirstSes-allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionFirstSes;

patch([timeLock,timeLock(end:-1:1)],[grandNSemBluePos,grandNSemBlueNeg(end:-1:1)],'b','EdgeColor','None');alpha(0.5);
patch([timeLock,timeLock(end:-1:1)],[grandNSemPurplePos,grandNSemPurpleNeg(end:-1:1)],'m','EdgeColor','None');alpha(0.5);

subplot(2,9,18);
title('NS extinction last day');
hold on;
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxblueExtinctionLastSes, 'b');
plot(timeLock, allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionLastSes,'m');

grandNSemBluePos= allRats(1).firstPox.grandMeanNSzpoxblueExtinctionLastSes+allRats(1).firstPox.grandSEMNSzpoxblueExtinctionLastSes;
grandNSemBlueNeg= allRats(1).firstPox.grandMeanNSzpoxblueExtinctionLastSes-allRats(1).firstPox.grandSEMNSzpoxblueExtinctionLastSes;

grandNSemPurplePos= allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionLastSes+allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionLastSes;
grandNSemPurpleNeg= allRats(1).firstPox.grandMeanNSzpoxpurpleExtinctionLastSes-allRats(1).firstPox.grandSEMNSzpoxpurpleExtinctionLastSes;

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
            allRats(1).firstPox.meanDSPElatencyStage2(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session

            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
       for cue = 1:numel(currentSubj(session).behavior.loxDSpoxRel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).firstPox.meanFirstloxDSstage2(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxDSstage2(transitionSession,subj)= nanmean(lastLox);
        end

           
             if transitionSession==1
                allRats(1).firstPox.meanDSPElatencyStage2FirstDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage2(1,subj);
             end
            sesCountA= sesCountA+1;
        end
    end
    
    allRats(1).firstPox.meanFirstloxDSstage2FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage2(1,subj);
    allRats(1).firstPox.meanLastloxDSstage2FirstDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage2(1,subj);
  
    
       %stage5 (condB)
    for transitionSession= 1:size(allRats(1).subjSessB,1)
        session= allRats(1).subjSessB(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).firstPox.meanDSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).firstPox.meanNSPElatencyStage5(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            for cue = 1:numel(currentSubj(session).behavior.loxDSpoxRel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).firstPox.meanFirstloxDSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxDSstage5(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSpoxRel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSpoxRel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).firstPox.meanFirstloxNSstage5(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxNSstage5(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).firstPox.meanDSPElatencyStage5FirstDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage5(1,subj);
                allRats(1).firstPox.meanNSPElatencyStage5FirstDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage5(1,subj);
            end            
             sesCountB= sesCountB+1; %only add to count if not nan
        end
    end
        
        %TODO: keep in mind that as we go through here by subj, empty 0s may be added to
        %meanDSPElatencyStage5 if one animal has more sessions meeting
        %criteria than the others... not a big deal if looking at specific
        %days but if you took a mean or something across days you'd want to
        % make them nan
    allRats(1).firstPox.meanDSPElatencyStage5LastDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage5(sesCountB,subj); 
    allRats(1).firstPox.meanNSPElatencyStage5LastDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage5(sesCountB,subj); 
    
    allRats(1).firstPox.meanFirstloxDSstage5FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage5(1,subj);
    allRats(1).firstPox.meanFirstloxDSstage5LastDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage5(sesCountB,subj);
    allRats(1).firstPox.meanLastloxDSstage5FirstDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage5(1,subj);
    allRats(1).firstPox.meanLastloxDSstage5LastDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage5(sesCountB,subj);
    
    
    allRats(1).firstPox.meanFirstloxNSstage5FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage5(1,subj);
    allRats(1).firstPox.meanFirstloxNSstage5LastDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage5(sesCountB,subj);
    allRats(1).firstPox.meanLastloxNSstage5FirstDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage5(1,subj);
    allRats(1).firstPox.meanLastloxNSstage5LastDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage5(sesCountB,subj);
    
    %end stage 7 (cond C)
%stage7 (condC)
    for transitionSession= 1:size(allRats(1).subjSessC,1)
        session= allRats(1).subjSessC(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).firstPox.meanDSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).firstPox.meanNSPElatencyStage7(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            for cue = 1:numel(currentSubj(session).behavior.loxDSpoxRel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).firstPox.meanFirstloxDSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxDSstage7(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSpoxRel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSpoxRel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).firstPox.meanFirstloxNSstage7(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxNSstage7(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).firstPox.meanDSPElatencyStage7FirstDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage7(1,subj);
                allRats(1).firstPox.meanNSPElatencyStage7FirstDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage7(1,subj);
            end            
             sesCountC= sesCountC+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).firstPox.meanDSPElatencyStage7LastDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage7(sesCountC,subj);
    allRats(1).firstPox.meanNSPElatencyStage7LastDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage7(sesCountC,subj);
    
    allRats(1).firstPox.meanFirstloxDSstage7FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage7(1,subj);
    allRats(1).firstPox.meanFirstloxDSstage7LastDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage7(sesCountC,subj);
    allRats(1).firstPox.meanLastloxDSstage7FirstDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage7(1,subj);
    allRats(1).firstPox.meanLastloxDSstage7LastDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage7(sesCountC,subj);
    
    
    allRats(1).firstPox.meanFirstloxNSstage7FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage7(1,subj);
    allRats(1).firstPox.meanFirstloxNSstage7LastDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage7(sesCountC,subj);
    allRats(1).firstPox.meanLastloxNSstage7FirstDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage7(1,subj);
    allRats(1).firstPox.meanLastloxNSstage7LastDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage7(sesCountC,subj);
    
    %end stage 7 (cond C)
    
%stage8 (condD)
    for transitionSession= 1:size(allRats(1).subjSessD,1)
        session= allRats(1).subjSessD(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).firstPox.meanDSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).firstPox.meanNSPElatencyStage8(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
           for cue = 1:numel(currentSubj(session).behavior.loxDSpoxRel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               allRats(1).firstPox.meanFirstloxDSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxDSstage8(transitionSession,subj)= nanmean(lastLox);
            end

            for cue= 1:numel(currentSubj(session).behavior.loxNSpoxRel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSpoxRel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
               
               allRats(1).firstPox.meanFirstloxNSstage8(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxNSstage8(transitionSession,subj)= nanmean(lastLox);
            end
            
            if transitionSession==1
                allRats(1).firstPox.meanDSPElatencyStage8FirstDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage8(1,subj);
                allRats(1).firstPox.meanNSPElatencyStage8FirstDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage8(1,subj);
            end            
             sesCountD= sesCountD+1; %only add to count if not nan
        end
    end
        
    
    allRats(1).firstPox.meanDSPElatencyStage8LastDay(1,subj)= allRats(1).firstPox.meanDSPElatencyStage8(sesCountD,subj);
    allRats(1).firstPox.meanNSPElatencyStage8LastDay(1,subj)= allRats(1).firstPox.meanNSPElatencyStage8(sesCountD,subj);
    
    allRats(1).firstPox.meanFirstloxDSstage8FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage8(1,subj);
    allRats(1).firstPox.meanFirstloxDSstage8LastDay(1,subj)= allRats(1).firstPox.meanFirstloxDSstage8(sesCountD,subj);
    allRats(1).firstPox.meanLastloxDSstage8FirstDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage8(1,subj);
    allRats(1).firstPox.meanLastloxDSstage8LastDay(1,subj)= allRats(1).firstPox.meanLastloxDSstage8(sesCountD,subj);
    
    
    allRats(1).firstPox.meanFirstloxNSstage8FirstDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage8(1,subj);
    allRats(1).firstPox.meanFirstloxNSstage8LastDay(1,subj)= allRats(1).firstPox.meanFirstloxNSstage8(sesCountD,subj);
    allRats(1).firstPox.meanLastloxNSstage8FirstDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage8(1,subj);
    allRats(1).firstPox.meanLastloxNSstage8LastDay(1,subj)= allRats(1).firstPox.meanLastloxNSstage8(sesCountD,subj);
    
    %end stage 8 (cond D)
    
%stage12 extinction (condE)
    for transitionSession= 1:size(allRats(1).subjSessE,1)
        session= allRats(1).subjSessE(transitionSession,subj);
        if ~isnan(session) %only run if the session is valid
            allRats(1).firstPox.meanDSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.DSpeLatency); %take the mean of all the PE latencies for this session
            allRats(1).firstPox.meanNSPElatencyExtinction(transitionSession,subj)= nanmean(currentSubj(session).behavior.NSpeLatency);
            
            %for licks, want to get an average of the 1st lick and the last
            %after the cue (TODO: this is just lick timestamps, not checking for bout
            %criteria yet)
            firstLox= []; %reset between sessions/subjs to prevent carryover of values
            lastLox= [];
            for cue = 1:numel(currentSubj(session).behavior.loxDSpoxRel) %loop through all trials
                if ~isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %only look for trials where there was a lick
                   firstLox(cue)= currentSubj(session).behavior.loxDSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxDSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               elseif isempty(currentSubj(session).behavior.loxDSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end
            end

            allRats(1).firstPox.meanFirstloxDSExtinction(transitionSession,subj)= nanmean(firstLox);
            allRats(1).firstPox.meanLastloxDSExtinction(transitionSession,subj)= nanmean(lastLox);
            
            for cue= 1:numel(currentSubj(session).behavior.loxNSpoxRel) %repeat for NS trials
               if ~isempty(currentSubj(session).behavior.loxNSpoxRel{cue})
                   firstLox(cue)= currentSubj(session).behavior.loxNSpoxRel{cue}(1);
                   firstLox(firstLox==0)= nan; %replace empty 0s with nan

                   lastLox(cue)=currentSubj(session).behavior.loxNSpoxRel{cue}(end);
                   lastLox(lastLox==0)=nan;
               
               elseif isempty(currentSubj(session).behavior.loxNSpoxRel{cue}) %in case there are no licks
                   firstLox(cue) = nan;
                   lastLox(cue)=nan;
               end    
            end
            
               allRats(1).firstPox.meanFirstloxNSExtinction(transitionSession,subj)= nanmean(firstLox);
               allRats(1).firstPox.meanLastloxNSExtinction(transitionSession,subj)= nanmean(lastLox);
            
            if transitionSession==1
                allRats(1).firstPox.meanDSPElatencyExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanDSPElatencyExtinction(1,subj);
                allRats(1).firstPox.meanNSPElatencyExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanNSPElatencyExtinction(1,subj);
            end            
             sesCountE= sesCountE+1; %only add to count if not nan
        end
    end
         
    allRats(1).firstPox.meanDSPElatencyExtinctionLastDay(1,subj)= allRats(1).firstPox.meanDSPElatencyExtinction(sesCountE,subj);
    allRats(1).firstPox.meanNSPElatencyExtinctionLastDay(1,subj)= allRats(1).firstPox.meanNSPElatencyExtinction(sesCountE,subj);
    
    allRats(1).firstPox.meanFirstloxDSExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanFirstloxDSExtinction(1,subj);
    allRats(1).firstPox.meanFirstloxDSExtinctionLastDay(1,subj)= allRats(1).firstPox.meanFirstloxDSExtinction(sesCountE,subj);
    allRats(1).firstPox.meanLastloxDSExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanLastloxDSExtinction(1,subj);
    allRats(1).firstPox.meanLastloxDSExtinctionLastDay(1,subj)= allRats(1).firstPox.meanLastloxDSExtinction(sesCountE,subj);
    
    allRats(1).firstPox.meanFirstloxNSExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanFirstloxNSExtinction(1,subj);
    allRats(1).firstPox.meanFirstloxNSExtinctionLastDay(1,subj)= allRats(1).firstPox.meanFirstloxNSExtinction(sesCountE,subj);
    allRats(1).firstPox.meanLastloxNSExtinctionFirstDay(1,subj)= allRats(1).firstPox.meanLastloxNSExtinction(1,subj);
    allRats(1).firstPox.meanLastloxNSExtinctionLastDay(1,subj)= allRats(1).firstPox.meanLastloxNSExtinction(sesCountE,subj);
    
    %end stage 12 extinction (cond E)
 
end %end subj loop


    %get a grand mean across all subjects for these events
    %stage 2 
allRats(1).firstPox.grandMeanDSPElatencyStage2FirstDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage2FirstDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage2FirstDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage2FirstDay);
allRats(1).firstPox.grandMeanlastLoxDSstage2FirstDay= nanmean(allRats(1).firstPox.meanLastloxDSstage2FirstDay);
    %stage 5
allRats(1).firstPox.grandMeanDSPElatencyStage5FirstDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage5FirstDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage5FirstDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage5FirstDay);
allRats(1).firstPox.grandMeanlastLoxDSstage5FirstDay= nanmean(allRats(1).firstPox.meanLastloxDSstage5FirstDay);

allRats(1).firstPox.grandMeanDSPElatencyStage5LastDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage5LastDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage5LastDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage5LastDay);
allRats(1).firstPox.grandMeanlastLoxDSstage5LastDay= nanmean(allRats(1).firstPox.meanLastloxDSstage5LastDay);

allRats(1).firstPox.grandMeanNSPElatencyStage5FirstDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage5FirstDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage5FirstDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage5FirstDay);
allRats(1).firstPox.grandMeanlastLoxNSstage5FirstDay= nanmean(allRats(1).firstPox.meanLastloxNSstage5FirstDay);

allRats(1).firstPox.grandMeanNSPElatencyStage5LastDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage5LastDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage5LastDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage5LastDay);
allRats(1).firstPox.grandMeanlastLoxNSstage5LastDay= nanmean(allRats(1).firstPox.meanLastloxNSstage5LastDay);
    %stage 7
allRats(1).firstPox.grandMeanDSPElatencyStage7FirstDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage7FirstDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage7FirstDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage7FirstDay);
allRats(1).firstPox.grandMeanlastLoxDSstage7FirstDay= nanmean(allRats(1).firstPox.meanLastloxDSstage7FirstDay);

allRats(1).firstPox.grandMeanDSPElatencyStage7LastDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage7LastDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage7LastDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage7LastDay);
allRats(1).firstPox.grandMeanlastLoxDSstage7LastDay= nanmean(allRats(1).firstPox.meanLastloxDSstage7LastDay);

allRats(1).firstPox.grandMeanNSPElatencyStage7FirstDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage7FirstDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage7FirstDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage7FirstDay);
allRats(1).firstPox.grandMeanlastLoxNSstage7FirstDay= nanmean(allRats(1).firstPox.meanLastloxNSstage7FirstDay);

allRats(1).firstPox.grandMeanNSPElatencyStage7LastDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage7LastDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage7LastDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage7LastDay);
allRats(1).firstPox.grandMeanlastLoxNSstage7LastDay= nanmean(allRats(1).firstPox.meanLastloxNSstage7LastDay);
    %stage 8
allRats(1).firstPox.grandMeanDSPElatencyStage8FirstDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage8FirstDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage8FirstDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage8FirstDay);
allRats(1).firstPox.grandMeanlastLoxDSstage8FirstDay= nanmean(allRats(1).firstPox.meanLastloxDSstage8FirstDay);

allRats(1).firstPox.grandMeanDSPElatencyStage8LastDay= nanmean(allRats(1).firstPox.meanDSPElatencyStage8LastDay);
allRats(1).firstPox.grandMeanfirstLoxDSstage8LastDay= nanmean(allRats(1).firstPox.meanFirstloxDSstage8LastDay);
allRats(1).firstPox.grandMeanlastLoxDSstage8LastDay= nanmean(allRats(1).firstPox.meanLastloxDSstage8LastDay);

allRats(1).firstPox.grandMeanNSPElatencyStage8FirstDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage8FirstDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage8FirstDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage8FirstDay);
allRats(1).firstPox.grandMeanlastLoxNSstage8FirstDay= nanmean(allRats(1).firstPox.meanLastloxNSstage8FirstDay);

allRats(1).firstPox.grandMeanNSPElatencyStage8LastDay= nanmean(allRats(1).firstPox.meanNSPElatencyStage8LastDay);
allRats(1).firstPox.grandMeanfirstLoxNSstage8LastDay= nanmean(allRats(1).firstPox.meanFirstloxNSstage8LastDay);
allRats(1).firstPox.grandMeanlastLoxNSstage8LastDay= nanmean(allRats(1).firstPox.meanLastloxNSstage8LastDay);
    %stage 12 (extinction)
allRats(1).firstPox.grandMeanDSPElatencyExtinctionFirstDay= nanmean(allRats(1).firstPox.meanDSPElatencyExtinctionFirstDay);
allRats(1).firstPox.grandMeanfirstLoxDSExtinctionFirstDay= nanmean(allRats(1).firstPox.meanFirstloxDSExtinctionFirstDay);
allRats(1).firstPox.grandMeanlastLoxDSExtinctionFirstDay= nanmean(allRats(1).firstPox.meanLastloxDSExtinctionFirstDay);

allRats(1).firstPox.grandMeanDSPElatencyExtinctionLastDay= nanmean(allRats(1).firstPox.meanDSPElatencyExtinctionLastDay);
allRats(1).firstPox.grandMeanfirstLoxDSExtinctionLastDay= nanmean(allRats(1).firstPox.meanFirstloxDSExtinctionLastDay);
allRats(1).firstPox.grandMeanlastLoxDSExtinctionLastDay= nanmean(allRats(1).firstPox.meanLastloxDSExtinctionLastDay);

allRats(1).firstPox.grandMeanNSPElatencyExtinctionFirstDay= nanmean(allRats(1).firstPox.meanNSPElatencyExtinctionFirstDay);
allRats(1).firstPox.grandMeanfirstLoxNSExtinctionFirstDay= nanmean(allRats(1).firstPox.meanFirstloxNSExtinctionFirstDay);
allRats(1).firstPox.grandMeanlastLoxNSExtinctionFirstDay= nanmean(allRats(1).firstPox.meanLastloxNSExtinctionFirstDay);

allRats(1).firstPox.grandMeanNSPElatencyExtinctionLastDay= nanmean(allRats(1).firstPox.meanNSPElatencyExtinctionLastDay);
allRats(1).firstPox.grandMeanfirstLoxNSExtinctionLastDay= nanmean(allRats(1).firstPox.meanFirstloxNSExtinctionLastDay);
allRats(1).firstPox.grandMeanlastLoxNSExtinctionLastDay= nanmean(allRats(1).firstPox.meanLastloxNSExtinctionLastDay);

subplot(2,9,1)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage2FirstDay,-allRats(1).firstPox.grandMeanDSPElatencyStage2FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage2FirstDay,allRats(1).firstPox.grandMeanfirstLoxDSstage2FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage2FirstDay,allRats(1).firstPox.grandMeanlastLoxDSstage2FirstDay], ylim, 'g--');%plot vertical line for last lick

hLegend= legend('465nm', '405nm', '465nm SEM','405nm SEM', 'port entry', 'mean cue Onset', 'mean first & last lick'); %add rats to legend, location outside of plot

legendPosition = [.94 0.7 0.03 0.1];
set(hLegend,'Position', legendPosition,'Units', 'normalized');

subplot(2,9,2)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage5FirstDay,-allRats(1).firstPox.grandMeanDSPElatencyStage5FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage5FirstDay,allRats(1).firstPox.grandMeanfirstLoxDSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage5FirstDay,allRats(1).firstPox.grandMeanlastLoxDSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,3)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage5LastDay,-allRats(1).firstPox.grandMeanDSPElatencyStage5LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage5LastDay,allRats(1).firstPox.grandMeanfirstLoxDSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage5LastDay,allRats(1).firstPox.grandMeanlastLoxDSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,4)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage7FirstDay,-allRats(1).firstPox.grandMeanDSPElatencyStage7FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage7FirstDay,allRats(1).firstPox.grandMeanfirstLoxDSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage7FirstDay,allRats(1).firstPox.grandMeanlastLoxDSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,5)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage7LastDay,-allRats(1).firstPox.grandMeanDSPElatencyStage7LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage7LastDay,allRats(1).firstPox.grandMeanfirstLoxDSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage7LastDay,allRats(1).firstPox.grandMeanlastLoxDSstage7LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,6)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage8FirstDay,-allRats(1).firstPox.grandMeanDSPElatencyStage8FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage8FirstDay,allRats(1).firstPox.grandMeanfirstLoxDSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage8FirstDay,allRats(1).firstPox.grandMeanlastLoxDSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,7)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyStage8LastDay,-allRats(1).firstPox.grandMeanDSPElatencyStage8LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSstage8LastDay,allRats(1).firstPox.grandMeanfirstLoxDSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSstage8LastDay,allRats(1).firstPox.grandMeanlastLoxDSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,8)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyExtinctionFirstDay,-allRats(1).firstPox.grandMeanDSPElatencyExtinctionFirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSExtinctionFirstDay,allRats(1).firstPox.grandMeanfirstLoxDSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSExtinctionFirstDay,allRats(1).firstPox.grandMeanlastLoxDSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,9)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanDSPElatencyExtinctionLastDay,-allRats(1).firstPox.grandMeanDSPElatencyExtinctionLastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxDSExtinctionLastDay,allRats(1).firstPox.grandMeanfirstLoxDSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxDSExtinctionLastDay,allRats(1).firstPox.grandMeanlastLoxDSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick



subplot(2,9,10) %no NS on stage 2


subplot(2,9,11)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage5FirstDay,-allRats(1).firstPox.grandMeanNSPElatencyStage5FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage5FirstDay,allRats(1).firstPox.grandMeanfirstLoxNSstage5FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage5FirstDay,allRats(1).firstPox.grandMeanlastLoxNSstage5FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,12)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage5LastDay,-allRats(1).firstPox.grandMeanNSPElatencyStage5LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage5LastDay,allRats(1).firstPox.grandMeanfirstLoxNSstage5LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage5LastDay,allRats(1).firstPox.grandMeanlastLoxNSstage5LastDay], ylim, 'g--');%plot vertical line for last lick


subplot(2,9,13)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage7FirstDay,-allRats(1).firstPox.grandMeanNSPElatencyStage7FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage7FirstDay,allRats(1).firstPox.grandMeanfirstLoxNSstage7FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage7FirstDay,allRats(1).firstPox.grandMeanlastLoxNSstage7FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,14)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage7LastDay,-allRats(1).firstPox.grandMeanNSPElatencyStage7LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage7LastDay,allRats(1).firstPox.grandMeanfirstLoxNSstage7LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage7LastDay,allRats(1).firstPox.grandMeanlastLoxNSstage7LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,15)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage8FirstDay,-allRats(1).firstPox.grandMeanNSPElatencyStage8FirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage8FirstDay,allRats(1).firstPox.grandMeanfirstLoxNSstage8FirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage8FirstDay,allRats(1).firstPox.grandMeanlastLoxNSstage8FirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,16)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyStage8LastDay,-allRats(1).firstPox.grandMeanNSPElatencyStage8LastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSstage8LastDay,allRats(1).firstPox.grandMeanfirstLoxNSstage8LastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSstage8LastDay,allRats(1).firstPox.grandMeanlastLoxNSstage8LastDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,17)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyExtinctionFirstDay,-allRats(1).firstPox.grandMeanNSPElatencyExtinctionFirstDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSExtinctionFirstDay,allRats(1).firstPox.grandMeanfirstLoxNSExtinctionFirstDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSExtinctionFirstDay,allRats(1).firstPox.grandMeanlastLoxNSExtinctionFirstDay], ylim, 'g--');%plot vertical line for last lick

subplot(2,9,18)
hold on;
plot([0,0], ylim, 'k--'); %plot vertical line for PE
plot([-allRats(1).firstPox.grandMeanNSPElatencyExtinctionLastDay,-allRats(1).firstPox.grandMeanNSPElatencyExtinctionLastDay], ylim, 'r--'); %plot vertical line for Cue onset (-mean peLatency)
plot([allRats(1).firstPox.grandMeanfirstLoxNSExtinctionLastDay,allRats(1).firstPox.grandMeanfirstLoxNSExtinctionLastDay], ylim, 'g--'); %plot vertical line for first lick
plot([allRats(1).firstPox.grandMeanlastLoxNSExtinctionLastDay,allRats(1).firstPox.grandMeanlastLoxNSExtinctionLastDay], ylim, 'g--');%plot vertical line for last lick