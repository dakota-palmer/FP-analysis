%% DFF heat plot of response to every individual cue


%Here, we'll make a figure for each subject with 4 subplots- blue z score
%response to DS, blue z score response to NS, purple z score response to
%DS, purple z score response to NS.

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
    for session = 1:numel(currentSubj) %for each training session this subject completed
                
        %collect all z score responses to every single DS across all sessions
        if session==1 %for first session, initialize 
            currentSubj(1).DSbluedffAllTrials= squeeze(currentSubj(session).periDS.DSbluedff); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubj(1).DSpurpledffAllTrials= squeeze(currentSubj(session).periDS.DSpurpledff); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            
            currentSubj(1).NSbluedffAllTrials= squeeze(currentSubj(session).periNS.NSbluedff); 
            currentSubj(1).NSpurpledffAllTrials= squeeze(currentSubj(session).periNS.NSpurpledff);
        else %add subsequent sessions using cat()
            currentSubj(1).DSbluedffAllTrials = cat(2, currentSubj.DSbluedffAllTrials, (squeeze(currentSubj(session).periDS.DSbluedff))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSpurpledffAllTrials = cat(2, currentSubj.DSpurpledffAllTrials, (squeeze(currentSubj(session).periDS.DSpurpledff))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
        
            currentSubj(1).NSbluedffAllTrials = cat(2, currentSubj.NSbluedffAllTrials, (squeeze(currentSubj(session).periNS.NSbluedff))); 
            currentSubj(1).NSpurpledffAllTrials = cat(2, currentSubj.NSpurpledffAllTrials, (squeeze(currentSubj(session).periNS.NSpurpledff))); 

        end
        
    end %end session loop
    
    %Transpose these data for readability
    currentSubj(1).DSbluedffAllTrials= currentSubj(1).DSbluedffAllTrials';
    currentSubj(1).DSpurpledffAllTrials= currentSubj(1).DSpurpledffAllTrials';    
    currentSubj(1).NSbluedffAllTrials= currentSubj(1).NSbluedffAllTrials';
    currentSubj(1).NSpurpledffAllTrials= currentSubj(1).NSpurpledffAllTrials';
      
    
    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSbluedffAllTrials,1); 
    currentSubj(1).totalNScount= 1:size(currentSubj(1).NSbluedffAllTrials,1);
    
    
    %TODO: split up yticks by session (this would show any clear differences between days)
    
     %Color axes   
     
     %First, we'll want to establish boundaries for our colormaps based on
     %the std of the z score response. We want to have equidistant
     %color axis max and min so that 0 sits directly in the middle
     
     %TODO: should this be a pooled std calculation (pooled blue & purple)?
     
     %define DS color axes
     
     %get the avg std in the blue and purple z score responses to all cues,
     %get absolute value and then multiply this by some factor to define a color axis max and min
     
     stdFactor= 8; %multiplicative factor- how many stds away do we want our color max & min?
     
     topDSdffblue= stdFactor*abs(mean((std(currentSubj(1).DSbluedffAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSdffpurple= stdFactor*abs(mean((std(currentSubj(1).DSpurpledffAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSdffblue = -stdFactor*abs(mean((std(currentSubj(1).DSbluedffAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSdffpurple= -stdFactor*abs(mean((std(currentSubj(1).DSpurpledffAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSdffblue, bottomDSdffpurple);
     topAllDS= max(topDSdffblue, topDSdffpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSbluedffAllTrials) %only run this if there's NS data
        topNSdffblue= stdFactor*abs(mean((std(currentSubj(1).NSbluedffAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSdffpurple= stdFactor*abs(mean((std(currentSubj(1).NSpurpledffAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSdffblue= -stdFactor*abs(mean((std(currentSubj(1).NSbluedffAllTrials, 0, 2))));
        bottomNSdffpurple= -stdFactor*abs(mean((std(currentSubj(1).NSpurpledffAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSdffblue, bottomNSdffpurple);
        topAllNS= max(topNSdffblue, topNSdffpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSbluedffAllTrials) %if there is an NS
        bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
        topAllShared= max(topAllDS, topAllNS); %find the absolute min value
    else
        bottomAllShared= bottomAllDS;
        topAllShared= topAllDS;
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.totalDScount= currentSubj(1).totalDScount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.bottomAllShared= bottomAllShared;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.topAllShared= topAllShared;
    
    %Heatplots!  
    
    %DS z plot
    figure(figureCount);
    hold on;
    
    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSdffblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSbluedffAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue dff response surrounding every DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue dff ');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSdffpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSpurpledffAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple dff response surrounding every DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple dff');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSbluedffAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSdffblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSbluedffAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue dff response surrounding every NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS dff');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSdffpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSpurpledffAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purpledff response surrounding every NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple dff');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

        saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueDffs_AllTrials','.fig')); %save the current figure in fig format
    end
    figureCount= figureCount+1;
end %end subj loop
