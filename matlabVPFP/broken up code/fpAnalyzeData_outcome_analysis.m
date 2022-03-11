
%% plot settings
eventLineLimits= [-2,5]; %range of ylim for vertical line overlays @ events


%% Plot post-PE response based on reward identity
%dp 10/30/2020 goal of this section is to create plot of post-PE activity
%for each unique reward identity (should be than plotting by pump)

%~~~~Logic here assumes that reward identity changes = coded as different
%stage in metadata excel sheet

%     initialize between subj arrays
allSubjPumpIDs= []
allSubjPumpOnTimeRel= [];
allSubjPEDSblue= [];
allSubjPEDSpurple= [];
allSubjfirstLickDS= [];
PEDSbluePump1= []; PEDSpurplePump1=[];

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    
          allStages= unique([currentSubj.trainStage]); 
          allRewardStages= allStages(allStages>=8);
          for thisStage= allRewardStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
              includedSessions= []; %excluded sessions will reset between unique stages

              rewardIDs= []; PEDSblue= []; PEDSpurple= []; pumpIDs= []; rewardsThisStage=[]; pumpOnTimeRel=[]; firstLickDS=[];%reset between subjects

              %First get all of the relevant data from each peTrial within each
              %variable reward session
            
            %loop through all sessions and record index of sessions that correspond only to this stage
            for session= 1:numel(currentSubj)
                if currentSubj(session).trainStage == thisStage %only include sessions from this stage
                   includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
                end
            end%end session loop
            
            for includedSession= includedSessions
                peTrial= []; %reset between sessions

                lickTrial= []; %want to get first lick timings so we can  plot overlay, but cell array makes indexing a bit more complicated 
                %fill empty lick cells with nan, just easier to index into
                currentSubj(includedSession).behavior.LoxDSpoxRel(find(cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel)))=nan; 
                firstLoxThisStage= nan(size(currentSubj(includedSession).periDS.DS)); %start with nan
                %possible that there are no licks during trials?
                firstLoxThisStage(find(~cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel)))= cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(find(~cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel))));
                
                
                for peTrial=find(currentSubj(includedSession).trialOutcome.DSoutcome==1)
                    pumpIDs= [pumpIDs; currentSubj(includedSession).reward.DSreward(peTrial)]; %list of pump identity for every peTrial                   
        
                    pumpOnTimeRel= [pumpOnTimeRel; currentSubj(includedSession).reward.pumpOnFirstPErel(peTrial)];
                    
                    PEDSblue= [PEDSblue, squeeze(currentSubj(includedSession).periDSpox.DSzpoxblue(:,:,peTrial))]; %list of peri- first PE response for every peTrial
                    PEDSpurple= [PEDSpurple, squeeze(currentSubj(includedSession).periDSpox.DSzpoxpurple(:,:,peTrial))]; %list of peri- first PE response for every peTrial
                    
%                     firstLickDS= [firstLickDS, nan(size(PEtrial))]; %start with nan, then replace with lick timings (since some trials may have no lick)
%                     firstLickDS= [firstLickDS, cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(peTrial))];
                    firstLickDS= [firstLickDS, firstLoxThisStage(peTrial)];

                end %end loop through PEtrials

                %make list of reward IDs given known pumpIDs for each trial
                rewardIDs= cell(size(pumpIDs)); %start with empty cell array (bc dealing with strings) and fill based on pumpID
                rewardIDs(find(pumpIDs==1))= {currentSubj(includedSession).reward.pump1};
                rewardIDs(find(pumpIDs==2))= {currentSubj(includedSession).reward.pump2};
                rewardIDs(pumpIDs==3)= {currentSubj(includedSession).reward.pump3};
            end %end includedSession loop
          
            %Now that we have the trial data and reward identity, let's make plots
            %based on each pump
            %Assuming that identity in each pump is constant for each
            %stage! Also assuming 3 pumps always being used!
            rewardsThisStage{1}= unique(rewardIDs(find(pumpIDs==1)));
            rewardsThisStage{2}= unique(rewardIDs(find(pumpIDs==2)));
            rewardsThisStage{3}= unique(rewardIDs(find(pumpIDs==3)));
           

        %There will be one subplot per rewardStage
            %with traces for each rewardID
            
            rewardColors= ['g','r','y']; %color plots based on reward identity
            
            figure(figureCount); sgtitle(strcat(subjects{subj},'-peri first PE DSz by reward identity (mean of all trials by stage)'));
%             subplot(1, numel(allRewardStages), find(allRewardStages==thisStage)); hold on;
            
             subplot(3, numel(allRewardStages),find(allRewardStages==thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'-pump1-reward=',rewardsThisStage{1}));
%              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{1}))), rewardColors(1)); %plot all trials
             plot(timeLock,nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{1}))),2), 'b'); %plot mean across all trials (for this stage)
             plot(timeLock,nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{1}))),2), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==1))), ylim, 'g', 'LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k', 'LineWidth',3);%overlay line for PE
             plot(ones(2,1)*nanmean(firstLickDS(pumpIDs==1)), ylim, 'r', 'LineWidth',3);% overlay mean first lick time
             
             subplot(3, numel(allRewardStages), numel(allRewardStages)+find(allRewardStages==thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'-pump2-reward=',rewardsThisStage{2}));
%              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{2}))), rewardColors(2)); %plot all trials
             plot(timeLock,nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{2}))),2), 'b'); %plot mean across all trials (for this stage)
             plot(timeLock,nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{2}))),2), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==2))), ylim, 'g', 'LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k', 'LineWidth',3);%overlay line for PE
             plot(ones(2,1)*nanmean(firstLickDS(pumpIDs==2)), ylim, 'r', 'LineWidth',3);% overlay mean first lick time
             
             subplot(3, numel(allRewardStages), numel(allRewardStages)+numel(allRewardStages)+find(allRewardStages==thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'-pump3-reward=',rewardsThisStage{3}));
%              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{3}))), rewardColors(3)); %plot all trials
             plot(timeLock,nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{3}))),2), 'b'); %plot mean across all trials (for this stage)
             plot(timeLock,nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{3}))),2), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==3))), ylim, 'g', 'LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k', 'LineWidth',3);%overlay line for PE
             plot(ones(2,1)*nanmean(firstLickDS(pumpIDs==3)), ylim, 'r', 'LineWidth',3);% overlay mean first lick time

             
             xlabel('time from PE (s)');
             ylabel('z score relative to pre-cue baseline)');

             %let's save data from this pump on this stage for later
             %between-subjects plots
             PEDSbluePump1(:,thisStage,subj)= nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{1}))),2); 
             PEDSpurplePump1(:,thisStage,subj)= nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{1}))),2);
             PEDSbluePump2(:,thisStage,subj)= nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{2}))),2);
             PEDSpurplePump2(:,thisStage,subj)= nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{2}))),2);
             PEDSbluePump3(:,thisStage,subj)= nanmean(PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{3}))),2);
             PEDSpurplePump3(:,thisStage,subj)= nanmean(PEDSpurple(:,find(strcmp(rewardIDs,rewardsThisStage{3}))),2);
             
             firstLickPump1(:,thisStage,subj)= nanmean(firstLickDS(pumpIDs==1));
             firstLickPump2(:,thisStage,subj)= nanmean(firstLickDS(pumpIDs==2));
             firstLickPump3(:,thisStage,subj)= nanmean(firstLickDS(pumpIDs==3));
             
         end %end stage loop
        linkaxes();
        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving      

        legend('465nm z score','405nm z score', 'pump on', 'first PE during DS', 'first lick');
                        
        figureCount= figureCount+1;
                
%             uniqueRewards= [uniqueRewards,unique(rewardIDs)];
%         end %end variable reward session conditional
%     end
    
% %need to replace all empty all zero columns in photometry data with nan
% PEDSbluePump1(:,~any(PEDSbluePump1,1),subj) = nan;
% PEDSpurplePump1(:,~any(PEDSpurplePump1,1),subj) = nan;

%let's save this subject's data into arrays for between subjects plots
%perhaps easiest way to do this is to cat all together
allSubjPumpIDs= [allSubjPumpIDs; pumpIDs]

allSubjPumpOnTimeRel= [allSubjPumpOnTimeRel; pumpOnTimeRel];

allSubjPEDSblue= [allSubjPEDSblue, PEDSblue];
allSubjPEDSpurple= [allSubjPEDSpurple,PEDSpurple];
allSubjfirstLickDS= [allSubjfirstLickDS, firstLickDS];

end %end subj loop

%need to replace all empty all zero columns in photometry data with nan
% testPEDSbluePump1= nan(size(PEDSbluePump1));
for subj=1:numel(subjects)
    for emptyStage= find(~any(PEDSbluePump1(:,:,subj))==1)
        PEDSbluePump1(:,emptyStage,subj) = nan(size(PEDSbluePump1,1),1);
        PEDSpurplePump1(:,emptyStage,subj) = nan(size(PEDSpurplePump1,1),1);
         PEDSbluePump2(:,emptyStage,subj) = nan(size(PEDSbluePump2,1),1);
        PEDSpurplePump2(:,emptyStage,subj) = nan(size(PEDSpurplePump2,1),1);
         PEDSbluePump3(:,emptyStage,subj) = nan(size(PEDSbluePump3,1),1);
        PEDSpurplePump3(:,emptyStage,subj) = nan(size(PEDSpurplePump3,1),1);
        
        firstLickPump1(:,emptyStage,subj) = nan;
        firstLickPump2(:,emptyStage, subj)= nan;
        firstLickPump3(:,emptyStage, subj)= nan;
    end
