%% load data- here temporarily (remove if put in fpAnalysis workflow)

load(uigetfile); %load subjData
load(uigetfile); %load subjDataAnalyzed

subjects= fieldnames(subjData);

figureCount=1; fs= 40; 

%% Photobleach correction
 %Going for something like (Patel et al 2019 bioRxiv)
for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
   
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       if currentSubj(session).trainStage==5
       clear cutTime reblue repurple
       
       cutTime= currentSubj(session).cutTime;
       reblue= currentSubj(session).reblue;
       repurple= controlFit(currentSubj(session).reblue, currentSubj(session).repurple); %currentSubj(session).repurple;
       
       
%        
     %let's fit an exponential function to the blue and purple signals

     %First order exponential fit
% ft=fittype('exp1');
% currentSubj(session).blueFit=fit(cutTime',reblue,ft);
% currentSubj(session).purpleFit=fit(cutTime',repurple,ft);

    %matlab's built in detrend function 
% detrendblue= detrend(reblue, 2);
% detrendpurple= detrend(repurple, 2);
%      
%      figure(figureCount);
%      figureCount=figureCount+1;
%      subplot(2,1,1);
%      plot(currentSubj(session).blueFit, cutTime, reblue)
%      hold on;
% %      plot(cutTime,detrendblue,'k');
%      subplot(2,1,2);
%      plot(currentSubj(session).purpleFit, 'k', cutTime, repurple, 'm')
%      hold on;
% %      plot(cutTime,detrendpurple,'k');
%      
%      set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
%      
% %      waitforbuttonpress;
%      close;

     
         %matlab's built in moving median function
         %inspired by(Patel, McAlinden, Matheison, &
         %Sakata, 2019 BioRxiv) but not really what they did
         
         %Here, a moving median is calculated as a dynamic measure of the
         %signal's baseline (since the baseline shifts throughout the
         %session)
    medianblue= movmean(reblue,800);
    medianpurple= movmedian(repurple, 800); %40=1s %800 = 20s
    
    dffblue= (reblue-medianblue)./medianblue;
    dffpurple= (repurple-medianpurple)./medianpurple;
    
    figure(figureCount);
    figureCount= figureCount+1;
    sgtitle(strcat('subj',num2str(currentSubj(session).rat),'-',num2str(currentSubj(session).date), '-photobleach/drift baseline correction (dF/F)'));
    subplot(4,1,1);
    title('blue raw with moving median')
    hold on;
    plot(cutTime,reblue);
    plot(cutTime,medianblue, 'k');
    subplot(4,1,2);
    hold on;
    title('blue dF/F (value-median/median)');
    plot(cutTime,dffblue);
    subplot(4,1,3);
    title('purple raw with moving median')
    hold on;
    plot(cutTime, repurple, 'm');
    plot(cutTime, medianpurple, 'k');
    subplot(4,1,4);
    hold on;
    title('purple dF/F (value-median/median)');
    plot(cutTime,dffpurple, 'm');
    
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
    
%     waitforbuttonpress; %COMMENT OUT if you don't want to review traces
    close;
    
    %trying to get an idea of relative dF/F for blue & purple channels
    %using this method
    figure(figureCount); figureCount=figureCount+1; hold on;
    sgtitle(strcat('subj',num2str(currentSubj(session).rat),'-',num2str(currentSubj(session).date), '- baseline corrected dF/F overlay'));
    plot(dffblue,'b');
    plot(dffpurple,'m');      
    
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
%     waitforbuttonpress; %COMMENT OUT if you don't want to review traces
    close;
    
    subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff= dffblue;
    subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff= dffpurple;
    
    % Testing different window durations
    windowLengths= [20, 100, 200, 500, 800, 2000]; %define durations you want to test
    subplotCount=1;
    for thisWindow= windowLengths
        windowBins= fs*thisWindow;
        
        %calculate moving baseline given this windowLength
        medianblue= movmedian(reblue,thisWindow);
        medianpurple= movmedian(repurple, thisWindow); %40=1s %800 = 20s
            
        %and corresponding dff
        dffblue= (reblue-medianblue)./medianblue;
        dffpurple= (repurple-medianpurple)./medianpurple;

        
        %visualize, 1 subplot per tested windowLength
        figure(figureCount); hold on; sgtitle(strcat('subject-',subjects{subj},'-',num2str(currentSubj(session).date),'- moving baseline estimate window length comparison'));
        subplot(numel(windowLengths),1,subplotCount); hold on; title(strcat('window=',num2str(thisWindow),'s'));
        plot(cutTime,reblue, 'b');
        plot(cutTime,medianblue, 'k');   
        plot(cutTime, repurple,'m');
        plot(cutTime,medianpurple,'r');
        
        %to get an idea of where "real" signal is happening, let's overlay
        %some events
           
        firstPoxDS= nan(size(currentSubjAnalyzed(session).periDS.DS)); %reset between sessions
        firstLoxDS= nan(size(currentSubjAnalyzed(session).periDS.DS)); 
       %get only first lox & pox during cue, using cellfun (since poxDS and loxDS are saved in a cell array and we only want the first value       
       index= ~cellfun('isempty',currentSubjAnalyzed(session).behavior.poxDS); %using this index accounts for empty cells
       firstPoxDS(index)= cellfun(@(v)v(1),currentSubjAnalyzed(session).behavior.poxDS(index));
       
       index= ~cellfun('isempty',currentSubjAnalyzed(session).behavior.loxDS); %using this index accounts for empty cells
       firstLoxDS(index)= cellfun(@(v)v(1),currentSubjAnalyzed(session).behavior.loxDS(index));
                    
       
       %plot events

       for cue= 1:numel(currentSubjAnalyzed(session).periDS.DS) %loop through DS trials and plot events
          plot([firstPoxDS(cue),firstPoxDS(cue)],[min(reblue),max(reblue)], 'c'); %vertical line for first PE during DS 
          plot([firstLoxDS(cue),firstLoxDS(cue)],[min(reblue),max(reblue)], 'g'); %vertical line for first lick during DS
          
%           plot([currentSubjAnalyzed(session).behavior.loxDS{cue}, currentSubjAnalyzed(session).behavior.loxDS{cue}], [min(reblue),max(reblue)], 'g');
       end
       
       if subplotCount==1
           legend('raw','moving median', 'first pe', 'first lick');
       end
              
       subplotCount=subplotCount+1; %iterate counter          
    end
    
    linkaxes;
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
    figureCount=figureCount+1;
    
   close; %breakpoint here if you want to examine traces
       end
   end %end session loop
end %end subject loop

%% ~~~Artifact identification/elimination~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Maybe we should just exclude extreme trials/ trials where artifacts are present
%Trying to visualize outliers here first
    
%% Histograms of individual trial z score response
% for subj= 1:numel(subjectsAnalyzed) %for each subject
%     
%     currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
%     
%     %histogram plot of the blue z score response to DS, #bins = # cue presentations
%     figure;
%     subplot(2,1,1);
%     histogram(currentSubj(1).periDS.DSzblueAllTrials, currentSubj(1).periDS.totalDScount(end), 'facecolor', 'b');
%     title(strcat('rat_', num2str(currentSubj(1).rat), 'blue z score in response to DS (n= ', num2str(currentSubj(1).periDS.totalDScount(end)), '*1601 timestamps)'));
%     xlabel(strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue'));
%     ylabel('# timestamps with this value');
%     xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
%     
%     %hist the purple z score response to DS #bins = # cue presentations
%     subplot(2,1,2)
%     histogram(currentSubj(1).periDS.DSzpurpleAllTrials, currentSubj(1).periDS.totalDScount(end) , 'facecolor', 'm');
%     xlabel(strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue'));
%     ylabel('# timestamps with this value');
%     title(strcat('rat_', num2str(currentSubj(1).rat), 'purple z score in response to DS (n= ', num2str(currentSubj(1).periDS.totalDScount(end)), '*1601 timestamps)'));
%     xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
%     
%     
% end

% % % HISTOGRAM OF RESPONSE OVER TIME
% % march through timestamps on button press
% % for subj= 1:numel(subjectsAnalyzed) %for each subject
% %     
% %     currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
% %     
% %     timeStep= [1:fs:numel(timeLock)]; %create an array containing 1s "steps" in time around the cue (based on fs)
% %     
% %     histogram plot of the blue z score response to DS
% %     figure(figureCount);
% %     figureCount= figureCount+1;
% %     disp('***displaying histograms of z score response to cue thru time');
% %     for timestamp= 1:numel(timeStep)
% %             subplot(2,1,1);
% %             histogram(currentSubj(1).periDS.DSzblueAllTrials(:,timestamp), 'facecolor', 'b');
% %             title(strcat('rat_', num2str(currentSubj(1).rat), 'blue z score in response to DS at T= ', num2str(timeLock(timeStep(timestamp)))));
% %             xlabel(strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue'));
% %             ylabel('# timestamps with this value');
% %             xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
% %         
% %             hist the purple z score response to DS 
% %             subplot(2,1,2)
% %             histogram(currentSubj(1).periDS.DSzpurpleAllTrials(:,timestamp), 'facecolor', 'm');
% %             xlabel(strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue'));
% %             ylabel('# timestamps with this value');
% %             title(strcat('rat_', num2str(currentSubj(1).rat), 'purple z score in response to DS at T= ', num2str(timeLock(timeStep(timestamp)))));
% %             xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
% %             pause(0.008); %this will automatically iterate (seconds); to wait for user input use pause()
% %     end
% %     close;
% % end

%% Looping histogram of z score DS response over time
% %TODO: save to movie
% timeStep= [1:fs:numel(timeLock)]; %create an array containing 1s "steps" in time around the cue (based on fs)
% 
% figure(figureCount);
% figureCount=figureCount+1;
% hold on;
% set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% 
% histTitle= sgtitle(strcat('z score in response to DS at T= ')); %add big title above all subplots
% 
% 
% % while 1 %infinite loop while true
%     disp('***displaying histograms of z score response to cue thru time, press key to stop');
%     
%     %loop through all timestamps, for each timestamp loop through subjects
%     %and plot the peri-cue z score values first in the blue channel then in
%     %the purple channel (looped twice in order to organize subplots so that
%     %blue is on top of purple for each subject)
%     
%     for timestamp= 1:numel(timeStep)
%         subplotCount= 1; %reset all the subplots between timestamps
%         
%         for subj= 1:numel(subjectsAnalyzed)
%             
%                histTitle.String= strcat('z score in response to DS at T= ', num2str(timeLock(timeStep(timestamp)))); %update the big title above all subplots, need to do it this way otherwise it draws over itself
%                 
%                 currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subjects within the struct
%             
%                 subplot(2, numel(subjectsAnalyzed), subplotCount);   
%                 subplotCount=subplotCount+1;
%                 
%                 histogram(currentSubj(1).periDS.DSzblueAllTrials(:,timestamp), 'facecolor', 'b');
%                 title(strcat('rat_', num2str(currentSubj(1).rat), 'blue z'));
%                 xlabel(strcat('DS blue z-score'));
%                 ylabel('# trials');
%                 xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
% 
%         end
%         
%         
%         for subj= 1:numel(subjectsAnalyzed)
%             
%                histTitle.String= strcat('z score in response to DS at T= ', num2str(timeLock(timeStep(timestamp)))); %update the big title above all subplots, need to do it this way otherwise it draws over itself
%                 
%                 currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subjects within the struct
%             
%                 %hist the purple z score response to DS #bins = # cue presentations
%                 subplot(2, numel(subjectsAnalyzed), subplotCount);
%                 subplotCount=subplotCount+1;
%                 histogram(currentSubj(1).periDS.DSzpurpleAllTrials(:,timestamp), 'facecolor', 'm');
%                 xlabel(strcat('DS blue z-score'));
%                 ylabel('# trials');
%                 title(strcat('rat_', num2str(currentSubj(1).rat), 'purple z'));
%                 xlim([currentSubj(1).periDS.bottomAllShared,currentSubj(1).periDS.topAllShared]); %set a shared x axis for comparison
%         end
%         
%         pause(0.005); %this will automatically iterate (seconds); to wait for user input use pause()
% 
%     end
% % end
% 
% close;
    
%% Artifact elimination
% 
% %Artifacts should be considered fast deflections in both channels in the same
% %direction, or we could just use the 405nm to keep it simple
% 
% %define a threshold criteria for the isosbestic channel based on std,
% %and discard frames where the isosbestic signal deviates above this threshold
% 
% %keep in mind that 405nm signal could vary with ca++ events
% 
% %this strategy seeems imperfect- good datapoints may be removed due to
% %bleaching and it doesn't capture all artifacts... instead of looking
% %at global std, need to do some kind of sliding calculation to look at
% %local std
    
for subj= 1:numel(subjects)
    
    currentSubj= subjData.(subjects{subj});
    
    disp(strcat('artifact elimination_', subjects{subj}));
    
    
%     figure(figureCount);
%     figureCount=figureCount+1;
%     sgtitle(strcat('Rat #',num2str(currentSubj(1).rat), 'artifact detection'));
    
%     subplotCount=1;

   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       subplotCount=1;
       
       artifactThreshold = std(currentSubj(session).repurple)*2;
       
       subjDataAnalyzed.(subjects{subj})(session).photometrySignals.artifactThreshold= artifactThreshold; %save this value
      
        for timestamp= 1:numel(currentSubj(session).repurple)
            if timestamp== 1
                currentSubj(session).dPurple(timestamp)= 0; %no change possible on the first timestamp
            else
                currentSubj(session).dPurple(timestamp) = currentSubj(session).repurple(timestamp)-currentSubj(session).repurple(timestamp-1);
            end  
        end
    
    dPurple= currentSubj(session).dPurple;
    
    %let's define a threshold beyond which we want to exclude data (noise)
    dThreshold = std(currentSubj(session).dPurple)*8;
    dMean= nanmean(currentSubj(session).dPurple);
    
    %identify points that exceed this threshold
    dArtifactIndex= find(dPurple>dThreshold | dPurple<-dThreshold);
    
    dArtifactsVals= dPurple(dPurple>dThreshold | dPurple<-dThreshold);
    
    
   %visualize
    figure(figureCount); figureCount= figureCount+1; %1 fig per session
    sgtitle(strcat('Rat #',num2str(currentSubj(session).rat),'-',num2str(currentSubj(session).date), 'artifact detection'));
    subplot(1,3,subplotCount);
    subplotCount=subplotCount+1;
    hold on;
    plot(currentSubj(session).dPurple, 'm');
    
    title('dPurple');
    %overlay threshold
    plot([1,numel(currentSubj(session).dPurple)], [dMean - dThreshold, dMean - dThreshold], 'k--');
    plot([1,numel(currentSubj(session).dPurple)], [dMean + dThreshold, dMean + dThreshold], 'k--');
    %overlay points beyond threshold
    scatter(dArtifactIndex, dArtifactsVals, 'gx')
   
    
    % let's put these excluded timestamps over the raw purple trace to compare
    
       subplot(1, 3, subplotCount);
       subplotCount= subplotCount+1;
       hold on;
       plot(currentSubj(session).repurple, 'm'); %plot 405 signal
       title('repurple, artifact timestamps calculated based on dPurple');
       
       %overlay + and - the threshold relative to the mean 405 signal
       plot([1,numel(currentSubj(session).repurple)], [nanmean(currentSubj(session).repurple) + artifactThreshold, nanmean(currentSubj(session).repurple) + artifactThreshold], 'k--')
       plot([1,numel(currentSubj(session).repurple)], [nanmean(currentSubj(session).repurple) - artifactThreshold, nanmean(currentSubj(session).repurple) - artifactThreshold], 'k--')

       scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(currentSubj(session).repurple), 'gx'); 
    
       %plot blue too
       plot(currentSubj(session).reblue,'b');
    

    

    %conservative threshold works well here- just looking for extreme
    %artifacts- big, abrupt changes
    
    %seems to work for most trials, but @ threshold = 10 std trhis misses a pretty big case for
    %VP-VTA-FP rat 9 trial 32
    
    %TODO: this is calculating dF timestamp by timestamp, but maybe we want to reject
    %rapid increases over a specific time period or do some kind of sliding
    %calculation

    %Let's actually remove the artifacts now
    
    cutTime= currentSubj(session).cutTime;
    
    %get the actual timestamp values to be excluded from cutTime
    excludedTimestamps = cutTime(dArtifactIndex);
        
    %extract all timestmap values from cutTime that aren't equal to these
    %excluded timestamps
    
    %make these excluded timestamps NaN
    cutTime(dArtifactIndex)= NaN;
    %extract timestamps that aren't NaN
    timeNoArtifact= cutTime(~isnan(cutTime));
    
%     disp(strcat('excluded_', num2str(numel(excludedTimestamps)), ' timestamps w/ artifacts '));
    
    %now use the same strategy to extract photometry signals
    reblueNoArtifact= currentSubj(session).reblue(~isnan(cutTime));
    repurpleNoArtifact= currentSubj(session).repurple(~isnan(cutTime));
    
    
   subplot(1, 3, subplotCount);
   subplotCount= subplotCount+1;
   hold on;
   plot(repurpleNoArtifact, 'm'); %plot 405 signal
   title('artifacts removed- this method isnt working');

   scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(currentSubj(session).repurple), 'gx'); 

   %plot blue too
   plot(reblueNoArtifact, 'b');

   set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

   
   %this method doesn't seem to work well enough- but at least we have
   %decent timestamps of artifacts... we maybe we can use this to exclude TRIALS
   %instead of trying to remove the artifacts themselves?
   
   %maybe it would be best to just exlucde trials with huge z scores
   
   %Maybe instead of excluding trials, change the baseline z score calc in
   %some way (exclude timestamps?)
   
   %save the artifact indices for each session
   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.dArtifactTimes= excludedTimestamps; %this is a list of the excluded timestamps
   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.cutTimeNoArtifacts= cutTime; %this is a time axis where timestamps with artifacts= NaN

   %save figure
  saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, num2str(currentSubj(session).date), '_ArtifactID','.tiff')); %save the current figure in fig format

   end %end session loop
   
    %save figure
%    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_ArtifactID','.tiff')); %save the current figure in fig format

end %end subj loop
 