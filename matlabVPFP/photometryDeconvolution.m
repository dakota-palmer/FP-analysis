%% Trying deconvolution

%Assume that total fluorescence = Sum(event evoked fluorescence + noise)
%Assume that event evoked fluorescence is consistent (doesn't vary between trials)


clear;
close all;
clc;

%% first load data
load(uigetfile('*.mat')); %load subjDataAnalyzed.mat generated by fpAnalyzeData.m

%initialize variables
subjects= fieldnames(subjDataAnalyzed);
flagThreshold= 0.2; %t in seconds to flag shifted event timestamps (since we shift event timestamps to make them match the downsampled time window) 
fs=40; %sampling frequency
%% Exclude data
for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    excludedSessions= [];
    for session= 1:numel(currentSubj)
        if currentSubj(session).trainStage ~= 7 %only include stage 7 days
           excludedSessions= cat(2,excludedSessions,session);
        end
    end%end session loop
   subjDataAnalyzed.(subjects{subj})(excludedSessions)= []; 
   
   currentSubj= subjDataAnalyzed.(subjects{subj});
   excludedSessions= [];
   for session= 1:numel(currentSubj) %loop through again and get rid of all except final stage 7 day
       if session<numel(currentSubj)
           excludedSessions= cat(2,excludedSessions,session);
       end
   end%end session loop 2
   
   subjDataAnalyzed.(subjects{subj})(excludedSessions)= []; 
   
end %end subj loop

%% get timestamps of events and photometry data from all trials   
trialCount= 0; %counter for total number of trials 

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       timeLock= currentSubj(session).periDS.timeLock;
       for cue= 1:numel(currentSubj(session).periDS.DS) %for each cue (trial) in this session
                     
           trialCount=trialCount+1; %count all trials between sessions & subjects 
 
       %Get cue timestamp TODO: change definition of trial start time to
       %introduce variability
           eventMaskCue(trialCount,:)=zeros(size(timeLock));
           eventMaskCue(trialCount, find(currentSubj(session).periDS.timeLock==0))= 1;
            
           
       %Get PE timestamps
           if ~isempty(currentSubj(session).behavior.poxDS{cue}) %only run if PE during this cue
               poxDS{trialCount,:}= currentSubj(session).behavior.poxDS{cue}-currentSubj(session).periDS.DS(cue); %get timestamps of PEs relative to DS
           else
               poxDS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskFirstPox(trialCount,:)= zeros(size(timeLock));
           
           %Important step! Shifting event timestamp to match timeLock
          poxDS{trialCount,:}= interp1(timeLock,timeLock, poxDS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(poxDS{trialCount,:}) %only run if there's a valid pe on this trial
              eventInd= find(timeLock(1,:)==poxDS{trialCount,:}(1)); %get index of timestamp corresponding to this event
              eventMaskFirstPox(trialCount,eventInd)= 1;  %replace 0s with 1s for first pe on this trial
                            
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(poxDS{trialCount,:}(1)-currentSubj(session).behavior.DSpeLatency(cue));
                if abs(timeShift(trialCount)) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconds)
                    disp(strcat('>>Error *big pox time shift_', num2str(timeShift(trialCount)), '; subj_', num2str(subj), '; sess_', num2str(session), '; cue_',num2str(cue)));
                end                
           end
           
            %Get lick timestamps
           if ~isempty(currentSubj(session).behavior.loxDS{cue}) %only run if PE during this cue
               loxDS{trialCount,:}= currentSubj(session).behavior.loxDS{cue}-currentSubj(session).periDS.DS(cue); %get timestamps of licks relative to DS
           else
               loxDS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskFirstLox(trialCount,:)= zeros(size(timeLock));
           
           %Important step!! Shifting event timestamp to match timeLock
          loxDS{trialCount,:}= interp1(timeLock,timeLock, loxDS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(loxDS{trialCount,:}) %only run if there's a valid pe on this trial
              eventInd= find(timeLock(1,:)==loxDS{trialCount,:}(1)); %get index of timestamp corresponding to this event
              eventMaskFirstLox(trialCount,eventInd)= 1;  %replace 0s with 1s for first pe on this trial
                            
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(loxDS{trialCount,:}(1)-currentSubj(session).behavior.loxDSrel{cue}(1));
                if abs(timeShift(trialCount)) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconds)
                    disp(strcat('>>Error *big lox time shift_', num2str(timeShift(trialCount)), '; subj_', num2str(subj), '; sess_', num2str(session), '; cue_',num2str(cue)));
                end                
           end
           
          %Get z score of 465nm photometry signal- timelocked to every event
          periCueBlueAllTrials(:,trialCount)= currentSubj(session).periDS.DSzblue(:,:,cue);
          periPoxBlueAllTrials(:,trialCount)= currentSubj(session).periDSpox.DSzpoxblue(:,:,cue);
          periLoxBlueAllTrials(:,trialCount)= currentSubj(session).periDSlox.DSzloxblue(:,:,cue);
          
          %Get z score of 405nm photometry signal- timelocked to every event
          periCuePurpleAllTrials(:, trialCount)= currentSubj(session).periDS.DSzpurple(:,:,cue);
          periPoxPurpleAllTrials(:,trialCount)= currentSubj(session).periDSpox.DSzpoxpurple(:,:,cue);
          periLoxPurpleAllTrials(:,trialCount)= currentSubj(session).periDSlox.DSzloxpurple(:,:,cue);
          
          
          %Add subj label for this trial
          subjLabel(:,trialCount)= ones(size(timeLock))'*subj;
           
          %Add trial type label for this trial
          trialTypeLabel(:,trialCount)= ones(size(timeLock))'; %1 for DS
          
          %keep track of timestamps              
          timeToCue(:,trialCount)= timeLock;

       end %end DS cue (trial) loop
       
       %Now repeat for NS
       for cue= 1:numel(currentSubj(session).periNS.NS) %for each cue (trial) in this session
           trialCount=trialCount+1; %count all trials between sessions & subjects 
           
       %Get cue timestamp TODO: change definition of trial start time to
       %introduce variability
           eventMaskCue(trialCount,:)=zeros(size(timeLock));
           eventMaskCue(trialCount, find(timeLock==0))= 1;
           
       %Get PE timestamps
           if ~isempty(currentSubj(session).behavior.poxNS{cue}) %only run if PE during this cue
               poxNS{trialCount,:}= currentSubj(session).behavior.poxNS{cue}-currentSubj(session).periNS.NS(cue); %get timestamps of PEs relative to NS
           else
               poxNS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskFirstPox(trialCount,:)= zeros(size(timeLock));
           
           %Important step!! Shifting event timestamp to match timeLock
          poxNS{trialCount,:}= interp1(timeLock,timeLock, poxNS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(poxNS{trialCount,:}) %only run if there's a valid pe on this trial
              eventInd= find(timeLock(1,:)==poxNS{trialCount,:}(1)); %get index of timestamp corresponding to this event
              eventMaskFirstPox(trialCount,eventInd)= 1;  %replace 0s with 1s for first pe on this trial
                            
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(poxNS{trialCount,:}(1)-currentSubj(session).behavior.NSpeLatency(cue));
                if abs(timeShift(trialCount)) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconNS)
                    disp(strcat('>>Error *big pox time shift_', num2str(timeShift(trialCount)), '; subj_', num2str(subj), '; sess_', num2str(session), '; cue_',num2str(cue)));
                end                
           end
           
            %Get lick timestamps
           if ~isempty(currentSubj(session).behavior.loxNS{cue}) %only run if PE during this cue
               loxNS{trialCount,:}= currentSubj(session).behavior.loxNS{cue}-currentSubj(session).periNS.NS(cue); %get timestamps of PEs relative to NS
           else
               loxNS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskFirstLox(trialCount,:)= zeros(size(timeLock));
           
           %Important step!! Shifting event timestamp to match timeLock
          loxNS{trialCount,:}= interp1(timeLock,timeLock, loxNS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(loxNS{trialCount,:}) %only run if there's a valid pe on this trial
              eventInd= find(timeLock(1,:)==loxNS{trialCount,:}(1)); %get index of timestamp corresponding to this event
              eventMaskFirstLox(trialCount,eventInd)= 1;  %replace 0s with 1s for first pe on this trial
                            
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(loxNS{trialCount,:}(1)-currentSubj(session).behavior.loxNSrel{cue}(1));
                if abs(timeShift(trialCount)) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconNS)
                    disp(strcat('>>Error *big lox time shift_', num2str(timeShift(trialCount)), '; subj_', num2str(subj), '; sess_', num2str(session), '; cue_',num2str(cue)));
                end                
           end
           
           if ~isempty(currentSubj(session).periNS.NS) %only run if NS present
              %Get z score of 465nm photometry signal- timelocked to every event
              periCueBlueAllTrials(:,trialCount)= currentSubj(session).periNS.NSzblue(:,:,cue);
              periPoxBlueAllTrials(:,trialCount)= currentSubj(session).periNSpox.NSzpoxblue(:,:,cue);
              periLoxBlueAllTrials(:,trialCount)= currentSubj(session).periNSlox.NSzloxblue(:,:,cue);

              %Get z score of 405nm photometry signal- timelocked to every event
              periCuePurpleAllTrials(:, trialCount)= currentSubj(session).periNS.NSzpurple(:,:,cue);
              periPoxPurpleAllTrials(:,trialCount)= currentSubj(session).periNSpox.NSzpoxpurple(:,:,cue);
              periLoxPurpleAllTrials(:,trialCount)= currentSubj(session).periNSlox.NSzloxpurple(:,:,cue);

           else
%                periCueBlueAllTrials(:,trialCount)= nan(size(timeLock))';
%                periCuePurpleAllTrials(:,trialCount)=  nan(size(timeLock))';
%                
%                periPoxBlueAllTrials(:,trialCount)= nan(size(timeLock))';
%                periPoxPurpleAllTrials(:,trialCount)=  nan(size(timeLock))';
%                
%                periPoxBlueAllTrials(:,trialCount)= nan(size(timeLock))';
%                periPoxPurpleAllTrials(:,trialCount)=  nan(size(timeLock))';
           end
           
              %Add subj label for this trial
              subjLabel(:,trialCount)= ones(size(timeLock))'*subj;

              %Add trial type label for this trial
              trialTypeLabel(:,trialCount)= zeros(size(timeLock))'; %0 for NS
           
              %keep track of timestamps
              timeToCue(:,trialCount)= timeLock;
              
       end %end NS cue (trial) loop
                  
   end %end session loop
end %end subject loop

% %% visualization- just checking if event timestamp mask looks appropriate (should be no negative PE timestamps etc.)
% %really slow bc scattering in a loop
% 
% figure;
% hold on; 
% for trial= 1:trialCount
%     if ~isempty(find(eventMaskFirstPox(trial,:)==1))
%     %     scatter(timeLock(find(eventMaskFirstPox(trial,:)==1)), ones(1,numel(eventMaskFirstPox(eventMaskFirstPox(trial,:)==1))));
%     end
% end
% 
% for trial= 1:trialCount
%     if ~isempty(find(eventMaskFirstLox(trial,:)==1))
% %         scatter(timeLock(find(eventMaskFirstLox(trial,:)==1)), ones(1,numel(eventMaskFirstLox(eventMaskFirstLox(trial,:)==1))));
%     end
% end

%Transpose event masks into (timestamp, trial) format
eventMaskCue= eventMaskCue';
eventMaskFirstLox= eventMaskFirstLox';
eventMaskFirstPox= eventMaskFirstPox';

%% Get relative timestamps of events (instead of binary mask)
timeToPox= nan(size(eventMaskFirstPox));
timeToLox= nan(size(eventMaskFirstPox));

for trial= 1:size(eventMaskFirstPox,2)
    eventInd= find(eventMaskFirstPox(:,trial)==1);
    timeToPox(eventInd,trial)= 0; %0 = time of pe
    timeToPox(1:eventInd-1,trial)= flip(-[1:eventInd-1]/fs); %fill timestamps preceding event
    timeToPox(eventInd+1:end,trial)= [1:size(timeToPox,1)-eventInd]/fs; %fill timestamps following event
end 

for trial= 1:size(eventMaskFirstLox,2)
    eventInd= find(eventMaskFirstLox(:,trial)==1);
    timeToLox(eventInd,trial)= 0; %0 = time of pe
    timeToLox(1:eventInd-1,trial)= flip(-[1:eventInd-1]/fs); %fill timestamps preceding event
    timeToLox(eventInd+1:end,trial)= [1:size(timeToLox,1)-eventInd]/fs; %fill timestamps following event
end 

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Iterative deconvolution model based on (Ghazidadeh, Fields, & Ambroggi 2010)

%Equation 2 from this paper: F= ZH+N ; where F=Bulk fluorescence, Z= Event timings, H= Event related fluorescence, N= Noise... all column vectors 

%initialize
F= []; %bulk fluorescence from all timestamps and all trials; column vector
Z= []; %binary coded event timings (1=event) ; MKxKT matrix (where M= # trials, K= # event types, T= # timestamps)
H= []; %event-related fluorescence; column  vector
N=[];%noise; column vector

DStrialCount= 0; %counters for trials of each type
NStrialCount= 0; 

%let's come up with a "Noise" distribution to sample from and estimate
%noise... we'll base it off of fluorescence before cue onset
noiseEst= periCueBlueAllTrials(1:4*fs,:);
noiseDistroBlue= fitdist(noiseEst(:), 'Normal'); %construct a normal distro based from first 2s in peri-cue period

%Get DS trial data
for trial= 1:trialCount
    if trialTypeLabel(:,trial)==1
        DStrialCount= DStrialCount+1;
        periCueBlueDStrials(:,DStrialCount)= periCueBlueAllTrials(:,trial);
        eventMaskDS(:,DStrialCount)= eventMaskCue(:,trial);
        eventMaskFirstPoxDStrials(:,DStrialCount)= eventMaskFirstPox(:,trial);
        eventMaskFirstLoxDStrials(:,DStrialCount)= eventMaskFirstLox(:,trial);
        
        periPoxBlueDStrials(:,DStrialCount)= periPoxBlueAllTrials(:,trial);
        periLoxBlueDStrials(:,DStrialCount)= periLoxBlueAllTrials(:,trial);
    end
end %end all trial loop


for DStrial= 1:DStrialCount
    F= cat(1, F, periCueBlueDStrials(:,DStrial)); %single column vector with fluorescence for every timestamp for every DS trial; all timestamps from each trial appended onto end 
    
end %end DS trial loop

    N=  random(noiseDistroBlue, size(F)); %single column vector with noise; randomly sample values from noise distribution constructed above; same size as F (noise for every timestamp)
%     plot(N, '.') %visualize estimated "noise"

    %save # of events, timestamps, trials for checking shape of outputs 
    K= 3; %# events
    T= size(timeLock,2); % # timestamps
    M= DStrialCount; % # trials

    %Binary coded event timestamps in (timestamp, event type) format; size MTxKT
    %according to paper, but I've got MTxK??
    
%     Z= zeros(M*T,K*T); %preallocate appropriate size
%     
%     for M= 1:DStrialCount
%         for eventType= 1:K
%             
%         end
%     end
%     
    %This resulted in an MTxK matrix
    Z(:,1)= eventMaskDS(:); %cue timestamps
    Z(:,2)= eventMaskFirstPoxDStrials(:); %first PE timestamps
    Z(:,3)= eventMaskFirstLoxDStrials (:); %first lick timestamps
    
% Equation 3 from this paper: take equation 2, multiply by Zt and divide by # trials M
% H' = (1/M)*VH + (1/M)*Z*N ; where H' = peri event histogram, M= #
% trials,Z= binary coded event times, V= "convolution matrix" size KTxKT equivalent to Z'*Z that 'maps the K
% event related fluorescence to the corresponding K PETHs', H= actual event
% related fluorescence,
    %initialize
    periEventsRaw= []; %raw peri event z score, analogous to H' or raw PETH for all events, KTx1 column vector
        
    periEventsRaw= [periCueBlueDStrials(:); periPoxBlueDStrials(:); periLoxBlueDStrials(:)];%append peri-event fluorescence into single column vector 
        
    %multiplication step to calculate V memory intensive bc result is very
    %large matrix. To workaround, use a sparse matrix... This will work because we're using
    %binary coding for event timestamps (so most elements will be==0)

%     V=zeros(K*T) %545gb 
%     V=zeros(K*T, 'uint8') %68.1gb 
%     V= spalloc(K*T,K*T,K*T); %6.49mb %KTxKT matrix with some reserved spots for 1s


    %convert Z to a sparse matrix and multiply
    Z= sparse(Z);

    %get convolution matrix V
    V= Z*Z'; % 'convolution matrix' , sparse due to very large KTxKT dimensions and binary coding... size actually seems to be MTxMT ????
    
%     (1/M)*Z'*F %eq 3
    
    
%Equation 5 from this paper- Find inverse of matrix V (to undo
%convolution) and get normalized vector PETH (Hbar) 
    
    %Establish S, scaling factor less than half of the "largest eigenvalue
    %of (1/M)V"
    
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Trying other regression based models
% 
% %% Get data into proper table format for model
% %Each column= variable (including response variable y, predictive variables x, and grouping variables g)
% %Each row= observation ); %vectorize into 1 column
% % eventMaskDSpox= eventMaskDSpox(:); %vectorize into 1 column
% periCueBlueAllTrials= periCueBlueAllTrials(:); %vectorize into 1 column
% periCuePurpleAllTrials= periCuePurpleAllTrials(:);%vectorize into 1 column
% eventMaskFirstPox= eventMaskFirstPox(:); %vectorize into 1 column
% eventMaskFirstLox= eventMaskFirstLox(:); %vectorize into 1 column
% trialTypeLabel= trialTypeLabel(:); %vectorize into 1 column
% timeToCue= timeToCue(:); %vectorize into 1 column
% subjLabel= subjLabel(:); %vectorize
% timeToPox= timeToPox(:); %vectorize
% timeToLox= timeToLox(:); %vectorize
% 
% 
% %trying only DS trials
% blueDStrials= periCueBlueAllTrials(find(trialTypeLabel==1));
% purpleDStrials= periCuePurpleAllTrials(find(trialTypeLabel==1));
% eventMaskFirstPoxDStrials= eventMaskFirstPox(find(trialTypeLabel==1));
% eventMaskFirstLoxDStrials= eventMaskFirstLox(find(trialTypeLabel==1));
% timeToCueDStrials= timeToCue(find(trialTypeLabel==1));
% subjLabelDStrials= subjLabel(find(trialTypeLabel==1));
% timeToPoxDStrials= timeToPox(find(trialTypeLabel==1));
% timeToLoxDStrials= timeToLox(find(trialTypeLabel==1));
% 
% 
% 
% %% Convolution- doesn't seem necessary
% 
% %convolution of event mask and photometry z score
% poxConvDStrials= conv(eventMaskFirstPoxDStrials, blueDStrials);
% loxConvDStrials= conv(eventMaskFirstLoxDStrials, blueDStrials);
% 
% %convolution of event mask and time series
% % poxConvDStrials= conv(eventMaskFirstPoxDStrials, timeToCueDStrials);
% % loxConvDStrials= conv(eventMaskFirstLoxDStrials, timeToCueDStrials);
% 
% %use padarray() to pad other variables with values to match size of conv result
% % blueDStrialsConv= padarray(blueDStrials, size(poxConvDStrials), nan);
% % blueDStrialsConv(:,1)= []; blueDStrialsConv(:,2)=[]; %this function pads in all dimensions, so delete new empty columns
% 
% %adjust for size of convolution (length convolution = length(kernel)+length(data)-1)
% blueDStrialsConv= nan([size(poxConvDStrials,1),1]); %make empty array matching size of conv result
% blueDStrialsConv(1:size(blueDStrials,1),1)= blueDStrials; %fill empty array with values in appropriate spots
% 
% timeToCueDStrialsConv= nan([size(poxConvDStrials,1),1]); %make empty array matching size of conv result
% timeToCueDStrialsConv(1:size(timeToCueDStrials,1),1)= timeToCueDStrials; %fill empty array with values in appropriate spots
% 
% 
% %% Generate and visualize models
% 
% predictors= [eventMaskFirstPox, eventMaskFirstLox, trialTypeLabel, timeToCue];
% 
% predictorsDS= [eventMaskFirstPoxDStrials, eventMaskFirstLoxDStrials, timeToCueDStrials];
% 
% predictorsDSconv= [poxConvDStrials, loxConvDStrials,timeToCueDStrialsConv];
% 
% predictorsDSrel = [timeToPoxDStrials, timeToLoxDStrials, timeToCueDStrials];
% 
% % %stepwise() may be useful in determining useful predictors
% % stepwiseModelBlue= stepwise(predictors, periCueBlueAllTrials);
% % stepwiseModelBlueDSconv= stepwise(predictorsDSconv, blueDStrialsConv);
% 
% modelTableBlue= table(timeToCue,trialTypeLabel,periCueBlueAllTrials); %all trials
% 
% modelTableDSblue= table(timeToCueDStrials, eventMaskFirstPoxDStrials, eventMaskFirstLoxDStrials, blueDStrials); %DS trials
% 
% modelTableDSblueConv= table(poxConvDStrials, loxConvDStrials, timeToCueDStrialsConv, blueDStrialsConv); %DS trial convs
% 
% modelTableDSblueRel= table(timeToPoxDStrials, timeToLoxDStrials, timeToCueDStrials, blueDStrials);
% 
% %Try LASSO
% lassoDS= lasso(predictorsDS, blueDStrials);
% % figure;
% % hold on;
% % scatter(eventMaskFirstPoxDStrials, blueDStrials);
% % plot(eventMaskFirstPoxDStrials, eventMaskFirstPoxDStrials*lassoDS(1,:))
% 
% %generate linear model
% % linearModelBlue= fitlm(modelTableBlue);
% 
% linearModelBlue= fitlm(modelTableBlue, 'periCueBlueAllTrials~timeToCue*trialTypeLabel');
% 
% figure;
% plot(linearModelBlue);
% 
% linearModelDSblue= fitlm(modelTableDSblue, 'blueDStrials~eventMaskFirstPoxDStrials*timeToCueDStrials+eventMaskFirstLoxDStrials*timeToCueDStrials');
% figure;
% plot(linearModelDSblue);
% 
% linearModelDSblueConv= fitlm(modelTableDSblueConv, 'blueDStrialsConv~timeToCueDStrialsConv*poxConvDStrials');
% figure;
% plot(linearModelDSblueConv);
% 
% linearModelDSblueRel= fitlm(modelTableDSblueRel, 'blueDStrials~timeToPoxDStrials+timeToLoxDStrials');
% figure;
% plot(linearModelDSblueRel);
% 
% % linearModelBlueCategorical= fitlm(periCueBlueAllTrials, predictors, 'Categorical', [1, 2, 3]);
% 
% % Try mixed effects model
% meTableDSblue= table(timeToCueDStrials, eventMaskFirstPoxDStrials, eventMaskFirstLoxDStrials, subjLabelDStrials, purpleDStrials, blueDStrials);
% 
% 
% mixedEffectsModelDSblue= fitlme(meTableDSblue, 'blueDStrials~timeToCueDStrials+eventMaskFirstPoxDStrials+eventMaskFirstLoxDStrials+purpleDStrials +(1|subjLabelDStrials)');
% figure;
% plotResiduals(mixedEffectsModelDSblue, 'fitted');
% 
% %gscatter
% 
% % figure;
% % gscatter(timeToCue,periCueBlueAllTrials,trialTypeLabel,'bgr','x.o');
% % x= linspace(min(timeLock),max(timeLock));
% % % line(x, feval(linearModelBlue,x,'0'),'Color','b');
% 
% % compute coefficients of predictor variables (events) using regress()
% % function
% 
% [regressBlue.coefficient, regressBlue.CI, regressBlue.residuals, regressBlue.stats]= regress(periCueBlueAllTrials, predictors);
% 
% [regressBlueDS.coefficient, regressBlueDS.CI, regressBlueDS.residuals, regressBlueDS.stats]= regress(blueDStrials, predictorsDS);
% 
% % for ts= 1:numel(eventMaskFirstPoxDStrials) %for each timestamp, let's model fluorescence given coefficients above
% %     bluePoxKernelDS(ts,1)= eventMaskFirstPoxDStrials(ts)*regressBlueDS.coefficient(1);
% % end
% 
% %% compare against data- making sure labels are right
% % figure;
% % hold on;
% % for subj= 1:numel(subjects)
% %     currentSubj= subjDataAnalyzed.(subjects{subj})
% %     for session = 1:numel(currentSubj)
% %         for cue= 1:size(currentSubj(session).periDS.DSzblue,3)
% %             scatter(timeLock,currentSubj(session).periDS.DSzblue(:,:,cue), 'g', '.')
% %         end
% %     end %end session loop
% % end %end subj loop