% replicate fp_latencyCorrelation with periEventTable

%% TODO: subset sessions for analysis

data= periEventTable;

%% gather data for latency corr

latencyCorrTable= data;

  %-- DS trials
  
%signal columns (what to replace with nan)
y=[];
y= ["DSblue", "DSpurple", "DSbluepox", "DSpurplePox"];


%replace signal following first PE for each trial with nan
ind=[];
ind= data.timeLock > data.poxDSrel;

latencyCorrTable(ind, y) = table(nan);


% % takes too long & unneccesary
% %independently collect data for each trialID;
% allDStrials= unique(data.DStrialIDcum);
% 
% for trial= 1:numel(allDStrials)
%    ind1= [];
%    
%    ind1= data.DStrialIDcum==trial;
%    
% %    data2= data(ind1,:);
%    
%   %exclude timestamps following first PE
% 
%     ind2=[];
%     ind2= data.timeLock > data.poxDSrel;
%     
%     
%     %combine ind for replacement in original table
%     ind3=[];
%     ind3= ind1 & ind2;
%     
%     latencyCorrTable(ind3, y) = table(nan);
%     
% end

% %independently run for each fileID
% 
% % allSessions= unique(data.fileID);
% % 
% % for session= 1:numel(allSessions)
% %    
% %     ind= []; 
% %     ind=data.fileID==allSessions(session);
% %     
% %     data2= data(ind,:);
% %     
% %     %--DS trials
% %         
% %     %exclude timestamps following first PE
% %     data2(
% %     
% % end

%% relevant for actual stat

%get trials only with pe 
% if (currentSubj(includedSession).trialOutcome.DSoutcome(cue)==1) %loop through DS trials with valid PE


%now exclude timestamps after port entry (to prevent contamination from consumption)
   tsExcluded= []; 
   tsExcluded= find(timeLock>=currentSubj(includedSession).behavior.poxDSrel{cue}(1)); 

   %make excluded timestamps nan
    %exclude ts after first PE
   blueZ(trialCount,tsExcluded)= nan; 
   peLat(trialCount, tsExcluded)= nan;
   
  %now run correlation for each timeStamp
%we will collect the correlation results from all subjects (1 row= 1 subject)
for timeStamp= 1:numel(timeLock)
    [rho(subj,timeStamp,thisStage),pval(subj,timeStamp,thisStage)]= corr(blueZ(:,timeStamp),peLat(:,timeStamp), 'Rows', 'Complete'); %Complete= ignore nan rows
end


%% -------OLD CODE--------------
%% Correlation between peri-cue Z score and PE latency

%If we want to relate Z scored fluorescence with PE latency, one way to do
%it would be to pool the Z score values for an individual timestamp
%(across all trials) and correlate them with the PE latency on that trial.
%Then, run a correlation between these Z scores and PE latency. Repeat for
%every timestamp of interest. Result is a beta coefficient for every
%timestamp with PE latency, so we can plot it over time.


%this will simply collect all of the unique stages from
%all subjects into an array (allStages)
allStages= []; %initialize
for subj= 1:numel(subjects) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
    allStages= [allStages, unique([currentSubj.trainStage])]; %cat unique stage values for all subj into one array
end
allStages= unique(allStages); %keep the unique stages (eliminate repeats from multiple subjects)
    
timeLock= subjDataAnalyzed.(subjects{subj})(1).periDS.timeLock; 


rho= nan(numel(subjects), numel(timeLock), numel(allStages)); %prefill with nan
pval= nan(numel(subjects), numel(timeLock), numel(allStages)); %prefill with nan
rhoSig= nan(size(rho));

peLatAllSubj= nan(numel(subjects), numel(allStages)); %prefill with nan


for subj= 1:numel(subjects)
    currentSubj=subjDataAnalyzed.(subjects{subj});
%     allStages= unique([currentSubj.trainStage]);

    
%     timeLock= currentSubj(1).periDS.timeLock;
    
     figure(figureCount); %1 fig per subj with all stages subplotted

    for thisStage= allStages
        if ~any([currentSubj.trainStage]==thisStage) %only run if this subject performed this stage
%             blueZ= nan(30, numel(timeLock));
%             peLat= nan(30, numel(timeLock));
                continue;
        end
        includedSessions= []; %reset between subjects
%         rho(subj,:,thisStage)= nan(numel(timeLock),1); %prefill with nan, save for all stages so we can plot all results later
%         pval(subj,:,thisStage)= nan(numel(timeLock),1);
        
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
               includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop

        trialCount= 1; %for easy indexing, reset between stages

        blueZ= nan(30*numel(includedSessions),numel(timeLock)); %prefill with nan (assumes 30 trials/session)
        peLat= nan(30*numel(includedSessions),numel(timeLock));
        
        for includedSession= includedSessions
            for cue= 1:numel(currentSubj(includedSession).periDS.DS)
                if (currentSubj(includedSession).trialOutcome.DSoutcome(cue)==1) %loop through DS trials with valid PE
                    for timeStamp= 1:numel(timeLock)
                      %assemble a matrix where each column contains z score value
                      %from all trials (rows) of a given timestamp
                      blueZ(trialCount,timeStamp)= currentSubj(includedSession).periDS.DSzblue(timeStamp,1,cue);
                      peLat(trialCount,timeStamp)= currentSubj(includedSession).behavior.poxDSrel{cue}(1); %get only first PE latency
                    end%end timestamp loop
                    
                    %now exclude timestamps after port entry (to prevent contamination from consumption)
                   tsExcluded= []; 
                   tsExcluded= find(timeLock>=currentSubj(includedSession).behavior.poxDSrel{cue}(1)); 

                   %make excluded timestamps nan
                    %exclude ts after first PE
                   blueZ(trialCount,tsExcluded)= nan; 
                   peLat(trialCount, tsExcluded)= nan;
                    
                   trialCount=trialCount+1; %iterate trialCount for indexing
                end %end DS with port entry loop
            end %end all DS loop
        end %end includedSession loop
        
%         figure(1); hold on;
%         for trial=1:trialCount
%             plot(blueZ(trial,:)) %just visualizing to make sure post port entry timestamps are being removed
%         end
        
        %now run correlation for each timeStamp
        %we will collect the correlation results from all subjects (1 row= 1 subject)
        for timeStamp= 1:numel(timeLock)
            [rho(subj,timeStamp,thisStage),pval(subj,timeStamp,thisStage)]= corr(blueZ(:,timeStamp),peLat(:,timeStamp), 'Rows', 'Complete'); %Complete= ignore nan rows
        end
        
            %some code here for individual figures for each stage
%         figure; hold on; sgtitle(strcat(subjects{subj},',-Stage-',num2str(thisStage), '-blueZ:PE latency by timestamp'));
%         subplot(2,1,1); hold on; title('correlation coeff rho'); plot(timeLock,rho);
%         xlabel('time from cue onset');
%         ylabel('corr coeff: all trials of this timestamp x latency from all trials'); 
        
%         rhoSig(subj,:,thisStage)= nan(1,size(rho,2));
        rhoSig(subj,pval(subj,:,thisStage)<=.05,thisStage)= rho(subj,pval(subj,:,thisStage)<=.05,thisStage); %get only values below alpha criteria
%         subplot(2,1,2); hold on; title('correlation coeff rho pval<=.05'); plot(timeLock,rhoSig);
%         xlabel('time from cue onset');        
%         
%         linkaxes();
        
    %would be nice to have a stage-by-stage plot in one figure:
        hold on; sgtitle(strcat(strcat(subjects{subj},'corr coeff rho-blueZ:PE latency by timestamp')));
        subplot(2, allStages(end), thisStage); title(strcat('stage-',num2str(thisStage)),'-rho'); hold on;
        
        xlabel('time to DS onset (s)'); ylabel('corr coef for this timestamp');
        plot(timeLock,rho(subj,:,thisStage));  
        plot([0,0],[-0.5,0.5],'k--'); %overlay vertical line @ cue onset
        
        if thisStage>=4 %before stage 4, mean PE latency tends to be longer than 10s, so linkaxes makes everything look small. Very likely that all the data displayed in plots happens before mean PE latency
            plot([nanmean(peLat(:,1)),nanmean(peLat(:,1))],[-0.5,0.5], 'g--'); %overlay vertical line @ mean PE latency
        end
        %add only one legend for the last subplot (seems to be easiest solution)
        if thisStage== allStages(end)
            legend('rho', 'DS onset', 'mean PE latency');
        end
        
        subplot(2, allStages(end), allStages(end)+thisStage); title(strcat('stage-',num2str(thisStage),'rho(pval<.05)')); hold on;
        xlabel('time to DS onset (s)'); ylabel('corr coef for this timestamp');
        plot(timeLock,rhoSig(subj,:,thisStage)); 
        plot([0,0],[-0.5,0.5],'k--'); %overlay vertical line @ cue onset
        if thisStage>=4 %before stage 4, mean PE latency tends to be longer than 10s, so linkaxes makes everything look small. Very likely that all the data displayed in plots happens before mean PE latency
            plot([nanmean(peLat(:,1)),nanmean(peLat(:,1))],[-0.5,0.5], 'g--'); %overlay vertical line @ mean PE latency
        end        
        
        %saving peLat between subjects for plotting later
        peLatAllSubj(subj,thisStage)= nanmean(peLat(:,1));
        
        if subj==1
           testLat=[]; 
        end
        if thisStage==5
           testLat=[testLat;peLat(:,1)]; %getting data for power analysis
        end
        
        
    end %end thisStage loop
    linkaxes();
    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    saveas(gcf,strcat(currentSubj(session).experiment, '_', subjects{subj}, '_ZscoreXpeLatencyCorr'));
        %dp saving by path not working for some reason?
%     saveas(gcf, strcat(figPath,currentSubj(session).experiment, '_', subjects{subj}, '_ZscoreXpeLatencyCorr')); %save the current figure in fig format
    figureCount=figureCount+1;
end %end subj loop

%% now make one figure with all subjects plotted as individual lines

stagesToPlot= [7]; %define specific stages you want to plot here

% for thisStage= stagesToPlot
for thisStage= stagesToPlot
    for subj= 1:numel(subjects)

        figure(figureCount); hold on; sgtitle(strcat(currentSubj(1).experiment,'-corr coeff rho-blueZ:PE latency by timestamp'));

%         subplot(2, numel(stagesToPlot), find(stagesToPlot==thisStage)); title(strcat('stage-',num2str(thisStage)),'-rho'); hold on;

        xlabel('time from DS onset (s)'); ylabel('mean correlation coefficient for this timestamp');
        
        if subjSex(subj)==0 %change plot color depending on sex
            plot(timeLock,rho(subj,:,thisStage))%,'g');  
        elseif subjSex(subj)==1
            plot(timeLock,rho(subj,:,thisStage))%,'b');
        end
        
        
        if thisStage>=4 %before stage 4, mean PE latency tends to be longer than 10s, so linkaxes makes everything look small. Very likely that all the data displayed in plots happens before mean PE latency
