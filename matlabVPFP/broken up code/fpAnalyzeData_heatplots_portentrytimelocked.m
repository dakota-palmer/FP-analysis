%% ~~~Heat plots (port-entry time locked) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Establish common date axis across subjects
 %since training day may vary between subjects, we want to eventually arrange
%all these data by the actual recording date. If a subject did not run a
%session on a date we should be able to make values on this date nan later 

%this section will simply collect all of the unique recording dates from
%all subjects into an array (allDates)

for subj= 1:numel(subjectsAnalyzed) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

    for session = 1:numel(currentSubj) %for each training session this subject completed
       
%       So save the dates in a cell array
        allDates(session,subj) = currentSubj(session).date;
       allDates(session)= currentSubj(session).date;
                
    end %end session loop
   
end

    %remove invalid dates (empty spots were filled with zero, let's make
    %these empty)
    allDates(allDates==0) = [];
    
    %retain only unique dates 
    allDates= unique(allDates); 


%% HEAT PLOT OF AVG RESPONSE TO PE (by session)

%Here, we'll make a figure for each subject with 4 subplots based on avg daily 
%response to cue- Avg blue z score response to DS, Avg blue z score response 
%to NS, Avg purple z score response to DS, Avg purple z score response to NS.

%we'll pull from the subjDataAnalyzed struct to make our heatplots
%first, we need to collect the avg cue response from all sessions and reshape for plotting

for subj= 1:numel(subjectsAnalyzed) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
    %DS - extract data for plots
    %avg cue response sorted by trial, timelocked to DS
    
    subjDates= zeros(1,numel(allDates));
    emptyDates= [];
    
    timeLock= [-preCueFrames:postCueFrames]/fs;
    
    %First find out which dates this subj has data for
    %get all dates for this subj
    for session= 1:numel(currentSubj)
        subjDates(session)= currentSubj(session).date;
    end %end session loop
    
    %now find out which dates from allDates this subj has data for 
    for thisDate = allDates %loop through all dates
        if isempty(subjDates(subjDates==thisDate)) %if this subj doesn't have valid data on this date
