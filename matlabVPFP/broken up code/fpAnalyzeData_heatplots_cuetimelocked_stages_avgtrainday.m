%% ~~~Stage Heat Plots~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% stage 1-4 , 5, and 6+ session DS plots

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   
   
  sesCountA= 1;
  sesCountB= 1;
  sesCountC= 1;% C=stages 6-8
 
  
  
  subjSessA= [];
  subjSessB= [];
  subjSessC= [];

 
   for session = 1:numel(currentSubj) %for each training session this subject completed
              
       %compare avg response to cue for each session across stages
       
       %First get data from sessions on stages <5
       if currentSubj(session).trainStage <5
            if sesCountA ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzblueSessionMeanA= currentSubj(session).periDS.DSzblueMean; 
                        currentSubj(1).DSzpurpleSessionMeanA= currentSubj(session).periDS.DSzpurpleMean;
                else % add on periDS response for subsequent sessions
                        currentSubj(1).DSzblueSessionMeanA= cat(2, currentSubj(1).DSzblueSessionMeanA, currentSubj(session).periDS.DSzblueMean);
                        currentSubj(1).DSzpurpleSessionMeanA= cat(2, currentSubj(1).DSzpurpleSessionMeanA, currentSubj(session).periDS.DSzpurpleMean);
            end
            sesCountA= sesCountA+1;
            subjSessA= cat(2, subjSessA, currentSubj(session).trainDay); %day count for y axis
       end %end conditional A
       
       %now get data from sessions on stage 5
       if currentSubj(session).trainStage == 5
              if sesCountB ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzblueSessionMeanB= currentSubj(session).periDS.DSzblueMean; 
                        currentSubj(1).DSzpurpleSessionMeanB= currentSubj(session).periDS.DSzpurpleMean;
                        currentSubj(1).NSzblueSessionMeanB= currentSubj(session).periNS.NSzblueMean;
                        currentSubj(1).NSzpurpleSessionMeanB= currentSubj(session).periNS.NSzpurpleMean;
              else % add on periDS response for subsequent sessions
                        currentSubj(1).DSzblueSessionMeanB= cat(2, currentSubj(1).DSzblueSessionMeanB, currentSubj(session).periDS.DSzblueMean);
                        currentSubj(1).DSzpurpleSessionMeanB= cat(2, currentSubj(1).DSzpurpleSessionMeanB, currentSubj(session).periDS.DSzpurpleMean);
                        currentSubj(1).NSzblueSessionMeanB= cat(2, currentSubj(1).NSzblueSessionMeanB, currentSubj(session).periNS.NSzblueMean);
                        currentSubj(1).NSzpurpleSessionMeanB= cat(2, currentSubj(1).NSzpurpleSessionMeanB, currentSubj(session).periNS.NSzpurpleMean);
              end
              sesCountB= sesCountB+1;
              subjSessB= cat(2, subjSessB, currentSubj(session).trainDay); %day count for y axis

       end %end conditional B
       
       %now get data from sessions above stage 5
       if currentSubj(session).trainStage >5
            if sesCountC ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzblueSessionMeanC= currentSubj(session).periDS.DSzblueMean; 
                        currentSubj(1).DSzpurpleSessionMeanC= currentSubj(session).periDS.DSzpurpleMean;
                        currentSubj(1).NSzblueSessionMeanC= currentSubj(session).periNS.NSzblueMean;
                        currentSubj(1).NSzpurpleSessionMeanC= currentSubj(session).periNS.NSzpurpleMean;
             else % add on periDS response for subsequent sessions
                        currentSubj(1).DSzblueSessionMeanC= cat(2, currentSubj(1).DSzblueSessionMeanC, currentSubj(session).periDS.DSzblueMean);
                        currentSubj(1).DSzpurpleSessionMeanC= cat(2, currentSubj(1).DSzpurpleSessionMeanC, currentSubj(session).periDS.DSzpurpleMean);
                        currentSubj(1).NSzblueSessionMeanC= cat(2, currentSubj(1).NSzblueSessionMeanC, currentSubj(session).periNS.NSzblueMean);
                        currentSubj(1).NSzpurpleSessionMeanC= cat(2, currentSubj(1).NSzpurpleSessionMeanC, currentSubj(session).periNS.NSzpurpleMean);
            end
            sesCountC= sesCountC+1;
            subjSessC= cat(2, subjSessC, currentSubj(session).trainDay); %day count for y axis

       end %end conditional C
    end %end session loop
 
 
    
    
    %Transpose for readability
    currentSubj(1).DSzblueSessionMeanA= currentSubj(1).DSzblueSessionMeanA';
    currentSubj(1).DSzpurpleSessionMeanA= currentSubj(1).DSzpurpleSessionMeanA';
    
    currentSubj(1).DSzblueSessionMeanB= currentSubj(1).DSzblueSessionMeanB';
    currentSubj(1).DSzpurpleSessionMeanB= currentSubj(1).DSzpurpleSessionMeanB';
    currentSubj(1).NSzblueSessionMeanB= currentSubj(1).NSzblueSessionMeanB';
    currentSubj(1).NSzpurpleSessionMeanB= currentSubj(1).NSzpurpleSessionMeanB';
    
    if currentSubj(session).trainStage >5
    currentSubj(1).DSzblueSessionMeanC= currentSubj(1).DSzblueSessionMeanC';
    currentSubj(1).DSzpurpleSessionMeanC= currentSubj(1).DSzpurpleSessionMeanC';
    currentSubj(1).NSzblueSessionMeanC= currentSubj(1).NSzblueSessionMeanC';
    currentSubj(1).NSzpurpleSessionMeanC= currentSubj(1).NSzpurpleSessionMeanC';
    end
