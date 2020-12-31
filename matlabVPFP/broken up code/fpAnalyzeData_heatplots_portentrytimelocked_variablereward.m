%% Variable reward z-score heatplot- timelocked to FIRST PE after cue

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct


rewardSessionCount= 0; %counter for sessions with valid variable reward data 


    for session = 1:numel(currentSubj) %for each training session this subject completed
                
        %clear between sessions
        indPump1= [];
        indPump2= [];
        indPump3= [];
        
        
        if ~isempty(currentSubj(session).reward) %make sure this is a valid stage with multiple rewards
            
            rewardSessionCount= rewardSessionCount+1; %counter for sessions with valid variable reward data 

            
            %first we need to get the z score data surrounding either pump1,
            %pump2, or pump3 DS trials. To do this, we'll use the reward
            %identities (reward.DSreward) as an indidices to get the right DS trials
           

            indPump1= find(currentSubj(session).reward.DSreward==1);
            indPump2= find(currentSubj(session).reward.DSreward==2);
            indPump3= find(currentSubj(session).reward.DSreward==3);
            
            %it's possible that indPump1,2, or 3 will result in an invalid
            %index (for a cue that was excluded in the peri cue analyses)
            %so let's check for that and exclude these (this may not be the
            %best method)
           
            for i= 1:numel(indPump1)
                if indPump1(i) > size(currentSubj(session).periDSpox.DSzpoxblue,3)
                   indPump1(i:end) = [];
                   break;
                end
            end
            
            for i= 1:numel(indPump2)
                if indPump2(i) > size(currentSubj(session).periDSpox.DSzpoxblue,3)
                   indPump2(i:end) = []; 
                  break;
                end
            end

            for i= 1:numel(indPump3)
                if indPump3(i) > size(currentSubj(session).periDSpox.DSzpoxblue,3)
                   indPump3(i:end) = []; 
                   break;
                end
            end

            %collect all z score responses to every single DS across all sessions
            if rewardSessionCount==1 %for first session, initialize 
                
                %now we'll use the reward identity (pump) indices to get only responses to those specific trials 
                if ~isempty(currentSubj(session).periDSpox.DSselected) %if there's valid DS data
                currentSubj(1).DSzpoxbluePump1= squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump1)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpoxbluePump2= squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump2)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpoxbluePump3= squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump3)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

                currentSubj(1).DSzpoxpurplePump1= squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump1)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpoxpurplePump2= squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump2)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpoxpurplePump3= squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump3)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

                rewardSessionCount= rewardSessionCount+1;
                end
%                 currentSubj(1).DSzpurpleAllTrials= squeeze(currentSubj(session).periDS.DSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
% 
%                 currentSubj(1).NSzblueAllTrials= squeeze(currentSubj(session).periNS.NSzblue); 
%                 currentSubj(1).NSzpurpleAllTrials= squeeze(currentSubj(session).periNS.NSzpurple);
            else %add subsequent sessions using cat()
                if ~isempty(currentSubj(session).periDSpox.DSselected) %if there's valid DS data
                currentSubj(1).DSzpoxbluePump1 = cat(2, currentSubj(1).DSzpoxbluePump1, squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump1))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpoxbluePump2 = cat(2, currentSubj(1).DSzpoxbluePump2, squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump2))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpoxbluePump3 = cat(2, currentSubj(1).DSzpoxbluePump3, squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,indPump3))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)

                currentSubj(1).DSzpoxpurplePump1 = cat(2, currentSubj(1).DSzpoxpurplePump1, squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump1))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpoxpurplePump2 = cat(2, currentSubj(1).DSzpoxpurplePump2, squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump2))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpoxpurplePump3 = cat(2, currentSubj(1).DSzpoxpurplePump3, squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,indPump3))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                
                rewardSessionCount= rewardSessionCount+1;

