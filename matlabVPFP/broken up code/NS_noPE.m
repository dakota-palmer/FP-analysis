%% HEAT PLOT OF RESPONSE TO FIRST LICK IN CUE EPOCH

%Here, we'll make a figure for each subject with 4 subplots- blue z score
%response to DS firstlox, blue z score response to NS firstlox, purple z score response to
%DS firstlox, purple z score response to NS firstlox.

%we'll pull from the subjDataAnalyzed struct to make our heatplots 


for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
    for session = 1:numel(currentSubj) %for each training session this subject completed
        
        %collect all z score responses to every single DSfirstPox across all sessions
        if session==1 %for first session, initialize 
            currentSubj(1).DSzloxblueAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubj(1).DSzloxpurpleAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubj(1).NSzloxblueAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxblue); 
            currentSubj(1).NSzloxpurpleAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxpurple);
        else %add subsequent sessions using cat()
            currentSubj(1).DSzloxblueAllTrials = cat(2, currentSubj.DSzloxblueAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxblue))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzloxpurpleAllTrials = cat(2, currentSubj.DSzloxpurpleAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
        
            currentSubj(1).NSzloxblueAllTrials = cat(2, currentSubj.NSzloxblueAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxblue))); 
            currentSubj(1).NSzloxpurpleAllTrials = cat(2, currentSubj.NSzloxpurpleAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxpurple))); 
        end
        
    end %end session loop
    
    %Transpose these data for readability
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials';
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials';    
    currentSubj(1).NSzloxblueAllTrials= currentSubj(1).NSzloxblueAllTrials';
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials';
      
    
    %exclude nan trials 
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials(all(~isnan(currentSubj(1).DSzloxblueAllTrials),2),:); 
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials(all(~isnan(currentSubj(1).DSzloxpurpleAllTrials),2),:); 

    currentSubj(1).NSzloxblueAllTrials= currentSubj(1).NSzloxblueAllTrials(all(~isnan(currentSubj(1).NSzloxblueAllTrials),2),:); 
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials(all(~isnan(currentSubj(1).NSzloxpurpleAllTrials),2),:); 

    % choose trials where animal entered the port but did not lick
    % This will be where a firstPoxind exists but a firstLoxind=nan
    
    
    
    
    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzloxblueAllTrials,1); 
    currentSubj(1).totalNScount= 1:size(currentSubj(1).NSzloxblueAllTrials,1);
    
    
    %TODO: split up yticks by session (this would show any clear differences between days)
    
     %Color axes   
     
     %First, we'll want to establish boundaries for our colormaps based on
     %the std of the z score response. We want to have equidistant
     %color axis max and min so that 0 sits directly in the middle
     
     %TODO: should this be a pooled std calculation (pooled blue & purple)?
     
     %define DS color axes
     
     %get the avg std in the blue and purple z score responses to all cues,
     %get absolute value and then multiply this by some factor to define a color axis max and min
     
     stdFactor= 4; %multiplicative factor- how many stds away do we want our color max & min?
     
     topDSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzloxblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is an NS
        bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
        topAllShared= max(topAllDS, topAllNS); %find the absolute min value
    else
        bottomAllShared= bottomAllDS;
        topAllShared= topAllDS;
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.totalDScount= currentSubj(1).totalDScount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.bottomAllShared= bottomAllShared;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.topAllShared= topAllShared;
    
    %Heatplots!  
    
    %DS z plot
    figure(figureCount);
    hold on;
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where lick onset =0
    
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzloxblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzloxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first Lick in DS epoch')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding DS');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzloxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzloxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first Lick in DS epoch')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding DS');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

   %saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzloxblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzloxblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first Lick in NS epoch ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from First Lick');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding NS');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzloxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzloxpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first Lick in NS epoch ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from First Lick ');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding NS');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

      % saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_perifirstLOXZ_AllTrials','.fig')); %save the current figure in fig format
    end
    
    
    figureCount= figureCount+1;
end %end subject loop