end

%calculate SEM
allRewardStages= 8:allStages(end);%manual for now
for thisStage= allRewardStages 
    semPEDSbluePump1(:,find(allRewardStages==thisStage))= nanstd(PEDSbluePump1(:,thisStage,:),0,3)/sqrt(numel(subjects));
    semPEDSbluePump2(:,find(allRewardStages==thisStage))= nanstd(PEDSbluePump2(:,thisStage,:),0,3)/sqrt(numel(subjects));
    semPEDSbluePump3(:,find(allRewardStages==thisStage))= nanstd(PEDSbluePump3(:,thisStage,:),0,3)/sqrt(numel(subjects));
end
%take mean across subjects
PEDSbluePump1= nanmean(PEDSbluePump1,3);
PEDSpurplePump1=  nanmean(PEDSpurplePump1,3);
PEDSbluePump2= nanmean(PEDSbluePump2,3);
PEDSpurplePump2= nanmean(PEDSpurplePump2,3);
PEDSbluePump3= nanmean(PEDSbluePump3,3);
PEDSpurplePump3= nanmean(PEDSpurplePump3,3);



%% Now make plots of between-subjects mean activity
            
rewardColors= ['g','r','y']; %color plots based on reward identity

figure(figureCount); sgtitle('between subj-peri first PE DSz by reward identity (between subj mean of all trials by stage)');
%             subplot(1, numel(allRewardStages), find(allRewardStages==thisStage)); hold on;
allRewardStages= 8:allStages(end)%8:12;%manual for now
for thisStage= [allRewardStages] 
     %There will be one subplot per rewardStage
            %with traces for each rewardID

             subplot(3, numel(allRewardStages),find(thisStage==[allRewardStages])); hold on; title(strcat('stage-',num2str(thisStage),'-pump1-reward=',rewardsThisStage{1}));
%              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{1}))), rewardColors(1)); %plot all trials
             plot(timeLock,PEDSbluePump1(:,thisStage), 'b'); %plot mean across all trials (for this stage)
%              plot(timeLock,PEDSpurplePump1(:,thisStage), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==1))), ylim, 'g','LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k','LineWidth',3);%overlay line for PE
             plot(ones(2,1)*firstLickPump1(:,thisStage), ylim, 'r','LineWidth',3);% overlay mean first lick time
             semPatchPos= PEDSbluePump1(:,thisStage)+semPEDSbluePump1(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             semPatchNeg= PEDSbluePump1(:,thisStage)-semPEDSbluePump1(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             patch([timeLock,timeLock(end:-1:1)],[semPatchPos',semPatchNeg(end:-1:1)'],'b','EdgeColor','None');alpha(0.3); %overlay SEM patch
%              

             subplot(3, numel(allRewardStages), numel(allRewardStages)+find(thisStage==[allRewardStages])); hold on; title(strcat('stage-',num2str(thisStage),'-pump2-reward=',rewardsThisStage{2}));
%              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{2}))), rewardColors(2)); %plot all trials
             plot(timeLock,PEDSbluePump2(:,thisStage), 'b'); %plot mean across all trials (for this stage)
