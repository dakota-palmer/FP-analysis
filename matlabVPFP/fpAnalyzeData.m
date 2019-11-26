%fp data analysis 
%11/25/19
clear
clc
close all

figPath = 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

% %% Load struct containing data organized by subject

load(uigetfile); %choose the subjData file to open for your experiment

subjects= fieldnames(subjData); %access subjData struct with dynamic fieldnames

figureCount= 1 ; %keep track of figure # throughout to prevent overwriting

%% Behavioral plots- in progress

% PLOT PORT ENTRY COUNT ACROSS DAYS FOR ALL SUBJECTS - not very meaningful,  but good template for DS PE ratio or latency
disp('plotting port entry counts')

figure(figureCount) %one figure with poxCount across sessions for all subjects
figureCount= figureCount+1;
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %Plot number of port entries across all sessions
       
        poxCount(session)= numel(currentSubj(session).pox); %get the total number of port entries across days
        days(session)= currentSubj(session).trainDay; %keep track of days to associate with poxCount
   end
   hold on;
   scatter(days, poxCount)
end

title(strcat(currentSubj(session).experiment,' port entry count across days'));
xlabel('training day');
ylabel('port entry count');
legend(subjects); %add rats to legend

%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'port_entries_by_session','.fig'));
%         close; %close 

%% Between subjects behavioral plots
%PLOT AVERAGE PORT ENTRY COUNT BETWEEN DAYS FOR ALL ANIMALS

disp('plotting avg port entry counts by animal');

figure(figureCount) %one figure with avg poxCount for all subjects
figureCount= figureCount+1;
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %Plot number of port entries across all sessions
       
        poxCount(session)= numel(currentSubj(session).pox); %get the total number of port entries across days
   end
   subjectLabel(subj)= currentSubj(session).rat; %get the rat # for proper x axis
   meanpoxCount(subj)= mean(poxCount);
   hold on;
   bar(subjectLabel,meanpoxCount)
end

title(strcat(currentSubj(session).experiment,' avg port entry count across all sessions by subject'));
xlabel('subject');
ylabel('avg port entry count');

%make figure full screen, save, and close this figure
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath, currentSubj(session).experiment,'_', subjects{subj},'average_port_entries_by_subject','.fig'));
%         close; %close 



%% Within-subjects photometry plots - this works but it's a lot of data and is inefficient so may be slow 
for subj= 1:numel(subjects)
    
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
end