%                 emptyDates= cat(1, emptyDates,thisDate); %save this empty date to an array (add onto array by using cat())
                currentSubj(end+1).date= thisDate; %use end+1 to add a new empty session
                
                %fill relevant fields with NaN for later 
                currentSubj(end).periDSpox.DSzpoxblueMean= NaN(size(timeLock'));
                currentSubj(end).periDSpox.DSzpoxpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzpoxblueMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzpoxpurpleMean= NaN(size(timeLock'));

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

    
    %now get the actual photometry data
    for session = 1:numel(currentSubj) %for each training session this subject completed       
            if session ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzpoxblueSessionMean= currentSubj(session).periDSpox.DSzpoxblueMean; 
                        currentSubj(1).DSzpoxpurpleSessionMean= currentSubj(session).periDSpox.DSzpoxpurpleMean;
                else % add on periDS response for subsequent sessions
                        currentSubj(1).DSzpoxblueSessionMean= cat(2, currentSubj(1).DSzpoxblueSessionMean, currentSubj(session).periDSpox.DSzpoxblueMean);
                        currentSubj(1).DSzpoxpurpleSessionMean= cat(2, currentSubj(1).DSzpoxpurpleSessionMean, currentSubj(session).periDSpox.DSzpoxpurpleMean);
            end
    end %end session loop
 
    
    %Transpose for readability
    currentSubj(1).DSzpoxblueSessionMean= currentSubj(1).DSzpoxblueSessionMean';
    currentSubj(1).DSzpoxpurpleSessionMean= currentSubj(1).DSzpoxpurpleSessionMean';

    %get list of session days for heatplot y axis (transposed for readability)
%     subjTrial= cat(2, currentSubj.trainDay).'; %this is only training days for this subj
    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

    %NS- extract data for plots
    %session axis (Y) is handled a bit differently because we only want to show sessions that have NS cues
    
    %photometry signals sorted by trial, timelocked to NS
    
    for session = 1:numel(currentSubj) %for each training session this subject completed
        %if there's no NS data, fill with NaNs first
        if isempty(currentSubj(session).periNSpox.NSzpoxblueMean)
            currentSubj(session).periNSpox.NSzpoxblueMean= NaN(size(timeLock'));
            currentSubj(session).periNSpox.NSzpoxpurpleMean= NaN(size(timeLock'));
        end
        
        if session ==1 %for the first session, get this sessions periDS blue z score response
                currentSubj(1).NSzpoxblueSessionMean= currentSubj(session).periNSpox.NSzpoxblueMean; 
                currentSubj(1).NSzpoxpurpleSessionMean= currentSubj(session).periNSpox.NSzpoxpurpleMean;
        else % add on periDS response for subsequent sessions
                currentSubj(1).NSzpoxblueSessionMean= cat(2, currentSubj(1).NSzpoxblueSessionMean, currentSubj(session).periNSpox.NSzpoxblueMean);
                currentSubj(1).NSzpoxpurpleSessionMean= cat(2, currentSubj(1).NSzpoxpurpleSessionMean, currentSubj(session).periNSpox.NSzpoxpurpleMean);
        end

    end %end session loop
    
    
    %Transpose for readability
    currentSubj(1).NSzpoxblueSessionMean= currentSubj(1).NSzpoxblueSessionMean';
    currentSubj(1).NSzpoxpurpleSessionMean= currentSubj(1).NSzpoxpurpleSessionMean';
   
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
     
     topDSzbluepox= stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurplepox= stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzbluepox = -stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurplepox= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpoxpurpleSessionMean, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSpox= min(bottomDSzbluepox, bottomDSzpurplepox);
     topAllDSpox= max(topDSzbluepox, topDSzpurplepox);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzpoxblueSessionMean) %only run this if there's NS data
        topNSzpoxblue= stdFactor*abs(nanmean((std(currentSubj(1).NSzpoxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpoxpurple= stdFactor*abs(nanmean((std(currentSubj(1).NSzpoxpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzpoxblue= -stdFactor*abs(nanmean((std(currentSubj(1).NSzpoxblueSessionMean, 0, 2))));
        bottomNSzpoxpurple= -stdFactor*abs(nanmean((std(currentSubj(1).NSzpoxpurpleSessionMean, 0, 2))));

        bottomAllNSpox= min(bottomNSzpoxblue, bottomNSzpoxpurple);
        topAllNSpox= max(topNSzpoxblue, topNSzpoxpurple);
    end
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzpoxblueSessionMean) %if there is an NS
        bottomMeanSharedpox= min(bottomAllDSpox, bottomAllNSpox); %find the absolute min value
        topMeanSharedpox= max(topAllDSpox, topAllNSpox); %find the absolute min value
    else
        bottomMeanSharedpox= bottomAllDSpox;
        topMeanSharedpox= topAllDSpox;
    end
    
    
    %Heatplots!       
    %DS z plot
    figure(figureCount);
    hold on;
    subplot(2,2,1); %subplot for shared colorbar

    %plot blue DS

    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMeanpox= imagesc(timeLock,subjTrial,currentSubj(1).DSzpoxblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).DSzpoxblueSessionMean));
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg blue z score response surrounding DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanSharedpox topMeanSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMeanpox= imagesc(timeLock,subjTrial,currentSubj(1).DSzpoxpurpleSessionMean,  'AlphaData', ~isnan(currentSubj(1).DSzpoxpurpleSessionMean)); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg purple z score response surrounding DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanSharedpox topMeanSharedpox]); %use a shared color axis to encompass all values
    

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMeanpox= imagesc(timeLock,subjTrial,currentSubj(1).NSzpoxblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzpoxblueSessionMean));
    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), 'avg blue z score response to NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanSharedpox topMeanSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMeanpox= imagesc(timeLock,subjTrial,currentSubj(1).NSzpoxpurpleSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzpoxpurpleSessionMean)); 

    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), ' avg purple z score response to NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanSharedpox topMeanSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periPEZSessionAvg','.fig')); %save the current figure in fig format
    figureCount=figureCount+1; %iterate the figure count


end %end subject loop
%% BETWEEN SUBJECTS HEATPLOTS- Avg response to cue (by session)
 
 %gathering all mean data from time window around PE 
 
 
 for subj= 1:numel(subjectsAnalyzed) %for each subject
     currentSubj=struct();
     currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
 
     %we'll want to organize these by common date instead of relative
     %training day as well
     
     %First find out which dates this subj has data for
    %get all dates for this subj
    for session= 1:numel(currentSubj);
        subjDates(session)= currentSubj(session).date;
    end %end session loop
    
    %now find out which dates from allDates this subj has data for 
    for thisDate = allDates %loop through all dates
        if isempty(subjDates(subjDates==thisDate)) %if this subj doesn't have valid data on this date
%                 emptyDates= cat(1, emptyDates,thisDate); %save this empty date to an array (add onto array by using cat())
                currentSubj(end+1).date= thisDate; %use end+1 to add a new empty session
                
                %fill relevant fields with NaN for later 
                currentSubj(end).periDSpox.DSzpoxblueMean= NaN(size(timeLock'));
                currentSubj(end).periDSpox.DSzpoxpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzpoxblueMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzpoxpurpleMean= NaN(size(timeLock'));
                
                currentSubj(end).periNSpox.NSselected= nan;

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

     
     
     NStrialCount= 1; %counter for ns sessions
     
     %now get the actual photometry data
     
     for session = 1:numel(currentSubj) %for each session this subject completed

         allRats.meanDSzpoxblue(:,session,subj)= currentSubj(session).periDSpox.DSzpoxblueMean;
         allRats.meanDSzpoxpurple(:,session,subj)= currentSubj(session).periDSpox.DSzpoxpurpleMean;

         if isempty(currentSubj(session).periNSpox.NSselected) %if there's no NS data, fill with NaNs
            currentSubj(session).periNSpox.NSzpoxblueMean= NaN(size(timeLock'));
            currentSubj(session).periNSpox.NSzpoxpurpleMean=  NaN(size(timeLock'));
         end
         
         allRats.meanNSzpoxblue(:,session,subj)= currentSubj(session).periNSpox.NSzpoxblueMean;
         allRats.meanNSzpoxpurple(:,session,subj)= currentSubj(session).periNSpox.NSzpoxpurpleMean;
         
%          if ~isempty(currentSubj(session).periNS.NS) %only run if NS data present
%             allRats.meanNSzblue(:,NStrialCount,subj)= currentSubj(session).periNS.NSzblueMean;
%             allRats.meanNSzpurple(:,NStrialCount,subj)= currentSubj(session).periNS.NSzpurpleMean;
%              
% %             allRats.subjTrialNS(NStrialCount,subj)= currentSubj(session).trainDay;
%             
%             NStrialCount= NStrialCount+1;
%             % zeros are appearing in sessions where there's no data! (e.g.
%             % rats are on different training days, so one can be on day 14
%             % ahead of others that are on day 13)
%                        %skipping from 6->10
%          else %if there's no NS data present, fill with nan (otherwise will fill with zeros)
%             allRats.meanNSzblue(:,session, subj)= nan(size(currentSubj(session).periDS.DSzblueMean));
%             allRats.meanNSzpurple(:,session,subj)= nan(size(currentSubj(session).periDS.DSzblueMean));        
%          end %end NS conditional
     end %end session loop
          
 end %end subj loop

 % mean of all rats per training day ( each column is a training day , each 3d page is a subject)
allRats.grandDSzpoxblue=nanmean(allRats.meanDSzpoxblue(:,1:26,1:numel(subjectsAnalyzed)),3)'; %(:,:,1:4),3)' % doing 1:4 in 3rd dmension because rat8 is a GFP animal but need to find more robust way to do this
allRats.grandDSzpoxpurple=nanmean(allRats.meanDSzpoxpurple(:,1:26,1:numel(subjectsAnalyzed)),3)'; %1:4),3)'
allRats.grandNSzpoxblue=nanmean(allRats.meanNSzpoxblue(:,1:26,1:numel(subjectsAnalyzed)),3)';%'; %1:4),3)'
allRats.grandNSzpoxpurple=nanmean(allRats.meanNSzpoxpurple(:,1:26,1:numel(subjectsAnalyzed)),3)'; %,1:4),3)'

 %get bottom and top for color axis of DS heatplot
 allRats.bottomMeanallDSpox = min(min(min(allRats.grandDSzpoxblue)), min(min(allRats.grandDSzpoxpurple))); %find the lowest value 
 allRats.topMeanallDSpox = max(max(max(allRats.grandDSzpoxblue)), max(max(allRats.grandDSzpoxpurple))); %find the highest value

 %get bottom and top for color axis of NS heatplot
 allRats.bottomMeanallNSpox = min(min(min(allRats.grandNSzpoxblue)), min(min(allRats.grandNSzpoxpurple)));
 allRats.topMeanallNSpox = max(max(max(allRats.grandNSzpoxblue)), max(max(allRats.grandNSzpoxpurple)));


%Establish a shared bottom and top for shared color axis of DS & NS means
    if ~isnan(allRats.bottomMeanallNSpox) %if there is an NS
        allRats.bottomMeanallSharedpox= min(allRats.bottomMeanallDSpox, allRats.bottomMeanallNSpox); %find the absolute min value
        allRats.topMeanallSharedpox= max(allRats.topMeanallDSpox, allRats.topMeanallNSpox); %find the absolute min value
    else
        allRats.bottomMeanallSharedpox= allRats.bottomMeanallDSpox;
        allRats.topMeanallSharedpox= allRats.topMeanallDSpox;
    end
    
 %get list of session days for heatplot y axis
%  for day= 1:size(allRats.grandDSzblue,1)   
%     allRats.subjTrialDS(day,1)= day;
%  end

    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

 
%get list of NS session days for heatplot y axis
% need to loop through all subjects and sessions, find unique trials with NS data
allRats.subjTrialNSpox=[];
 for subj = 1:numel(subjectsAnalyzed)

    currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing
    for session = 1:numel(currentSubj) %for each training session this subject completed
        if ~isempty(currentSubj(session).periNSpox.NSselected) %if there's an NS trial in this session, add it to the array that will mark the y axis
%              allRats.subjTrialNS= cat(2, allRats.subjTrialNS, currentSubj(session).trainDay);
%              disp(currentSubj(session).trainDay);
        end
    end %end session loop
     
     
 end %end subj loop
   
%get only unique elements of subjTrialNS
% allRats.subjTrialNS= unique(allRats.subjTrialNS);

% HEATPLOT

 %DS z plot
    figure(figureCount);
    figureCount=figureCount+1;
    hold on;
    subplot(2,2,1); %subplot for shared colorbar

    %plot blue DS

    timeLock = [-preCueFrames:postCueFrames]/fs;% [-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMeanallpox= imagesc(timeLock,subjTrial,allRats.grandDSzpoxblue);
    title(' All rats avg blue z score response to DS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallSharedpox allRats.topMeanallSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMeanallpox= imagesc(timeLock,subjTrial,allRats.grandDSzpoxpurple); 

    title(' All rats avg purple z score response to DS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 

    caxis manual;
    caxis([allRats.bottomMeanallSharedpox allRats.topMeanallSharedpox]); %use a shared color axis to encompass all values
    
%     %% TODO: try linspace with caxis

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    %         figure(figureCount-1); %subplotting on the same figure as the DS heatplots
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-preCueFrames:postCueFrames]/fs;%[-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMeanallpox= imagesc(timeLock,subjTrial,allRats.grandNSzpoxblue, 'AlphaData', ~isnan(allRats.grandNSzpoxpurple));
    title(' All rats avg blue z score response to NS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallSharedpox allRats.topMeanallSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMean= imagesc(timeLock,subjTrial,allRats.grandNSzpoxpurple, 'AlphaData', ~isnan(allRats.grandNSzpoxpurple)); 

    title(' All rats avg purple z score response to NS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 
    caxis manual;
    caxis([allRats.bottomMeanallSharedpox allRats.topMeanallSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize'));%make the figure full screen before saving
    
    saveas(gcf, strcat(figPath, 'allrats', '_', 'avgbyTrainDay', '_periPEZ_avg','.fig')); %save the current figure in fig format
    
%% HEAT PLOT OF RESPONSE TO FIRST PE IN CUE EPOCH

%Here, we'll make a figure for each subject with 4 subplots- blue z score
%response to DS firstPox, blue z score response to NS firstPox, purple z score response to
%DS firstPox, purple z score response to NS firstPox.

%we'll pull from the subjDataAnalyzed struct to make our heatplots 

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
    for session = 1:numel(currentSubj) %for each training session this subject completed
        
        %collect all z score responses to every single DSfirstPox across all sessions
        if session==1 %for first session, initialize 
            currentSubj(1).DSzpoxblueAllTrials= squeeze(currentSubj(session).periDSpox.DSzpoxblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubj(1).DSzpoxpurpleAllTrials= squeeze(currentSubj(session).periDSpox.DSzpoxpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            
            currentSubj(1).NSzpoxblueAllTrials= squeeze(currentSubj(session).periNSpox.NSzpoxblue); 
            currentSubj(1).NSzpoxpurpleAllTrials= squeeze(currentSubj(session).periNSpox.NSzpoxpurple);
        else %add subsequent sessions using cat()
            currentSubj(1).DSzpoxblueAllTrials = cat(2, currentSubj.DSzpoxblueAllTrials, (squeeze(currentSubj(session).periDSpox.DSzpoxblue))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzpoxpurpleAllTrials = cat(2, currentSubj.DSzpoxpurpleAllTrials, (squeeze(currentSubj(session).periDSpox.DSzpoxpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
        
            currentSubj(1).NSzpoxblueAllTrials = cat(2, currentSubj.NSzpoxblueAllTrials, (squeeze(currentSubj(session).periNSpox.NSzpoxblue))); 
            currentSubj(1).NSzpoxpurpleAllTrials = cat(2, currentSubj.NSzpoxpurpleAllTrials, (squeeze(currentSubj(session).periNSpox.NSzpoxpurple))); 
        end
        
    end %end session loop
    
    %Transpose these data for readability
    currentSubj(1).DSzpoxblueAllTrials= currentSubj(1).DSzpoxblueAllTrials';
    currentSubj(1).DSzpoxpurpleAllTrials= currentSubj(1).DSzpoxpurpleAllTrials';    
    currentSubj(1).NSzpoxblueAllTrials= currentSubj(1).NSzpoxblueAllTrials';
    currentSubj(1).NSzpoxpurpleAllTrials= currentSubj(1).NSzpoxpurpleAllTrials';
      
    
    %remove nan trials (NSzpox arrays retain nan values bc of the 3d structure)
    currentSubj(1).NSzpoxblueAllTrials= currentSubj(1).NSzpoxblueAllTrials(all(~isnan(currentSubj(1).NSzpoxblueAllTrials),2),:); 
    currentSubj(1).NSzpoxpurpleAllTrials= currentSubj(1).NSzpoxpurpleAllTrials(all(~isnan(currentSubj(1).NSzpoxpurpleAllTrials),2),:); 

    
    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzpoxblueAllTrials,1); 
    currentSubj(1).totalNScount= 1:size(currentSubj(1).NSzpoxblueAllTrials,1);
    
    
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
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(mean((std(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(mean((std(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(mean((std(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %if there is an NS
        bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
        topAllShared= max(topAllDS, topAllNS); %find the absolute min value
    else
        bottomAllShared= bottomAllDS;
        topAllShared= topAllDS;
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.totalDScount= currentSubj(1).totalDScount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.bottomAllShared= bottomAllShared;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.topAllShared= topAllShared;
    
    %Heatplots!  
    
    %DS z plot
    figure(figureCount);
    hold on;
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where PE onset =0
    
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzpoxblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpoxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first PE in DS epoch')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding DS');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpoxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpoxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first PE in DS epoch')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding DS');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

   %saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzpoxblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpoxblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding first PE in NS epoch ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from PE');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding NS');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpoxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpoxpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first PE in NS epoch ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from PE ');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding NS');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

        saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_perifirstPoxZ_AllTrials','.fig')); %save the current figure in fig format
    end
    
    
    figureCount= figureCount+1;
end %end subject loop


%% LATENCY SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

 
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
     
     topDSzpoxblue= stdFactor*abs(mean((std(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpoxpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzpoxblue = -stdFactor*abs(mean((std(currentSubj(1).DSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpoxpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpoxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSpox= min(bottomDSzpoxblue, bottomDSzpoxpurple);
     topAllDSpox= max(topDSzpoxblue, topDSzpoxpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %only run this if there's NS data
        topNSzpoxblue= stdFactor*abs(mean((std(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpoxpurple= stdFactor*abs(mean((std(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzpoxblue= -stdFactor*abs(mean((std(currentSubj(1).NSzpoxblueAllTrials, 0, 2))));
        bottomNSzpoxpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzpoxpurpleAllTrials, 0, 2))));

        bottomAllNSpox= min(bottomNSzpoxblue, bottomNSzpoxpurple);
        topAllNSpox= max(topNSzpoxblue, topNSzpoxpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %if there is an NS
        bottomAllSharedpox= 2/3*(min(bottomAllDSpox, bottomAllNSpox)); %find the absolute min value
        topAllSharedpox= 2/3*(max(topAllDSpox, topAllNSpox)); %find the absolute min value
    else
        bottomAllSharedpox= 2/3*(bottomAllDSpox);
        topAllSharedpox= 2/3*(topAllDSpox);
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.totalDSpoxcount= currentSubj(1).totalDSpoxcount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.bottomAllSharedpox= bottomAllSharedpox;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSpox.topAllSharedpox= topAllSharedpox;
    
    %Heatplots!  
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %DS z plot
    figure(figureCount);
    hold on;
    
   
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzblueAllTrialspox= imagesc(timeLock,currentSubj(1).totalDSpoxcount,currentSubj(1).DSzpoxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSpoxcount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrialspox= imagesc(timeLock,currentSubj(1).totalDSpoxcount,currentSubj(1).DSzpoxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from PE');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSpoxcount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzpoxblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzblueAllTrialspox= imagesc(timeLock,currentSubj(1).totalNSpoxcount,currentSubj(1).NSzpoxblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from PE');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSpoxcount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpurpleAllTrialspox= imagesc(timeLock,currentSubj(1).totalNSpoxcount,currentSubj(1).NSzpoxpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from PE');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSpoxcount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllSharedpox topAllSharedpox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    end   
    
   
    %Overlay scatter of Cue onset
   subplot(2,2,1) %DS blue
   hold on
   scatter(-DSpoxpeLatencySorted,currentSubj(1).totalDSpoxcount', 'k.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(-DSpoxpeLatencySorted,currentSubj(1).totalDSpoxcount', 'k.');
   
   if ~isempty(currentSubj(1).NSzpoxblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSpoxpeLatencySorted,currentSubj(1).totalNSpoxcount', 'k.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSpoxpeLatencySorted,currentSubj(1).totalNSpoxcount', 'k.');
   end
 saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periPEZ_AllTrials_latencysorted','.fig')); %save the current figure in fig format
    figureCount= figureCount+1;
   
end %end subject loop

