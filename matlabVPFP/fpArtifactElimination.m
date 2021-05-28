%% load data- here temporarily (remove if put in fpAnalysis workflow)

cd('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP')


load(uigetfile('*.mat')); %load subjData
load(uigetfile('*.mat')); %load subjDataAnalyzed

% subjects= fieldnames(subjData);
subjects= fieldnames(subjDataAnalyzed);

figureCount=1; fs= 40; 

%temporarily restricting to single session to compare methods
subjects= {'rat8'}



%% fit and launch gui

%longer threshold window = can capture broader artifacts (e.g. period of
%stability between two extreme rise and fall times)

%shorter movMADS window= more MADS variability, more individual shifts resolved which combine if using longer windows 

for subj= 1:numel(subjects)
    includedSessions= [8];
    currentSubj= subjData.(subjects{subj})
    for session= includedSessions
        reblue= currentSubj(session).reblue;
        %simple 1st order fit
        fitpurple= controlFit(currentSubj(session).reblue, currentSubj(session).repurple);
        
        %launch gui app artifactParmeterTest(signal,reference)
        artifactParameterTest(reblue, fitpurple)
    end
end



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
    windowLengths= [100, 200, 300, 400, 500, 600, 800]; %define durations you want to test
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
    
%    close; %breakpoint here if you want to examine traces
    
%     %trying detrend function- doesn't work well
%         figure(figureCount); hold on; sgtitle(strcat('subject-',subjects{subj},'-',num2str(currentSubj(session).date),'-detrend function'));
%         subplot(2,1,1); hold on; title('raw');
%         plot(cutTime,reblue, 'b');
% %         plot(cutTime,medianblue, 'k');   
%         plot(cutTime, repurple,'m');
% %         plot(cutTime,medianpurple,'r');
%         subplot(2,1,2); hold on; title('detrended');
%         plot(cutTime, detrend(reblue),'b');
%         plot(cutTime, detrend(repurple), 'm');
%         
%         set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving/closing
%         figureCount=figureCount+1 
        
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
       
       artifactThreshold = std(currentSubj(session).repurple)*2; %single threshold
       
       repurple= currentSubj(session).repurple;% controlFit(currentSubj(session).reblue, currentSubj(session).repurple); %currentSubj(session).repurple;

       
       %moving threshold- repurple
       movBaseline= movmedian(repurple,1000);
%        movBaseline= detrend(repurple);
       movDev= movstd(abs(repurple),1000);
       movDev= std(currentSubj(session).repurple)*ones(size(repurple));
       movThresholdPos= movBaseline+movDev*4;
       movThresholdNeg= movBaseline-movDev*4;
       
       figure; hold on; plot(repurple,'-m');
       plot(movBaseline,'k');
       plot(movThresholdPos,'g');
       plot(movThresholdNeg,'g');
       
       close;
       
       subjDataAnalyzed.(subjects{subj})(session).photometrySignals.artifactThreshold= artifactThreshold; %save this value
      
       %go through each timestamp in repurple, calculating the delta
       %between this timestamp's value and the previous timestamp's value (dPurple)
       %TODO: this may be simpler using the diff() function
%         for timestamp= 1:numel(currentSubj(session).repurple)
%             if timestamp== 1
%                 currentSubj(session).dPurple(timestamp)= 0; %no change possible on the first timestamp
%             else
%                 currentSubj(session).dPurple(timestamp) = currentSubj(session).repurple(timestamp)-currentSubj(session).repurple(timestamp-1);
%             end  
%         end
    currentSubj(session).dPurple= [0;diff(repurple)]; %diff() fxn calculates difference between each timestamp
    
    dPurple= currentSubj(session).dPurple;
    
    %let's define a threshold beyond which we want to exclude data (noise)
    dThreshold = std(currentSubj(session).dPurple)*8;
    dMean= nanmean(currentSubj(session).dPurple); 
    
     %moving threshold- dPurple... picks up quite a few more 'artifacts'
        movBaseline= movmedian(currentSubj(session).dPurple,1000);
%        movBaseline= detrend(currentSubj(session).dPurple);
       movDev= movstd(abs(currentSubj(session).dPurple),4000);
%        movDev= ones(numel(movDev),1)*std(abs(currentSubj(session).dPurple));
%        movDev= std(currentSubj(session).dPurple)*ones(size(currentSubj(session).repurple));
       movDev= std(currentSubj(session).dPurple)*ones(size(currentSubj(session).dPurple));
       movThresholdPos= movDev*8;
       movThresholdNeg= -movDev*8;
       
       figure; hold on; plot(currentSubj(session).dPurple,'-m');
       plot(movBaseline,'k');
       plot(movThresholdPos,'g');
       plot(movThresholdNeg,'g');
    
       close;
       
       %moving
       dMean= nanmean(dPurple);%movBaseline; %moving baseline plot freezes for some reason
       dThreshold= movThresholdPos;
       
    %identify points that exceed this threshold
    dArtifactIndex= find(dPurple>dThreshold | dPurple<-dThreshold);
    
    dArtifactsVals= dPurple(dPurple>dThreshold | dPurple<-dThreshold);

    %lets instead base it on the raw repurple- will need to use a moving
    %threshold due to bleaching etc.
    reMean= movmedian(currentSubj(session).repurple,8000);
%     reDev= movstd(abs(currentSubj(session).repurple),1000);
    
    reThreshold= reMean+std(currentSubj(session).repurple)*ones(size(currentSubj(session).repurple))*4;
    