%             plot([nanmean(peLat(:,1)),nanmean(peLat(:,1))],[-0.5,0.5], 'g--'); %overlay vertical line @ mean PE latency
        end
        %add only one legend for the last subplot (seems to be easiest solution)
        if thisStage== stagesToPlot(end)
%             legend('rho', 'DS onset', 'mean PE latency');
        end

%         subplot(2,  numel(stagesToPlot), numel(stagesToPlot)+find(stagesToPlot==thisStage)); title(strcat('stage-',num2str(thisStage),'rho(pval<.05)')); hold on;
%         xlabel('time from DS onset (s)'); ylabel('corr coef for this timestamp');
%         if subjSex(subj)==0 %change plot color depending on sex
%             plot(timeLock,rhoSig(subj,:,thisStage),'g');  
%         elseif subjSex(subj)==1
%             plot(timeLock,rhoSig(subj,:,thisStage),'b');
%         end%         plot([0,0],[-0.5,0.5],'k--'); %overlay vertical line @ cue onset

        if thisStage>=4 %before stage 4, mean PE latency tends to be longer than 10s, so linkaxes makes everything look small. Very likely that all the data displayed in plots happens before mean PE latency
%             plot([nanmean(peLat(:,1)),nanmean(peLat(:,1))],[-0.5,0.5], 'g--'); %overlay vertical line @ mean PE latency
        end        
    end %end subj loop
        
        %plot mean btwn subjects
        plot(timeLock,nanmean(rho(:,:,thisStage),1), 'k-', 'LineWidth', 2); %overlay mean btwn subj

    
        %plot SEM between subjects
        semDSblueAllSubj= []; ; %calculate SEM
        semDSblueAllSubj= nanstd(rho(:,:,thisStage),0,1)/sqrt(numel(subjects));
             %overlay SEM 
        semLinePosAllSubj= nanmean(rho(:,:,thisStage),1)+semDSblueAllSubj;
        semLineNegAllSubj= nanmean(rho(:,:,thisStage),1)-semDSblueAllSubj;
        patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj,semLineNegAllSubj(end:-1:1)],'b','EdgeColor','None');alpha(0.3);
          
        plot([0,0],[-0.3,0.3],'k--'); %overlay vertical line @ cue onset

        
        %plot mean peLat between subjects
        plot([nanmean(peLatAllSubj(:,thisStage)),nanmean(peLatAllSubj(:,thisStage))],[-0.5,0.5],'m-.'); %overlay vertical line @ cue onset
        legend(subjects{:},'mean','sem','cue','mean peLat')

