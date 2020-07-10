%% ~~~Heat plots (first-lick time locked) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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


%% HEAT PLOT OF AVG RESPONSE TO FIRST LICK IN TRIAL(by session)

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
                currentSubj(end).periDSpox.DSzloxblueMean= NaN(size(timeLock'));
                currentSubj(end).periDSpox.DSzloxpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzloxblueMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzloxpurpleMean= NaN(size(timeLock'));

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

    
    %now get the actual photometry data
    for session = 1:numel(currentSubj) %for each training session this subject completed       
            if session ==1 %for the first session, get this sessions periDS blue z score response
                        currentSubj(1).DSzloxblueSessionMean= currentSubj(session).periDSlox.DSzloxblueMean; 
                        currentSubj(1).DSzloxpurpleSessionMean= currentSubj(session).periDSlox.DSzloxpurpleMean;
            elseif ~isnan(currentSubj(session).rat) % add on periDS response for subsequent sessions
                        currentSubj(1).DSzloxblueSessionMean= cat(2, currentSubj(1).DSzloxblueSessionMean, currentSubj(session).periDSlox.DSzloxblueMean);
                        currentSubj(1).DSzloxpurpleSessionMean= cat(2, currentSubj(1).DSzloxpurpleSessionMean, currentSubj(session).periDSlox.DSzloxpurpleMean);
            end
    end %end session loop
 
    
    %Transpose for readability
    currentSubj(1).DSzloxblueSessionMean= currentSubj(1).DSzloxblueSessionMean';
    currentSubj(1).DSzloxpurpleSessionMean= currentSubj(1).DSzloxpurpleSessionMean';

    %get list of session days for heatplot y axis (transposed for readability)
%     subjTrial= cat(2, currentSubj.trainDay).'; %this is only training days for this subj
    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

    %NS- extract data for plots
    %session axis (Y) is handled a bit differently because we only want to show sessions that have NS cues
    
    %photometry signals sorted by trial, timelocked to NS
    
    for session = 1:numel(currentSubj) %for each training session this subject completed
        %if there's no NS data, fill with NaNs first
        if ~isnan(currentSubj(session).rat);
        if isempty(currentSubj(session).periNSlox.NSzloxblueMean)
            currentSubj(session).periNSlox.NSzloxblueMean= NaN(size(timeLock'));
            currentSubj(session).periNSlox.NSzloxpurpleMean= NaN(size(timeLock'));
        end
        end
        if session ==1 %for the first session, get this sessions periDS blue z score response
                currentSubj(1).NSzloxblueSessionMean= currentSubj(session).periNSlox.NSzloxblueMean; 
                currentSubj(1).NSzloxpurpleSessionMean= currentSubj(session).periNSlox.NSzloxpurpleMean;
        elseif ~isnan(currentSubj(session).rat) % add on periDS response for subsequent sessions
                currentSubj(1).NSzloxblueSessionMean= cat(2, currentSubj(1).NSzloxblueSessionMean, currentSubj(session).periNSlox.NSzloxblueMean);
                currentSubj(1).NSzloxpurpleSessionMean= cat(2, currentSubj(1).NSzloxpurpleSessionMean, currentSubj(session).periNSlox.NSzloxpurpleMean);
        end

    end %end session loop
    
    
    %Transpose for readability
    currentSubj(1).NSzloxblueSessionMean= currentSubj(1).NSzloxblueSessionMean';
    currentSubj(1).NSzloxpurpleSessionMean= currentSubj(1).NSzloxpurpleSessionMean';
   
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
     
     topDSzbluelox= stdFactor*abs(nanmean((std(currentSubj(1).DSzloxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurplelox= stdFactor*abs(nanmean((std(currentSubj(1).DSzloxpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzbluelox = -stdFactor*abs(nanmean((std(currentSubj(1).DSzloxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurplelox= -stdFactor*abs(nanmean((std(currentSubj(1).DSzloxpurpleSessionMean, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSlox= min(bottomDSzbluelox, bottomDSzpurplelox);
     topAllDSlox= max(topDSzbluelox, topDSzpurplelox);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzloxblueSessionMean) %only run this if there's NS data
        topNSzloxblue= stdFactor*abs(nanmean((std(currentSubj(1).NSzloxblueSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzloxpurple= stdFactor*abs(nanmean((std(currentSubj(1).NSzloxpurpleSessionMean, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzloxblue= -stdFactor*abs(nanmean((std(currentSubj(1).NSzloxblueSessionMean, 0, 2))));
        bottomNSzloxpurple= -stdFactor*abs(nanmean((std(currentSubj(1).NSzloxpurpleSessionMean, 0, 2))));

        bottomAllNSlox= min(bottomNSzloxblue, bottomNSzloxpurple);
        topAllNSlox= max(topNSzloxblue, topNSzloxpurple);
    end
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzloxblueSessionMean) %if there is an NS
        bottomMeanSharedlox= min(bottomAllDSlox, bottomAllNSlox); %find the absolute min value
        topMeanSharedlox= max(topAllDSlox, topAllNSlox); %find the absolute min value
    else
        bottomMeanSharedlox= bottomAllDSlox;
        topMeanSharedlox= topAllDSlox;
    end
    
    
    %Heatplots!       
    %DS z plot
    figure(figureCount);
    hold on;
    subplot(2,2,1); %subplot for shared colorbar

    %plot blue DS

    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMeanlox= imagesc(timeLock,subjTrial,currentSubj(1).DSzloxblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).DSzloxblueSessionMean));
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg blue z score response surrounding DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanSharedlox topMeanSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMeanlox= imagesc(timeLock,subjTrial,currentSubj(1).DSzloxpurpleSessionMean,  'AlphaData', ~isnan(currentSubj(1).DSzloxpurpleSessionMean)); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' daily avg purple z score response surrounding DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanSharedlox topMeanSharedlox]); %use a shared color axis to encompass all values
    

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMeanlox= imagesc(timeLock,subjTrial,currentSubj(1).NSzloxblueSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzloxblueSessionMean));
    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), 'avg blue z score response to NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomMeanSharedlox topMeanSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMeanlox= imagesc(timeLock,subjTrial,currentSubj(1).NSzloxpurpleSessionMean, 'AlphaData', ~isnan(currentSubj(1).NSzloxpurpleSessionMean)); 

    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), ' avg purple z score response to NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomMeanSharedlox topMeanSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periLOXZSessionAvg','.fig')); %save the current figure in fig format
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
                currentSubj(end).periDSpox.DSzloxblueMean= NaN(size(timeLock'));
                currentSubj(end).periDSpox.DSzloxpurpleMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzloxblueMean= NaN(size(timeLock'));
                currentSubj(end).periNSpox.NSzloxpurpleMean= NaN(size(timeLock'));
                
                currentSubj(end).periNSlox.NSselected= nan;

        end
    end
    
    %now let's resort the struct with empty sessions by date
     subjTable = struct2table(currentSubj); % convert the struct array to a table
     subjTableSorted = sortrows(subjTable, 'date'); % sort the table by 'date'
     currentSubj = table2struct(subjTableSorted); %convert back to struct

     
     
     NStrialCount= 1; %counter for ns sessions
     
     %now get the actual photometry data
     
     for session = 1:numel(currentSubj) %for each session this subject completed
     if ~isnan(currentSubj(session).rat)% adding this conditional for sessions where rat was not in box
         allRats.meanDSzloxblue(:,session,subj)= currentSubj(session).periDSlox.DSzloxblueMean;
         allRats.meanDSzloxpurple(:,session,subj)= currentSubj(session).periDSlox.DSzloxpurpleMean;
     end
         if isempty(currentSubj(session).periNSlox.NSselected) %if there's no NS data, fill with NaNs
            currentSubj(session).periNSlox.NSzloxblueMean= NaN(size(timeLock'));
            currentSubj(session).periNSlox.NSzloxpurpleMean=  NaN(size(timeLock'));
         end
         
         if ~isnan(currentSubj(session).rat)% adding this conditional for sessions where rat was not in box
         allRats.meanNSzloxblue(:,session,subj)= currentSubj(session).periNSlox.NSzloxblueMean;
         allRats.meanNSzloxpurple(:,session,subj)= currentSubj(session).periNSlox.NSzloxpurpleMean;
         end 
         
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
allRats.grandDSzloxblue=nanmean(allRats.meanDSzloxblue(:,:,1:numel(subjectsAnalyzed)),3)'; %(:,:,1:4),3)' % doing 1:4 in 3rd dmension because rat8 is a GFP animal but need to find more robust way to do this
allRats.grandDSzloxpurple=nanmean(allRats.meanDSzloxpurple(:,:,1:numel(subjectsAnalyzed)),3)'; %1:4),3)'
allRats.grandNSzloxblue=nanmean(allRats.meanNSzloxblue(:,:,1:numel(subjectsAnalyzed)),3)';%'; %1:4),3)'
allRats.grandNSzloxpurple=nanmean(allRats.meanNSzloxpurple(:,:,1:numel(subjectsAnalyzed)),3)'; %,1:4),3)'

 %get bottom and top for color axis of DS heatplot
 allRats.bottomMeanallDSlox = min(min(min(allRats.grandDSzloxblue)), min(min(allRats.grandDSzloxpurple))); %find the lowest value 
 allRats.topMeanallDSlox = max(max(max(allRats.grandDSzloxblue)), max(max(allRats.grandDSzloxpurple))); %find the highest value

 %get bottom and top for color axis of NS heatplot
 allRats.bottomMeanallNSlox = min(min(min(allRats.grandNSzloxblue)), min(min(allRats.grandNSzloxpurple)));
 allRats.topMeanallNSlox = max(max(max(allRats.grandNSzloxblue)), max(max(allRats.grandNSzloxpurple)));


%Establish a shared bottom and top for shared color axis of DS & NS means
    if ~isnan(allRats.bottomMeanallNSlox) %if there is an NS
        allRats.bottomMeanallSharedlox= min(allRats.bottomMeanallDSlox, allRats.bottomMeanallNSlox); %find the absolute min value
        allRats.topMeanallSharedlox= max(allRats.topMeanallDSlox, allRats.topMeanallNSlox); %find the absolute min value
    else
        allRats.bottomMeanallSharedlox= allRats.bottomMeanallDSlox;
        allRats.topMeanallSharedlox= allRats.topMeanallDSlox;
    end
    
 %get list of session days for heatplot y axis
%  for day= 1:size(allRats.grandDSzblue,1)   
%     allRats.subjTrialDS(day,1)= day;
%  end

    subjTrial= 1:numel(allDates); %let's just number each training day starting at 1

 
%get list of NS session days for heatplot y axis
% need to loop through all subjects and sessions, find unique trials with NS data
allRats.subjTrialNSlox=[];
 for subj = 1:numel(subjectsAnalyzed)

    currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing
    for session = 1:numel(currentSubj) %for each training session this subject completed
        if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's an NS trial in this session, add it to the array that will mark the y axis
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

    timeLock =[-preCueFrames:postCueFrames]/fs;% [-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblueMeanalllox= imagesc(timeLock,subjTrial,allRats.grandDSzloxblue);
    title(' All rats avg blue z score response to Frist Lick after DS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallSharedlox allRats.topMeanallSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleMeanalllox= imagesc(timeLock,subjTrial,allRats.grandDSzloxpurple); 

    title(' All rats avg purple z score response to First Lick after DS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 

    caxis manual;
    caxis([allRats.bottomMeanallSharedlox allRats.topMeanallSharedlox]); %use a shared color axis to encompass all values
    
%     %% TODO: try linspace with caxis

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    %         figure(figureCount-1); %subplotting on the same figure as the DS heatplots
    hold on;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-preCueFrames:postCueFrames]/fs;%[-periDSFrames:periDSFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblueMeanalllox= imagesc(timeLock,subjTrial,allRats.grandNSzloxblue, 'AlphaData', ~isnan(allRats.grandNSzloxpurple));
    title(' All rats avg blue z score response to First Lick after NS '); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([allRats.bottomMeanallSharedlox allRats.topMeanallSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurpleMeanalllox= imagesc(timeLock,subjTrial,allRats.grandNSzloxpurple, 'AlphaData', ~isnan(allRats.grandNSzloxpurple)); 

    title(' All rats avg purple z score response to First Lick after NS ') %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); 
    caxis manual;
    caxis([allRats.bottomMeanallSharedlox allRats.topMeanallSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize'));%make the figure full screen before saving
    
    saveas(gcf, strcat(figPath, 'allrats', '_', 'avgbyTrainDay', '_periLOXZ_avg','.fig')); %save the current figure in fig format
    
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
      
    
    %remove nan trials 
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials(all(~isnan(currentSubj(1).DSzloxblueAllTrials),2),:); 
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials(all(~isnan(currentSubj(1).DSzloxpurpleAllTrials),2),:); 

    currentSubj(1).NSzloxblueAllTrials= currentSubj(1).NSzloxblueAllTrials(all(~isnan(currentSubj(1).NSzloxblueAllTrials),2),:); 
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials(all(~isnan(currentSubj(1).NSzloxpurpleAllTrials),2),:); 

    
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
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %only run this if there's NS data
        topNSzblue= stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzpurple= stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzblue= -stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));
        bottomNSzpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));

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

        saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_perifirstLOXZ_AllTrials','.fig')); %save the current figure in fig format
    end
    
    
    figureCount= figureCount+1;
end %end subject loop


%% LATENCY SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

 
        %initialize arrays for convenience
        currentSubj(1).NSzloxblueAllTrials= [];
        currentSubj(1).NSzloxpurpleAllTrials= [];
        currentSubj(1).NSloxpeLatencyAllTrials= [];
        currentSubj(1).NSloxrelpoxAllTrials=[]; 
        
    for session = 1:numel(currentSubj) %for each training session this subject completed
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= currentSubj(session).periDSlox.DSselected;  % all the DS cues

        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
        
        
        %lets convert this to an index of trials with a valid value 
        DSselected= find(~isnan(DSselected));
        
            
        %Repeat above for NS 
        if ~isempty(currentSubj(session).periNSlox.NSselected)
             NSselected= currentSubj(session).periNSlox.NSselected;  

            
            %lets convert this to an index of trials with a valid value 
            NSselected= find(~isnan(NSselected));
        end %end NS conditional       
       
        
        
        %collect all z score responses to every single DS across all sessions
        %we'll use DSselected and NSselected as indices to pull only data
        %from trials with port entries
        if session==1 %for first session, initialize 
            
    
            
           currentSubj(1).DSzloxblueAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSzloxpurpleAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSloxpeLatencyAllTrials= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
           currentSubj(1).DSloxrelpoxAllTrials=currentSubj(session).behavior.loxDSpoxRel(DSselected);% utilize time between PE and licks to plot cue on set and PE
           if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                currentSubj(1).NSzloxblueAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                currentSubj(1).NSzloxpurpleAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                currentSubj(1).NSloxpeLatencyAllTrials= currentSubj(session).behavior.NSpeLatency(NSselected);
                currentSubj(1).NSloxrelpoxAllTrials=currentSubj(session).behavior.loxNSpoxRel(NSselected);

           else
               continue %continue if no NS data
           end
        else %add subsequent sessions using cat()
            currentSubj(1).DSzloxblueAllTrials = cat(2, currentSubj.DSzloxblueAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzloxpurpleAllTrials = cat(2, currentSubj.DSzloxpurpleAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSloxpeLatencyAllTrials = cat(2,currentSubj(1).DSloxpeLatencyAllTrials,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
            currentSubj(1).DSloxrelpoxAllTrials=cat(2,currentSubj(1).DSloxrelpoxAllTrials,currentSubj(session).behavior.loxDSpoxRel(DSselected));
            
            
            if ~isempty(currentSubj(session).periNSlox.NSselected)
                currentSubj(1).NSzloxblueAllTrials = cat(2, currentSubj.NSzloxblueAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                currentSubj(1).NSzloxpurpleAllTrials = cat(2, currentSubj.NSzloxpurpleAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                currentSubj(1).NSloxpeLatencyAllTrials = cat(2,currentSubj(1).NSloxpeLatencyAllTrials,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                currentSubj(1).NSloxrelpoxAllTrials=cat(2,currentSubj(1).NSloxrelpoxAllTrials,currentSubj(session).behavior.loxNSpoxRel(NSselected));
            
            else
                continue %continue if nos NS data
            end
        end        
    end %end session loop
    
    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data
    [DSloxpeLatencySorted,DSsortInd] = sort(currentSubj(1).DSloxpeLatencyAllTrials); 

    [NSloxpeLatencySorted,NSsortInd] = sort(currentSubj(1).NSloxpeLatencyAllTrials);
    
    %Sort loxrelpox trials
    currentSubj(1).DSloxrelpoxAllTrials= currentSubj(1).DSloxrelpoxAllTrials(:,DSsortInd);
    currentSubj(1).NSloxrelpoxAllTrials= currentSubj(1).NSloxrelpoxAllTrials(:,NSsortInd);
  
    % get first timestamp of first lick relative to PE for plotting cue
    % onset and PE
    %initialize
    DSloxrelpoxAllTrials=[];
    NSloxrelpoxAllTrials=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrials)
    DSloxrelpoxAllTrials(1,trial)= currentSubj(1).DSloxrelpoxAllTrials{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrials)
    NSloxrelpoxAllTrials(1,trial)=currentSubj(1).NSloxrelpoxAllTrials{1,trial}(1,1);
    end
    
    %Sort all trials by PE latency
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials(:,DSsortInd);
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials(:,DSsortInd);
    currentSubj(1).NSzloxblueAllTrials = currentSubj(1).NSzloxblueAllTrials(:,NSsortInd);
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials(:,NSsortInd);
    
    %Transpose these data for readability
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials';
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials';    
    currentSubj(1).NSzloxblueAllTrials= currentSubj(1).NSzloxblueAllTrials';
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials';

    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDSloxcount= 1:size(currentSubj(1).DSzloxblueAllTrials,1); 
    currentSubj(1).totalNSloxcount= 1:size(currentSubj(1).NSzloxblueAllTrials,1);
    
    
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
     
     topDSzloxblue= stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzloxpurple= stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzloxblue = -stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzloxpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSlox= min(bottomDSzloxblue, bottomDSzloxpurple);
     topAllDSlox= max(topDSzloxblue, topDSzloxpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %only run this if there's NS data
        topNSzloxblue= stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzloxpurple= stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzloxblue= -stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));
        bottomNSzloxpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));

        bottomAllNSlox= min(bottomNSzloxblue, bottomNSzloxpurple);
        topAllNSlox= max(topNSzloxblue, topNSzloxpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is an NS
        bottomAllSharedlox= 2/3*(min(bottomAllDSlox, bottomAllNSlox)); %find the absolute min value
        topAllSharedlox= 2/3*(max(topAllDSlox, topAllNSlox)); %find the absolute min value
    else
        bottomAllSharedlox= 2/3*(bottomAllDSlox);
        topAllSharedlox= 2/3*(topAllDSlox);
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.totalDSloxcount= currentSubj(1).totalDSloxcount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.bottomAllSharedlox= bottomAllSharedlox;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.topAllSharedlox= topAllSharedlox;
    
    %Heatplots!  
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %DS z plot
    figure(figureCount);
    hold on;
    
   
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzblueAllTrialslox= imagesc(timeLock,currentSubj(1).totalDSloxcount,currentSubj(1).DSzloxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSloxcount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrialslox= imagesc(timeLock,currentSubj(1).totalDSloxcount,currentSubj(1).DSzloxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSloxcount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzblueAllTrialslox= imagesc(timeLock,currentSubj(1).totalNSloxcount,currentSubj(1).NSzloxblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from First Lick');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSloxcount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpurpleAllTrialslox= imagesc(timeLock,currentSubj(1).totalNSloxcount,currentSubj(1).NSzloxpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from First Lick');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSloxcount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    end   
    
   
    %Overlay scatter of Cue onset (-Time from Cue to PE + - Time from PE to
    %First Lick)
   subplot(2,2,1) %DS blue
   hold on
   scatter(-DSloxpeLatencySorted-DSloxrelpoxAllTrials,currentSubj(1).totalDSloxcount', 'k.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(-DSloxpeLatencySorted-DSloxrelpoxAllTrials,currentSubj(1).totalDSloxcount', 'k.');
   
   if ~isempty(currentSubj(1).NSzloxblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSloxpeLatencySorted-NSloxrelpoxAllTrials,currentSubj(1).totalNSloxcount', 'k.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSloxpeLatencySorted-NSloxrelpoxAllTrials,currentSubj(1).totalNSloxcount', 'k.');
   end
   
   %Overlay scatter of PE (- Time from PE to First Lick)
   subplot(2,2,1) %DS blue
   hold on
   scatter(-DSloxrelpoxAllTrials,currentSubj(1).totalDSloxcount', 'm.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(-DSloxrelpoxAllTrials,currentSubj(1).totalDSloxcount', 'm.');
   
   if ~isempty(currentSubj(1).NSzloxblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSloxrelpoxAllTrials,currentSubj(1).totalNSloxcount', 'm.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSloxrelpoxAllTrials,currentSubj(1).totalNSloxcount', 'm.');
   end
 saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periLOXZ_AllTrials_latencysorted','.fig')); %save the current figure in fig format
    figureCount= figureCount+1;
   
end %end subject loop


%% POX TO LOX SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency

%we'll pull from the subjDataAnalyzed struct to make our heatplots

for subj= 1:numel(subjectsAnalyzed) %for each subject
currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

 
        %initialize arrays for convenience
        currentSubj(1).NSzloxblueAllTrials= [];
        currentSubj(1).NSzloxpurpleAllTrials= [];
        currentSubj(1).NSloxpeLatencyAllTrials= [];
        currentSubj(1).NSloxrelpoxAllTrials=[]; 
        
    for session = 1:numel(currentSubj) %for each training session this subject completed
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= currentSubj(session).periDSlox.DSselected;  % all the DS cues

        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
        
        
        %lets convert this to an index of trials with a valid value 
        DSselected= find(~isnan(DSselected));
        
            
        %Repeat above for NS 
        if ~isempty(currentSubj(session).periNSlox.NSselected)
             NSselected= currentSubj(session).periNSlox.NSselected;  

            
            %lets convert this to an index of trials with a valid value 
            NSselected= find(~isnan(NSselected));
        end %end NS conditional       
       
        
        
        %collect all z score responses to every single DS across all sessions
        %we'll use DSselected and NSselected as indices to pull only data
        %from trials with port entries
        if session==1 %for first session, initialize 
            
    
            
           currentSubj(1).DSzloxblueAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSzloxpurpleAllTrials= squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
           currentSubj(1).DSloxpeLatencyAllTrials= currentSubj(session).behavior.DSpeLatency(DSselected); %collect all the 1st PE latency values from trials of interest
           currentSubj(1).DSloxrelpoxAllTrials=currentSubj(session).behavior.loxDSpoxRel(DSselected);% utilize time between PE and licks to plot cue on set and PE
           if ~isempty(currentSubj(session).periNSlox.NSselected) %if there's valid NS data
                currentSubj(1).NSzloxblueAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)); 
                currentSubj(1).NSzloxpurpleAllTrials= squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected));
                currentSubj(1).NSloxpeLatencyAllTrials= currentSubj(session).behavior.NSpeLatency(NSselected);
                currentSubj(1).NSloxrelpoxAllTrials=currentSubj(session).behavior.loxNSpoxRel(NSselected);

           else
               continue %continue if no NS data
           end
        else %add subsequent sessions using cat()
            currentSubj(1).DSzloxblueAllTrials = cat(2, currentSubj.DSzloxblueAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxblue(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSzloxpurpleAllTrials = cat(2, currentSubj.DSzloxpurpleAllTrials, (squeeze(currentSubj(session).periDSlox.DSzloxpurple(:,:,DSselected)))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubj(1).DSloxpeLatencyAllTrials = cat(2,currentSubj(1).DSloxpeLatencyAllTrials,currentSubj(session).behavior.DSpeLatency(DSselected)); %collect all of the DSpeLatencies for sorting between sessions
            currentSubj(1).DSloxrelpoxAllTrials=cat(2,currentSubj(1).DSloxrelpoxAllTrials,currentSubj(session).behavior.loxDSpoxRel(DSselected));
            
            
            if ~isempty(currentSubj(session).periNSlox.NSselected)
                currentSubj(1).NSzloxblueAllTrials = cat(2, currentSubj.NSzloxblueAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxblue(:,:,NSselected)))); 
                currentSubj(1).NSzloxpurpleAllTrials = cat(2, currentSubj.NSzloxpurpleAllTrials, (squeeze(currentSubj(session).periNSlox.NSzloxpurple(:,:,NSselected)))); 
                currentSubj(1).NSloxpeLatencyAllTrials = cat(2,currentSubj(1).NSloxpeLatencyAllTrials,currentSubj(session).behavior.NSpeLatency(NSselected)); %collect all of the NSpeLatencies for sorting between sessions
                currentSubj(1).NSloxrelpoxAllTrials=cat(2,currentSubj(1).NSloxrelpoxAllTrials,currentSubj(session).behavior.loxNSpoxRel(NSselected));
            
            else
                continue %continue if nos NS data
            end
        end        
    end %end session loop
    
    
  
    % get first timestamp of first lick relative to PE for plotting cue
    % onset and PE
    %initialize
    DSloxrelpoxAllTrials=[];
    NSloxrelpoxAllTrials=[];
    for trial=1:numel(currentSubj(1).DSloxrelpoxAllTrials)
    DSloxrelpoxAllTrials(1,trial)= currentSubj(1).DSloxrelpoxAllTrials{1,trial}(1,1);
    end
    
    for trial=1:numel(currentSubj(1).NSloxrelpoxAllTrials)
    NSloxrelpoxAllTrials(1,trial)=currentSubj(1).NSloxrelpoxAllTrials{1,trial}(1,1);
    end
    
    %Sort PE to First Lick latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data
    [DSloxrelpoxAllTrialsSorted,DSsortInd] = sort(DSloxrelpoxAllTrials); 

    [NSloxrelpoxAllTrialsSorted,NSsortInd] = sort(NSloxrelpoxAllTrials);
    
    %Sort Cue to PE latencies 
    DSloxpeLatency= currentSubj(1).DSloxpeLatencyAllTrials(:,DSsortInd);
    NSloxpeLatency= currentSubj(1).NSloxpeLatencyAllTrials(:,NSsortInd);
    
    
    %Sort all trials by PE latency
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials(:,DSsortInd);
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials(:,DSsortInd);
    currentSubj(1).NSzloxblueAllTrials = currentSubj(1).NSzloxblueAllTrials(:,NSsortInd);
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials(:,NSsortInd);
    
    %Transpose these data for readability
    currentSubj(1).DSzloxblueAllTrials= currentSubj(1).DSzloxblueAllTrials';
    currentSubj(1).DSzloxpurpleAllTrials= currentSubj(1).DSzloxpurpleAllTrials';    
    currentSubj(1).NSzloxblueAllTrials= currentSubj(1).NSzloxblueAllTrials';
    currentSubj(1).NSzloxpurpleAllTrials= currentSubj(1).NSzloxpurpleAllTrials';

    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDSloxcount= 1:size(currentSubj(1).DSzloxblueAllTrials,1); 
    currentSubj(1).totalNSloxcount= 1:size(currentSubj(1).NSzloxblueAllTrials,1);
    
    
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
     
     topDSzloxblue= stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzloxpurple= stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzloxblue = -stdFactor*abs(mean((std(currentSubj(1).DSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzloxpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzloxpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDSlox= min(bottomDSzloxblue, bottomDSzloxpurple);
     topAllDSlox= max(topDSzloxblue, topDSzloxpurple);
     
    %same, but defining color axes for NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %only run this if there's NS data
        topNSzloxblue= stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
        topNSzloxpurple= stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

        bottomNSzloxblue= -stdFactor*abs(mean((std(currentSubj(1).NSzloxblueAllTrials, 0, 2))));
        bottomNSzloxpurple= -stdFactor*abs(mean((std(currentSubj(1).NSzloxpurpleAllTrials, 0, 2))));

        bottomAllNSlox= min(bottomNSzloxblue, bottomNSzloxpurple);
        topAllNSlox= max(topNSzloxblue, topNSzloxpurple);
    end
    
    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is an NS
        bottomAllSharedlox= 2/3*(min(bottomAllDSlox, bottomAllNSlox)); %find the absolute min value
        topAllSharedlox= 2/3*(max(topAllDSlox, topAllNSlox)); %find the absolute min value
    else
        bottomAllSharedlox= 2/3*(bottomAllDSlox);
        topAllSharedlox= 2/3*(topAllDSlox);
    end
    
    %save for later 
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.totalDSloxcount= currentSubj(1).totalDSloxcount;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.bottomAllSharedlox= bottomAllSharedlox;
    subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDSlox.topAllSharedlox= topAllSharedlox;
    
    %Heatplots!  
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %DS z plot
    figure(figureCount);
    hold on;
    
   
    %plot blue DS

    subplot(2,2,1); %subplot for shared colorbar
    
    heatDSzblueAllTrialslox= imagesc(timeLock,currentSubj(1).totalDSloxcount,currentSubj(1).DSzloxblueAllTrials);
    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding DS trials with valid PE - sorted by POX to LOX latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSloxcount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurpleAllTrialslox= imagesc(timeLock,currentSubj(1).totalDSloxcount,currentSubj(1).DSzloxpurpleAllTrials); 

    title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding DS trials with valid PE - sorted by POX to LOX latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from First Lick');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDSloxcount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format

    if ~isempty(currentSubj(1).NSzloxblueAllTrials) %if there is NS data
        
        %plot blue NS
        subplot(2,2,2); %subplot for shared colorbar

        heatNSzblueAllTrialslox= imagesc(timeLock,currentSubj(1).totalNSloxcount,currentSubj(1).NSzloxblueAllTrials);
        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding NS trials with valid PE - sorted by POX to LOX latency (Lo-Hi) ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
        xlabel('seconds from First Lick');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSloxcount(end)), ')'));
    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
        caxis manual;
        caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        
        
           %   plot purple NS (subplotted for shared colorbar)
        subplot(2,2,4);
        heatNSzpurpleAllTrialslox= imagesc(timeLock,currentSubj(1).totalNSloxcount,currentSubj(1).NSzloxpurpleAllTrials); 

        title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding NS trials with valid PE - sorted by POX to LOX latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
        xlabel('seconds from First Lick');
        ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNSloxcount(end)), ')'));

    %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately

        caxis manual;
        caxis([bottomAllSharedlox topAllSharedlox]); %use a shared color axis to encompass all values

        c= colorbar; %colorbar legend
        c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    end   
    
   
    %Overlay scatter of Cue onset (-Time from Cue to PE + - Time from PE to
    %First Lick)
   subplot(2,2,1) %DS blue
   hold on
   scatter(-DSloxpeLatency-DSloxrelpoxAllTrialsSorted,currentSubj(1).totalDSloxcount', 'k.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(-DSloxpeLatency-DSloxrelpoxAllTrialsSorted,currentSubj(1).totalDSloxcount', 'k.');
   
   if ~isempty(currentSubj(1).NSzloxblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSloxpeLatency-NSloxrelpoxAllTrialsSorted,currentSubj(1).totalNSloxcount', 'k.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSloxpeLatency-NSloxrelpoxAllTrialsSorted,currentSubj(1).totalNSloxcount', 'k.');
   end
   
   %Overlay scatter of PE (- Time from PE to First Lick)
   subplot(2,2,1) %DS blue
   hold on
   scatter(-DSloxrelpoxAllTrialsSorted,currentSubj(1).totalDSloxcount', 'm.');
   subplot(2,2,3) %DS purple
   hold on
   scatter(-DSloxrelpoxAllTrialsSorted,currentSubj(1).totalDSloxcount', 'm.');
   
   if ~isempty(currentSubj(1).NSzloxblueAllTrials)
      subplot(2,2,2) %NS blue
      hold on
      scatter(-NSloxrelpoxAllTrialsSorted,currentSubj(1).totalNSloxcount', 'm.');
     
      subplot(2,2,4) %NS purple
      hold on
      scatter(-NSloxrelpoxAllTrialsSorted,currentSubj(1).totalNSloxcount', 'm.');
   end
 saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periLOXZ_AllTrials_POXtoLOXsorted','.fig')); %save the current figure in fig format
    figureCount= figureCount+1;
   
end %end subject loop