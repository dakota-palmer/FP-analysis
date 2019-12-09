%fp data analysis 
%12/4/19
clear
clc
close all

figPath = 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

% %% Load struct containing data organized by subject

load(uigetfile); %choose the subjData file to open for your experiment

subjects= fieldnames(subjData); %access subjData struct with dynamic fieldnames

figureCount= 1 ; %keep track of figure # throughout to prevent overwriting

fs= 40; %This is important- if you change sampling frequency of photometry recordings for some reason, change this too! TODO: just save this in subjData as more metadata

% Behavioral plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% PLOT PORT ENTRY COUNT ACROSS DAYS FOR ALL SUBJECTS - not very meaningful,  but good template for DS PE ratio or latency
disp('plotting port entry counts')

figure(figureCount) %one figure with poxCount across sessions for all subjec

figureCount= figureCount+1;
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %Plot number of port entries across all sessions
       
        poxCount(session)= numel(currentSubj(session).pox); %get the total number of port entries across days
        days(session)= currentSubj(session).trainDay; %keep track of days to associate with poxCount
   end
   hold on;
   plot(days, poxCount)
end

title(strcat(currentSubj(session).experiment,' port entry count across days'));
xlabel('training day');
ylabel('port entry count');
legend(subjects); %add rats to legend

%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'port_entries_by_session','.fig'));
%         close; %close 

%% PLOT AVERAGE PORT ENTRY COUNT BETWEEN DAYS FOR ALL ANIMALS

disp('plotting avg port entry counts by animal');

figure(figureCount) %one figure with avg poxCount for all subjects
figureCount= figureCount+1;
title(strcat(currentSubj(session).experiment,'avg port entry count by subject +/- SEM'));
xlabel('subject');
ylabel(' port entry count');
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %Plot number of port entries across all sessions
       
        poxCount(session,subj)= numel(currentSubj(session).pox); %get the total number of port entries across days
        subjectLabel(session,subj)= currentSubj(session).rat;
   end
%    poxCount(subj,:)= poxCount;
   meanpoxCount(subj)= mean(poxCount(:,subj));
   sempoxCount(1,subj)= std(poxCount(:,subj))/sqrt(numel(currentSubj));

   hold on;
   scatter(subjectLabel(:,subj), poxCount(:,subj)); %scatter daily port entry counts by subject
   plot([subjectLabel(1,subj)-.2,subjectLabel(1,subj)+.2] , [meanpoxCount(subj), meanpoxCount(subj)], 'k'); %overlay mean of each subject
   
   plot([subjectLabel(1,subj)-.2,subjectLabel(1,subj)+.2] , [meanpoxCount(subj)-sempoxCount(1,subj), meanpoxCount(subj)-sempoxCount(1,subj)], 'k--');%overlay - sem of each subject
   plot([subjectLabel(1,subj)-.2,subjectLabel(1,subj)+.2] , [meanpoxCount(subj)+sempoxCount(1,subj), meanpoxCount(subj)+sempoxCount(1,subj)], 'k--');%overlay + sem of each subject
   plot([subjectLabel(1,subj), subjectLabel(1,subj)], [meanpoxCount(subj),meanpoxCount(subj)-sempoxCount(1,subj)], 'k--'); %connect -SEM to mean
   plot([subjectLabel(1,subj), subjectLabel(1,subj)], [ meanpoxCount(subj), meanpoxCount(subj)+sempoxCount(1,subj)], 'k--'); %connect +SEM to mean
end

%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'average_port_entries_by_subject','.fig'));
%         close; %close 


% Photometry plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Within-subjects photometry plots - this works but it's a lot of data and is inefficient so may be slow 
for subj= 1:numel(subjects)
    tic
    disp(strcat('plotting photometry data for_', subjects{subj}));
    
    figure(figureCount) %one figure per subject, with all sessions subplotted
    figureCount= figureCount+1;
    
   sgtitle(strcat(currentSubj(1).experiment, subjects{subj}, 'downsampled photometry traces')); %add big title above all subplots
    
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %% Raw session plots- within subjects
        subplot(numel(subjData.(subjects{subj})),1,session); 
        hold on
        plot(currentSubj(session).cutTime, currentSubj(session).reblue, 'b');
        plot(currentSubj(session).cutTime, currentSubj(session).repurple,'m');
        title(strcat('Rat #',num2str(currentSubj(session).rat),' training day :', num2str(currentSubj(session).trainDay), ' downsampled '));
        xlabel('time (s)');
        ylabel('mV');
        legend('blue (465)',' purple (405)');
   end  
        %make figure full screen, save, and close this figure
        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