% %% Within-subjects event-triggered analysis- in progress
% for subj= 1:numel(subjects) %for each subject
%    for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
%        
%         currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
%         %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or NS)
%         %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
%         %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  
% 
%         %here we are establishing some variables for our event triggered-analysis
%         periCueTime = 20;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
%         periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  
% 
%         slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)
% 
%         %%%%%TIMELOCK TO DS
%         
%         DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)
% 
%         for cue=1:length(currentSubj(session).DS) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset
% 
%             DSonset = currentSubj(session).DS(cue,1); %each entry in DS is a timestamp of the DS onset before downsampling- this needs to be aligned with our current time axis   
% 
%             %find closest value (min difference) in cutTime (the current time axis) to DSonset by subtraction
%             for ts = 1:length(currentSubj(session).cutTime) %for each timestamp in cutTime 
%                 timeDiff(1,ts) = abs(DSonset-currentSubj(session).cutTime(ts)); %get the absolute difference between this cue's actual timestamp and each resampled timestamp- define this as timeDiff
%             end
% 
%             [~,DSonsetShifted] = min(timeDiff); %Find the timestamp with the minimum difference- this is the index of the closest timestamp in cutTime to the actual DSonset- define this as DSonsetShifted
% 
% 
%             timeShift= cutTime(DSonsetShifted)-currentSubj(session).DS(cue,1);  %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
%             if abs(timeShift) >0.5 %this will flag cues whose time shift deviates above a threshold (in seconds- 0.5s)
%                 disp(strcat('>>Error *big cue time shift cue# ', num2str(cue), 'shifted DS ', num2str(cutTime(DSonsetShifted)), ' - actual DS ', num2str(DS(cue,1)), ' = ', num2str(timeShift), '*'));
%             end
% 
%             %define the frames (datapoints) around each cue to analyze
%             preEventTimeDS = DSonsetShifted-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
%             postEventTimeDS = DSonsetShifted+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)
% 
%            if preEventTimeDS< 1 %TODO: Double check this
%               disp(strcat('****DS cue ', num2str(cue), ' too close to beginning, breaking out'));
%               DSskipped= DSskipped+1;
%               break
%            end
% 
%            if postEventTimeDS> length(cutTime)-slideTime %if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
%               disp(strcat('****DS cue ', num2str(cue), ' too close to end, breaking out'));
%               DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
%               break %break out of the loop and move onto the next DS cue
%            end
% 
%             % Calculate average baseline mean&stdDev 10s prior to DS for z-score
%             %blueA
%             baselineMeanblueA=mean(currentSubj(session).reblueA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
%             baselineStdblueA=std(currentSubj(session).reblueA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
%             %purpleA
%             baselineMeanpurpleA=mean(currentSubj(session).repurpleA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
%             baselineStdpurpleA=std(currentSubj(session).repurpleA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
%             %blueB
%             baselineMeanblueB=mean(currentSubj(session).reblueB((DSonsetShifted-slideTime):DSonsetShifted)); %'' for boxB
%             baselineStdblueB=std(currentSubj(session).reblueB((DSonsetShifted-slideTime):DSonsetShifted));
%             %purpleB
%             baselineMeanpurpleB=mean(currentSubj(session).repurpleB((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxB
%             baselineStdpurpleB=std(currentSubj(session).repurpleB((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxB
% 
%                  %for the first cue, initialize arrays for dF and time surrounding cue
%         if cue==1
% 
%             eventTimeDS = currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS); %define the time axis for the event (cue onset +/- periCueTime)
% 
%             %blue signal indexed 20s before and after cue 
%             DSblueA = currentSubj(session).reblueA(preEventTimeDS:postEventTimeDS);  %extract the raw data corresponding to this time window for blue
%             DSblueB = currentSubj(session).reblueB(preEventTimeDS:postEventTimeDS);      
% 
%             %repear for purple signal
%             DSpurpleA = currentSubj(session).repurpleA(preEventTimeDS:postEventTimeDS);  %extract the raw data corresponding to this time window for purple
%             DSpurpleB = currentSubj(session).repurpleB(preEventTimeDS:postEventTimeDS); 
% 
%            %calculate zscore for each point in the peri-event period based on
%            %baseline mean and stdDev in the preceding 10s for blue and purple
%            DSzblueA=(((currentSubj(session).reblueA(preEventTimeDS:postEventTimeDS))-baselineMeanblueA))/(baselineStdblueA);  
%            DSzblueB=(((currentSubj(session).reblueB(preEventTimeDS:postEventTimeDS))-baselineMeanblueB))/(baselineStdblueB);         
% 
%            DSzpurpleA=(((currentSubj(session).repurpleA(preEventTimeDS:postEventTimeDS))-baselineMeanpurpleA))/(baselineStdpurpleA);  
%            DSzpurpleB=(((currentSubj(session).repurpleB(preEventTimeDS:postEventTimeDS))-baselineMeanpurpleB))/(baselineStdpurpleB);   
% 
% 
%         else        %for subsequent cues (~=1), add onto these arrays as new 3d pages        
%             eventTimeDS = cat(3,eventTimeDS,cutTime(preEventTimeDS:postEventTimeDS)); %concatenate in the 3rd dimension (such that each cue has its own 2d page with the surrounding cue-related data)
% 
%             %for blue
%             DSblueA = cat(3, DSblueA, currentSubj(session).reblueA(preEventTimeDS:postEventTimeDS));
%             DSblueB = cat(3,DSblueB, currentSubj(session).reblueB(preEventTimeDS:postEventTimeDS));
%             %for purple
%             DSpurpleA = cat(3, DSpurpleA, currentSubj(session).repurpleA(preEventTimeDS:postEventTimeDS));
%             DSpurpleB = cat(3,DSpurpleB, currentSubj(session).repurpleB(preEventTimeDS:postEventTimeDS));
%             %for blue
%             DSzblueA= cat(3,DSzblueA,(((currentSubj(session).reblueA(preEventTimeDS:postEventTimeDS))-baselineMeanblueA)/(baselineStdblueA)));  
%             DSzblueB= cat(3,DSzblueB,(((currentSubj(session).reblueB(preEventTimeDS:postEventTimeDS))-baselineMeanblueB)/(baselineStdblueB)));
%             %for purple
%             DSzpurpleA= cat(3,DSzpurpleA,(((currentSubj(session).repurpleA(preEventTimeDS:postEventTimeDS))-baselineMeanpurpleA)/(baselineStdpurpleA)));  
%             DSzpurpleB= cat(3,DSzpurpleB,(((currentSubj(session).repurpleB(preEventTimeDS:postEventTimeDS))-baselineMeanpurpleB)/(baselineStdpurpleB)));
%         end    
%            
%    end
%        
% end

disp(strcat('all done, expect ', num2str(figureCount-1), ' figures'));