%     %get list of session days for heatplot y axis (transposed for readability)
%     subjTrial= cat(2, currentSubj.trainDay).'; %this is only training days for this subj

  
    
    %get list of session days for heatplot y axis
%     subjTrialNS=[]; %keep track of sessions that have valid NS trials
%     dateNS= [];
%     for session = 1:numel(currentSubj) %for each training session this subject completed
%         if ~isempty(currentSubj(session).periNS.NSzblueMean) %if there's an NS trial in this session, add it to the array that will mark the y axis
% %              subjTrialNS= cat(2, subjTrialNS, currentSubj(session).trainDay); %old method based on trainDay
%                 dateNS= cat(2, dateNS, currentSubj(session).date);
%         end
%     end %end session loop
%     
%     %search NS dates for the appropriate index in allDates, then label it
%     %similar to subjTrial
%     for thisDate = 1:numel(dateNS) 
%         subjTrialNS(thisDate)= find(allDates==dateNS(thisDate)); %returns the index in allDates that matches the date of this NS session
%     end
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
     topDSzblueA= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleA= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueA = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanA, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleA= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanA, 0, 2))));
     
     %cond b
     topDSzblueB= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleB= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueB = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanB, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleB= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanB, 0, 2))));
     
     %cond c
     if currentSubj(session).trainStage >5
     topDSzblueC= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurpleC= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblueC = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMeanC, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurpleC= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMeanC, 0, 2))));
    
     
     bottoms= [bottomDSzblueA, bottomDSzblueB, bottomDSzblueC, bottomDSzpurpleA, bottomDSzpurpleB, bottomDSzpurpleC];
     tops= [topDSzblueA, topDSzblueB, topDSzblueC, topDSzpurpleA, topDSzpurpleB, topDSzpurpleC];
     
     else 
     bottoms= [bottomDSzblueA, bottomDSzblueB, bottomDSzpurpleA, bottomDSzpurpleB];
     tops= [topDSzblueA, topDSzblueB, topDSzpurpleA, topDSzpurpleB];
     end
         
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottoms);
     topAllDS= max(tops);
     
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
        bottomMeanShared= bottomAllDS;
        topMeanShared= topAllDS;
%     end
    
   

    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

        figure(figureCount);
        figureCount= figureCount+1;

        sgtitle(strcat(subjData.(subjects{subj})(1).experiment, ' ', subjects{subj}, 'Avg response by session to DS across training stages')); %add big title above all subplots


        subplot(2,3,1) %plot of stage 1-4 blue (cond A blue)
        
            imagesc(timeLock,subjSessA,currentSubj(1).DSzblueSessionMeanA) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 465nm z score response surrounding DS- Stages 1-4')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 465nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
            
            
        subplot(2,3,2) %plot of stage 5 blue (cond B blue)
            
            imagesc(timeLock,subjSessB,currentSubj(1).DSzblueSessionMeanB) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 465nm z score response surrounding DS- Stage 5')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 465nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
     if currentSubj(session).trainStage >5    
        subplot(2,3,3) %plot of stage 6-8 blue (cond C blue)
            imagesc(timeLock,subjSessC,currentSubj(1).DSzblueSessionMeanC) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 465nm z score response surrounding DS- Stages 6-8')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 465nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
     end  

       subplot(2,3,4) %plot of stage 1-4 purple (cond A purple)
            imagesc(timeLock,subjSessA,currentSubj(1).DSzpurpleSessionMeanA) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 405nm z score response surrounding DS- Stages 1-4')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessA); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 405nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
       subplot(2,3,5) %plot of stage 5 purple (cond B purple)
            imagesc(timeLock,subjSessB,currentSubj(1).DSzpurpleSessionMeanB) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 405nm z score response surrounding DS- Stage 5')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessB); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 405nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
              
      if currentSubj(session).trainStage >5    
       subplot(2,3,6) %plot of stage 6-8 purple (cond C purple)
            imagesc(timeLock,subjSessC,currentSubj(1).DSzpurpleSessionMeanC) %, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
            title(strcat('daily avg 405nm z score response surrounding DS- Stages 6-8')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
            xlabel('seconds from cue onset');
            ylabel('training day');
            set(gca, 'ytick', subjSessC); %label trials appropriately
            caxis manual;
            caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

            c= colorbar; %colorbar legend
            c.Label.String= strcat('DS 405nm z-score calculated from', num2str(slideTime/fs), 's preceding cue');
      end
            set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
            
             saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, 'stages_cuelocked_avgtrainday','.fig')); %save the current figure in fig format

end %end subject loop


