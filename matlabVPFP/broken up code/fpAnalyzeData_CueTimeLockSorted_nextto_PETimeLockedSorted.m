%% LATENCY SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

        %initialize arrays for convenience
        currentSubj(1).NSzblueAllTrials= [];
        currentSubj(1).NSzpurpleAllTrials= [];
        currentSubj(1).NSpeLatencyAllTrials= [];

    for session = 1:numel(currentSubj) %for each training session this subject completed
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= currentSubj(session).periDS.DS;  % all the DS cues

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
        if ~isempty(currentSubj(session).periNS.NS)
             NSselected= currentSubj(session).periNS.NS;  

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
        
        %collect all z score responses to every single DS across all sessions
        %we'll use DSselected and NSselected as indices to pull only data
        %from trials with port entries
        if session==1 %for first session, initialize 
           currentSubj(1).DSzblueAllTrials= squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSzpurpleAllTrials= squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSpeLatencyAllTrials= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
         
           if ~isempty(currentSubj(session).periNS.NS) %if there's valid NS data
                currentSubj(1).NSzblueAllTrials= squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)); 
                currentSubj(1).NSzpurpleAllTrials= squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected));
                currentSubj(1).NSpeLatencyAllTrials= currentSubj(session).behavior.NSpeLatency(NSselected); 
           else
               continue %continue if no NS data
           end
        else %add subsequent sessions using cat()
            currentSubj(1).DSzblueAllTrials = cat(2, currentSubj.DSzblueAllTrials, (squeeze(currentSubj(session).periDS.DSzblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzpurpleAllTrials = cat(2, currentSubj.DSzpurpleAllTrials, (squeeze(currentSubj(session).periDS.DSzpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSpeLatencyAllTrials = cat(2,currentSubj(1).DSpeLatencyAllTrials,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
        
            if ~isempty(currentSubj(session).periNS.NS)
                currentSubj(1).NSzblueAllTrials = cat(2, currentSubj.NSzblueAllTrials, (squeeze(currentSubj(session).periNS.NSzblue(:,:,NSselected)))); 
                currentSubj(1).NSzpurpleAllTrials = cat(2, currentSubj.NSzpurpleAllTrials, (squeeze(currentSubj(session).periNS.NSzpurple(:,:,NSselected)))); 
                currentSubj(1).NSpeLatencyAllTrials = cat(2,currentSubj(1).NSpeLatencyAllTrials,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
            else
                continue %continue if nos NS data
            end
        end        
    end %end session loop
    
    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data
    [DSpeLatencySorted,DSsortInd] = sort(currentSubj(1).DSpeLatencyAllTrials);       

    [NSpeLatencySorted,NSsortInd] = sort(currentSubj(1).NSpeLatencyAllTrials);
    
    %Sort all trials by PE latency
    currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials(:,DSsortInd);
    currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials(:,DSsortInd);
    currentSubj(1).NSzblueAllTrials = currentSubj(1).NSzblueAllTrials(:,NSsortInd);
    currentSubj(1).NSzpurpleAllTrials= currentSubj(1).NSzpurpleAllTrials(:,NSsortInd);

    %Transpose these data for readability
    currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials';
    currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';    
    currentSubj(1).NSzblueAllTrials= currentSubj(1).NSzblueAllTrials';
    currentSubj(1).NSzpurpleAllTrials= currentSubj(1).NSzpurpleAllTrials';
      
    
    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzblueAllTrials,1); 
    currentSubj(1).totalNScount= 1:size(currentSubj(1).NSzblueAllTrials,1);
    
    
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
     
     topDSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpurpleAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
        bottomAllShared= 2/3*(min(bottomAllDS, bottomAllNS)); %find the absolute min value
        topAllShared= 2/3*(max(topAllDS, topAllNS)); %find the absolute min value
    else
        bottomAllShared= 2/3*(bottomAllDS);
        topAllShared= 2/3*(topAllDS);
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.totalDScount= currentSubj(1).totalDScount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.bottomAllShared= bottomAllShared;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.topAllShared= topAllShared;
    
   




%% LATENCY SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency

%we'll pull from the subjDataAnalyzed struct to make our heatplots


 
        %initialize arrays for convenience
        currentSubj(1).NSzpoxblueAllTrials= [];
        currentSubj(1).NSzpoxpurpleAllTrials= [];
        currentSubj(1).NSpoxpeLatencyAllTrials= [];
        currentSubj(1).NSpoxcueonsetAllTrials=[]; 
    for session = 1:numel(currentSubj) %for each training session this subject completed
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= currentSubj(session).periDSpox.DSselected;  % all the DS cues

        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
        
        
        %lets convert this to an index of trials with a valid value 
        DSselected= find(~isnan(DSselected));
        
            
        %Repeat above for NS 
        if ~isempty(currentSubj(session).periNSpox.NSselected)
             NSselected= currentSubj(session).periNSpox.NSselected;  

            
            %lets convert this to an index of trials with a valid value 
            NSselected= find(~isnan(NSselected));
        end %end NS conditional       
       
        
        
        %collect all z score responses to every single DS across all sessions
        %we'll use DSselected and NSselected as indices to pull only data
        %from trials with port entries
        if session==1 %for first session, initialize 
            
    
            
           currentSubj(1).DSzpoxblueAllTrials= squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSzpoxpurpleAllTrials= squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSpoxpeLatencyAllTrials= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
           
           if ~isempty(currentSubj(session).periNSpox.NSselected) %if there's valid NS data
                currentSubj(1).NSzpoxblueAllTrials= squeeze(currentSubj(session).periNSpox.NSzpoxblue(:,:,NSselected)); 
                currentSubj(1).NSzpoxpurpleAllTrials= squeeze(currentSubj(session).periNSpox.NSzpoxpurple(:,:,NSselected));
                currentSubj(1).NSpoxpeLatencyAllTrials= currentSubj(session).behavior.NSpeLatency(NSselected);

           else
               continue %continue if no NS data
           end
        else %add subsequent sessions using cat()
            currentSubj(1).DSzpoxblueAllTrials = cat(2, currentSubj.DSzpoxblueAllTrials, (squeeze(currentSubj(session).periDSpox.DSzpoxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzpoxpurpleAllTrials = cat(2, currentSubj.DSzpoxpurpleAllTrials, (squeeze(currentSubj(session).periDSpox.DSzpoxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSpoxpeLatencyAllTrials = cat(2,currentSubj(1).DSpoxpeLatencyAllTrials,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
          
            
            
            if ~isempty(currentSubj(session).periNSpox.NSselected)
                currentSubj(1).NSzpoxblueAllTrials = cat(2, currentSubj.NSzpoxblueAllTrials, (squeeze(currentSubj(session).periNSpox.NSzpoxblue(:,:,NSselected)))); 
                currentSubj(1).NSzpoxpurpleAllTrials = cat(2, currentSubj.NSzpoxpurpleAllTrials, (squeeze(currentSubj(session).periNSpox.NSzpoxpurple(:,:,NSselected)))); 
                currentSubj(1).NSpoxpeLatencyAllTrials = cat(2,currentSubj(1).NSpoxpeLatencyAllTrials,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                
            else
                continue %continue if nos NS data
            end
        end        
    end %end session loop
    
    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data
    [DSpoxpeLatencySorted,DSsortInd] = sort(currentSubj(1).DSpoxpeLatencyAllTrials);       

    [NSpoxpeLatencySorted,NSsortInd] = sort(currentSubj(1).NSpoxpeLatencyAllTrials);
    
    %Sort all trials by PE latency
    currentSubj(1).DSzpoxblueAllTrials= currentSubj(1).DSzpoxblueAllTrials(:,DSsortInd);
    currentSubj(1).DSzpoxpurpleAllTrials= currentSubj(1).DSzpoxpurpleAllTrials(:,DSsortInd);
    currentSubj(1).NSzpoxblueAllTrials = currentSubj(1).NSzpoxblueAllTrials(:,NSsortInd);
    currentSubj(1).NSzpoxpurpleAllTrials= currentSubj(1).NSzpoxpurpleAllTrials(:,NSsortInd);
    
    %Transpose these data for readability
    currentSubj(1).DSzpoxblueAllTrials= currentSubj(1).DSzpoxblueAllTrials';
    currentSubj(1).DSzpoxpurpleAllTrials= currentSubj(1).DSzpoxpurpleAllTrials';    
    currentSubj(1).NSzpoxblueAllTrials= currentSubj(1).NSzpoxblueAllTrials';
    currentSubj(1).NSzpoxpurpleAllTrials= currentSubj(1).NSzpoxpurpleAllTrials';

    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDSpoxcount= 1:size(currentSubj(1).DSzpoxblueAllTrials,1); 
    currentSubj(1).totalNSpoxcount= 1:size(currentSubj(1).NSzpoxblueAllTrials,1);
    
    
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
     
     topDSzpoxblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpoxpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzpoxblue = -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpoxpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSpox= min(bottomDSzpoxblue, bottomDSzpoxpurple);
     topAllDSpox= max(topDSzpoxblue, topDSzpoxpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %only run this if there's NS data
        topNSzpoxblue= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpoxpurple= stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzpoxblue= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));
        bottomNSzpoxpurple= -stdFactor*abs(nanmean((nanstd(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));

        bottomAllNSpox= min(bottomNSzpoxblue, bottomNSzpoxpurple);
        topAllNSpox= max(topNSzpoxblue, topNSzpoxpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of CueDS &
    %PEDS and CueNS & PENS
    
    bottomAllSharedDScuePE= 2/3*(min(bottomAllDS, bottomAllDSpox)); %find the absolute min value
    topAllSharedDScuePE= 2/3*(max(topAllDS, topAllDSpox)); %find the absolute min value 
    
    
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %if there is an NS
        bottomAllSharedNScuePE= 2/3*(min(bottomAllNS, bottomAllNSpox)); %find the absolute min value
        topAllSharedNScuePE= 2/3*(max(topAllNS, topAllNSpox)); %find the absolute min value   
    end
    
%     %save for later 
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.totalDSpoxcount= currentSubj(1).totalDSpoxcount;
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.bottomAllSharedpox= bottomAllSharedpox;
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.topAllSharedpox= topAllSharedpox;
%     
   


%% DS PLOTS

 timeLock = [-preCueFrames:postCueFrames]/fs; %define a shared common time axis, timeLock, where cue onset =0
    
    %DS z plot
    figure(figureCount);
    hold on;   
    
 %DS for CUELock+PELock
 %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedDScuePE topAllSharedDScuePE]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

    caxis manual;
    caxis([bottomAllSharedDScuePE topAllSharedDScuePE]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

   
 %plot blue DS PE timelocked

    subplot(2,2,2); %subplot for shared colorbar
    
    heatDSzblueAllTrialspox= imagesc(timeLock,currentSubj(1).totalDSpoxcount,currentSubj(1).DSzpoxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSpoxcount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedDScuePE topAllSharedDScuePE]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS PE  timeLocked (subplotted for shared colorbar)
    subplot(2,2,4);
    heatDSzpurpleAllTrialspox= imagesc(timeLock,currentSubj(1).totalDSpoxcount,currentSubj(1).DSzpoxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSpoxcount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllSharedDScuePE topAllSharedDScuePE]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

   
    %Overlay scatter of PE latency
   subplot(2,2,1) %DS blue
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
   
   
   
   
       %Overlay scatter of Cue onset
   subplot(2,2,2) %DS blue
   hold on
   scatter(-DSpoxpeLatencySorted,currentSubj(1).totalDSpoxcount', 'k.');
   subplot(2,2,4) %DS purple
   hold on
   scatter(-DSpoxpeLatencySorted,currentSubj(1).totalDSpoxcount', 'k.');
   

   
%   set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving  
%  saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_DSperiCueandPEZ_AllTrials_latencysorted','.pdf')); %save the current figure in fig format
    figureCount= figureCount+1;


%% NS PLOTS

 if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is NS data
        
         %NS z plot
    figure(figureCount);
    hold on;   
    
 %NS for CUELock+PELock
 %plot blue NS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatNSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedNScuePE topAllSharedNScuePE]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatNSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    caxis manual;
    caxis([bottomAllSharedNScuePE topAllSharedNScuePE]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

   
 %plot blue NS PE timelocked

    subplot(2,2,2); %subplot for shared colorbar
    
    heatNSzblueAllTrialspox= imagesc(timeLock,currentSubj(1).totalNSpoxcount,currentSubj(1).NSzpoxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalNSpoxcount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedNScuePE topAllSharedNScuePE]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS PE  timeLocked (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleAllTrialspox= imagesc(timeLock,currentSubj(1).totalNSpoxcount,currentSubj(1).NSzpoxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSpoxcount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllSharedNScuePE topAllSharedNScuePE]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');


 %Overlay PE Latency
 
 
      subplot(2,2,1) %NS blue
      hold on
      scatter(NSpeLatencySorted,currentSubj(1).totalNScount', 'm.');
     
      subplot(2,2,3) %NS purple
      hold on
      scatter(NSpeLatencySorted,currentSubj(1).totalNScount', 'm.');

 
 %Overlay Cue Onset
 
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSpoxpeLatencySorted,currentSubj(1).totalNSpoxcount', 'k.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSpoxpeLatencySorted,currentSubj(1).totalNSpoxcount', 'k.');
   
      
%       set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving  
%       saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_NSperiCueandPEZ_AllTrials_latencysorted','.pdf')); %save the current figure in fig format
%     
      figureCount= figureCount+1;
 end
   
 end %end Subj loop   