%              plot(timeLock,PEDSpurplePump2(:,thisStage), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==2))), ylim, 'g', 'LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k', 'LineWidth',3);%overlay line for PE
             plot(ones(2,1)*firstLickPump3(:,thisStage), ylim, 'r', 'LineWidth',3);% overlay mean first lick time
             semPatchPos= PEDSbluePump2(:,thisStage)+semPEDSbluePump2(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             semPatchNeg= PEDSbluePump2(:,thisStage)-semPEDSbluePump2(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             patch([timeLock,timeLock(end:-1:1)],[semPatchPos',semPatchNeg(end:-1:1)'],'b','EdgeColor','None');alpha(0.3); %overlay SEM patch
             %              

             subplot(3, numel(allRewardStages), numel(allRewardStages)+numel(allRewardStages)+find(allRewardStages==thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'-pump3-reward=',rewardsThisStage{3}));
% %              plot(timeLock,PEDSblue(:,find(strcmp(rewardIDs,rewardsThisStage{3}))), rewardColors(3)); %plot all trials
             plot(timeLock,PEDSbluePump3(:,thisStage), 'b'); %plot mean across all trials (for this stage)
%              plot(timeLock,PEDSpurplePump3(:,thisStage), 'm'); %plot mean across all trials (for this stage)
             plot(ones(2,1)*nanmean(unique(pumpOnTimeRel(pumpIDs==3))), ylim, 'g', 'LineWidth',3); %overlay line for pump on time (for now using nanmean bc slight differences unique() picks up probably because they haven't been rounded to the nearest timestamp)
             plot(ones(2,1)*0, ylim, 'k', 'LineWidth',3);%overlay line for PE
             plot(ones(2,1)*firstLickPump3(:,thisStage), ylim, 'r', 'LineWidth',3);% overlay mean first lick time
             semPatchPos= PEDSbluePump3(:,thisStage)+semPEDSbluePump3(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             semPatchNeg= PEDSbluePump3(:,thisStage)-semPEDSbluePump3(:,find(allRewardStages==thisStage)); %need to save intermediate for indexing
             patch([timeLock,timeLock(end:-1:1)],[semPatchPos',semPatchNeg(end:-1:1)'],'b','EdgeColor','None');alpha(0.3); %overlay SEM patch
             
             xlabel('time from PE (s)');
             ylabel('z score relative to pre-cue baseline)');
             legend('465nm','pump on','port entry', 'first lick');
             
             linkaxes();

end

%first take mean across all trials 
allSubjPEDSblueMean= nanmean(squeeze(allSubjPEDSblue), 1); 
allSubjPEDSpurpleMean= nanmean(squeeze(allSubjPEDSpurple),1); 
%% Classify trials by outcome history (trying to get at RPE)
% plotting peri-first PE in DS epoch based on outcome

trialsBack= 1; %trying to build in some future support for integrating history over multiple trials

%will need to determine which pump corresponds to 'hi', 'med', 'lo' values
%for each stage/session. Then probably can calculate an RPE estimate based
%on n trials back

allSubjPEDSblue=[]; allSubjPEDSpurple=[]; allSubjTransitions=[]; allSubjStages=[]; allSubjTransitionLabels={};
allSubjDSblue= []; allSubjDSpurple=[];


for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    
    allStages= unique([currentSubj.trainStage]);
    %dp 10/1/2021 between subj stuff should work if you only run one stage at a time (if
    %reward IDs change code needs to be updated to accomodate)
    allRewardStages= allStages(allStages>=8 & allStages<12); %12 = extinction so exclude
    
    for thisStage= allRewardStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        
% % % %         figure() %1 fig per subj per stage
        
        includedSessions= []; %excluded sessions will reset between unique stages
        %clear between stages
        rewardIDs= []; PEDSblue= []; PEDSpurple= []; pumpIDs= []; rewardsThisStage=[]; pumpOnTimeRel=[]; firstLickDS=[];%reset between subjects
        outcomeValue= []; outcomeExpected= []; outcomeRPE= []; outcomeTransitions= [];
        noPEDSblue= []; noPEDSpurple=[]; DSblue=[]; DSpurple=[]; PEDS= []; noPEDS= []; DScount= [];
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
                includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
        
        for includedSession= includedSessions
            peTrial= []; noPEtrial=[]; %reset between sessions
            
            lickTrial= []; %want to get first lick timings so we can  plot overlay, but cell array makes indexing a bit more complicated
            %fill empty lick cells with nan, just easier to index into
            currentSubj(includedSession).behavior.LoxDSpoxRel(find(cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel)))=nan;
            firstLoxThisStage= nan(size(currentSubj(includedSession).periDS.DS)); %start with nan
            firstLoxThisStage(find(~cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel)))= cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(find(~cellfun(@isempty,currentSubj(includedSession).behavior.loxDSpoxRel))));
            
            %get all DS trial data first, then isolate PE vs no PE later
            for trial=1:numel(currentSubj(includedSession).periDS.DS)
                pumpIDs= [pumpIDs; currentSubj(includedSession).reward.DSreward(trial)]; %list of pump identity for every peTrial
                
                pumpOnTimeRel= [pumpOnTimeRel; currentSubj(includedSession).reward.pumpOnDSrel(trial)];
                %CUE
                %                     DSblue= [DSblue, squeeze(currentSubj(includedSession).periDS.DSzblue(:,:,trial))]; %list of peri- DS response for every trial
                %                     DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDS.DSzpurple(:,:,trial))]; %list of peri- DS response for every trial
                %LICK
                %really want to see zscore timelocked to lick (actual
                %consumption and outcome experience)
                DSblue= [DSblue, squeeze(currentSubj(includedSession).periDSlox.DSzloxblue(:,:,trial))];
                DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDSlox.DSzloxpurple(:,:,trial))];
                
                %                     %save indices of trials by PE outcome (noPE, PE, inPort)
                %                     if currentSubj(includedSession).trialOutcome.DSoutcome(trial)==1
                %                         PEDS= [PEDS, trial];
                %                     end
                %                     if currentSubj(includedSession).trialOutcome.DSoutcome(trial)==2
                %                         noPEDS= [noPEDS, trial];
                %                     end
                
                %                     firstLickDS= [firstLickDS, nan(size(PEtrial))]; %start with nan, then replace with lick timings (since some trials may have no lick)
                %                     firstLickDS= [firstLickDS, cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(peTrial))];
                firstLickDS= [firstLickDS, firstLoxThisStage(trial)];
                
                DScount= DScount+1; %total trial count
            end %end loop through DS
            
            %                 for peTrial=find(currentSubj(includedSession).trialOutcome.DSoutcome==1)
            %                     pumpIDs= [pumpIDs; currentSubj(includedSession).reward.DSreward(peTrial)]; %list of pump identity for every peTrial
            %
            %                     pumpOnTimeRel= [pumpOnTimeRel; currentSubj(includedSession).reward.pumpOnFirstPErel(peTrial)];
            %
            %                     PEDSblue= [PEDSblue, squeeze(currentSubj(includedSession).periDS.DSzblue(:,:,peTrial))]; %list of peri- first PE response for every peTrial
            %                     PEDSpurple= [PEDSpurple, squeeze(currentSubj(includedSession).periDS.DSzpurple(:,:,peTrial))]; %list of peri- first PE response for every peTrial
            %
            % %                     firstLickDS= [firstLickDS, nan(size(PEtrial))]; %start with nan, then replace with lick timings (since some trials may have no lick)
            % %                     firstLickDS= [firstLickDS, cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(peTrial))];
            %                     firstLickDS= [firstLickDS, firstLoxThisStage(peTrial)];
            %                 end %end loop through PEtrials
            %
            %                  for noPEtrial=find(currentSubj(includedSession).trialOutcome.DSoutcome==2)
            % %                     pumpIDs= [pumpIDs; currentSubj(includedSession).reward.DSreward(noPEtrial)]; %list of pump identity for every peTrial
            %
            %                     %but, no pump on if no pe
            % %                     pumpOnTimeRel= [pumpOnTimeRel; currentSubj(includedSession).reward.pumpOnFirstPErel(noPEtrial)];
            %
            %                     noPEDSblue= [noPEDSblue, squeeze(currentSubj(includedSession).periDS.DSzblue(:,:,noPEtrial))]; %list of peri- first PE response for every peTrial
            %                     noPEDSpurple= [noPEDSpurple, squeeze(currentSubj(includedSession).periDS.DSzpurple(:,:,noPEtrial))]; %list of peri- first PE response for every peTrial
            %
            % %                     firstLickDS= [firstLickDS, nan(size(PEtrial))]; %start with nan, then replace with lick timings (since some trials may have no lick)
            % %                     firstLickDS= [firstLickDS, cellfun(@(v)v(1),currentSubj(includedSession).behavior.loxDSpoxRel(peTrial))];
            % %                     firstLickDS= [firstLickDS, firstLoxThisStage(noPEtrial)];
            %                 end %end loop through PEtrials
            
            %now let's isolate PE and noPE trials
            %will need to have nan size of DSblue then fill in right
            %trials
            % %                 noPEDSblue= nan(size(DSblue));
            %                 noPEDSblue(:,noPEDS)= DSblue(:,noPEDS);
            % %                 PEDSblue= nan(size(DSblue));
            %                 PEDSblue(:,PEDS)= DSblue(:,PEDS);
            
            %make list of reward IDs given known pumpIDs for each trial
            rewardIDs= cell(size(pumpIDs)); %start with empty cell array (bc dealing with strings) and fill based on pumpID
            rewardIDs(find(pumpIDs==1))= {currentSubj(includedSession).reward.pump1};
            rewardIDs(find(pumpIDs==2))= {currentSubj(includedSession).reward.pump2};
            rewardIDs(pumpIDs==3)= {currentSubj(includedSession).reward.pump3};
            
            %Now that we have the trial data and reward identity, let's make plots
            %based on each pump
            
            %Assuming that identity in each pump is constant for each
            %stage! Also assuming 3 pumps always being used!!
            %todo: doesn't have to be this way, I think code added around
            %~april 2021 for trial-by-trial outcome analyses has fixes for this
            %todo: there's an extra layer of cells being introduced here by using {1} {2} {3}, should be (1) (2) (3)
            rewardsThisStage{1}= unique(rewardIDs(find(pumpIDs==1)));
            rewardsThisStage{2}= unique(rewardIDs(find(pumpIDs==2)));
            rewardsThisStage{3}= unique(rewardIDs(find(pumpIDs==3)));
            
            %now we have reward identities, let's convert these to some
            %numerical value
            %Ottenheimer et al 2020 used maltodextrin='rho, a free parameter we estimated during model fitting', 1=sucrose, 0=water
            %let's make a cell array of possible outcomes along with an
            %array of corresponding numerical 'values'
            %dp 10/1/2021 space after 20% sucrose needs to be fixed, just
            %made exception
            outcomes= {'20% sucrose','20% sucrose ','10% sucrose', '5% sucrose', 'DI H20', 'empty'};
            values= [2, 2,1,0.5,0,0];
            %             for pump= 1:numel(rewardsThisStage)
            %                 hiRewardIndex= ismember(rewardsThisStage,'20% sucrose')%(rewardsThisStage{pump}, '20% sucrose');
            %             end
            %loop through each possible reward outcomes and find matching pump
            %that corresponds in this session
            for outcome= 1:numel(outcomes) %now find the corresponding value of each pump outcome in this session
                for pump= 1:numel(rewardsThisStage) %3 pumps
                    %if this pump contains this reward outcome string, will return true and we'll assign the corresponding numerical outcome value to this pump
                    if (contains(outcomes(outcome),rewardsThisStage{pump}))==1
                        pumpValue(pump)= values(outcome);
                    end
                end
            end
            
            %now that we have pump values, assign outcome value to each
            %trial
            outcomeValue= pumpValue(pumpIDs)';
            
            %let's classify expected value of each trial based on previous outcome (n trials
            %back?)... probably want to do a more complicated model
            for trial= 1:numel(pumpIDs) %loop through all trials
                if trial <= trialsBack %if we don't have n trials before the current trial
                    outcomeExpected(trial) = 1; %simply = learned value of 10% sucrose?
                else
                    %now this is just grabbing the value of n trials back,
                    %if we want to integrate history over multiple trials
                    %we'll have to do some kind of summation of averaging function
                    outcomeExpected(trial,1)= sum(pumpIDs(trial-trialsBack:trial-1));
                end
            end
            
            %now that we have outcome and expected value for each trial, we
            %can compute an RPE for each trial
            
            
            %very simple outcome-expected here
            outcomeRPE= outcomeValue-outcomeExpected;
            %             numel(unique(outcomeRPE)) %just checking
            
            %let's classify trials by outcome transition (we might see
            %something different from RPE e.g. maybe a pump1->pump1 looks
            %different from a pump3->pump3 even if RPE is the same)
            
            %first find unique combinations (could be helpful for looping later)
            %since it's possible to get the same outcome multiple trials in
            %a row, making an array of possible outcomes with a duplicate
            %for each trial included, doesn't seem to be a built in matlab
            %function for this with replacement so using code from https://www.mathworks.com/matlabcentral/answers/429709-combinations-of-a-vector-with-replacement
            
            rewardsThisStage= [rewardsThisStage{:}]; %when I made this earlier I guess I accidentally added an extra layer of cells... removing this to make it easier to do the strcat function below
            
            [A1,A2] = ndgrid(1:numel(rewardsThisStage));
            transitionsPossible= arrayfun(@(k) polyval([A2(k),A1(k)],10), 1:numel(A1))'; %these are the unique transition combos
            
            %now let's get the corresponding unique labels of actual
            %reward (good for plot legends), code from https://www.mathworks.com/matlabcentral/answers/392649-generate-combinations-of-cells-that-contain-text
            [A1,A2] = ndgrid(1:numel(rewardsThisStage));
            transitionLabelsPossible = strcat(rewardsThisStage(A2(:)),'-->',rewardsThisStage(A1(:)))';
            
            %now go trial by trial and assign transition type along with label
            for trial= 1:numel(pumpIDs) %loop through all trials
                if trial <= trialsBack
                    outcomeTransitions(trial)= 1; %not sure how to deal with the earliest trials except just mark them as 1 (could make nan)
                    outcomeTransitionLabels{trial}= 'firstTrials';
                else
                    %concatenate outcome history (use sprintf to combine
                    %into one value)
                    outcomeTransitions(trial)= str2num(sprintf(num2str(pumpIDs(trial-trialsBack:trial))));
                    
                    %let's also save label of what was actually in the pumps (good
                    %for figure legends)
                    outcomeTransitionLabels{trial}= strcat((rewardIDs{pumpIDs(trial-trialsBack:trial)}));
                end
            end
            
            %finally, identify PE vs. noPE trials
            PEtrial=find(currentSubj(includedSession).trialOutcome.DSoutcome==1);
            noPEtrial=find(currentSubj(includedSession).trialOutcome.DSoutcome==2);
            
            %intermediate assignment so size of DSblue is same as PEDS and noPEDS.
            %empty trials for each will just be nan
            i= nan(size(DSblue,1),size(currentSubj(includedSession).periDS.DSblue,3));
            i(:,PEtrial)=DSblue(:,PEtrial);
            
            %cat this session with previous
            PEDSblue= [PEDSblue, i];
            
            i=nan(size(DSblue,1),size(currentSubj(includedSession).periDS.DSblue,3));
            i(:,noPEtrial)= DSblue(:,noPEtrial);
            noPEDSblue= [noPEDSblue, i];
            
            %repeat for 405nm
            %intermediate assignment so size of DSpurple is same as PEDS and noPEDS.
            %empty trials for each will just be nan
            i= nan(size(DSpurple,1),size(currentSubj(includedSession).periDS.DSpurple,3));
            i(:,PEtrial)=DSpurple(:,PEtrial);
            
            %cat this session with previous
            PEDSpurple= [PEDSpurple, i];
            
            i=nan(size(DSpurple,1),size(currentSubj(includedSession).periDS.DSpurple,3));
            i(:,noPEtrial)= DSpurple(:,noPEtrial);
            noPEDSpurple= [noPEDSpurple, i];
            
            
        end %end includedSession loop
        
        
        %one plot per stage with overlaid mean of
        %transitions. subplot blue and purple