% currentSubj(1).DSzpurpleAllTrials = cat(2, currentSubj.DSzpurpleAllTrials, (squeeze(currentSubj(session).periDS.DSzpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
% 
%                 currentSubj(1).NSzblueAllTrials = cat(2, currentSubj.NSzblueAllTrials, (squeeze(currentSubj(session).periNS.NSzblue))); 
%                 currentSubj(1).NSzpurpleAllTrials = cat(2, currentSubj.NSzpurpleAllTrials, (squeeze(currentSubj(session).periNS.NSzpurple))); 
                end
            end
             %save for later
    
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump1= currentSubj(1).DSzpoxbluePump1;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump2= currentSubj(1).DSzpoxbluePump2;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump3= currentSubj(1).DSzpoxbluePump3;
                
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluemeanPump1= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump1,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluemeanPump2= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump2,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluemeanPump3= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxbluePump3,2);
    
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump1= currentSubj(1).DSzpoxpurplePump1;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump2= currentSubj(1).DSzpoxpurplePump2;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump3= currentSubj(1).DSzpoxpurplePump3;
                
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplemeanPump1= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump1,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplemeanPump2= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump2,2);
    subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplemeanPump3= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).periDSpox.DSzpoxpurplePump3,2);
        end %end session loop
    end %end ~isempty reward conditional (alternative to stage conditional)
    
       
    if rewardSessionCount ~=0 %if this subject had a session with valid variable reward data

        %Transpose these data for readability
        currentSubj(1).DSzpoxbluePump1= currentSubj(1).DSzpoxbluePump1';
        currentSubj(1).DSzpoxbluePump2= currentSubj(1).DSzpoxbluePump2';
        currentSubj(1).DSzpoxbluePump3= currentSubj(1).DSzpoxbluePump3';


%         currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';    
%         currentSubj(1).NSzblueAllTrials= currentSubj(1).NSzblueAllTrials';
%         currentSubj(1).NSzpurpleAllTrials= currentSubj(1).NSzpurpleAllTrials';
%           

        %get a trial count to use for the heatplot ytick
        currentSubj(1).DSpoxcountPump1= 1:size(currentSubj(1).DSzpoxbluePump1,1); 
        currentSubj(1).DSpoxcountPump2= 1:size(currentSubj(1).DSzpoxbluePump2,1); 
        currentSubj(1).DSpoxcountPump3= 1:size(currentSubj(1).DSzpoxbluePump3,1); 


 
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

         topDSzpoxbluePump1= stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump1, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         topDSzpoxbluePump2= stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump2, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         topDSzpoxbluePump3= stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump3, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         
         
%          topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         bottomDSzpoxbluePump1 = -stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump1, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         bottomDSzpoxbluePump2 = -stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump2, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
         bottomDSzpoxbluePump3 = -stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxbluePump3, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

         
%          bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));

         %now choose the most extreme of these two (between blue and
         %purple)to represent the color axis 
         bottomAllDSpox= min([bottomDSzpoxbluePump1, bottomDSzpoxbluePump2, bottomDSzpoxbluePump3]);
         topAllDSpox= max([topDSzpoxbluePump1, topDSzpoxbluePump2, topDSzpoxbluePump3]);

%         %same, but defining color axes for NS
%         if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
%             topNSzblue= stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%             topNSzpurple= stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%             bottomNSzblue= -stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));
%             bottomNSzpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));
% 
%             bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
%             topAllNS= max(topNSzblue, topNSzpurple);
%         end

%         %Establish a shared bottom and top for shared color axis of DS & NS
%         if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
%             bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
%             topAllShared= max(topAllDS, topAllNS); %find the absolute min value
%         else
            bottomAllSharedpox= bottomAllDSpox;
            topAllSharedpox= topAllDSpox;
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

        heatDSzpoxbluePump1= imagesc(timeLock,currentSubj(1).DSpoxcountPump1,currentSubj(1).DSzpoxbluePump1);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first PE- Pump1 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from PE');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legendsd
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        
                %plot pump2 blue DSz

        subplot(3,1,2); %subplot for shared colorbar

        heatDSzpoxbluePump2= imagesc(timeLock,currentSubj(1).DSpoxcountPump2,currentSubj(1).DSzpoxbluePump2);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first PE- Pump2 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from PE');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

                %plot pump3 blue DSz

        subplot(3,1,3); %subplot for shared colorbar

        heatDSzpoxbluePump3= imagesc(timeLock,currentSubj(1).DSpoxcountPump3,currentSubj(1).DSzpoxbluePump3);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first PE- Pump3 DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from PE');
%         ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        %TODO: add purple plot
        
               set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
               
               saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'PElocked_variable_reward_heatplots','.fig'));


    end %end variable reward conditional
end %end subject loop
