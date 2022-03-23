%Previous nested organization of struct very difficult to work with,
%pulling out data and saving as table for easier analysis (and exporting to python, R)


%should have one row per timestamp
fpTable= table;


% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\VP-VTA-FP-01-Mar-2022subjDataRaw.mat")

data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-noArtifact-21-Mar-2022subjDataAnalyzed.mat");

data=data.subjDataAnalyzed;

%this works well on single level, but the nested info is lost
T=struct2table(struct2array(data));


%% manually retrieve data and organize into table - binary coded events

% %binary coding relies on cutTime to line up with events, just save the
% %timestamps instead
% 
% %a bit slow
% %may be able to loop through and count total # of ts to preallocate and
% %save some time? 
% 
% %should have one row per timestamp per session
% %poor form looping through files like this but should work
% fpTable= table;
% 
% 
% fileID= 1; %unique file ID per session (good for grouping stuff later)
% for session= 1:size(T,1)
%     if session==1
%         %keep table index corresponding to this session's data
%         sesInd= 1:numel(T.raw(session).cutTime); %1 row per ts
%     else
%         sesInd= sesInd(end)+1:sesInd(end)+ numel(T.raw(session).cutTime);
%     end
%         
%     fpTable.fileID(sesInd)= fileID;
%     fpTable.subject(sesInd)= T.rat(session);
%     fpTable.stage(sesInd)= T.trainStage(session);
%     fpTable.trainDay(sesInd)= T.trainDay(session);
%     fpTable.date(sesInd)= {T.date(session)};
%     fpTable.cutTime(sesInd)= T.raw(session).cutTime;
%     fpTable.reblue(sesInd)= T.raw(session).reblue;
%     fpTable.repurple(sesInd)= T.raw(session).repurple;
%      
% %         %variable reward info
% %     fpTable.pumpID= T(session).reward.DSreward(cue) %get pumpID
% % 
% %     fpTable.rewardID(find(fpTable.pumpID==1))=  {currentSubj(includedSession).reward.pump1};
% %     fpTable.rewardID(find(fpTable.pumpID==2))=  {currentSubj(includedSession).reward.pump2};
% %     fpTable.rewardID(find(fpTable.pumpID==3))=  {currentSubj(includedSession).reward.pump3};
% 
%     
%     %now find timestamps corresponding to event times in this fileID and mark these
%     %simple binary coding 1 at timestamp where event occurred
%    
%     %~~FLAG: interp() here to cutTime, ideally shouldnt do this...
%     
%     %port entry (pox)
%     eventTime=[]; eventInd= [];
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).pox, 'nearest');    
%     eventTime= T.raw(session).pox;
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.pox(eventInd)= 1; 
%     
%     %lox
%     eventTime=[]; eventInd= [];
%     eventTime= T.raw(session).lox;
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).lox, 'nearest');   
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.lox(eventInd)= 1;     
%     %port exit (out)
%     eventTime=[]; eventInd= [];
%     eventTime= T.raw(session).out;
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).out, 'nearest');   
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.out(eventInd)= 1; 
%     
%     %pump on (reward)
%     eventTime=[]; eventInd= [];
%     eventTime= T.reward{session}.pumpOnTime;
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.reward{session}.pumpOnTime, 'nearest');   
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.pumpTime(eventInd)= 1; 
%     
%     %DS cue
%     eventTime=[]; eventInd= [];
%     eventTime= T.periDS{session}.DS;
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.periDS{session}.DS, 'nearest');   
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.DS(eventInd)= 1; 
%     
%     %NS cue
%     eventTime=[]; eventInd= [];
%     eventTime= T.periNS{session}.NS;
% %     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.periNS{session}.NS, 'nearest');   
%     eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
%     fpTable.NS(eventInd)= 1; 
%     
%     %TODO ideally will combine into 2 variables: eventTime and eventType
%     %should be able to do this post hoc in python or r though
%     
%     %TODO: also will need to save pumpID for variable reward sessions
% 
%     fileID=fileID+1; %iterate fileID
% end


%% manually retrieve data and organize into table - timestamps 
fpTable= table;