%     reMean= nanmean(currentSubj(session).repurple);
    
    reArtifactIndex= find(currentSubj(session).repurple>reThreshold | currentSubj(session).repurple<-reThreshold);
    
    reArtifactsVals= currentSubj(session).repurple(currentSubj(session).repurple>reThreshold | currentSubj(session).repurple<-reThreshold);

    figure; hold on; plot(currentSubj(session).repurple, 'm'); 
    plot(reMean, 'k',  'LineWidth', 2); 
    plot(reThreshold, 'r--');
    plot(-reThreshold, 'r--');
    scatter(reArtifactIndex, reArtifactsVals, 'gx');
    
    %Now, trying to exclude 'chunks' of artifact... Signal exceeds
    %threshold, but assume it will return below threshold at some point.
    %So, find the point when it crosses below threshold again and make all
    %the intervening data NaN
    
    %clear between sessions
    dArtifactIndexChunk=[]; artifactCount= [];
%     dArtifactIndexChunk(:,1)= find(dPurple>dThreshold | dPurple < -dThreshold); %all 'artifact' indices
    dArtifactIndexChunk(:,1)= find(abs(dPurple)>dThreshold); %all 'artifact' indices

    
    
    for artifactCount= 1:size(dArtifactIndexChunk,1)
         %find the first (min) index where the signal goes back below the threshold
         
         %a lot going on in this complicated line of code- what's happening
         %is for each artifact identified, we are comparing the rest of the
         %absolute change in the 405 signal (dPurple) from artifact onset to the end of the signal
         %to the dynamic threshold from the artifact onset to the end of
         %the signal. Then we are using find() to get an index of the
         %timestamp where the dPurple dips back below the
         %threshold. These indices are returned as relative to the artifact onset, so
         %we add the artifact onset to this to get an absolute index. Then
         %we get the min() index of this = The first timestamp after
         %artifact onset when the change dips back below the threshold
          
         %wrapped inside a conditional to check if the signal does indeed
         %go back below the threshold (if it's too close to the end of the
         %recording it may not)
         if ~isempty(find(abs(dPurple(dArtifactIndexChunk(artifactCount:end,1):end))<dThreshold(dArtifactIndexChunk(artifactCount:end,1):end))+dArtifactIndexChunk(artifactCount,1))
            dArtifactIndexChunk(artifactCount,2)= min(find(abs(dPurple(dArtifactIndexChunk(artifactCount:end,1):end))<dThreshold(dArtifactIndexChunk(artifactCount:end,1):end))+dArtifactIndexChunk(artifactCount,1));
         end
    end
     
%     %trying exclusion based on rolling z score of whole trace
%         %calculate rolling z score for whole trace - this actually
%         %occludes extreme values so it's not good
%             movingWindowFrames= 10*fs; %time to include in moving window / fs  
% 
%             rollingMeanPurple= movmean(currentSubj(session).repurple,movingWindowFrames); %moving mean
%             rollingStdPurple= movstd(currentSubj(session).repurple,movingWindowFrames); %moving std
% 
%             purple_normalized= (currentSubj(session).repurple-rollingMeanPurple)./rollingStdPurple; %now z scored trace simply based on moving baseline
% 
%             figure(figureCount); figureCount=figureCount+1; plot(purple_normalized, 'm');
            
    %Now exclude datapoints corresponding within the artifact windows
    
      %Let's actually remove the artifacts now
    
    cutTime= currentSubj(session).cutTime;
    
    
    %get the actual timestamp values to be excluded from cutTime
    excludedTimestamps = []; %initialize, will cat together in a loop
    for artifactCount= 1: size(dArtifactIndexChunk,1)
        %exclude from the beginning of the artifaact to the "end"
        %identified- this method didn't work very well
%         excludedTimestamps = [excludedTimestamps,dArtifactIndexChunk(artifactCount,1):dArtifactIndexChunk(artifactCount,2)];

        %perhaps easier to just take a fixed amount of time- including
        %bigger time periods should be ok but still am seeing remaining
        %artifact, I think there either needs to be a loop or the
        %artifact definition needs to change from instantaneous delta to
        %something else
        periArtifactTime= 10; %time in seconds around 'artifact start' to exclude
        excludedTimestamps= [excludedTimestamps, dArtifactIndexChunk(artifactCount,1)-periArtifactTime*fs:dArtifactIndexChunk(artifactCount,1)+periArtifactTime*fs];
    end
    %extract all timestmap values from cutTime that aren't equal to these
    %excluded timestamps
   
    %Need to make sure there are no 'exludedTimestamps' that fall outside
    %of potential values in cutTime... for example if an artifact is at the
    %very start or end of the recording we can't exclude beyond the
    %artifact
    excludedTimestamps(excludedTimestamps<=0)= []; 
    excludedTimestamps(excludedTimestamps>numel(cutTime))= [];
    
    %make these excluded timestamps NaN    cutTime(excludedTimestamps)= NaN;
%     %extract timestamps that aren't NaN
%     timeNoArtifact= cutTime(~isnan(cutTime));
        
    %now use the same strategy to extract photometry signals

    reblueNoArtifact= currentSubj(session).reblue;
    repurpleNoArtifact= repurple;
    reblueNoArtifact(excludedTimestamps)=nan;
    repurpleNoArtifact(excludedTimestamps)=nan;
    
    %visualize
       figure(figureCount); figureCount= figureCount+1; %1 fig per session
    sgtitle(strcat('Rat #',num2str(currentSubj(session).rat),'-',num2str(currentSubj(session).date), 'artifact detection'));
    subplot(1,3,subplotCount);
    subplotCount=subplotCount+1;
    hold on;
    plot(currentSubj(session).dPurple, 'm');
    
    title('dPurple');
    %overlay threshold
        plot(-dThreshold, 'k--');
        plot(dThreshold, 'k--');
%     plot([1,numel(currentSubj(session).dPurple)], [-dThreshold,-dThreshold], 'k--');
%     plot([1,numel(currentSubj(session).dPurple)], [dThreshold,dThreshold], 'k--');
    %overlay points beyond threshold (artifacts)
%     scatter(dArtifactIndex, dArtifactsVals, 'gx');
    if ~isempty(dArtifactIndexChunk) %prevents error if empty bc we are using a specific index (:,2)
         scatter(dArtifactIndexChunk(:,2), dArtifactsVals, 'gx');
    end

    
    % let's put these excluded timestamps over the raw purple trace to compare
    
       subplot(1, 3, subplotCount);
       subplotCount= subplotCount+1;
       hold on;
       plot(repurple, 'm'); %plot 405 signal
       title('repurple, artifact timestamps calculated based on dPurple');
       
       %overlay + and - the threshold relative to the mean 405 signal