end %end stage loop
linkaxes();
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf,strcat(currentSubj(session).experiment, '_', subjects{subj}, '_ZscoreXpeLatencyCorr'));


%% ~~~~~~~older code below~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%% Impulse response function

%this is older code, but could be useful to exclude data after port
%entry (e.g. to isolate only pre-PE activity)

%Should be able to visualize/approximate impulse response function (to cue) by
%excluding all timestamps after port entry & averaging result

%only including trials w PE

for subj= 1:numel(subjects)
    currentSubj=subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);

    
    timeLock= currentSubj(1).periDS.timeLock;
    

    for thisStage= allStages
        includedSessions= []; %reset between stage

        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
               includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
    
    
        figure; hold on; title(strcat(subjects{subj},',-Stage-',num2str(thisStage), '; estimated impulse response to DS cue'));

        for includedSession= includedSessions  %now loop through all includedSessions of thisStage
           impulseCue= nan(numel(timeLock),numel(currentSubj(includedSession).periDS.DS)); %reset between sessions, prefill with nan
           for cue= 1:numel(currentSubj(includedSession).periDS.trialShift.DSrelShifted)
               if currentSubj(includedSession).trialOutcome.DSoutcome(cue)==1 %only include trial if there was a valid PE during cue
                   tsExcluded= [];

                   tsExcluded= find(timeLock>=currentSubj(includedSession).behavior.poxDSrel{cue}(1));

                   %make excluded timestamps nan
                    %exclude ts after first PE
                   currentSubj(includedSession).periDS.DSzblue(tsExcluded,:,cue)= nan; 

                   impulseCue(:,cue)= currentSubj(includedSession).periDS.DSzblue(:,:,cue);
               end %end exclusion conditional
           end %end DS loop


           if ~isempty(impulseCue) %only run if there are PEtrials in this session (e.g. there may be none on extinction days)
               %visualize
               for trial= 1:size(impulseCue,2)
                   plot(timeLock,impulseCue(:,trial), 'b');
               end
                    %overlay mean
               plot(timeLock,nanmean(impulseCue,2), 'k');
               legend('trial', 'mean')
           end
           
        end %end Stage loop
       
    end%end session loop