fileID= 1; %unique file ID per session (good for grouping stuff later)
for session= 1:size(T,1)
    if session==1
        %keep table index corresponding to this session's data
        sesInd= 1:numel(T.raw(session).cutTime); %1 row per fp timestamp, arbitrary # of timestamps in each event column
    else
        sesInd= sesInd(end)+1:sesInd(end)+ numel(T.raw(session).cutTime);
    end
        
    fpTable.fileID(sesInd)= fileID;
    fpTable.subject(sesInd)= T.rat(session);
    fpTable.stage(sesInd)= T.trainStage(session);
    fpTable.trainDay(sesInd)= T.trainDay(session);
    fpTable.date(sesInd)= {T.date(session)};
    fpTable.cutTime(sesInd)= T.raw(session).cutTime;
    fpTable.reblue(sesInd)= T.raw(session).reblue;
    fpTable.repurple(sesInd)= T.raw(session).repurple;
    
    %preallocate events with nan
    fpTable.pox(sesInd)= nan;
    fpTable.lox(sesInd)= nan;
    fpTable.out(sesInd)= nan;
    fpTable.pumpTime(sesInd)= nan;
    fpTable.DS(sesInd)= nan;
    fpTable.NS(sesInd)= nan;


       
    %now find timestamps corresponding to event times in this fileID 
    %just save the raw timestamps

    
    %~~FLAG: interp() here to cutTime, ideally shouldnt do this...
    
    %-port entry (pox)
    eventTime=[]; eventInd= [];
    eventTime= T.raw(session).pox;
    
        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    
%     %TODO: place in nearest time bin in cutTime (but keep raw timestamp)?
%     eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.reward{session}.pumpOnTime, 'nearest');   
    
    fpTable.pox(eventInd)= eventTime; 
    
    %-licks (lox)
    eventTime=[]; eventInd= [];
    eventTime= T.raw(session).lox;
    
        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    fpTable.lox(eventInd)= eventTime; 
    
    %-port exit (out)
    eventTime=[]; eventInd= [];
    eventTime= T.raw(session).out;
    
        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    fpTable.out(eventInd)= eventTime; 
    
    %-pump on (reward)
    eventTime=[]; eventInd= [];
    eventTime= T.reward{session}.pumpOnTime;
        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    fpTable.pumpTime(eventInd)= eventTime; 
    
    %DS cue
    eventTime=[]; eventInd= [];
    eventTime= T.periDS{session}.DS;
        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    fpTable.DS(eventInd)= eventTime; 
    
    %NS cue
    eventTime=[]; eventInd= [];
%     eventTime= T.periNS{session}.NS;
    eventTime= T.periNS(session).NS;


        %assign timestamps
    eventInd= sesInd(1:numel(eventTime));
    fpTable.NS(eventInd)= eventTime; 
    
    
    %TODO ideally will combine into 2 variables: eventTime and eventType
    %should be able to do this post hoc in python or r though
    
    %TODO: also will need to save pumpID for variable reward sessions

         
%         %variable reward info
%     fpTable.pumpID= T(session).reward.DSreward(cue) %get pumpID
% 
%     fpTable.rewardID(find(fpTable.pumpID==1))=  {currentSubj(includedSession).reward.pump1};
%     fpTable.rewardID(find(fpTable.pumpID==2))=  {currentSubj(includedSession).reward.pump2};
%     fpTable.rewardID(find(fpTable.pumpID==3))=  {currentSubj(includedSession).reward.pump3};

    
    fileID=fileID+1; %iterate fileID
end

%% save table
% % test= fpTable(1:5,:)
% % writetable(test, strcat('vp-vta-fp','-', date, 'test.csv', 'Delimeter', ',')); 
% 
% % writetable(fpTable, strcat('vp-vta-fp','-', date, 'fpTable.xlsx')); 

%% save table as Parquet file
% % https://www.quora.com/When-should-I-use-parquet-file-to-store-data-instead-of-csv
% 
% % test.date= [test.date{:}]'
% 
% % datetime(test.date, 'InputFormat', 'dd/MM/yyyy HH')
% 
% % parquetwrite('test.parquet', test);

% %changing dtype of date, parquet doesn't like cells
fpTable.date= [fpTable.date{:}]';
parquetwrite(strcat('vp-vta-fp','-', date), fpTable);