%         saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'_downsampled_session_traces','.fig'));
%         close; %close 
    toc
end

%% Create subjDataAnalyzed struct for analyzed data

%Fill with metadata
 for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
       
       experimentName= currentSubj(session).experiment;
       
       subjDataAnalyzed.(subjects{subj})(session).experiment= currentSubj(session).experiment;
       subjDataAnalyzed.(subjects{subj})(session).rat= currentSubj(session).rat;
       subjDataAnalyzed.(subjects{subj})(session).trainDay= currentSubj(session).trainDay;
       subjDataAnalyzed.(subjects{subj})(session).trainStage= currentSubj(session).trainStage;
      subjDataAnalyzed.(subjects{subj})(session).box= currentSubj(session).box;       
   end %end session loop
end %end subject loop

% Event-Triggered Analyses %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: indexing is probably taking way too long here, find more efficient
%solution (maybe get rid of dynamic fieldnames or save to struct at end)
%Try using currentSubj throughout then assigning to subjectDataAnalyzed at
%very end

%% TIMELOCK TO DS
for subj= 1:numel(subjects) %for each subject
    
        currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
        %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or NS)
        %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
        %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  

        %here we are establishing some variables for our event triggered-analysis
        periCueTime = 20;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
        periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  

        slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)
              
   for session = 1:numel(currentSubj) %for each training session this subject completed
       tic
       
       clear timeDiff %this is cleared between sessions to prevent spillover
             
       disp(strcat('running DS-triggered analysis subject ', num2str(subj), '/', num2str(numel(subjects)), ' session ', num2str(session), '/', num2str(numel(currentSubj))));
              
        DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)
 
        for cue=1:length(currentSubj(session).DS) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset

            DSonset = currentSubj(session).DS(cue,1); %each entry in DS is a timestamp of the DS onset before downsampling- this needs to be aligned with our current time axis   

            %find closest value (min difference) in cutTime (the current time axis) to DSonset by subtraction
            for ts = 1:length(currentSubj(session).cutTime) %for each timestamp in cutTime 
                timeDiff(1,ts) = abs(DSonset-currentSubj(session).cutTime(ts)); %get the absolute difference between this cue's actual timestamp and each resampled timestamp- define this as timeDiff
            end

            [~,DSonsetShifted] = min(timeDiff); %Find the timestamp with the minimum difference- this is the index of the closest timestamp in cutTime to the actual DSonset- define this as DSonsetShifted


            timeShift= currentSubj(session).cutTime(DSonsetShifted)-currentSubj(session).DS(cue,1);  %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
            if abs(timeShift) >0.5 %this will flag cues whose time shift deviates above a threshold (in seconds- 0.5s)
                disp(strcat('>>Error *big cue time shift cue# ', num2str(cue), 'shifted DS ', num2str(currentSubj(session).cutTime(DSonsetShifted)), ' - actual DS ', num2str(DS(cue,1)), ' = ', num2str(timeShift), '*'));
            end

            %define the frames (datapoints) around each cue to analyze
            preEventTimeDS = DSonsetShifted-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTimeDS = DSonsetShifted+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)

           if preEventTimeDS< 1 %TODO: Double check this
              disp(strcat('****DS cue ', num2str(cue), ' too close to beginning, breaking out'));
              DSskipped= DSskipped+1;
              break
           end

           if postEventTimeDS> length(currentSubj(session).cutTime)-slideTime %if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
              disp(strcat('****DS cue ', num2str(cue), ' too close to end, breaking out'));
              DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
              break %break out of the loop and move onto the next DS cue
           end

            % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %blueA
            baselineMeanblue=mean(currentSubj(session).reblue((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
            baselineStdblue=std(currentSubj(session).reblue((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple=mean(currentSubj(session).repurple((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
            baselineStdpurple=std(currentSubj(session).repurple((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
       
            %save the data
            
            subjDataAnalyzed.(subjects{subj})(session).DSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeDS:postEventTimeDS);
            subjDataAnalyzed.(subjects{subj})(session).DSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeDS:postEventTimeDS);
            
            subjDataAnalyzed.(subjects{subj})(session).DSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeDS:postEventTimeDS))-baselineMeanblue))/(baselineStdblue);
            subjDataAnalyzed.(subjects{subj})(session).DSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeDS:postEventTimeDS))- baselineMeanpurple))/(baselineStdpurple);
            
            %get the mean response to the DS for this session
            subjDataAnalyzed.(subjects{subj})(session).meanDSblue = mean(subjDataAnalyzed.(subjects{subj})(session).DSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).meanDSpurple = mean(subjDataAnalyzed.(subjects{subj})(session).DSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

            subjDataAnalyzed.(subjects{subj})(session).meanDSzblue = mean(subjDataAnalyzed.(subjects{subj})(session).DSzblue, 3);

            subjDataAnalyzed.(subjects{subj})(session).meanDSzpurple = mean(subjDataAnalyzed.(subjects{subj})(session).DSzpurple, 3);

        end %end DS cue loop
        toc
   end %end session loop
end %end subject loop
        
%% TIMELOCK TO NS
for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       tic;
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct

       clear timeDiff;
  
      NSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

      disp(strcat('running NS-triggered analysis subject ', num2str(subj), '/', num2str(numel(subjects)), ' session ', num2str(session), '/', num2str(numel(currentSubj))));

      if isnan(currentSubj(session).NS)  %only run if NS is present (e.g. stage 5 and above), otherwise fill with NaN 
        subjDataAnalyzed.(subjects{subj})(session).NSblue=[]; %(1:periCueFrames*2+1,1)= nan;
        subjDataAnalyzed.(subjects{subj})(session).NSpurple=[]; %(1:periCueFrames*2+1,1)= nan;

        subjDataAnalyzed.(subjects{subj})(session).NSzblue= [];%(1:periCueFrames*2+1,1)= nan;
        subjDataAnalyzed.(subjects{subj})(session).NSzpurple=[]; %(1:periCueFrames*2+1,1)= nan;

        %get the mean response to the DS for this session
        subjDataAnalyzed.(subjects{subj})(session).meanNSblue=[]; %(1:periCueFrames*2+1,1) = nan;
        subjDataAnalyzed.(subjects{subj})(session).meanNSpurple=[]; %(1:periCueFrames*2+1,1) = nan; 

        subjDataAnalyzed.(subjects{subj})(session).meanNSzblue=[]; %(1:periCueFrames*2+1,1) = nan;

        subjDataAnalyzed.(subjects{subj})(session).meanNSzpurple= []; %(1:periCueFrames*2+1,1) = nan;
      else

            for cue=1:length(currentSubj(session).NS) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset
                NSonset = currentSubj(session).NS(cue,1); %each entry in DS is a timestamp of the DS onset before downsampling- this needs to be aligned with our current time axis   

                %find closest value (min difference) in cutTime (the current time axis) to DSonset by subtraction
                for ts = 1:length(currentSubj(session).cutTime) %for each timestamp in cutTime 
                    timeDiff(1,ts) = abs(NSonset-currentSubj(session).cutTime(ts)); %get the absolute difference between this cue's actual timestamp and each resampled timestamp- define this as timeDiff
                end

                [~,NSonsetShifted] = min(timeDiff); %Find the timestamp with the minimum difference- this is the index of the closest timestamp in cutTime to the actual DSonset- define this as DSonsetShifted


                timeShift= currentSubj(session).cutTime(NSonsetShifted)-currentSubj(session).NS(cue,1);  %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
                if abs(timeShift) >0.5 %this will flag cues whose time shift deviates above a threshold (in seconds- 0.5s)
                    disp(strcat('>>Error *big cue time shift cue# ', num2str(cue), 'shifted NS ', num2str(currentSubj(session).cutTime(NSonsetShifted)), ' - actual DS ', num2str(NS(cue,1)), ' = ', num2str(timeShift), '*'));
                end

                %define the frames (datapoints) around each cue to analyze
                preEventTimeNS = NSonsetShifted-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
                postEventTimeNS = NSonsetShifted+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)

               if preEventTimeDS< 1 %TODO: Double check this
                  disp(strcat('****NS cue ', num2str(cue), ' too close to beginning, breaking out'));
                  NSskipped= NSskipped+1;
                  break
               end

               if postEventTimeNS> length(currentSubj(session).cutTime)-slideTime %if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                  disp(strcat('****NS cue ', num2str(cue), ' too close to end, breaking out'));
                  NSskipped= NSskipped+1;  %iterate the counter for skipped DS cues
                  break %break out of the loop and move onto the next DS cue
               end

                % Calculate average baseline mean&stdDev 10s prior to DS for z-score
                %blueA
                baselineMeanblue=mean(currentSubj(session).reblue((NSonsetShifted-slideTime):NSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
                baselineStdblue=std(currentSubj(session).reblue((NSonsetShifted-slideTime):NSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
                %purpleA
                baselineMeanpurple=mean(currentSubj(session).repurple((NSonsetShifted-slideTime):NSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
                baselineStdpurple=std(currentSubj(session).repurple((NSonsetShifted-slideTime):NSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA

                %save the data

                subjDataAnalyzed.(subjects{subj})(session).NSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeNS:postEventTimeNS);
                subjDataAnalyzed.(subjects{subj})(session).NSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeNS:postEventTimeNS);

                subjDataAnalyzed.(subjects{subj})(session).NSzblue(:,:,cue)= (((currentSubj(session).reblue(preEventTimeNS:postEventTimeNS))-baselineMeanblue))/(baselineStdblue);
                subjDataAnalyzed.(subjects{subj})(session).NSzpurple(:,:,cue)= (((currentSubj(session).repurple(preEventTimeNS:postEventTimeNS))- baselineMeanpurple))/(baselineStdpurple);

                %get the mean response to the DS for this session
                subjDataAnalyzed.(subjects{subj})(session).meanNSblue = mean(subjDataAnalyzed.(subjects{subj})(session).NSblue, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

                subjDataAnalyzed.(subjects{subj})(session).meanNSpurple = mean(subjDataAnalyzed.(subjects{subj})(session).NSpurple, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 

                subjDataAnalyzed.(subjects{subj})(session).meanNSzblue = mean(subjDataAnalyzed.(subjects{subj})(session).NSzblue, 3);

                subjDataAnalyzed.(subjects{subj})(session).meanNSzpurple = mean(subjDataAnalyzed.(subjects{subj})(session).NSzpurple, 3);
            end % end NS cue loop
      end %end if NS ~nan conditional 
      toc
   end %end session loop
end %end subject loop

% Visualize analyzed data from subjDataAnalyzed struct %%%%%%%%%%%%%%%%%%%

subjectsAnalyzed = fieldnames(subjDataAnalyzed); 
% Heat plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% HEAT PLOT OF AVG RESPONSE TO CUE (by trial)

%here, we'll pull from the subjDataAnalyzed struct to make our heatplots
%first, we need to collect the avg cue response from all sessions and reshape for plotting

for subj= 1:numel(subjectsAnalyzed) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct

    %DS - extract data for plots
    %avg cue response sorted by trial, timelocked to DS
    currentSubj(1).DSzblueAllTrials= cat(2,currentSubj.meanDSzblue).'; %transpose for better readability; only need to save one
    currentSubj(1).DSzpurpleAllTrials= cat(2,currentSubj.meanDSzpurple).';%transpose for better readability


    %get list of session days for heatplot y axis
    subjTrial= cat(2, currentSubj.trainDay).';
    
    if currentSubj(1).rat== 13 %exception for this specific subject bc file loaded out of order for some reason
       subjTrial= [1:numel(currentSubj)]; 
    end

    %get bottom and top for color axis of DS heatplot
    bottomDS = min(min(min(currentSubj(1).DSzblueAllTrials)), min(min(currentSubj(1).DSzpurpleAllTrials))); %find the lowest value 
    topDS = max(max(max(currentSubj(1).DSzblueAllTrials)), max(max(currentSubj(1).DSzpurpleAllTrials))); %find the highest value


    %NS- extract data for plots
    %time axis is handled a bit differently because we only want to show sessions that have NS cues
    
    %photometry signals sorted by trial, timelocked to DS
    currentSubj(1).NSzblueAllTrials= cat(2,currentSubj.meanNSzblue).';%transpose for better readability; only need to save one
    currentSubj(1).NSzpurpleAllTrials= cat(2,currentSubj.meanNSzpurple).';%transpose for better readability
            
    %get list of session days for heatplot y axis
    subjTrialNS=[]; %keep track of sessions that have valid NS trials
    for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed

        if ~isempty(currentSubj(session).meanNSzblue) %if there's an NS trial in this session
             subjTrialNS= cat(2, subjTrialNS, currentSubj(session).trainDay);
        end
    end %end session loop

    %get bottom and top for color axis of NS heatplot
    bottomNS = min(min(min(currentSubj(1).NSzblueAllTrials)), min(min(currentSubj(1).NSzpurpleAllTrials)));
    topNS = max(max(max(currentSubj(1).NSzblueAllTrials)), max(max(currentSubj(1).NSzpurpleAllTrials)));


    %Establish a shared bottom and top for shared color axis of DS & NS
    if ~isempty(bottomNS) %if there is an NS
        bottomShared= min(bottomDS, bottomNS); %find the absolute min value
        topShared= max(topDS, topNS); %find the absolute min value
    else
        bottomShared= bottomDS;
        topShared= topDS;
    end
    %Heatplots!       
    %DS z plot
    figure(figureCount);
    hold on;
    subplot(2,2,1); %subplot for shared colorbar

    %plot blue DS

    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatDSzblue= imagesc(timeLock,subjTrial,currentSubj(1).DSzblueAllTrials);
    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), 'avg blue z score response to DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrial); %label trials appropriately
    caxis manual;
    caxis([bottomShared topShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,2,3);
    heatDSzpurple= imagesc(timeLock,subjTrial,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), ' avg purple z score response to DS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomShared topShared]); %use a shared color axis to encompass all values
    
    %% try linspace with caxis

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving




    %     %NS z plot
    %         figure(figureCount-1); %subplotting on the same figure as the DS heatplots
    hold on;
    figureCount=figureCount+1;
    subplot(2,2,2); %subplot for shared colorbar

    timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

    heatNSzblue= imagesc(timeLock,subjTrialNS,currentSubj(1).NSzblueAllTrials);
    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), 'avg blue z score response to NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel('training day');
    set(gca, 'ytick', subjTrialNS); %label trials appropriately
    caxis manual;
    caxis([bottomShared topShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple NS (subplotted for shared colorbar)
    subplot(2,2,4);
    heatNSzpurple= imagesc(timeLock,subjTrialNS,currentSubj(1).NSzpurpleAllTrials); 

    title(strcat('rat ', num2str(subjectsAnalyzed{subj}), ' avg purple z score response to NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel('training day');

    set(gca, 'ytick', subjTrialNS); %TODO: NS trial labels must be different, only stage 5 trials

    caxis manual;
    caxis([bottomShared topShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving


end %end subject loop

%% Power analysis 

%Need to define a timescale within which to look for cue-related effect
%Here, we will use a 1s time window after cue onset
effectStartTime= ((periCueTime*fs)/2);
effectDuration= 1; %1s
effectWindow= effectStartTime+1:effectStartTime+(effectDuration*fs);


%Because 405nm and 465nm signals are inversely related, looking for an
%effect between these signals doesn't seem appropriate. We could look for
%a difference between response to DS vs. response to NS. We could also look
%for a difference between cue-related response and 'spontaneous'
%activity during ITI. I think there must be some normalized metric between
%subjects to estimate an effect size
for subj= 1:numel(subjectsAnalyzed) %for each subject
   currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
   
   disp(strcat('working on effect size estimate for subj', num2str(subj), ' / ', num2str(numel(subjectsAnalyzed))));
   
   for session = 1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj})) %for each training session this subject completed
   tic
       %raw blue and purple signals don't mean much as their value is arbitrary, can't really compare the two directly 
       %instead, need to look at change in signal over time
%        subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSblue= currentSubj(session).DSblue(effectWindow, 1, :);
%        subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSblueMean= mean(mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSblue, 3)); %avg response throughout 1s,grand avg across all cues for that session
%        
%        subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSpurple= currentSubj(session).DSpurple(effectWindow, 1, :);
%        subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSpurpleMean= mean(mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSpurple, 3)); %avg response throughout 1s,grand avg across all cues for that session
%        
       %Z score already uses std dev to calculate, so probably not good to
       %calculate effect size on top of this, but will try
       
       %get the z score values during the 'effect' time window
       %for now, interested in blue signal
       
       %Extract the blue z score response to cue in a specific time window of interest
       %for all DS cues (and then the avg response to all cues)...
       subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblue= currentSubj(session).DSzblue(effectWindow, 1, :);
       subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueMean= mean(mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblue, 3)); %avg response throughout 1s,grand avg across all cues for that session
       %then calculate the std of this response to cues (and then the avg std of response to all cues)
       subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueStd= std(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).DSzblue(effectWindow,1,:)); %this gives us std of response to each cue
       subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueAvgStd= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueStd); %this gives us the avg std of response to each cue
       
       %repeat above but for response to NS cue
       if isempty(currentSubj(session).NSzblue) %if there's no valid NS, there's no effect to look for
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblue= [];
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueMean= [];
           
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueStd= [];
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueAvgStd= [];
       else %if an NS is present, extract cue-related activity in the 'effect' time window
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblue= currentSubj(session).NSzblue(effectWindow,1,:);
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueMean= mean(mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblue,3));
       
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueStd= std(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).NSzblue(effectWindow,1,:)); %this gives us std of response to each cue
           subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueAvgStd= mean(subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueStd); %this gives us the avg std of response to each cue
       end
              
       %Instead of looking at z score, I could calculate some kind of df/F for both channels relative to the 'baseline'activity 10s preceding the cue?
       %this would look like (blue-baselineblue)/baselineblue for each timestamp


   end %end session loop
   
  %get a grand mean of 'effect' (here the z score in the blue channel) across all cues and all sessions for each subject
  grandMeanEffectDSzblue(:,subj)= mean(cat(2,subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueMean));  
  grandMeanEffectNSzblue(:,subj)= mean(cat(2,subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueMean));
   
  %get a grand avg std of the z score (again, this seems inappropriate because std of the raw signal is used to calculate z score?)
  grandStdDSzblue(:,subj)= mean(cat(2,subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectDSzblueAvgStd));  
  grandStdNSzblue(:,subj)= mean(cat(2,subjDataAnalyzed.(subjectsAnalyzed{subj})(session).effectNSzblueAvgStd));  

   
  toc
end %end subject loop

  %now avg everything across subjects
  grandMeanEffectDSzblueAllSubjects= mean(grandMeanEffectDSzblue); %avg response to DS
  grandMeanEffectNSzblueAllSubjects= mean(grandMeanEffectNSzblue); %avg response to NS

  grandStdDSzblueAllSubjects= mean(grandStdDSzblue); %avg std in response to DS
  grandStdNSzblueAllSubjects= mean(grandStdNSzblue); %avg std in response to NS
  
  
  %now, calculate a pooledStd between the DS and NS 
  pooledStdAllSubjects= sqrt(((grandStdDSzblueAllSubjects^2)+(grandStdNSzblueAllSubjects^2))/2); 

 %now, estimate Cohen's D (mean1-mean2)/pooledStd
 
 cohensDzBlue= abs((grandMeanEffectDSzblueAllSubjects-grandMeanEffectNSzblueAllSubjects)/pooledStdAllSubjects)
 %resulting Cohen's D estimate is pretty small, but I think it may have to
 %do with stacked variance caused by the z score calculation? Also, I may
 %need to refine the time period over which to look for an effect (1s seems
 %too broad, heatplots show response ~500ms after cue)
 
 %just for fun, what n would I need for .80 power?
 nCuePresentationsNeeded = sampsizepwr('t',[grandMeanEffectDSzblueAllSubjects, pooledStdAllSubjects], grandMeanEffectNSzblueAllSubjects, .80,[])
 
 %% use 'z' for sampsizepwr ?
 
 %that's a lot of trials... 1398/30 per day ~ 47 days of training

 
 %lets save this too
for subj= 1:numel(subjectsAnalyzed) %for each subject
   subjDataAnalyzed.(subjectsAnalyzed{subj})(1).cohensDzBlue= cohensDzBlue;
   subjDataAnalyzed.(subjectsAnalyzed{subj})(1).nCuePresentationsNeeded= nCuePresentationsNeeded;
end %end subject loop
%% Inferential stats

% I think the data here will be parametric - at least in latter stages of
% training, there seem to be consistent cue responses 

% Since I'd like to see how the neural cue response changes with training, I would like to
% use n-way ANOVA to look at the main effect of cue, the main effect of session,
% and any interaction


%% Save the analyzed data 
%save the subjDataAnalyzed struct for later analysis
save(strcat(experimentName,'-', date), 'subjDataAnalyzed');

%% End of file 
disp(strcat('all done, expect ', num2str(figureCount-1), ' figures'));
figureCount=1;


%% Example structure of loop through subjects and sessions 
% for subj= 1:numel(subjects) %for each subject
%    currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
%    for session = 1:numel(currentSubj)) %for each training session this subject completed
%    end %end session loop
% end %end subject loop