end%end subj loop

%% Scatter of cue-elicited response vs. port entry outcome (does cue elicited response predict PE?)

%again, old code that may be useful in relating post-cue activity to action
%outcome...

%goal here will be to create scatter of mean response to cue with 3 different outcomes: no PE, PE, or already in port (denoted by color of plot) 

%first set parameters
cueResponseLastFrame=.8*fs; %time after cue over which to take avg activity (t in seconds * fs)
cueResponseFirstFrame= (periCueFrames-postCueFrames)+ (.5*fs); %first frame after cue onset = (periCueFrames-postCueFrames)+1
for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);
   
    for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        includedSessions= []; %excluded sessions will reset between unique stages
        
        inPortDSblue= []; inPortDSpurple= []; noPEDSblue= []; noPEDSpurple= []; PEDSblue= []; PEDSpurple= []; %reset between sessions
        inPortNSblue= []; inPortNSpurple= []; noPENSblue= []; noPENSpurple= []; PENSblue= []; PENSpurple= []; %reset between sessions
        
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
               includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
    
         for includedSession= includedSessions %loop through only sessions that match this stage
            DSinPort= []; DSnoPE= []; DSPE= []; %reset between sessions
            NSinPort= []; NSnoPE= []; NSPE= [];
             %Extracting cue response
             %to do so, will use
             %cueOnsetFrame:cueOnsetFrame+cueResponseFrames as indices to
             %pull out relevant photometry data and will take the nanmean()

              %Identify trials where animal was in port at trial start,
              %trials with no PE, and trials with a valid PE. For each
              %trial type, loop through trials and get mean
              %cue-elicited response 

                %First, let's get trials where animal was already in port
                DSinPort= find(~isnan(currentSubj(includedSession).behavior.inPortDS));

                %Then, let's get trials where animal did not make a PE during the cue epoch. (cellfun('isempty'))
                DSnoPE = find(cellfun('isempty', currentSubj(includedSession).behavior.poxDS));
                 %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
                 for inPortTrial= DSinPort
                    DSnoPE(DSnoPE==inPortTrial)=[]; %eliminate trials where animal was in port
                 end
                 
             %lastly, get trials with valid PE
             DSPE= find(~cellfun('isempty', currentSubj(includedSession).behavior.poxDS));
              %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
             for inPortTrial= DSinPort
                 DSPE(DSPE==inPortTrial)=[]; %eliminate trials where animal was in port
             end
             
                %Make sure the trial types are all mutually exclusive to prevent errors (intersect() should return empty because no trials should be the same) 
             if ~isempty(intersect(DSinPort,DSnoPE)) || ~isempty(intersect(DSinPort, DSPE)) || ~isempty(intersect(DSnoPE, DSPE))
                disp('~~~~~~~~error: trial types not mutually exclusive');
             end
             
             %Repeat for NS trials
             %First, let's get trials where animal was already in port
                NSinPort= find(~isnan(currentSubj(includedSession).behavior.inPortNS));

                %Then, let's get trials where animal did not make a PE during the cue epoch. (cellfun('isempty'))
                NSnoPE = find(cellfun('isempty', currentSubj(includedSession).behavior.poxNS))'; %transpose ' due to shape
                 %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
                 for inPortTrial= NSinPort
                    NSnoPE(NSnoPE==inPortTrial)=[]; %eliminate trials where animal was in port
                 end
                 
             %lastly, get trials with valid PE
             NSPE= find(~cellfun('isempty', currentSubj(includedSession).behavior.poxNS))'; %transpose ' due to shape
              %additional check here to make sure animal was not in the
                %port at trial start even if a valid PE exists
             for inPortTrial= NSinPort
                 NSPE(NSPE==inPortTrial)=[]; %eliminate trials where animal was in port
             end
             
                %Make sure the trial types are all mutually exclusive to prevent errors (intersect() should return empty because no trials should be the same) 
             if ~isempty(intersect(NSinPort,NSnoPE)) || ~isempty(intersect(NSinPort, NSPE)) || ~isempty(intersect(NSnoPE, NSPE))
                disp('~~~~~~~~error: trial types not mutually exclusive');
             end
             
             
         %Now, loop through each trial type and get mean cue response for each trial
            for inPortTrial = DSinPort %loop through trials and cat mean response into one array
                inPortDSblue= [inPortDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,inPortTrial))];
            end    

            for noPEtrial= DSnoPE
                noPEDSblue= [noPEDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,noPEtrial))];
            end

            for PEtrial= DSPE
                PEDSblue= [PEDSblue, nanmean(currentSubj(includedSession).periDS.DSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,PEtrial))];
            end   

            if thisStage >= 5
                for inPortTrial = NSinPort %loop through trials and cat mean response into one array
                    inPortNSblue= [inPortNSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,inPortTrial))];
                end    

                for noPEtrial= NSnoPE
                    noPENSblue= [noPENSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,noPEtrial))];
                end

                for PEtrial= NSPE
                    PENSblue= [PENSblue, nanmean(currentSubj(includedSession).periNS.NSzblue(cueResponseFirstFrame:cueResponseFirstFrame+cueResponseLastFrame,:,PEtrial))];
                end
            end
          
         end %end includedSession loop
        
               %TODO: would be much more efficient to loop through trial
               %types (inPort, PE, noPE) instead of having discrete
               %variables for each
         %calculate within-subjects & within-stage SEM 
         SEMinPortDSblue= nanstd(inPortDSblue)/sqrt(numel(inPortDSblue)); %calculate SEM for each stage (n= # trials with this PE outcome)
         SEMnoPEDSblue= nanstd(noPEDSblue)/sqrt(numel(noPEDSblue));
         SEMPEDSblue= nanstd(PEDSblue)/sqrt(numel(noPEDSblue));
         
         SEMinPortNSblue= nanstd(inPortNSblue)/sqrt(numel(inPortNSblue)); %calculate SEM for each stage (n= # trials with this PE outcome)
         SEMnoPENSblue= nanstd(noPENSblue)/sqrt(numel(noPENSblue));
         SEMPENSblue= nanstd(PENSblue)/sqrt(numel(noPENSblue));
         
        
        figure(figureCount); hold on; sgtitle(strcat(subjectsAnalyzed{subj},'-PE outcome vs. mean cue response (',num2str(cueResponseFirstFrame/fs-preCueFrames/fs) ,': ' ,num2str(cueResponseLastFrame/fs),' s)'));
        subplot(2, allStages(end), thisStage); title(strcat('DS stage-',num2str(thisStage))); hold on;
%         histogram(inPortDSblue); %hist
%         histogram(noPEDSblue);
%         histogram(PEDSblue);
%         xlabel('mean 465nm DS response');
%         ylabel('trial count');
        scatter(ones(1,numel(inPortDSblue)), inPortDSblue); %scatter
        scatter(2*ones(1,numel(noPEDSblue)), noPEDSblue);
        scatter(3*ones(1,numel(PEDSblue)), PEDSblue);
        
            %overlay mean & SEM
        plot([1-.2, 1+.2], [nanmean(inPortDSblue), nanmean(inPortDSblue)], 'k');
        plot([1-.2,1+.2] , [nanmean(inPortDSblue)+SEMinPortDSblue, nanmean(inPortDSblue)+SEMinPortDSblue], 'k--');%overlay + sem of each subject
        plot([1-.2,1+.2] , [nanmean(inPortDSblue)-SEMinPortDSblue, nanmean(inPortDSblue)-SEMinPortDSblue], 'k--');%overlay - sem of each subject
        plot([1, 1], [nanmean(inPortDSblue),nanmean(inPortDSblue)-SEMinPortDSblue], 'k--'); %connect -SEM to mean
        plot([1, 1], [nanmean(inPortDSblue),nanmean(inPortDSblue)+SEMinPortDSblue], 'k--'); %connect -SEM to mean
        
        plot([2-.2, 2+.2], [nanmean(noPEDSblue), nanmean(noPEDSblue)], 'k');
        plot([2-.2,2+.2] , [nanmean(noPEDSblue)+SEMnoPEDSblue, nanmean(noPEDSblue)+SEMnoPEDSblue], 'k--');%overlay + sem of each subject
        plot([2-.2,2+.2] , [nanmean(noPEDSblue)-SEMnoPEDSblue, nanmean(noPEDSblue)-SEMnoPEDSblue], 'k--');%overlay - sem of each subject
        plot([2, 2], [nanmean(noPEDSblue),nanmean(noPEDSblue)-SEMnoPEDSblue], 'k--'); %connect -SEM to mean
        plot([2, 2], [nanmean(noPEDSblue),nanmean(noPEDSblue)+SEMnoPEDSblue], 'k--'); %connect -SEM to mean
        
        plot([3-.2, 3+.2], [nanmean(PEDSblue), nanmean(PEDSblue)], 'k');
        plot([3-.2,3+.2] , [nanmean(PEDSblue)+SEMPEDSblue, nanmean(PEDSblue)+SEMPEDSblue], 'k--');%overlay + sem of each subject
        plot([3-.2,3+.2] , [nanmean(PEDSblue)-SEMPEDSblue, nanmean(PEDSblue)-SEMPEDSblue], 'k--');%overlay - sem of each subject
        plot([3, 3], [nanmean(PEDSblue),nanmean(PEDSblue)-SEMPEDSblue], 'k--'); %connect -SEM to mean
        plot([3, 3], [nanmean(PEDSblue),nanmean(PEDSblue)+SEMPEDSblue], 'k--'); %connect -SEM to mean
        
        xlim([0,4]);
        
        xlabel('PE outcome');
        ylabel('mean 465nm z score response');
        if thisStage==allStages(1)
           legend('in port at cue onset', 'no port entry (unrewarded)', 'port entry during cue epoch (rewarded)'); 
        end
        
            %NS plot
        subplot(2,allStages(end), allStages(end)+thisStage); title(strcat('NS stage-', num2str(thisStage))); hold on;
        scatter(ones(1,numel(inPortNSblue)), inPortNSblue); %scatter
        scatter(2*ones(1,numel(noPENSblue)), noPENSblue);
        scatter(3*ones(1,numel(PENSblue)), PENSblue);
        
                    %overlay mean & SEM
        plot([1-.2, 1+.2], [nanmean(inPortNSblue), nanmean(inPortNSblue)], 'k');
        plot([1-.2,1+.2] , [nanmean(inPortNSblue)+SEMinPortNSblue, nanmean(inPortNSblue)+SEMinPortNSblue], 'k--');%overlay + sem of each subject
        plot([1-.2,1+.2] , [nanmean(inPortNSblue)-SEMinPortNSblue, nanmean(inPortNSblue)-SEMinPortNSblue], 'k--');%overlay - sem of each subject
        plot([1, 1], [nanmean(inPortNSblue),nanmean(inPortNSblue)-SEMinPortNSblue], 'k--'); %connect -SEM to mean
        plot([1, 1], [nanmean(inPortNSblue),nanmean(inPortNSblue)+SEMinPortNSblue], 'k--'); %connect -SEM to mean
        
        plot([2-.2, 2+.2], [nanmean(noPENSblue), nanmean(noPENSblue)], 'k');
        plot([2-.2,2+.2] , [nanmean(noPENSblue)+SEMnoPENSblue, nanmean(noPENSblue)+SEMnoPENSblue], 'k--');%overlay + sem of each subject
        plot([2-.2,2+.2] , [nanmean(noPENSblue)-SEMnoPENSblue, nanmean(noPENSblue)-SEMnoPENSblue], 'k--');%overlay - sem of each subject
        plot([2, 2], [nanmean(noPENSblue),nanmean(noPENSblue)-SEMnoPENSblue], 'k--'); %connect -SEM to mean
        plot([2, 2], [nanmean(noPENSblue),nanmean(noPENSblue)+SEMnoPENSblue], 'k--'); %connect -SEM to mean
        
        plot([3-.2, 3+.2], [nanmean(PENSblue), nanmean(PENSblue)], 'k');
        plot([3-.2,3+.2] , [nanmean(PENSblue)+SEMPENSblue, nanmean(PENSblue)+SEMPENSblue], 'k--');%overlay + sem of each subject
        plot([3-.2,3+.2] , [nanmean(PENSblue)-SEMPENSblue, nanmean(PENSblue)-SEMPENSblue], 'k--');%overlay - sem of each subject
        plot([3, 3], [nanmean(PENSblue),nanmean(PENSblue)-SEMPENSblue], 'k--'); %connect -SEM to mean
        plot([3, 3], [nanmean(PENSblue),nanmean(PENSblue)+SEMPENSblue], 'k--'); %connect -SEM to mean
        
        xlim([0,4]);
        
        xlabel('PE outcome');
        ylabel('mean 465nm z score response');
        if thisStage==allStages(1)
           legend('in port at cue onset', 'no port entry (unrewarded)', 'port entry during cue epoch (unrewarded)'); 
        end
        
    end %end Stage loop 
       set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
%        linkaxes();

      figureCount= figureCount+1;
end %end subj loop