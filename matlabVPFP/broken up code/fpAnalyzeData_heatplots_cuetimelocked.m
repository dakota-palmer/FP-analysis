%% ~~~Heat plots ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

%% HEAT PLOT OF AVG RESPONSE TO CUE (by session)

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
    
    timeLock= [-periCueFrames:periCueFrames]/fs;
    
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
                currentSubj(end).periDS.DSzblueMean= NaN(size(timeLock'));
                currentSubj(end).periDS.DSzpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNS.NSzblueMean= NaN(size(timeLock'));
                currentSubj(end).periNS.NSzpurpleMean= NaN(size(timeLock'));

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

    
    %now get the actual photometry data
    for session = 1:numel(currentSubj) %for each training session this subject completed       
            if session ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzblueSessionMean= currentSubj(session).periDS.DSzblueMean; 
                        currentSubj(1).DSzpurpleSessionMean= currentSubj(session).periDS.DSzpurpleMean;
                else % add on periDS response for subsequent sessions
                        currentSubj(1).DSzblueSessionMean= cat(2, currentSubj(1).DSzblueSessionMean, currentSubj(session).periDS.DSzblueMean);
                        currentSubj(1).DSzpurpleSessionMean= cat(2, currentSubj(1).DSzpurpleSessionMean, currentSubj(session).periDS.DSzpurpleMean);
            end
    end %end session loop
 
    
    %Transpose for readability
    currentSubj(1).DSzblueSessionMean= currentSubj(1).DSzblueSessionMean';
    currentSubj(1).DSzpurpleSessionMean= currentSubj(1).DSzpurpleSessionMean';

    %get list of session days for heatplot y axis (transposed for readability)
%     subjTrial= cat(2, currentSubj.trainDay).'; %this is only training days for this subj
    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

    %NS- extract data for plots
    %session axis (Y) is handled a bit differently because we only want to show sessions that have NS cues
    
    %photometry signals sorted by trial, timelocked to NS
    
    for session = 1:numel(currentSubj) %for each training session this subject completed
        %if there's no NS data, fill with NaNs first
        if isempty(currentSubj(session).periNS.NSzblueMean)
            currentSubj(session).periNS.NSzblueMean= NaN(size(timeLock'));
            currentSubj(session).periNS.NSzpurpleMean= NaN(size(timeLock'));
        end
        
        if session ==1 %for the first session, get this sessions periDS blue z score response
                currentSubj(1).NSzblueSessionMean= currentSubj(session).periNS.NSzblueMean; 
                currentSubj(1).NSzpurpleSessionMean= currentSubj(session).periNS.NSzpurpleMean;
        else % add on periDS response for subsequent sessions
                currentSubj(1).NSzblueSessionMean= cat(2, currentSubj(1).NSzblueSessionMean, currentSubj(session).periNS.NSzblueMean);
                currentSubj(1).NSzpurpleSessionMean= cat(2, currentSubj(1).NSzpurpleSessionMean, currentSubj(session).periNS.NSzpurpleMean);
        end

    end %end session loop
    
    
    %Transpose for readability
    currentSubj(1).NSzblueSessionMean= currentSubj(1).NSzblueSessionMean';
    currentSubj(1).NSzpurpleSessionMean= currentSubj(1).NSzpurpleSessionMean';
   
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
     
     topDSzblue= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleSessionMean, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzblueSessionMean) %only run this if there's NS data
        topNSzblue= stdFactor*abs(nanmean((std(currentSubj(1).NSzblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(nanmean((std(currentSubj(1).NSzblueSessionMean, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleSessionMean, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzblueSessionMean) %if there is an NS
        bottomMeanShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
        topMeanShared= max(topAllDS, topAllNS); %find the absolute min value
    else
        bottomMeanShared= bottomAllDS;
        topMeanShared= topAllDS;
    end
    
    
    %Heatplots!       
    %DS z plot
    figure(figureCount);
    hold on;
    subplot(2,2,1); %subplot for shared colorbar

    %plot blue DS

    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMean= imagesc(timeLock,subjTrial,currentSubj(1).DSzblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).DSzblueSessionMean));
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg blue z score response surrounding DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMean= imagesc(timeLock,subjTrial,currentSubj(1).DSzpurpleSessionMean,  'AlphaData', ~isnan(currentSubj(1).DSzpurpleSessionMean)); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg purple z score response surrounding DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values
    

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMean= imagesc(timeLock,subjTrial,currentSubj(1).NSzblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzblueSessionMean));
    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), 'avg blue z score response to NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMean= imagesc(timeLock,subjTrial,currentSubj(1).NSzpurpleSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzpurpleSessionMean)); 

    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), ' avg purple z score response to NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanShared topMeanShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZSessionAvg','.fig')); %save the current figure in fig format
    figureCount=figureCount+1; %iterate the figure count


end %end subject loop
%% BETWEEN SUBJECTS HEATPLOTS- Avg response to cue (by session)
 
 %gathering all mean data from time window around cue 
 
 
 for subj= 1:numel(subjectsAnalyzed) %for each subject
     
     currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
 
     %we'll want to organize these by common date instead of relative
     %training day as well
     
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
                currentSubj(end).periDS.DSzblueMean= NaN(size(timeLock'));
                currentSubj(end).periDS.DSzpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNS.NSzblueMean= NaN(size(timeLock'));
                currentSubj(end).periNS.NSzpurpleMean= NaN(size(timeLock'));
                
                currentSubj(end).periNS.NS= nan;

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

     
     
     NStrialCount= 1; %counter for ns sessions
     
     %now get the actual photometry data
     
     for session = 1:numel(currentSubj) %for each session this subject completed

         allRats.meanDSzblue(:,session,subj)= currentSubj(session).periDS.DSzblueMean;
         allRats.meanDSzpurple(:,session,subj)= currentSubj(session).periDS.DSzpurpleMean;

         if isempty(currentSubj(session).periNS.NS) %if there's no NS data, fill with NaNs
            currentSubj(session).periNS.NSzblueMean= NaN(size(timeLock'));
            currentSubj(session).periNS.NSzpurpleMean=  NaN(size(timeLock'));
         end
         
         allRats.meanNSzblue(:,session,subj)= currentSubj(session).periNS.NSzblueMean;
         allRats.meanNSzpurple(:,session,subj)= currentSubj(session).periNS.NSzpurpleMean;
         
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
allRats.grandDSzblue=nanmean(allRats.meanDSzblue(:,1:26,1:numel(subjectsAnalyzed)),3)'; %(:,:,1:4),3)' % doing 1:4 in 3rd dmension because rat8 is a GFP animal but need to find more robust way to do this
allRats.grandDSzpurple=nanmean(allRats.meanDSzpurple(:,1:26,1:numel(subjectsAnalyzed)),3)'; %1:4),3)'
allRats.grandNSzblue=nanmean(allRats.meanNSzblue(:,1:26,1:numel(subjectsAnalyzed)),3)';%'; %1:4),3)'
allRats.grandNSzpurple=nanmean(allRats.meanNSzpurple(:,1:26,1:numel(subjectsAnalyzed)),3)'; %,1:4),3)'

 %get bottom and top for color axis of DS heatplot
 allRats.bottomMeanallDS = min(min(min(allRats.grandDSzblue)), min(min(allRats.grandDSzpurple))); %find the lowest value 
 allRats.topMeanallDS = max(max(max(allRats.grandDSzblue)), max(max(allRats.grandDSzpurple))); %find the highest value

 %get bottom and top for color axis of NS heatplot
 allRats.bottomMeanallNS = min(min(min(allRats.grandNSzblue)), min(min(allRats.grandNSzpurple)));
 allRats.topMeanallNS = max(max(max(allRats.grandNSzblue)), max(max(allRats.grandNSzpurple)));


%Establish a shared bottom and top for shared color axis of DS & NS means
    if ~isnan(allRats.bottomMeanallNS) %if there is an NS
        allRats.bottomMeanallShared= min(allRats.bottomMeanallDS, allRats.bottomMeanallNS); %find the absolute min value
        allRats.topMeanallShared= max(allRats.topMeanallDS, allRats.topMeanallNS); %find the absolute min value
    else
        allRats.bottomMeanallShared= allRats.bottomMeanallDS;
        allRats.topMeanallShared= allRats.topMeanallDS;
    end
    
 %get list of session days for heatplot y axis
%  for day= 1:size(allRats.grandDSzblue,1)   
%     allRats.subjTrialDS(day,1)= day;
%  end

    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

 
%get list of NS session days for heatplot y axis
% need to loop through all subjects and sessions, find unique trials with NS data
allRats.subjTrialNS=[];
 for subj = 1:numel(subjectsAnalyzed)

    currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing
    for session = 1:numel(currentSubj) %for each training session this subject completed
        if ~isempty(currentSubj(session).periNS.NS) %if there's an NS trial in this session, add it to the array that will mark the y axis
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

    timeLock = [-periCueFrames:periCueFrames]/fs;% [-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMeanall= imagesc(timeLock,subjTrial,allRats.grandDSzblue);
    title(' All rats avg blue z score response to DS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallShared allRats.topMeanallShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMeanall= imagesc(timeLock,subjTrial,allRats.grandDSzpurple); 

    title(' All rats avg purple z score response to DS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 

    caxis manual;
    caxis([allRats.bottomMeanallShared allRats.topMeanallShared]); %use a shared color axis to encompass all values
    
%     %% TODO: try linspace with caxis

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    %         figure(figureCount-1); %subplotting on the same figure as the DS heatplots
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-periCueFrames:periCueFrames]/fs;%[-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMeanall= imagesc(timeLock,subjTrial,allRats.grandNSzblue, 'AlphaData', ~isnan(allRats.grandNSzpurple));
    title(' All rats avg blue z score response to NS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallShared allRats.topMeanallShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMean= imagesc(timeLock,subjTrial,allRats.grandNSzpurple, 'AlphaData', ~isnan(allRats.grandNSzpurple)); 

    title(' All rats avg purple z score response to NS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 
    caxis manual;
    caxis([allRats.bottomMeanallShared allRats.topMeanallShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize'));%make the figure full screen before saving
    
    saveas(gcf, strcat(figPath, 'allrats', '_', 'avgbyTrainDay', '_periCueZ_avg','.fig')); %save the current figure in fig format
    
%% HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION- sorted by trial 

%Here, we'll make a figure for each subject with 4 subplots- blue z score
%response to DS, blue z score response to NS, purple z score response to
%DS, purple z score response to NS.

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
    sesCount= 1; %counter to keep track of sessions that meet a condition (e.g. if you only want to look at stage 5 sessions
    for session = 1:numel(currentSubj) %for each training session this subject completed
%         if currentSubj(session).trainStage == 5
%         if currentSubj(session).trainStage== 1 || currentSubj(session).trainStage ==2 || currentSubj(session).trainStage==3
        %collect all z score responses to every single DS across all sessions
            if sesCount==1 %for first session, initialize 
                currentSubj(1).DSzblueAllTrials= squeeze(currentSubj(session).periDS.DSzblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
                currentSubj(1).DSzpurpleAllTrials= squeeze(currentSubj(session).periDS.DSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

                currentSubj(1).NSzblueAllTrials= squeeze(currentSubj(session).periNS.NSzblue); 
                currentSubj(1).NSzpurpleAllTrials= squeeze(currentSubj(session).periNS.NSzpurple);
            else %add subsequent sessions using cat()
                currentSubj(1).DSzblueAllTrials = cat(2, currentSubj.DSzblueAllTrials, (squeeze(currentSubj(session).periDS.DSzblue))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
                currentSubj(1).DSzpurpleAllTrials = cat(2, currentSubj.DSzpurpleAllTrials, (squeeze(currentSubj(session).periDS.DSzpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)

                currentSubj(1).NSzblueAllTrials = cat(2, currentSubj.NSzblueAllTrials, (squeeze(currentSubj(session).periNS.NSzblue))); 
                currentSubj(1).NSzpurpleAllTrials = cat(2, currentSubj.NSzpurpleAllTrials, (squeeze(currentSubj(session).periNS.NSzpurple))); 

%             end
            sesCount=sesCount+1   

        end
    end %end session loop
    
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
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
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
    
    heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding every DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding every DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding every NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding every NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

        saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format
    end
    
%      %overlay plot of transitions between training stages - TODO: this
%      %stopped working after stage 6 I think
%     transitionCue= [];
%     transitionDay=[];
%     
%     cueCount = 1;
%     
%     stageCount= 1;
%     
%     for session= 1:numel(currentSubj)
%        
%        if session ==1 
%            trainStage = currentSubj(session).trainStage;
%        end
%         
%        if currentSubj(session).trainStage ~= trainStage
%            %if the trainStage changes, save this day as a transision
%            trainStage = currentSubj(session).trainStage;
%            
%            %iterate stageCount
%            stageCount=stageCount+1
%            transitionDay(stageCount) = currentSubj(session).trainDay;
%            
% %            disp(strcat('transition day ', num2str(transitionDay(session))));
%            
%            %since we are plotting individual trials and not days, 
%            %find the cue corresponding to the transition
%            %to do so,loop over all cues in the session, finding the
%            %matching saved to DSzblueAllTrials
%            for cue = 1:numel(currentSubj(session).periDS.DS) %for each cue in this session
%                 cueCount=cueCount+1;                                
%                 if find(currentSubj(1).DSzblueAllTrials'==currentSubj(session).periDS.DSzblue(:,:,cue),1)% currentSubj(1).DSzblueAllTrials(cue,:)' == currentSubj(session).periDS.DSzblue(:,:,cue)
%                     
% %                     [~, cueInd] =  find(currentSubj(1).DSzblueAllTrials'==currentSubj(session).periDS.DSzblue(:,:,cue),1);
%                     transitionCue(stageCount)= cueCount;
%                 end
%            end
% %            disp(strcat('transition Cue', num2str(transitionCue(session))))
%        end %end stage transition conditional
%     end %end session loop
%  
%     
%     for i= 1:numel(transitionCue)
%         if transitionCue(i) ~= 0
%             subplot(2,2,1) %DS blue
%             hold on;
%             plot([timeLock(1), timeLock(end)], [transitionCue(i), transitionCue(i)], 'k--')  
%             
%             subplot(2,2,3) %DS puprle
%             hold on;
%             plot([timeLock(1), timeLock(end)], [transitionCue(i), transitionCue(i)], 'k--')
%             
%         end
%     end
%        
    figureCount= figureCount+1;
end %end subject loop


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
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(mean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));

        bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
        topAllNS= max(topNSzblue, topNSzpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
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
    
    heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from cue onset');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    end   
    
   
    %Overlay scatter of PE latency
   subplot(2,2,1) %DS blue
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
   
   if ~isempty(currentSubj(1).NSzblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(NSpeLatencySorted,currentSubj(1).totalNScount', 'm.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(NSpeLatencySorted,currentSubj(1).totalNScount', 'm.');
   end
 saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format
    figureCount= figureCount+1;
   
end %end subject loop

