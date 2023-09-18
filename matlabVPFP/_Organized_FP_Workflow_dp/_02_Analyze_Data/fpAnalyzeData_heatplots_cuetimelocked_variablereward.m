%% Variable reward z score heatplot- timlocked to CUE
%here we will make a figure with subplotted heatplots of the z score
%response to all Pump1, Pump2, and Pump3 DS trials

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct




    for session = 1:numel(currentSubj) %for each training session this subject completed
        rewardSessionCount= 0; %counter for sessions with valid variable reward data 
                
        if ~isempty(currentSubj(session).reward) %make sure this is a valid stage with multiple rewards
            
            rewardSessionCount= rewardSessionCount+1; %counter for sessions with valid variable reward data 

            
            %first we need to get the z score data surrounding either pump1,
            %pump2, or pump3 DS trials. To do this, we'll use the reward
            %identities (reward.DSreward) as an indidices to get the right DS trials

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
    %save for later
    
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump1= currentSubj(1).DSzbluePump1;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump2= currentSubj(1).DSzbluePump2;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump3= currentSubj(1).DSzbluePump3;
                
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluemeanPump1= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump1,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluemeanPump2= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump2,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluemeanPump3= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzbluePump3,2);
    
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump1= currentSubj(1).DSzpurplePump1;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump2= currentSubj(1).DSzpurplePump2;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump3= currentSubj(1).DSzpurplePump3;
                
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplemeanPump1= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump1,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplemeanPump2= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump2,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplemeanPump3= nanmean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDS.DSzpurplePump3,2);
    
        end %end ~isempty reward conditional (alternative to stage conditional)
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


    %     currentSubj(1).totalNScount= 1:size(currentSubj(1).NSzblueAllTrials,1);


        %TODO: split up yticks by session (this would show any clear differences between days)

%          Color axes   

         %First, we'll want to establish boundaries for our colormaps based on
         %the std of the z score response. We want to have equidistant
         %color axis max and min so that 0 sits directly in the middle

         %TODO: should this be a pooled std calculation (pooled blue & purple)?

         %define DS color axes

         %get the avg std in the blue and purple z score responses to all cues,
         %get absolute value and then multiply this by some factor to define a color axis max and min

         stdFactor= 4; %multiplicative factor- how many stds away do we want our color max & min?

         topDSzbluePump1= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump1, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         topDSzbluePump2= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump2, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         topDSzbluePump3= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump3, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         
         
%          topDSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         bottomDSzbluePump1 = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump1, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         bottomDSzbluePump2 = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump2, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         bottomDSzbluePump3 = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzbluePump3, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         
%          bottomDSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrials, 0, 2))));

         %now choose the most extreme of these two (between blue and
         %purple)to represent the color axis 
         bottomAllDS= min([bottomDSzbluePump1, bottomDSzbluePump2, bottomDSzbluePump3]);
         topAllDS= max([topDSzbluePump1, topDSzbluePump2, topDSzbluePump3]);

%         %same, but defining color axes for NS
%         if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
%             topNSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%             topNSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%             bottomNSzblue= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueAllTrials, 0, 2))));
%             bottomNSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleAllTrials, 0, 2))));
% 
%             bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
%             topAllNS= max(topNSzblue, topNSzpurple);
%         end

%         %Establish a shared bottom and top for shared color axis of DS & NS
%         if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
%             bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
%             topAllShared= max(topAllDS, topAllNS); %find the absolute min value
%         else
            bottomAllShared= bottomAllDS;
            topAllShared= topAllDS;
%         end
% 
%         %save for later 
%         subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.totalDScount= currentSubj(1).totalDScount;
%         subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.bottomAllShared= bottomAllShared;
%         subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.topAllShared= topAllShared;

        %Heatplots!  

        %DS z plot
        figure(figureCount);
        figureCount=figureCount+1;
        hold on;

        timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

        %plot pump1 blue DSz

        subplot(3,1,1); %subplot for shared colorbar

        heatDSzbluePump1= imagesc(timeLock,currentSubj(1).DScountPump1,currentSubj(1).DSzbluePump1);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding Pump1 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legendsd
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        
                %plot pump2 blue DSz

        subplot(3,1,2); %subplot for shared colorbar

        heatDSzbluePump1= imagesc(timeLock,currentSubj(1).DScountPump2,currentSubj(1).DSzbluePump2);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding Pump2 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

                %plot pump3 blue DSz

        subplot(3,1,3); %subplot for shared colorbar

        heatDSzbluePump3= imagesc(timeLock,currentSubj(1).DScountPump3,currentSubj(1).DSzbluePump3);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding Pump3 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        %TODO: add purple plot
        
               set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
               
               saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'cuelocked_variable_reward_heatplots','.fig'));

    end %end variable reward conditional
end %end subject loop