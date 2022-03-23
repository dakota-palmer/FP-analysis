for subj= 1:numel(subjects)
    currentSubj= subjData.(subjects{subj});
    currentSubjAnalyzed= subjDataAnalyzed.(subjects{subj});
    for session = 1:numel(currentSubj)
        
    %for each event, get the nearest time bin in cutTime
     
%     %--example: raw all port entry times (pox)
%         eventTimeBinned=[]; eventInd= []; %clear between events
%         eventTime= currentSubj(session).pox;
%          % get nearest timestamp in cutTime (using interp())
%         eventTimeBinned= interp1(currentSubj(session).cutTime, currentSubj(session).cutTime, eventTime, 'nearest');
%         %  use find() to get matching index of this timeBin
%         
%         for event=1:numel(eventTimeBinned) %loop bc multiple events (tho could possibly use cellfun more efficiently?)
%             if ~isnan(eventTimeBinned) %exception in case event is outside of cutTime range (e.g. first and last part of recordings 'cut' out for artifacts)
%                 eventInd(event)= find(currentSubj(session).cutTime==eventTimeBinned(event));
%             else 
%                 eventInd(event)= nan;
%             end
%         end
%         
%         currentSubj(session).poxBinned= eventTimeBinned; %output to save
%         currentSubj(session).poxBinnedInd= eventInd; %output to save

        %-- example: Only first of each trial-based event poxDS
        eventTimeBinned=[]; eventInd= []; %clear between events
        eventTime= currentSubjAnalyzed(session).behavior.poxDS;
         % get nearest timestamp in cutTime (using interp())
        
        for trial= 1:numel(eventTime) %loop through trials and get first from cell array
            if ~isempty(eventTime{trial})
                eventTimeFirst= eventTime{trial}(1); %First Event within this trial only (could do all with looping or cellfun but for encoding we really only want the first)

                eventTimeBinned(trial)= interp1(currentSubj(session).cutTime, currentSubj(session).cutTime, eventTimeFirst, 'nearest');

               %  use find() to get matching index of this timeBin

                if ~isnan(eventTimeBinned(trial)) %exception in case event is outside of cutTime range (e.g. first and last part of recordings 'cut' out for artifacts)
                    eventInd(trial)= find(currentSubj(session).cutTime==eventTimeBinned(trial));
                else 
                    eventInd(trial)= nan;
                end
            else
                eventTimeBinned(trial)=nan;
                eventInd(trial)=nan;
            end
        end
                
        currentSubj(session).behavior.poxDSbinned= eventTimeBinned; %output to save
        currentSubj(session).behavior.poxDSbinnedInd= eventInd; %output to save

        
    end %session loop
end %end subj loop