%        plot([1,numel(repurple)], [nanmean(repurple) + artifactThreshold, nanmean(repurple) + artifactThreshold], 'k--')
%        plot([1,numel(repurple)], [nanmean(repurple) - artifactThreshold, nanmean(repurple) - artifactThreshold], 'k--')

%        scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(repurple), 'gx'); 
      if ~isempty(dArtifactIndexChunk) %conditional to prevent error in case empty
       scatter(dArtifactIndexChunk(:,1), ones(size(dArtifactIndexChunk,1),1)*artifactThreshold+nanmean(repurple), 'bx'); 
       scatter(dArtifactIndexChunk(:,2), ones(size(dArtifactIndexChunk,1),1)*artifactThreshold+nanmean(repurple), 'gx'); 
      end
       %plot blue too
       plot(currentSubj(session).reblue,'b');
        
    
        
       subplot(1, 3, subplotCount);
       subplotCount= subplotCount+1;
       hold on;
       plot(repurpleNoArtifact, 'm'); %plot 405 signal
       title('artifacts removed (nan)');

%        scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(repurple), 'gx'); 
      if ~isempty(dArtifactIndexChunk)
       scatter(dArtifactIndexChunk(:,1), ones(size(dArtifactIndex,1),1)*artifactThreshold+nanmean(repurple), 'bx'); 
       scatter(dArtifactIndexChunk(:,2), ones(size(dArtifactIndex,1),1)*artifactThreshold+nanmean(repurple), 'gx'); 
      end

       %plot blue too
       plot(reblueNoArtifact, 'b');

       set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    
%     close;
    
    
%      %identify points that exceed this (moving) threshold
%     dArtifactIndex= find(dPurple>dThreshold | dPurple<-dThreshold);
%     
%     dArtifactsVals= dPurple(dPurple>dThreshold | dPurple<-dThreshold);
    
% %    %visualize
% %     figure(figureCount); figureCount= figureCount+1; %1 fig per session
% %     sgtitle(strcat('Rat #',num2str(currentSubj(session).rat),'-',num2str(currentSubj(session).date), 'artifact detection'));
% %     subplot(1,3,subplotCount);
% %     subplotCount=subplotCount+1;
% %     hold on;
% %     plot(currentSubj(session).dPurple, 'm');
% %     
% %     title('dPurple');
% %     %overlay threshold
% %         plot(-dThreshold, 'k--');
% %         plot(dThreshold, 'k--');
% % %     plot([1,numel(currentSubj(session).dPurple)], [-dThreshold,-dThreshold], 'k--');
% % %     plot([1,numel(currentSubj(session).dPurple)], [dThreshold,dThreshold], 'k--');
% %     %overlay points beyond threshold (artifacts)
% %     scatter(dArtifactIndex, dArtifactsVals, 'gx');
% %    
% %     
% %     % let's put these excluded timestamps over the raw purple trace to compare
% %     
% %        subplot(1, 3, subplotCount);
% %        subplotCount= subplotCount+1;
% %        hold on;
% %        plot(repurple, 'm'); %plot 405 signal
% %        title('repurple, artifact timestamps calculated based on dPurple');
% %        
% %        %overlay + and - the threshold relative to the mean 405 signal
% %        plot([1,numel(repurple)], [nanmean(repurple) + artifactThreshold, nanmean(repurple) + artifactThreshold], 'k--')
% %        plot([1,numel(repurple)], [nanmean(repurple) - artifactThreshold, nanmean(repurple) - artifactThreshold], 'k--')
% % 
% %        scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(repurple), 'gx'); 
% %     
% %        %plot blue too
% %        plot(currentSubj(session).reblue,'b');
% %         

% %     %conservative threshold works well here- just looking for extreme
% %     %artifacts- big, abrupt changes
% %     
% %     %seems to work for most trials, but @ threshold = 10 std trhis misses a pretty big case for
% %     %VP-VTA-FP rat 9 trial 32
% %     
% %     %TODO: this is calculating dF timestamp by timestamp, but maybe we want to reject
% %     %rapid increases over a specific time period or do some kind of sliding
% %     %calculation
% % 
% %     %Let's actually remove the artifacts now
% %     
% %     cutTime= currentSubj(session).cutTime;
% %     
% %     %get the actual timestamp values to be excluded from cutTime
% %     excludedTimestamps = cutTime(dArtifactIndex);
% %         
% %     %extract all timestmap values from cutTime that aren't equal to these
% %     %excluded timestamps
% %     
% %     %make these excluded timestamps NaN
% %     cutTime(dArtifactIndex)= NaN;
% %     %extract timestamps that aren't NaN
% %     timeNoArtifact= cutTime(~isnan(cutTime));
% %     
% % %     disp(strcat('excluded_', num2str(numel(excludedTimestamps)), ' timestamps w/ artifacts '));
% %     
% %     %now use the same strategy to extract photometry signals
% % %     reblueNoArtifact= currentSubj(session).reblue(~isnan(cutTime));
% % %     repurpleNoArtifact= currentSubj(session).repurple(~isnan(cutTime));
% % 
% %     reblueNoArtifact= currentSubj(session).reblue;
% %     repurpleNoArtifact= repurple;
% %     reblueNoArtifact(isnan(cutTime))=nan;
% %     repurpleNoArtifact(isnan(cutTime))=nan;
% %     
% %    subplot(1, 3, subplotCount);
% %    subplotCount= subplotCount+1;
% %    hold on;
% %    plot(repurpleNoArtifact, 'm'); %plot 405 signal
% %    title('artifacts removed (nan)');
% % 
% %    scatter(dArtifactIndex, ones(numel(dArtifactIndex),1)*artifactThreshold+nanmean(repurple), 'gx'); 
% % 
% %    %plot blue too
% %    plot(reblueNoArtifact, 'b');
% % 
% %    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

   
   %this method doesn't seem to work well enough- but at least we have
   %decent timestamps of artifacts... we maybe we can use this to exclude TRIALS
   %instead of trying to remove the artifacts themselves?
   
   %maybe it would be best to just exlucde trials with huge z scores
   
   %Maybe instead of excluding trials, change the baseline z score calc in
   %some way (exclude timestamps?)
   
   % dp 1/19/21 have tried identifying 'artifacts' & excluding using either a static or rolling std and rolling mean of timestamp-
 %-to-timestamp delta in the 405 signal with varying parameters. This method is probably good for finding the 
 %start of an artifact but we don't know how big they are. It tends to miss the 'middle' of artifacts where
 %raw values are extreme but the instantaneous delta is relatively small
 %SO
   
   %save the artifact indices for each session & traces without artifacts
   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.dArtifactTimes= excludedTimestamps; %this is a list of the excluded timestamps
   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.cutTimeNoArtifacts= cutTime; %this is a time axis where timestamps with artifacts= NaN

   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.repurpleNoArtifact= repurpleNoArtifact;
   subjDataAnalyzed.(subjects{subj})(session).photometrySignals.reblueNoArtifact= reblueNoArtifact;
   %save figure
   
