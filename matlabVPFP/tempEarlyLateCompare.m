%% Early vs Late Peri-cue activity by PE outcome (PE, noPE, or inPort)
% goal here is to plot peri-DS response for each stage based on trial outcome (either rat
% was in port at cue onset, made a PE during cue epoch, or
% did not make a PE)

%Early vs late! compare 1st session of a stage with last session of that
%stage

%initialize some variables
allSubjPEDSblue= []; allSubjPEDSpurple= []; allSubjPENSblue= []; allSubjPENSpurple=[];
allSubjNoPEDSblue= []; allSubjNoPEDSpurple= []; allSubjNoPENSblue= []; allSubjNoPENSpurple= [];
allSubjInPortDSblue= []; allSubjInPortDSpurple= []; allSubjInPortNSblue= []; allSubjInPortNSpurple= [];
allSubjFirstPoxDS= []; allSubjFirstPoxNS= [];

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);
   
    for thisStage= 1:numel(allStages) %using 1:numel(allStages) here bc if i want to plot a late stage alone it's easier %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        includedSessions= []; %excluded sessions will reset between unique stages
        inPortDSblue= []; inPortDSpurple= []; noPEDSblue= []; noPEDSpurple= []; PEDSblue= []; PEDSpurple= []; %reset between sessions
        inPortNSblue= []; inPortNSpurple= []; noPENSblue= []; noPENSpurple= []; PENSblue= []; PENSpurple= []; %reset between sessions
        firstPoxDS=[]; firstPoxNS= [];
                
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= numel(currentSubj) %1st and last session
            if currentSubj(session).trainStage == allStages(thisStage) %only include sessions from this stage
                includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
    
         for includedSession= includedSessions %loop through only sessions that match this stage
            DSinPort= []; DSnoPE= []; DSPE= []; %reset between sessions
            NSinPort= []; NSnoPE= []; NSPE= [];
            
            
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
                
                firstPoxDS(includedSessions==includedSession)= nanmean((cellfun(@(v)v(1),currentSubj(includedSession).behavior.poxDSrel(PEtrial==1))));

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
        
        
        for sessionCount= 1:numel(includedSessions)
            if sessionCount==1
               subplotCount=0; 
            end
                subplotCount=subplotCount+1;
                subplot(3, numel(includedSessions), (subplotCount)); hold on; title(strcat('No PE DS stage-',num2str(thisStage),num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));

        %         subplot(3, allStages(end), thisStage); hold on; title(strcat('No PE DS stage-',num2str(thisStage)));
        %         plot(timeLock, noPEDSblue, 'b'); %plot individual session means
        %         plot(timeLock, noPEDSpurple,'m');  %plot individual session means
            plot(timeLock, noPEDSblue(:,sessionCount),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, noPEDSpurple(:,sessionCount), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

            subplotCount= subplotCount+1;
            subplot(3, numel(includedSessions), subplotCount); hold on; title(strcat('PE DS stage-',num2str(thisStage),num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));
    %         plot(timeLock, PEDSblue, 'b'); %plot individual session means
    %         plot(timeLock, PEDSpurple, 'm'); %plot individual session means
            plot(timeLock, PEDSblue(:,sessionCount),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, PEDSpurple(:,sessionCount), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

            subplotCount= subplotCount+1;
            subplot(3, numel(includedSessions),  subplotCount); hold on; title(strcat('inPort DS stage-',num2str(thisStage),num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));
    %         plot(timeLock, inPortDSblue, 'b'); %plot individual session means
    %         plot(timeLock, inPortDSpurple, 'm'); %plot individual session means
            plot(timeLock, inPortDSblue(:,sessionCount),'k','LineWidth',2); %plot mean between all sessions of this stage
            plot(timeLock, inPortDSpurple(:,sessionCount), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage
            linkaxes();

                %todo : overlay mean & SEM

            xlabel('time from DS onset');
            ylabel(' 465nm z score response');
        end %end included session loop

        %repeat for NS
        if allStages(thisStage)>= 5%only run for stages with NS
            for sessionCount= 1:numel(includedSessions)
                if sessionCount==1
                   subplotCountNS=0; 
                end
                subplotCountNS=subplotCountNS+1;
                figure(figureCount+1); hold on; sgtitle(strcat(subjectsAnalyzed{subj},'peri-NS response session means by PE outcome'));
                subplot(3,numel(includedSessions), subplotCountNS); hold on; title(strcat('No PE NS stage-',num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));
    %             plot(timeLock, noPENSblue, 'b'); %plot individual session means 
    %             plot(timeLock, noPENSpurple,'m');%plot individual session means 
                plot(timeLock, mean(noPENSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
                plot(timeLock, mean(noPENSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

                subplotCountNS= subplotCountNS+1;
                subplot(3,numel(includedSessions), subplotCountNS); hold on; title(strcat('PE NS stage-',num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));
    %             plot(timeLock, PENSblue, 'b');%plot individual session means 
    %             plot(timeLock, PENSpurple, 'm');%plot individual session means 
                plot(timeLock, mean(PENSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
                plot(timeLock, mean(PENSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

                subplotCountNS= subplotCountNS+1;
                subplot(3, numel(includedSessions), subplotCountNS); hold on; title(strcat('inPort NS stage-',num2str(allStages(thisStage)),'-session#',num2str(includedSessions(sessionCount))));
    %             plot(timeLock, inPortNSblue, 'b');%plot individual session means 
    %             plot(timeLock, inPortNSpurple, 'm');%plot individual session means 
                plot(timeLock, mean(inPortNSblue,2),'k','LineWidth',2); %plot mean between all sessions of this stage
                plot(timeLock, mean(inPortNSpurple, 2), 'r', 'LineWidth', 2); %plot mean between all sessions of this stage

            end %end NS stage conditional
        end %end included session loop
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

% Now make a between-subj plot of mean across all animals
    %DS
figure;
figureCount=figureCount+1; sgtitle('peri-DS response by PE outcome: mean between subjects ');
for subj= 1:numel(subjects)
    for thisStage= 1:numel(allStages) % 1:size(allSubjDSblue,2) 
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
    for thisStage= 1:numel(allStages) %1:size(allSubjNSblue,2) 
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


%% Now let's do a between subj with DS and NS 465 overlaid

stagesToPlot= allStages % [4,5,7,12] %easy way to plot specific stages
eventLineLimits= [-1,4]; %range of ylim for vertical line overlays @ events

figure;
figureCount=figureCount+1; sgtitle('peri-cue response by PE outcome: mean between subjects ');
for subj= 1:numel(subjects)
    for thisStage= 1:numel(allStages) %stagesToPlot 
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
        subplot(subplot(3, numel(stagesToPlot), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'PEtrial')) 
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
%         xline(thisStageFirstPoxDS, 'm--');
       
%         if ~isnan(thisStageFirstPoxNS)
% %             xline(thisStageFirstPoxNS, 'g--');
%             plot([thisStageFirstPoxNS, thisStageFirstPoxNS], eventLineLimits,'g--');
%         end
%         
        xlabel('time from cue onset (s)'); ylabel('z-score relative to pre-cue baseline');
        
        subplot(subplot(3, numel(stagesToPlot), numel(stagesToPlot)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'noPE trial')) 
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
        
        subplot(subplot(3, numel(stagesToPlot), numel(stagesToPlot)+numel(stagesToPlot)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'DS inPort')) 
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
           legend('DS 465','NS 465','sem','sem','cue onset','mean port entry latency');
%         end
    end
end
linkaxes();