% % % %         subplot(2,1,1); hold on; title(strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri first DS Lick blue, PE trials by transitionType'));
        %assigning some colors for plotting manually here
        colors= [103,0,31; 178,24,43; 214,96,77; 244,165,130;253,219,199; 209,229,240; 146,197,222; 67, 147, 195; 33,102,172; 5,48,97];
        colors= colors/255; %values above were from colorbrewer based on 0-255 scale, matlab wants them between 0-1 so just divide
% % % %         colororder(colors);
% % % %         Legend={};
        
        for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
            %plotting mean first in one loop to get legend, then individual trials
            if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
                %                   plot(timeLock,PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
%                 plot(timeLock, nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:), 'lineWidth',3); %mean of all trials
%                 Legend= [Legend,(transitionLabelsPossible{transitionType})];
                
                %                   %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
                %                   semDSblue(:,thisStage,subj)= (nanstd(PEDSblue,0,2))/sqrt(size(PEDSblue,2));
                %                   semDSblue(:,(find(all(semDSblue(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
                %                   semLinePos= nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)+semDSblue(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
                %                   semLineNeg= nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)-semDSblue(:,thisStage,subj);
                %
                %                   patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],colors(find(transitionsPossible==transitionsPossible(transitionType)),:),'EdgeColor','None');alpha(0.5);
            end
        end
        %Plot SEM in separate loop so legend doesn't get packed
% % % %         legend(Legend); %add legend now so extra entries aren't made in between trial types
% % % %         xlabel('time from first lick');
% % % %         ylabel('z score 465nm');
        
        %TODO: SEM not accurate here, n needs to be based on num  trials
        %wi
        for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
            %plotting mean first in one loop to get legend, then individual trials
            if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
                %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
                %for sem be sure to exclude observations that have all
                %nan (these are other trial types)
                semDSblue(:,thisStage,subj)= (nanstd(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),0,2))/sqrt(size(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2));
                
                %                   semDSblue(:,thisStage,subj)= nanstd(PEDSblue(:,(~all(isnan(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)))))),2)/sqrt(size(PEDSblue,2));
                semDSblue(:,(find(all(semDSblue(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
                semLinePos= nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)+semDSblue(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
                semLineNeg= nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)-semDSblue(:,thisStage,subj);
                
% % % %                 patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],colors(find(transitionsPossible==transitionsPossible(transitionType)),:),'EdgeColor','None');alpha(0.5);
            end
        end
        
        %405nm
% % % %         subplot(2,1,2); hold on; title(strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri first DS Lick purple, PE trials by transitionType'));
        %assigning some colors for plotting manually here
        colors= [103,0,31; 178,24,43; 214,96,77; 244,165,130;253,219,199; 209,229,240; 146,197,222; 67, 147, 195; 33,102,172; 5,48,97];
        colors= colors/255; %values above were from colorbrewer based on 0-255 scale, matlab wants them between 0-1 so just divide
% % % %         colororder(colors);
% % % %         Legend={};
        
        for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
            %plotting mean first in one loop to get legend, then individual trials
            if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
                %                   plot(timeLock,PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
% % % %                 plot(timeLock, nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:), 'lineWidth',3); %mean of all trials
%                 Legend= [Legend,(transitionLabelsPossible{transitionType})];
                %
                %                   %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
                %                   semDSpurple(:,thisStage,subj)= (nanstd(PEDSpurple,0,2))/sqrt(size(PEDSpurple,2));
                %                   semDSpurple(:,(find(all(semDSpurple(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
                %                   semLinePos= nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2)+semDSpurple(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
                %                   semLineNeg= nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2)-semDSpurple(:,thisStage,subj);
                %
                %                   patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],colors(find(transitionsPossible==transitionsPossible(transitionType)),:),'EdgeColor','None');alpha(0.5);
            end
        end
        %Plot SEM in separate loop so legend doesn't get packed
% % % %         legend(Legend); %add legend now so extra entries aren't made in between trial types
% % % %         xlabel('time from first lick');
% % % %         ylabel('z score 465nm');
        
        for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
            %plotting mean first in one loop to get legend, then individual trials
            if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
                %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
                semDSpurple(:,thisStage,subj)= (nanstd(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),0,2))/sqrt(size(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2));
                semDSpurple(:,(find(all(semDSpurple(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
                semLinePos= nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2)+semDSpurple(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
                semLineNeg= nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2)-semDSpurple(:,thisStage,subj);
                
% % % %                 patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],colors(find(transitionsPossible==transitionsPossible(transitionType)),:),'EdgeColor','None');alpha(0.5);
            end
        end
        
        
        %          for transitionType= 1:numel(transitionsPossible)
        %             if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
        %               plot(timeLock,PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
        %             end
        %          end
        %
        %Subplot PE vs noPE trials. We don't have many noPE trials at this
        %point so not really interesting
        %~~~PLOTS by outcomeTransition
        % %           %one fig per stage, subplot of all transition types?
        % %           %maybe better to do one plot per stage with overlaid mean of
        % %           %transitions
        % %           subplot(2,1,1); hold on; title(strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri DS blue, PE trials by transitionType'));
        % %            %assigning some colors for plotting manually here
        % %           colors= [103,0,31; 178,24,43; 214,96,77; 244,165,130;253,219,199; 209,229,240; 146,197,222; 67, 147, 195; 33,102,172; 5,48,97];
        % %           colors= colors/255; %values above were from colorbrewer based on 0-255 scale, matlab wants them between 0-1 so just divide
        % %           colororder(colors);
        % %           Legend={};
        % %
        % %           for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
        % %               %plotting mean first in one loop to get legend, then individual trials
        % %               if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
        % % %                   plot(timeLock,PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
        % %                   plot(timeLock, nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2), 'lineWidth',3); %mean of all trials
        % %                   Legend= [Legend,(transitionLabelsPossible{transitionType})];
        % %               end
        % %
        % %           end
        % %           legend(Legend);
        % %
        % %          for transitionType= 1:numel(transitionsPossible)
        % %             if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
        % % %               plot(timeLock,PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
        % %             end
        % %          end
        % %
        % %           subplot(2,1,2); hold on; title(strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri DS blue, noPE trials by transitionType'));
        % %               if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
        % % %                   plot(timeLock,noPEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
        % %                   plot(timeLock, nanmean(noPEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2), 'lineWidth',3); %mean of all trials
        % % %                   Legend= [Legend,(transitionLabelsPossible{transitionType})];
        % %                  disp('plot')
        % %               end
        % %
        % %
        % %          for transitionType= 1:numel(transitionsPossible)
        % %             if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
        % % %               plot(timeLock,noPEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:)); %individual trials
        % %             end
        % %          end
        
        % %          xlabel('time from DS');
        % %          ylabel('z score 465nm');
        %          legend(Legend);
        
        
        %save data for between subj analysis later
        %          %should get mean by outcome transition, not stage?
        %        allSubjDSblue(:,thisStage,subj)= nanmean(PEDSblue,2);
        %        allSubjDSpurple(:,thisStage, subj)= nanmean(PEDSpurple,2);
        %        allSubjTransitionsPossible(:,thisStage,subj)= transitionsPossible;
        %
        %        allSubjOutcomeTransitions{:,thisStage,subj}= outcomeTransitions;
        
        %collect data into array separately, along with label of transition type, and
        %label of subj and stage?
        for transitionType= 1:numel(transitionsPossible)
            
            %should get mean by outcome transition, not stage?
            %but since the IDs vary between stages will need to do that too
            %(unless running 1 stage at a time) dp 10/1/21
            allSubjDSblue(:,transitionType,subj)= nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2);
            allSubjDSpurple(:,transitionType,subj)= nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2);
            
            allSubjTransitions(:,transitionType,subj)= transitionsPossible(transitionType).*ones(size(nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)));
            allSubjTransitionLabels{1,transitionType,subj}= transitionLabelsPossible(transitionType);
            
            allSubjStage(:,transitionType,subj)= thisStage.*ones(size(nanmean(PEDSblue(:,outcomeTransitions==transitionsPossible(transitionType)),2)));
        end
        
         % GRAMM plots of outcome value transitions
    
    %organize data into table 
    data=table();
    data.PEDSblue= PEDSblue(:); 
    data.PEDSpurple= PEDSpurple(:);
    %repeat labels as necessary
    data.timeLock= repmat(timeLock,1,size(PEDSblue,2))'; %repeat all timestamps per transition type
    temp=repmat(outcomeTransitions, size(timeLock,2),1); %same outcomeTransition per timestamp per transition type
    data.outcomeTransitions= temp(:);
    
    data.transitionLabels= cell(size(data,1),1);
    
%     transitionLabels={}

%    for transitionType= 1:numel(transitionsPossible) %loop through possible transition types
%        if sum(outcomeTransitions==transitionsPossible(transitionType))>0 %possible that we don't have a trial of a given type, if so this avoids an error
%            transitionLabels{transitionType}= transitionLabelsPossible{transitionType};    
%        end
%    end
   transitionLabels= cell(size(outcomeTransitions));
    for i = 1:numel(outcomeTransitions)
        if ~isempty(find(transitionsPossible==outcomeTransitions(i)))
          transitionLabels{i}= transitionLabelsPossible{find(transitionsPossible==outcomeTransitions(i))};
        end
    end
   
    temp=repmat(transitionLabels, size(timeLock,2),1); %same transitionLabel per timestamp per transition type
    data.transitionLabels= temp(:);

    %REMOVE data from first trials before N trialsBack(these have no 'preceding' value) 
    %At this point these should have empty transitionLabels since there is
    %no matching label for a single outcome
%     for i= 1:size(data,2)
%         data= data(~isempty(data.transitionLabels))
%       data = data(cellfun(@isempty,data));
    loc=cellfun('isempty', data{:,'transitionLabels'});
    data(loc,:)= [];
    %     end
    
    figure();
    g=gramm('x', data.timeLock, 'y', data.PEDSblue, 'color', data.transitionLabels);
    %define stats to show
    g.stat_summary('type','sem','geom','area');

    %define labels for plot axes
    g.set_names('x','time from first lick (s)','y','465nm (z score)','color','reward outcome transition')
    g.set_title((strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri first DS Lick 465nm, PE trials by reward transitionType')))
    
    %sort by relative value (RPE) calculated (TODO: manual for now)
    transitionValues= [0, -1, 1, 1, 0, 2, -1, -2, 0];
    [~,sortOrder]= sort(transitionValues);
    transitionsSorted= transitionLabelsPossible(sortOrder);
%     transitionsSorted= {'empty-->20% sucrose','empty-->10% sucrose','empty-->empty',
%             '10% sucrose-->empty', '   
    colorMap= [178,24,43
                214,96,77
                244,165,130
                253,219,199
                247,247,247
                209,229,240
                146,197,222
                67,147,195
                33,102,172];
    colorMap= colorMap/255;
    g.set_order_options('color',transitionsSorted);
    g.set_color_options('map',colorMap)
    
    %draw the actual plot
    g.draw()
    saveas(gcf, strcat(figPath, subjData.(subjects{subj})(1).experiment, '_', subjectsAnalyzed{subj}, '_GRAMM_RPE_firstLick_stage',num2str(thisStage),'.fig')); %save the current figure in fig format
    
        
    end %end stage loop %DP 10/26/21 should be transitionType loop?
    
%     %just take mean across subjects to flatten into 2d
%     allSubjDSblue= nanmean(allSubjDSblue,3)
%     allSubjDSpurple= nanmean(allSubjDSpurple,3)
    
   
% % % %     plot(timeLock, nanmean(PEDSpurple(:,outcomeTransitions==transitionsPossible(transitionType)),2),'color',colors(find(transitionsPossible==transitionsPossible(transitionType)),:), 'lineWidth',3); %mean of all trials

    
end % end subj loop

% close all;
    % between-subj stuff 
%collect data from all subjects for a between-subjects mean plot
%take mean across all subjects
% allSubjDSblue= nanmean(allSubjDSblue,3)
%this still needs to be broken down by stage as well as transition? since
%identity changes across stages? should check with allSubjTransitionLabels

%replace all subj columns that have all zeros with nans (this could happen if an animal
%didn't run a particular stage)        
for subj= 1:numel(subjects)
%     %9/30/21 doesn't seem like all 0s are happening, and this causes error 
%     allSubjDSblue(:,find(all(allSubjDSblue(:,:,subj)==0)),subj)= nan;
%     allSubjDSpurple(:,find(all(allSubjDSpurple(:,:,subj)==0)), subj)= nan;
end

%reshaping to plot based on unique reward labels instead of stage
%dp 9/30/21 necessary? I think reshape() is inappropriately breaking up
%data- reshaping from 3d to 2d
allSubjDSblue=reshape(allSubjDSblue,size([allSubjTransitionLabels{:}],2),[])';
allSubjDSpurple=reshape(allSubjDSpurple,size([allSubjTransitionLabels{:}],2),[])';
allSubjTransitions= reshape(allSubjTransitions,size([allSubjTransitionLabels{:}],2),[])';
%reshape 281x9x9 -> 81x281

A= [1:10;11:20];
A(:,:,2)= [21:30;31:40];

B = reshape(A,[],2);

%allSubj matrix shapes = peri-event time bin, transitionType, subj
%permute so that 

test= allSubjDSblue(:);
test= squeeze(allSubjDSblue);

test= allSubjDSblue;
test1= permute(test,[1,3,2]);
test2= reshape(test1,[],size(test,2),1);

test1= permute(test,[2,1,3]);
test2= reshape(test1,[],size(test,2),1);

%% between subj plots
% Now make a between-subj plot of mean across all animals- DS & NS overlay
figure;
figureCount=figureCount+1; sgtitle('peri-first DS lick response by outcome transition: mean between subjects ');
for subj= 1:numel(subjects)
%     for thisStage= 1:size(allSubjDSblue,2)
        for transitionType= (unique([allSubjTransitionLabels{:}])) %loop through possible transition type labels
            %index matching columns belonging to this specific outcome
            %transition
            thisTransitionCount= find(ismember((unique([allSubjTransitionLabels{:}])),transitionType{1}));
            thisTransitionCol= find(ismember([allSubjTransitionLabels{:}],transitionType{1}));
                %calculate between subj mean data for this outcome
                %transition %not really 'thisStageDSblue' but
                %'thisTransitionDSblue'
            thisStageDSblue= nanmean(nanmean(allSubjDSblue(:,thisTransitionCol,:),3),2);
            thisStageDSpurple= nanmean(nanmean(allSubjDSpurple(:,thisTransitionCol,:),3),2);c
%             thisStageNSblue= nanmean(allSubjNSblue(:,thisTransitionCol,:), 3);
%             thisStageNSpurple= nanmean(allSubjNSpurple(:,thisTransitionCol,:),3);

                %calculate SEM between subjects
            semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
            semDSblueAllSubj= nanmean(nanstd(allSubjDSblue(:,thisTransitionCol,:),0,3)/sqrt(numel(subjects)),2);
            semDSpurpleAllSubj= nanmean(nanstd(allSubjDSpurple(:,thisTransitionCol,:),0,3)/sqrt(numel(subjects)),2);
%             semNSblueAllSubj= nanstd(allSubjNSblue(:,thisTransitionCol,:),0,3)/sqrt(numel(subjects));
%             semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisTransitionCol,:),0,3)/sqrt(numel(subjects));


                    %DS
%             subplot(subplot(1, size(allSubjDSblue,2), thisTransitionCount)); hold on; title(strcat('stage-',num2str(thisTransitionCount),'peri-cue')) 
    %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
    %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%             plot(timeLock, thisStageDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
            plot(timeLock, thisStageDSblue,'LineWidth',2); %plot between-subjects mean blue

                %dp 9/30/21 will need more colors
%             plot(timeLock, thisStageDSblue,'Color', colors(find(transitionsPossible==transitionsPossible(transitionType{:})),:),'EdgeColor','None')
            hold on;
    %         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
                            %overlay SEM blue
            semLinePosAllSubj= thisStageDSblue+semDSblueAllSubj;%nanmean(semDSblue(:,thisStage,:),3);
            semLineNegAllSubj= thisStageDSblue-semDSblueAllSubj;%nanmean(semDSblue(:,thisStage,:),3);
%             patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.2);
            patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.2);

                %NS- dp 9/30/21 not done yet         
% 
%             plot(timeLock, thisStageNSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean blue
%     %         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                                %overlay SEM blue
% %             semLinePosAllSubj= thisStageNSblue+semNSblueAllSubj;%nanmean(semNSblue(:,thisStage,:),3);
% %             semLineNegAllSubj= thisStageNSblue-semNSblueAllSubj;%nanmean(semNSblue(:,thisStage,:),3);
%             patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.2);
%     %                 %overlay SEM purple
%     %         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
%     %         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
%     %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        end%end loop through outcome transitions
        legend(unique([allSubjTransitionLabels{:}]));
        if thisTransitionCount==1
%            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
%              legend('DS 465nm', 'SEM', 'NS 465nm','SEM');
        end
%     end %end stage loop
end %end subj loop

linkaxes(); %link axes for scale comparison
%     figure();
%     subplot(2,1,1); hold on; title(strcat(subjects{subj},'-stage-',num2str(thisStage),'-','peri DS blue, PE trials by transitionType'));

%% Peri-cue activity by PE outcome (PE, noPE, or inPort)
% goal here is to plot peri-DS response for each stage based on trial outcome (either rat
% was in port at cue onset, made a PE during cue epoch, or
% did not make a PE)

%initialize some variables
allSubjPEDSblue= []; allSubjPEDSpurple= []; allSubjPENSblue= []; allSubjPENSpurple=[];
allSubjNoPEDSblue= []; allSubjNoPEDSpurple= []; allSubjNoPENSblue= []; allSubjNoPENSpurple= [];
allSubjInPortDSblue= []; allSubjInPortDSpurple= []; allSubjInPortNSblue= []; allSubjInPortNSpurple= [];
allSubjFirstPoxDS= []; allSubjFirstPoxNS= [];
    
allSubjPumpOnTimeRel= nan(([numel(allStages), numel(subjects)]));

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);
   
    
    for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        includedSessions= []; %excluded sessions will reset between unique stages
        inPortDSblue= []; inPortDSpurple= []; noPEDSblue= []; noPEDSpurple= []; PEDSblue= []; PEDSpurple= []; %reset between sessions
        inPortNSblue= []; inPortNSpurple= []; noPENSblue= []; noPENSpurple= []; PENSblue= []; PENSpurple= []; %reset between sessions
        firstPoxDS=[]; firstPoxNS= []; pumpOnTimeRel= []; 
        
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
               includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
    
         for includedSession= includedSessions %loop through only sessions that match this stage
            DSinPort= []; DSnoPE= []; DSPE= []; %reset between sessions
            NSinPort= []; NSnoPE= []; NSPE= [];
            PEtrial= []; noPEtrial=[]; inPortTrial=[];
             %Extract data based on trial outcome
             
         %loop through each trial type (1= PE, 2= noPE, 3= inPort) and get
         %peri-DS response
                           
         %Here we will collect mean() peri-DS response within sessions,
         %that we can see if there's a particularly bad session that would
         %otherwise be hidden in a between-session mean
            for PEtrial= currentSubj(includedSession).trialOutcome.DSoutcome==1 %loop through trials and cat responses into one array
                PEDSblue= [PEDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(:,:,PEtrial),3)];
                PEDSpurple= [PEDSpurple, nanmean(currentSubj(includedSession).periDS.DSzpurple(:,:,PEtrial),3)];
                
                %record first pe and lick latency for later overlay on plots
                %TODO: there is some bug here or earlier with poxDSrel that might
                %make PEtrials empty? just skipping over empty cells here
                %(checking to make sure PEtrial==1)
                
                %WORKING HEREE
                firstPoxDS(includedSessions==includedSession)= nanmean((cellfun(@(v)v(1),currentSubj(includedSession).behavior.poxDSrel(PEtrial==1))));
                pumpOnTimeRel= [pumpOnTimeRel; currentSubj(includedSession).reward.pumpOnDSrel(PEtrial)];

            end
            
            for noPEtrial= currentSubj(includedSession).trialOutcome.DSoutcome==2 %loop through trials and cat responses into one array
                noPEDSblue= [noPEDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(:,:,noPEtrial),3)];
                noPEDSpurple= [noPEDSpurple, nanmean(currentSubj(includedSession).periDS.DSzpurple(:,:,noPEtrial),3)];
            end
            
            for inPortTrial = currentSubj(includedSession).trialOutcome.DSoutcome==3 %loop through trials and cat responses into one array
                inPortDSblue= [inPortDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(:,:,inPortTrial),3)];
                inPortDSpurple= [inPortDSpurple, nanmean(currentSubj(includedSession).periDS.DSzpurple(:,:,inPortTrial),3)];
            end  
            
            %repeat for NS
            PEtrial= []; noPEtrial= []; inPortTrial=[];
            for PEtrial= currentSubj(includedSession).trialOutcome.NSoutcome==1 %loop through trials and cat responses into one array
                PENSblue= [PENSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(:,:,PEtrial),3)];
                PENSpurple= [PENSpurple, nanmean(currentSubj(includedSession).periNS.NSzpurple(:,:,PEtrial),3)];
            
                firstPoxNS(includedSessions==includedSession)= nanmean((cellfun(@(v)v(1),currentSubj(includedSession).behavior.poxNSrel(PEtrial==1))));
            end
            
            for noPEtrial= currentSubj(includedSession).trialOutcome.NSoutcome==2 %loop through trials and cat responses into one array
                noPENSblue= [noPENSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(:,:,noPEtrial),3)];
                noPENSpurple= [noPENSpurple, nanmean(currentSubj(includedSession).periNS.NSzpurple(:,:,noPEtrial),3)];
            end
            
            for inPortTrial = currentSubj(includedSession).trialOutcome.NSoutcome==3 %loop through trials and cat responses into one array
                inPortNSblue= [inPortNSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(:,:,inPortTrial),3)];
                inPortNSpurple= [inPortNSpurple, nanmean(currentSubj(includedSession).periNS.NSzpurple(:,:,inPortTrial),3)];
            end    
            
            
         end %end includedSession loop         
        
          %collect data from all subjects for a between-subjects mean plot
        allSubjPEDSblue(:,thisStage,subj)= nanmean(PEDSblue,2);
        allSubjPEDSpurple(:,thisStage, subj)= nanmean(PEDSpurple,2);
        
        allSubjNoPEDSblue(:, thisStage, subj)= nanmean(noPEDSblue, 2);
        allSubjNoPEDSpurple(:, thisStage, subj)= nanmean(noPEDSpurple, 2);
        
        allSubjInPortDSblue(:,thisStage, subj)= nanmean(inPortDSblue, 2);
        allSubjInPortDSpurple(:,thisStage, subj)= nanmean(inPortDSpurple,2);
       
        
        allSubjPumpOnTimeRel(thisStage,subj)= nanmean(pumpOnTimeRel);


    
        if ~isempty(PENSblue)
           allSubjPENSblue(:,thisStage,subj)= nanmean(PENSblue,2);
           allSubjPENSpurple(:,thisStage,subj)= nanmean(PENSpurple,2);
           
           allSubjNoPENSblue(:,thisStage,subj)= nanmean(noPENSblue,2);
           allSubjNoPENSpurple(:,thisStage,subj)= nanmean(noPENSpurple,2);
           
              
           allSubjInPortNSblue(:,thisStage,subj)= nanmean(inPortNSblue,2);
           allSubjInPortNSpurple(:,thisStage,subj)= nanmean(inPortNSpurple,2);
        end
        
        %collect mean pe and lick latency for this stage as well, so we can overlay in plots
        allSubjFirstPoxDS(:,thisStage,subj)= nanmean(firstPoxDS);
        allSubjFirstPoxNS(:,thisStage,subj)= nanmean(firstPoxNS);        
         
        figure(figureCount); hold on; sgtitle(strcat(subjectsAnalyzed{subj},'peri-DS response session means by PE outcome'));
        
        subplot(3, allStages(end), thisStage); hold on; title(strcat('No PE DS stage-',num2str(thisStage)));
%         plot(timeLock, noPEDSblue, 'b'); %plot individual session means
%         plot(timeLock, noPEDSpurple,'m');  %plot individual session means
        plot(timeLock, mean(noPEDSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
        plot(timeLock, mean(noPEDSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
        
        subplot(3,allStages(end), allStages(end)+thisStage); hold on; title(strcat('PE DS stage-',num2str(thisStage)));
%         plot(timeLock, PEDSblue, 'b'); %plot individual session means
%         plot(timeLock, PEDSpurple, 'm'); %plot individual session means
        plot(timeLock, mean(PEDSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
        plot(timeLock, mean(PEDSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

        plot([nanmean(pumpOnTimeRel),  nanmean(pumpOnTimeRel)], eventLineLimits, 'm--', 'LineWidth',2) %ovelay line at mean pump onset
        
        
        subplot(3, allStages(end),  allStages(end)+allStages(end)+thisStage); hold on; title(strcat('inPort DS stage-',num2str(thisStage)));
%         plot(timeLock, inPortDSblue, 'b'); %plot individual session means
%         plot(timeLock, inPortDSpurple, 'm'); %plot individual session means
        plot(timeLock, mean(inPortDSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
        plot(timeLock, mean(inPortDSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
        linkaxes();

            %todo : overlay mean & SEM
        
        xlabel('time from DS onset');
        ylabel(' 465nm z score response');

        %repeat for NS
        if thisStage>= 5%only run for stages with NS
            figure(figureCount+1); hold on; sgtitle(strcat(subjectsAnalyzed{subj},'peri-NS response session means by PE outcome'));

            subplot(3, allStages(end), thisStage); hold on; title(strcat('No PE NS stage-',num2str(thisStage)));
%             plot(timeLock, noPENSblue, 'b'); %plot individual session means 
%             plot(timeLock, noPENSpurple,'m');%plot individual session means 
            plot(timeLock, mean(noPENSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, mean(noPENSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
            
            subplot(3,allStages(end), allStages(end)+thisStage); hold on; title(strcat('PE NS stage-',num2str(thisStage)));
%             plot(timeLock, PENSblue, 'b');%plot individual session means 
%             plot(timeLock, PENSpurple, 'm');%plot individual session means 
            plot(timeLock, mean(PENSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, mean(PENSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
        
            subplot(3, allStages(end),  allStages(end)+allStages(end)+thisStage); hold on; title(strcat('inPort NS stage-',num2str(thisStage)));
%             plot(timeLock, inPortNSblue, 'b');%plot individual session means 
%             plot(timeLock, inPortNSpurple, 'm');%plot individual session means 
            plot(timeLock, mean(inPortNSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, mean(inPortNSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
        
        end %end NS stage conditional
        linkaxes();
        
    end %end Stage loop 
       set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
       set(figure(figureCount), 'Position', get(0, 'Screensize'));
%        linkaxes();

      figureCount= figureCount+2; %+2 because alternating plot on separate DS & NS figures
end %end subj loop

%replace columns that have all zeros with nans (this could happen if an animal
%didn't run a particular stage)
for subj= 1:numel(subjects)
    allSubjPEDSblue(:,find(all(allSubjPEDSblue(:,:,subj)==0)),subj)= nan;
    allSubjPEDSpurple(:,find(all(allSubjPEDSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjNoPEDSblue(:,find(all(allSubjNoPEDSblue(:,:,subj)==0)), subj)= nan;
    allSubjNoPEDSpurple(:,find(all(allSubjNoPEDSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjInPortDSblue(:,find(all(allSubjInPortDSblue(:,:,subj)==0)), subj)= nan;
    allSubjInPortDSpurple(:,find(all(allSubjInPortDSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjPENSblue(:,find(all(allSubjPENSblue(:,:,subj)==0)),subj)= nan;
    allSubjPENSpurple(:,find(all(allSubjPENSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjNoPENSblue(:,find(all(allSubjNoPENSblue(:,:,subj)==0)), subj)= nan;
    allSubjNoPENSpurple(:,find(all(allSubjNoPENSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjInPortNSblue(:,find(all(allSubjInPortNSblue(:,:,subj)==0)), subj)= nan;
    allSubjInPortNSpurple(:,find(all(allSubjInPortNSpurple(:,:,subj)==0)), subj)= nan;
    
    allSubjFirstPoxDS(:,find(allSubjFirstPoxDS(:,:,subj)==0),subj)=nan;
    allSubjFirstPoxNS(:,find(allSubjFirstPoxNS(:,:,subj)==0),subj)=nan;

end

%% Now make a between-subj plot of mean across all animals
    %DS
figure;
figureCount=figureCount+1; sgtitle('peri-DS response by PE outcome: mean between subjects ');
for subj= 1:numel(subjects)
    for thisStage= 1:size(allSubjPEDSblue,2) 
        thisStagePEDSblue= nanmean(allSubjPEDSblue(:,thisStage,:),3);
        thisStagePEDSpurple= nanmean(allSubjPEDSpurple(:,thisStage,:),3);
        
        thisStageNoPEDSblue= nanmean(allSubjNoPEDSblue(:,thisStage,:),3);
        thisStageNoPEDSpurple= nanmean(allSubjNoPEDSpurple(:,thisStage,:),3);

        thisStageInPortDSblue= nanmean(allSubjInPortDSblue(:,thisStage,:),3);
        thisStageInPortDSpurple= nanmean(allSubjInPortDSpurple(:,thisStage,:),3);
        
              %calculate SEM between subjects
        semPEDSblueAllSubj= []; semPEDSpurpleAllSubj=[]; semPENSblueAllSubj= []; semPENSpurpleAllSubj=[]; %reset btwn stages
        semNoPEDSblueAllSubj= []; semNoPEDSpurpleAllSubj= []; semNoPENSblueAllSubj= []; semNoPENSpurpleAllSubj= [];
        semInPortDSblueAllSubj= []; semInPortDSpurpleAllSubj= []; semInPortNSblueALlSubj= []; semInPortNSpurpleAllSubj=[];
        
        semPEDSblueAllSubj= nanstd(allSubjPEDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semPEDSpurpleAllSubj= nanstd(allSubjPEDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPEDSblueAllSubj= nanstd(allSubjNoPEDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPEDSpurpleAllSubj= nanstd(allSubjNoPEDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortDSblueAllSubj= nanstd(allSubjInPortDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortDSpurpleAllSubj= nanstd(allSubjInPortDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));

                %DS
        subplot(subplot(3, size(allSubjPEDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'DS PE')) 
%         plot(timeLock, (allSubjPEDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjPEDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStagePEDSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStagePEDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
            %sem overlay
        semLinePosAllSubj= thisStagePEDSblue+semPEDSblueAllSubj;
        semLineNegAllSubj= thisStagePEDSblue-semPEDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStagePEDSpurple+semPEDSpurpleAllSubj;
        semLineNegAllSubj= thisStagePEDSpurple-semPEDSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
        
        subplot(subplot(3, size(allSubjPEDSblue,2), size(allSubjPEDSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'DS noPE')) 
%         plot(timeLock, (allSubjNoPEDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjNoPEDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStageNoPEDSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageNoPEDSpurple,'r','LineWidth',2); %plot between-subjects mean purple

                    %sem overlay
        semLinePosAllSubj= thisStageNoPEDSblue+semNoPEDSblueAllSubj;
        semLineNegAllSubj= thisStageNoPEDSblue-semNoPEDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStageNoPEDSpurple+semNoPEDSpurpleAllSubj;
        semLineNegAllSubj= thisStageNoPEDSpurple-semNoPEDSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
        
        subplot(subplot(3, size(allSubjPEDSblue,2), size(allSubjPEDSblue,2)+size(allSubjPEDSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'DS inPort')) 
%         plot(timeLock, (allSubjInPortDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjInPortDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStageInPortDSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageInPortDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
                    %sem overlay
        semLinePosAllSubj= thisStageInPortDSblue+semInPortDSblueAllSubj;
        semLineNegAllSubj= thisStageInPortDSblue-semInPortDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStageInPortDSpurple+semInPortDSpurpleAllSubj;
        semLineNegAllSubj= thisStageInPortDSpurple-semInPortDSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
        
        if thisStage==1
           legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
        end
    end
end

linkaxes(); %link axes for scale comparison


%NS
figure;
figureCount=figureCount+1; sgtitle('peri-NS response by PE outcome: mean between subjects ');
for subj= 1:numel(subjects)
    for thisStage= 1:size(allSubjPENSblue,2) 
        thisStagePENSblue= nanmean(allSubjPENSblue(:,thisStage,:),3);
        thisStagePENSpurple= nanmean(allSubjPENSpurple(:,thisStage,:),3);
        
        thisStageNoPENSblue= nanmean(allSubjNoPENSblue(:,thisStage,:),3);
        thisStageNoPENSpurple= nanmean(allSubjNoPENSpurple(:,thisStage,:),3);

        thisStageInPortNSblue= nanmean(allSubjInPortNSblue(:,thisStage,:),3);
        thisStageInPortNSpurple= nanmean(allSubjInPortNSpurple(:,thisStage,:),3);
        
              %calculate SEM between subjects
        semPENSblueAllSubj= []; semPENSpurpleAllSubj=[]; semPENSblueAllSubj= []; semPENSpurpleAllSubj=[]; %reset btwn stages
        semNoPENSblueAllSubj= []; semNoPENSpurpleAllSubj= []; semNoPENSblueAllSubj= []; semNoPENSpurpleAllSubj= [];
        semInPortNSblueAllSubj= []; semInPortNSpurpleAllSubj= []; semInPortNSblueALlSubj= []; semInPortNSpurpleAllSubj=[];
        
        semPENSblueAllSubj= nanstd(allSubjPENSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semPENSpurpleAllSubj= nanstd(allSubjPENSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPENSblueAllSubj= nanstd(allSubjNoPENSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPENSpurpleAllSubj= nanstd(allSubjNoPENSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortNSblueAllSubj= nanstd(allSubjInPortNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortNSpurpleAllSubj= nanstd(allSubjInPortNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));

                %NS
        subplot(subplot(3, size(allSubjPENSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'NS PE')) 
%         plot(timeLock, (allSubjPENSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjPENSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStagePENSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStagePENSpurple,'r','LineWidth',2); %plot between-subjects mean purple
            %sem overlay
        semLinePosAllSubj= thisStagePENSblue+semPENSblueAllSubj;
        semLineNegAllSubj= thisStagePENSblue-semPENSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStagePENSpurple+semPENSpurpleAllSubj;
        semLineNegAllSubj= thisStagePENSpurple-semPENSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
      
        subplot(subplot(3, size(allSubjPENSblue,2), size(allSubjPENSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'NS noPE')) 
%         plot(timeLock, (allSubjNoPENSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjNoPENSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStageNoPENSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageNoPENSpurple,'r','LineWidth',2); %plot between-subjects mean purple
                    %sem overlay
        semLinePosAllSubj= thisStageNoPENSblue+semNoPENSblueAllSubj;
        semLineNegAllSubj= thisStageNoPENSblue-semNoPENSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStageNoPENSpurple+semNoPENSpurpleAllSubj;
        semLineNegAllSubj= thisStageNoPENSpurple-semNoPENSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        subplot(subplot(3, size(allSubjPENSblue,2), size(allSubjPENSblue,2)+size(allSubjPENSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'NS inPort')) 
%         plot(timeLock, (allSubjInPortNSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
%         plot(timeLock, (allSubjInPortNSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
        plot(timeLock, thisStageInPortNSblue,'k','LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageInPortNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
                    %sem overlay
        semLinePosAllSubj= thisStageInPortNSblue+semInPortNSblueAllSubj;
        semLineNegAllSubj= thisStageInPortNSblue-semInPortNSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
        
        semLinePosAllSubj= thisStageInPortNSpurple+semInPortNSpurpleAllSubj;
        semLineNegAllSubj= thisStageInPortNSpurple-semInPortNSpurpleAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
        
        if thisStage==1
           legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
        end
    end
end
linkaxes();


% Now let's do a between subj with DS and NS 465 overlaid

stagesToPlot= [4,5,7,12]; %easy way to plot specific stages
% stagesToPlot= [5,7] %easy way to plot specific stages


figure;
figureCount=figureCount+1; sgtitle('peri-cue response by PE outcome: mean between subjects ');
for subj= 1:numel(subjects)
    for thisStage= stagesToPlot 
        thisStagePEDSblue= nanmean(allSubjPEDSblue(:,thisStage,:),3);
        thisStagePEDSpurple= nanmean(allSubjPEDSpurple(:,thisStage,:),3);
        
        thisStageNoPEDSblue= nanmean(allSubjNoPEDSblue(:,thisStage,:),3);
        thisStageNoPEDSpurple= nanmean(allSubjNoPEDSpurple(:,thisStage,:),3);

        thisStageInPortDSblue= nanmean(allSubjInPortDSblue(:,thisStage,:),3);
        thisStageInPortDSpurple= nanmean(allSubjInPortDSpurple(:,thisStage,:),3);
        
        thisStagePENSblue= nanmean(allSubjPENSblue(:,thisStage,:),3);
        thisStagePENSpurple= nanmean(allSubjPENSpurple(:,thisStage,:),3);
        
        thisStageNoPENSblue= nanmean(allSubjNoPENSblue(:,thisStage,:),3);
        thisStageNoPENSpurple= nanmean(allSubjNoPENSpurple(:,thisStage,:),3);

        thisStageInPortNSblue= nanmean(allSubjInPortNSblue(:,thisStage,:),3);
        thisStageInPortNSpurple= nanmean(allSubjInPortNSpurple(:,thisStage,:),3);
        
        thisStageFirstPoxDS= nanmean(allSubjFirstPoxDS(:,thisStage,:),3);
        thisStageFirstPoxNS= nanmean(allSubjFirstPoxNS(:,thisStage,:),3);
        
              %calculate SEM between subjects
        semPEDSblueAllSubj= []; semPEDSpurpleAllSubj=[]; semPENSblueAllSubj= []; semPENSpurpleAllSubj=[]; %reset btwn stages
        semNoPEDSblueAllSubj= []; semNoPEDSpurpleAllSubj= []; semNoPENSblueAllSubj= []; semNoPENSpurpleAllSubj= [];
        semInPortDSblueAllSubj= []; semInPortDSpurpleAllSubj= []; semInPortNSblueALlSubj= []; semInPortNSpurpleAllSubj=[];
        
        semPEDSblueAllSubj= nanstd(allSubjPEDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semPEDSpurpleAllSubj= nanstd(allSubjPEDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPEDSblueAllSubj= nanstd(allSubjNoPEDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPEDSpurpleAllSubj= nanstd(allSubjNoPEDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortDSblueAllSubj= nanstd(allSubjInPortDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortDSpurpleAllSubj= nanstd(allSubjInPortDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semPENSblueAllSubj= nanstd(allSubjPENSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semPENSpurpleAllSubj= nanstd(allSubjPENSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPENSblueAllSubj= nanstd(allSubjNoPENSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semNoPENSpurpleAllSubj= nanstd(allSubjNoPENSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortNSblueAllSubj= nanstd(allSubjInPortNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
        semInPortNSpurpleAllSubj= nanstd(allSubjInPortNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));


                %DS
        subplot(subplot(3, numel(stagesToPlot), find(stagesToPlot==thisStage))); hold on; title(strcat('stage-',num2str(thisStage),'PEtrial')) 
        plot(timeLock, thisStagePEDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStagePENSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean purple

            %sem overlay
        semLinePosAllSubj= thisStagePEDSblue+semPEDSblueAllSubj;
        semLineNegAllSubj= thisStagePEDSblue-semPEDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.15);
        
        semLinePosAllSubj= thisStagePENSblue+semPENSblueAllSubj;
        semLineNegAllSubj= thisStagePENSblue-semPENSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.15);
        
            %overlay line at cue onset
        plot([0,0],eventLineLimits,'k--');
%         xline(0, 'k--');
            %overlay line at mean first PE
        plot([thisStageFirstPoxDS, thisStageFirstPoxDS], eventLineLimits,'m-.');
            %overlay line at mean pump on
        plot([nanmean(allSubjPumpOnTimeRel(thisStage,:)),  nanmean(allSubjPumpOnTimeRel(thisStage,:))], eventLineLimits, 'g--', 'LineWidth',2) %ovelay line at mean pump onset

%         xline(thisStageFirstPoxDS, 'm--');
       
%         if ~isnan(thisStageFirstPoxNS)
% %             xline(thisStageFirstPoxNS, 'g--');
%             plot([thisStageFirstPoxNS, thisStageFirstPoxNS], eventLineLimits,'g--');
%         end
%         
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
        
        subplot(subplot(3, numel(stagesToPlot), numel(stagesToPlot)+find(stagesToPlot==thisStage))); hold on; title(strcat('stage-',num2str(thisStage),'noPE trial')) 
        plot(timeLock, thisStageNoPEDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageNoPENSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean purple
            %sem overlay
        semLinePosAllSubj= thisStageNoPEDSblue+semNoPEDSblueAllSubj;
        semLineNegAllSubj= thisStageNoPEDSblue-semNoPEDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.15);
        
        semLinePosAllSubj= thisStageNoPENSblue+semNoPENSblueAllSubj;
        semLineNegAllSubj= thisStageNoPENSblue-semNoPENSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.15);
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');

           %overlay line at cue onset
        plot([0,0],eventLineLimits,'k--');
%         xline(0,'k--');
        
        subplot(subplot(3, numel(stagesToPlot), numel(stagesToPlot)+numel(stagesToPlot)+find(stagesToPlot==thisStage))); hold on; title(strcat('stage-',num2str(thisStage),'DS inPort')) 
        plot(timeLock, thisStageInPortDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
        plot(timeLock, thisStageInPortNSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean purple
            %sem overlay
        semLinePosAllSubj= thisStageInPortDSblue+semInPortDSblueAllSubj;
        semLineNegAllSubj= thisStageInPortDSblue-semInPortDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.15);
        
        semLinePosAllSubj= thisStageInPortNSblue+semInPortNSblueAllSubj;
        semLineNegAllSubj= thisStageInPortNSblue-semInPortNSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.15);
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
       
            %overlay line at cue onset
        plot([0,0],eventLineLimits,'k--');
%         xline(0,'k--');
        
        
%         if find(stagesToPlot==thisStage)==1 
           subplot(3,numel(stagesToPlot),1)
           legend('DS 465','NS 465','sem','sem', 'cue onset','mean port entry latency', 'mean pump on');
%         end
    end
end
linkaxes();
ylim([-2,5]);
    