%   saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, num2str(currentSubj(session).date), '_ArtifactID','.tiff')); %save the current figure in fig format
%     close;
   end %end session loop
   
    %save figure
%    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_ArtifactID','.tiff')); %save the current figure in fig format

end %end subj loop
 

%% Compare peri-event plots between raw signal vs. signal without artifacts
for subj= 1:numel(subjects)
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
    
    %for heatplots- reset between subjects
    DSzblue= []; DSzpurple= []; DSzblueNoArtifact= []; DSzpurpleNoArtifact=[];
    
    for session = 1:numel(currentSubj)
        cutTime=[]; %reset between sessions
        cutTime= currentSubjAnalyzed(session).raw.cutTime;
        for cue = 1:numel(currentSubjAnalyzed(session).periDS.DS)
            %find the index corresponding to the first and last timestamps of this event's window
            preEventTime= find(cutTime==currentSubjAnalyzed(session).periDS.periDSwindow(:,1,cue));
            postEventTime= find(cutTime==currentSubjAnalyzed(session).periDS.periDSwindow(:,end,cue));
           
            %use that index to get signal within the peri event window
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSblueNoArtifact(:,:,cue)= currentSubjAnalyzed(session).photometrySignals.reblueNoArtifact(preEventTime:postEventTime); 
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurpleNoArtifact(:,:,cue)= currentSubjAnalyzed(session).photometrySignals.repurpleNoArtifact(preEventTime:postEventTime);
        
            %need to get a baseline mean & std for Z score of signal without artifact
            baselineMeanblue(cue)=nanmean(currentSubjAnalyzed(session).photometrySignals.reblueNoArtifact(currentSubjAnalyzed(session).periDS.baselineWindow(:,:,cue))); %baseline mean blue 10s prior to DS onset for boxA
            baselineMeanpurple(cue)= nanmean(currentSubjAnalyzed(session).photometrySignals.repurpleNoArtifact(currentSubjAnalyzed(session).periDS.baselineWindow(:,:,cue)));
            
            baselineStdblue(cue)= nanstd(currentSubjAnalyzed(session).photometrySignals.reblueNoArtifact(currentSubjAnalyzed(session).periDS.baselineWindow(:,:,cue)));
            baselineStdpurple(cue)= nanstd(currentSubjAnalyzed(session).photometrySignals.repurpleNoArtifact(currentSubjAnalyzed(session).periDS.baselineWindow(:,:,cue)));
       
            %calculate a z score using this baseline
            
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblueNoArtifact(:,:,cue)= (((currentSubjAnalyzed(session).photometrySignals.reblueNoArtifact(preEventTime:postEventTime))-baselineMeanblue(cue)))/(baselineStdblue(cue)); 
            subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurpleNoArtifact(:,:,cue)= (((currentSubjAnalyzed(session).photometrySignals.repurpleNoArtifact(preEventTime:postEventTime))-baselineMeanpurple(cue)))/(baselineStdpurple(cue)); 
        end %end DS loop
       
        currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj}); 
       
        figure; hold on; sgtitle('raw vs. artifact removed periDS');
        subplot(2,1,1); hold on; title('raw');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSblue), 'b');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSpurple), 'm');
        
        subplot(2,1,2); hold on; title('noArtifact');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSblueNoArtifact),'b');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSpurpleNoArtifact),'m');
        
        linkaxes();
        
        close;
        
        figure; hold on; sgtitle('raw vs. artifact removed periDS baseline for z calc');
        subplot(2,1,1); hold on; title('raw');
        plot(squeeze(currentSubjAnalyzed(session).periDS.baselineMeanblue), 'b');
        plot(squeeze(currentSubjAnalyzed(session).periDS.baselineMeanpurple), 'm');
        
        subplot(2,1,2); hold on; title('noArtifact');
        plot(squeeze(baselineMeanblue),'b');
        plot(squeeze(baselineMeanpurple),'m');
        
        linkaxes();
        
        close;
        
        figure; hold on; sgtitle('raw vs. artifact removed periDS z score');
        subplot(2,1,1); hold on; title('raw');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSzblue), 'b');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSzpurple), 'm');
        
        subplot(2,1,2); hold on; title('noArtifact');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSzblueNoArtifact),'b');
        plot(squeeze(currentSubjAnalyzed(session).periDS.DSzpurpleNoArtifact),'m');
        
        linkaxes();
        
        close;
           
        %cat data from all sessions into one array for heatplots
        DSzblue= [DSzblue,squeeze(currentSubjAnalyzed(session).periDS.DSzblue)]; 
        DSzpurple= [DSzpurple, squeeze(currentSubjAnalyzed(session).periDS.DSzpurple)];
        DSzblueNoArtifact= [DSzblueNoArtifact, squeeze(currentSubjAnalyzed(session).periDS.DSzblueNoArtifact)];
        DSzpurpleNoArtifact= [DSzpurpleNoArtifact, squeeze(currentSubjAnalyzed(session).periDS.DSzpurpleNoArtifact)];
        
        
    end %end session loop
    
    %      %define color axes
%      %get the avg std in the blue and purple z score responses to all cues,
%      %get absolute value and then multiply this by some factor to define a color axis max and min
%      
     stdFactor= 4; %multiplicative factor- how many stds away should we set our max & min color value?
    
    %get minimum and maximum value for colorbar
    top= stdFactor*abs(nanmean((nanstd([DSzblue, DSzblueNoArtifact, DSzpurple, DSzpurpleNoArtifact], 0, 2))));
    bottom= -stdFactor*abs(nanmean((nanstd([DSzblue, DSzblueNoArtifact, DSzpurple, DSzpurpleNoArtifact], 0, 2))));

%     bottom= min(min([DSzblue, DSzblueNoArtifact, DSzpurple, DSzpurpleNoArtifact],[],2)); 
%     top= max(max([DSzblue, DSzblueNoArtifact, DSzpurple, DSzpurpleNoArtifact], [],2));
    
    %heatplots
    figure; hold on; sgtitle('raw vs noArtifact periDS heatplots');
    subplot(2,2,1); hold on; title('raw 465');
    caxis manual; caxis([bottom, top]);

    imagesc(DSzblue');
    subplot(2,2,2); hold on; title('raw 405');
    caxis manual; caxis([bottom, top]);

    imagesc(DSzpurple');
    subplot(2,2,3); hold on; title('noArtifact 465');
    caxis manual; caxis([bottom, top]);

    imagesc(DSzblueNoArtifact');
    subplot(2,2,4); hold on; title('noArtifact 405');
    imagesc(DSzpurpleNoArtifact');
    caxis manual; caxis([bottom, top]);
    
    colorbar;
    
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

    
end %end subj loop




%% Exclude artifact trials (old code needs to be adapted)
% %Now that we have timestamps of 'artifacts', check if the peri-event window
% %includes an artifact. If so, exclude this trial.
% 
% 
% for subj= 1:numel(subjectsAnalyzed) %for each subject
% currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
%     for session = 1:numel(currentSubj) %for each training session this subject completed
% 
%         %go through each session and check to see if periDS window contains an
%         %excluded timestamp (due to artifact being detected)
%         DSincluded = size(currentSubj(session).periDS.periDSwindow,3);
% 
%         DSexcluded= []; %keep track of which cues were excluded for this session
% 
%             for cue = 1:DSincluded
%                 preEventTimeDS= currentSubj(session).periDS.periDSwindow(:,1,cue);
%                 postEventTimeDS= currentSubj(session).periDS.periDSwindow(:,end,cue);
% 
%                 for artifact= currentSubj(session).photometrySignals.dArtifactTimes
%                     %if artifact occurs between preEventTime and postEventTime
%                     if artifact>preEventTimeDS && artifact<postEventTimeDS
%                         disp(strcat('rat_ ', num2str(currentSubj(1).rat), ' session ', num2str(session), ' artifact detected, exluding DS_', num2str(cue), ' from heat plot'))
%                         DSexcluded= [DSexcluded, cue]; %add this cue to the list of excluded cues for this session
%                         continue; %if this cue has an artifact, we don't need to keep checking anymore
%                     end
%                 end
%             end
% 
%             currentSubj(session).periDS.DSexcludedArtifact= DSexcluded; %save list of excluded cues for each session
% 
%             %now that we have excluded cues, let's go in and extract only data
%             %from included cues
% 
%             for excludedTrial = DSexcluded
%                 %make all the dat in excluded trials = nan
%                 currentSubj(session).periDS.DSzblue(:,:,excludedTrial)= nan; %first make all these values nan
%                 currentSubj(session).periDS.DSzpurple(:,:,excludedTrial)=nan; 
%             end
% 
% 
%       %collect all z score responses to every single DS across all sessions (and the latency to PE in response to every single DS)
%             if session==1
%                 currentSubj(1).DSzblueAllTrials= squeeze(currentSubj(session).periDS.DSzblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
%                 currentSubj(1).DSzpurpleAllTrials= squeeze(currentSubj(session).periDS.DSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
% 
%             else
%                 currentSubj(1).DSzblueAllTrials = cat(2, currentSubj.DSzblueAllTrials, (squeeze(currentSubj(session).periDS.DSzblue))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
%                 currentSubj(1).DSzpurpleAllTrials = cat(2, currentSubj.DSzpurpleAllTrials, (squeeze(currentSubj(session).periDS.DSzpurple))); %concatenate- this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
%             end
% 
%             %repeat above steps for NS
%             
%         if ~isempty(currentSubj(session).periNS.periNSwindow) %only run if there's NS data present
%             NSincluded = size(currentSubj(session).periNS.periNSwindow,3);
% 
%             NSexcluded= []; %keep track of which cues were excluded for this session
% 
%                 for cue = 1:NSincluded
%                     preEventTimeNS= currentSubj(session).periNS.periNSwindow(:,1,cue);
%                     postEventTimeNS= currentSubj(session).periNS.periNSwindow(:,end,cue);
% 
%                     for artifact= currentSubj(session).photometrySignals.dArtifactTimes
%                         %if artifact occurs between preEventTime and postEventTime
%                         if artifact>preEventTimeNS && artifact<postEventTimeNS
%                             disp(strcat('rat_ ', num2str(currentSubj(1).rat), ' session ', num2str(session), ' artifact detected, exluding NS_', num2str(cue), ' from heat plot'))
%                             NSexcluded= [NSexcluded, cue]; %add this cue to the list of excluded cues for this session
%                             continue; %if this cue has an artifact, we don't need to keep checking anymore
%                         end
%                     end
%                 end
% 
%                 currentSubj(session).periNS.NSexcludedArtifact= NSexcluded; %save list of excluded cues for each session
% 
%                 %now that we have excluded cues, let's go in and extract only data
%                 %from included cues
% 
%                 for excludedTrial = NSexcluded
%                     %make all the dat in excluded trials = nan
%                     currentSubj(session).periNS.NSzblue(:,:,excludedTrial)= nan; %first make all these values nan
%                     currentSubj(session).periNS.NSzpurple(:,:,excludedTrial)=nan; 
%                 end
% 
% 
%           %collect all z score responses to every single DS across all sessions (and the latency to PE in response to every single NS)
%                 if session==1
%                     currentSubj(1).NSzblueAllTrials= squeeze(currentSubj(session).periNS.NSzblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
%                     currentSubj(1).NSzpurpleAllTrials= squeeze(currentSubj(session).periNS.NSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
% 
%                 else
%                     currentSubj(1).NSzblueAllTrials = cat(2, currentSubj.NSzblueAllTrials, (squeeze(currentSubj(session).periNS.NSzblue))); %concatenate- this contains z score response to NS from every NS (should have #columns= ~30 cues x #sessions)
%                     currentSubj(1).NSzpurpleAllTrials = cat(2, currentSubj.NSzpurpleAllTrials, (squeeze(currentSubj(session).periNS.NSzpurple))); %concatenate- this contains z score response to NS from every NS (should have #columns= ~30 cues x #sessions)
%                 end
%                  
%         else %if there's no NS data present
%             currentSubj(1).NSzblueAllTrials= [];
%             currentSubj(1).NSzpurpleAllTrials= [];    
%         end %end NS conditional
%         
%     end %end session loop
% 
%     %Transpose these data for readability
%     currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials';
%     currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';
%    
%     if ~isempty(currentSubj(1).NSzblueAllTrials)
%         currentSubj(1).NSzblueAllTrials= currentSubj(1).NSzblueAllTrials';
%         currentSubj(1).NSzpurpleAllTrials= currentSubj(1).NSzpurpleAllTrials';
%     end
%      %Color axes   
%      
%      %First, we'll want to establish boundaries for our colormaps based on
%      %the std of the z score response. We want to have equidistant
%      %color axis max and min so that 0 sits directly in the middle
%      
%      %TODO: should this be a pooled std calculation (pooled blue & purple)?
%      
%      %define DS color axes
%      
%      %get the avg std in the blue and purple z score responses to all cues,
%      %get absolute value and then multiply this by some factor to define a color axis max and min
%      
%      stdFactor= 4;
%      
%      %need to use nanmean now bc we have nans on excluded trials
%      topDSzblue= stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%      topDSzpurple= stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%      bottomDSzblue = -stdFactor*abs(nanmean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%      bottomDSzpurple= -stdFactor*abs(nanmean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
%      
%      %now choose the most extreme of these two (between blue and
%      %purple)to represent the color axis 
%      bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
%      topAllDS= max(topDSzblue, topDSzpurple);
%      
%         %same defining color axes for NS
%     if ~isempty(currentSubj(1).NSzblueAllTrials) %only run this if there's NS data
%         topNSzblue= stdFactor*abs(nanmean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
%         topNSzpurple= stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
% 
%         bottomNSzblue= -stdFactor*abs(nanmean((std(currentSubj(1).NSzblueAllTrials, 0, 2))));
%         bottomNSzpurple= -stdFactor*abs(nanmean((std(currentSubj(1).NSzpurpleAllTrials, 0, 2))));
% 
%         bottomAllNS= min(bottomNSzblue, bottomNSzpurple);
%         topAllNS= max(topNSzblue, topNSzpurple);
%     end
%     %Establish a shared bottom and top for shared color axis of DS & NS
%     if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is an NS
%         bottomAllShared= min(bottomAllDS, bottomAllNS); %find the absolute min value
%         topAllShared= max(topAllDS, topAllNS); %find the absolute min value
%     else
%         bottomAllShared= bottomAllDS;
%         topAllShared= topAllDS;
%     end
%            
%     
%     %get a trial count to use for the heatplot ytick
%     currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzblueAllTrials,1); 
%     currentSubj(1).totalNScount= 1:size(currentSubj(1).NSzblueAllTrials,1); 
% 
%     %save for later 
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.totalDScount= currentSubj(1).totalDScount;
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.bottomAllShared= bottomAllShared;
%     subjDataAnalyzed.(subjectsAnalyzed{subj})(1).periDS.topAllShared= topAllShared;
%     
%     %TODO: split up yticks by session (this would show any clear differences between days)
%     
%      %Heatplots!       
%     %DS z plot
%     figure(figureCount);
%     hold on;
%     subplot(2,2,1); %subplot for shared colorbar
% 
%     %plot blue DS
% 
%     timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
% 
%     heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
%     title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding every DS- ARTIFACT TRIALS REMOVED ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
%     xlabel('seconds from cue onset');
%     ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
% %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
%     caxis manual;
%     caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
% 
%     c= colorbar; %colorbar legend
%     c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
% 
% 
%     %   plot purple DS (subplotted for shared colorbar)
%     subplot(2,2,3);
%     heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 
% 
%     title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding every DS- ARTIFACT TRIALS REMOVED ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
%     xlabel('seconds from cue onset');
%     ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
% 
% %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
% 
%     caxis manual;
%     caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
%     
%     c= colorbar; %colorbar legend
%     c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
% 
%     set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
%     saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials_ArtifactRemoved','.fig')); %save the current figure in fig format
% 
%       if ~isempty(currentSubj(1).NSzblueAllTrials) %if there is NS data
%         
%         %plot blue NS
%         subplot(2,2,2); %subplot for shared colorbar
% 
%         heatNSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzblueAllTrials);
%         title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' blue z score response surrounding every NS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
%         xlabel('seconds from cue onset');
%         ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
%     %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
%         caxis manual;
%         caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
% 
%         c= colorbar; %colorbar legend
%         c.Label.String= strcat('NS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');
%         
%         
%            %   plot purple NS (subplotted for shared colorbar)
%         subplot(2,2,4);
%         heatNSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalNScount,currentSubj(1).NSzpurpleAllTrials); 
% 
%         title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding every NS ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
%         xlabel('seconds from cue onset');
%         ylabel(strcat('NS trial (n= ', num2str(currentSubj(1).totalNScount(end)), ')'));
% 
%     %     set(gca, 'ytick', currentSubj(1).totalNScount); %label trials appropriately
% 
%         caxis manual;
%         caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
% 
%         c= colorbar; %colorbar legend
%         c.Label.String= strcat('NS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');
% 
%         set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% 
%         saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_periCueZ_AllTrials','.fig')); %save the current figure in fig format
%     end
%     
%     
%     
%     figureCount= figureCount+1;

% end%end subj loop




%% another method

D.signal = repurple;
signal = D.signal;
t = (0:length(signal)-1)';                              % Create Time Vector
p = polyfit(t, signal, 2);                              % Polynomial Fit For Detrending
dtrnd_sig = signal - polyval(p, t);                     % Detrend
t2 = t;                                                 % Temporary Time Vector
signal(dtrnd_sig < -100) = [];                          % Set Signal ‘Dips’ To ‘Empty’
t2(dtrnd_sig < -100) = [];                              % Set Corresponding Time Of ‘Dips’ To ‘Empty’
signal_new = interp1(t2, signal, t, 'linear');          % Interpolate To Fill Missing Data
figure(1); hold on;
subplot(3,1,1); title('signal new');
plot(t,signal_new,'-r');
subplot(3,1,2); title('signal interp');
plot(t,D.signal,'-m');
% subplot(3,1,3); title('signal cut');
% plot(t2,'-g');

%% yet another- this one seems like it needs some kind of moving calculation
% https://www.mathworks.com/matlabcentral/answers/358022-how-to-remove-artifacts-from-a-signal

for subj= 1:numel(subjDataAnalyzed)
    currentSubj= subjData.(subjects{subj});
    for session= 1:numel(currentSubj)
        
        %clear variables
        signal= []; d= []; isValid=[]; signalCut=[]; signalClean=[];
        signal= currentSubj(session).repurple;

        d = [0; diff( signal )] ; 
        
        threshold= std(d)*5; %adjust threshold

        
        isValid = ~logical( cumsum( -sign( d ) .* (abs( d ) > threshold) )) ;
        %fill w nan
        signalCut = signal ;
        signalCut(~isValid) = NaN ;
        %or interpolate
        t = 1 : numel( signal ) ;
        signalClean = interp1( t(isValid), signal(isValid), t ) ;
        %vis 
        figure(figureCount); figureCount=figureCount+1;
        subplot( 4, 1, 1) ;  plot( signal, 'b', 'LineWidth', 2 ) ;
        grid ;  title( 'Signal' ) ;
        subplot( 4, 1, 2 ) ;  plot( isValid, 'r', 'LineWidth', 2 ) ;
        grid ;  title( '"is valid"' ) ;
        subplot( 4, 1, 3) ;  plot( signalCut, 'g', 'LineWidth', 2 ) ;
        grid ;  title( 'Cut signal' ) ;
        subplot( 4, 1, 4) ;  plot( signalClean, 'm', 'LineWidth', 2 ) ;
        grid ;  title( 'Cleaned signal' ) ;
    end
end

    %% One more method here - this one is good but appears to eliminate calcium events
    %adapted from https://www.mathworks.com/matlabcentral/answers/358022-how-to-remove-artifacts-from-a-signal
    %ImageAnalyst: You can detect "bad" elements either by computing the MAD and then thresholding to identify them, and then replacing them with zero or NAN (whichever you want)    
for subj= 1:numel(subjDataAnalyzed)
    currentSubj= subjData.(subjects{subj});
    for session= 1:numel(currentSubj)

        %first, let's determine direction of changes in 465nm and 405nm signal...
%artifacts should be limited to times when 405nm and 465nm are trending in the same direction
%else, we might accidentally remove some calcium events (where ca++ is driving a dip in the 405nm signal)
        dReblue= diff(currentSubj(session).reblue);
        dRepurple= diff(currentSubj(session).repurple);

    
        %I think if this is done over a rolling window it will work better, instantaeous change is too quick 
        dReblue= movmean(dReblue, 2*fs);
        dRepurple= movmean(dRepurple, 2*fs);

        trendAgrees= zeros(size(dReblue));
        
        trendAgrees(dReblue>0 & dRepurple>0)= 1; 
        trendAgrees(dReblue<0 & dRepurple<0)=1; 
        
        figure;
        subplot(3,1,1); hold on; title('diff reblue');
        plot(dReblue, 'b');
        subplot(3,1,2); hold on; title('diff repurple');
        plot(dRepurple, 'm');
        subplot(3,1,3); hold on; title('trend agrees');
        plot(trendAgrees);
        plot([trendAgrees,trendAgrees],[zeros(size(trendAgrees)), ones(size(trendAgrees))]);
        
        %begin artifact id & removal
        s.signal = controlFit(currentSubj(session).reblue, currentSubj(session).repurple); %currentSubj(session).repurple;

        signal = s.signal;

        % Now fix the signal.
%         windowWidth = 60*fs; %DEFINE TIME WINDOW
        %as it stands, longer window = higher threshold, smoother MAD
        %also makes "blurred" signal sharper
        
        %15s window seems pretty good
        
        %two versions of this, original uses convolution to "blur"/smoothen the
        %signal and gets the mean absolute difference between actual signal
        %and this "blurred" version... I think the "blurred" version is
        %acting as a rough moving baseline in this way. Instead of doing
        %this I also made a version that uses the movmad() function to
        %compute a moving median absolute deviation of the signal. Whatever
        %method is used, then check if MAD is above some threshold and
        %remove timestamps where it is.
        convWindowWidth = round([1, 2, 3] * fs); %time window sizes to test ; round bc needs to be integer for indexing
        thresholdWindowWidth= round([2]*fs)
        for convwindow= convWindowWidth %loop throught window sizes
            figure; sgtitle(strcat('window width=',num2str(convwindow/fs),'s'));
            ax1= subplot(4, 1, 1);
            plot(signal, 'm-'); hold on; title('signal');
            plot(currentSubj(session).reblue, 'b');
            grid on;
            kernel = ones(1, convwindow) / convwindow;
            blurredSignal = conv(signal, kernel, 'same');
            ax2= subplot(4, 1, 2); hold on; title('blurredSignal');
            plot(blurredSignal, 'm-');
            grid on;
%             MAD= movstd(signal, windowWidth);
%             MAD= movmad(signal, window/2); %new method, using movmad()
            MAD = abs(signal - blurredSignal); %original method, using conv()
            ax3= subplot(4, 1, 3);
            plot(MAD, 'm-'); hold on; title('mean absolute difference (MAD)')
            grid on;
    %         threshold= mean(MAD)+2*std(MAD); %10; %DEFINE THRESHOLD- original method, static
    %         threshold= movmedian(MAD, windowWidth)+std(MAD)*2; %worked ok, misses some of #2, bad #4
    %         threshold= movmean(MAD, windowWidth)+std(MAD)*2; %worked ok, misses some of #2, may hit some ca events
                threshold= movmean(MAD, thresholdWindowWidth)+std(MAD)*3; %does pretty well, misses some of 2 but hits #4
    %         yline(threshold, 'r--'); %plot static threshold
            plot(threshold, 'r--') %plot dynamic threshold
            badIndexes= MAD>threshold;%MAD(trendAgrees==1)>threshold(trendAgrees==1);
            fixedSignal= signal;
            fixedSignal(badIndexes)=nan;
            currentSubj(session).reblue(badIndexes)= nan;
            ax4= subplot(4, 1, 4); hold on; title('fixedSignal');
            plot(fixedSignal, 'm-');
            grid on;
            plot(currentSubj(session).reblue,'b');
            linkaxes([ax1,ax3,ax4],'x'); linkaxes([ax1,ax4],'y');
        end %end loop through window sizes 
        
        
        %trying to make interactive plot with GUI to easily test parameters

    end
end
    
    %% another
    
        %run the fxn
    cleanSignal= deleteArtifactMax(repurple, .05, 'false')
    figure;
    subplot(2,1,1); hold on; title('raw signal');
    plot(repurple,'-m');
    subplot(2,1,2); hold on; title('clean signal');
    plot(cleanSignal,'-k');
    
        %define the fxn
    function signal = deleteArtifactMax(signal, threshold, interpolation)
      global samplingFrequency maxInterpolationDuration;
       %vis- added by dp 
        figure();
        subplot( 4, 1, 1) ; hold on;
        plot( signal, 'm', 'LineWidth', 2 ) ;
        grid ;  title( 'Signal' ) ;
      
      signal(isnan(signal)) = 0;
      time = repmat([1:size(signal,1)]',1,size(signal,2));
      movingAverage = (...
          signal(1:end-9,:) + ...
          signal(2:end-8,:) + ...
          signal(3:end-7,:) + ...
          signal(4:end-6,:) + ...
          signal(5:end-5,:) + ...
          signal(6:end-4,:) + ...
          signal(7:end-3,:) + ...
          signal(8:end-2,:) + ...
          signal(9:end-1,:) + ...
          signal(10:end,:))/10;
      isValid = abs(signal(5:end-5,:) - movingAverage) <= movingAverage*threshold;
      notValid = logical([zeros(4,size(signal,2)); ~isValid; zeros(5,size(signal,2))]);
      signal(notValid) = NaN;
      signal(signal == 0) = NaN;
      timeCut = time .* notValid;
      
      
      for i = 1:size(signal,2)
          timeCutCell{i} = find(timeCut(:,i) ~= 0);
      end
      
             %vis - added by dp
        plot(movingAverage, 'k'); plot(movingAverage*threshold, 'r--');
        subplot( 4, 1, 2 ) ;  plot( timeCut, 'r', 'LineWidth', 2 ) ;
        grid ;  title( '"is valid"' ) ;
        subplot( 4, 1, 3) ;  plot( signal, 'g', 'LineWidth', 2 ) ;
        grid ;  title( 'Cut signal' ) ;
%         subplot( 4, 1, 4) ;  plot( signalClean, 'm', 'LineWidth', 2 ) ;
%         grid ;  title( 'Cleaned signal' ) ;
      
      
      if interpolation == true
          for i = 1:size(signal,2)
              if ~isempty(timeCutCell{1,i})
                  % Delete too long interpolation
                  iNotToInterpolate = [];
                  dTimeCutCell = [0; diff(timeCutCell{:,i})];
                  k=0;
                  for j=1:size(dTimeCutCell)
                      if dTimeCutCell(j) == 1
                          k=k+1;
                      else
                          if k > maxInterpolationDuration*60/samplingFrequency
                              iNotToInterpolate = [iNotToInterpolate j-k:j-1];
                          end
                          k=0;
                      end
                  end
                  % Selection of points to interpolate
                  iToInterpolate = setdiff(timeCutCell{1,i},timeCutCell{1,i}(iNotToInterpolate));
                  interpTime = time(:,i);
                  interpTime(iToInterpolate) = [];
                  interpSignal = signal(:,i);
                  interpSignal(iToInterpolate) = [];
                  % Interpolation
                  signal(iToInterpolate,i) = interp1(interpTime, interpSignal, iToInterpolate, 'linear');
              end
          end
      end
    end
    
    

