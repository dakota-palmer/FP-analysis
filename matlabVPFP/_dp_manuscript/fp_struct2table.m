%Previous nested organization of struct very difficult to work with,
%pulling out data and saving as table for easier analysis (and exporting to python, R)


%should have one row per timestamp
fpTable= table;


%this works well on single level, but the nested info is lost
T=struct2table(struct2array(subjDataAnalyzed));


%% manually retrieve data and organize into table 

%a bit slow
%may be able to loop through and count total # of ts to preallocate and
%save some time? 

%should have one row per timestamp per session
%poor form looping through files like this but should work
fpTable= table;


fileID= 1; %unique file ID per session (good for grouping stuff later)
for session= 1:size(T,1)
    if session==1
        %keep table index corresponding to this session's data
        sesInd= 1:numel(T.raw(session).cutTime); %1 row per ts
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
    
    %now find timestamps corresponding to event times in this fileID and mark these
    %simple binary coding 1 at timestamp where event occurred
   
    %port entry (pox)
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).pox, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.pox(eventInd)= 1; 
    
    %lox
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).lox, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.lox(eventInd)= 1;     
    %port exit (out)
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.raw(session).out, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.out(eventInd)= 1; 
    
    %pump on (reward)
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.reward{session}.pumpOnTime, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.pumpTime(eventInd)= 1; 
    
    %DS cue
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.periDS{session}.DS, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.DS(eventInd)= 1; 
    
    %NS cue
    eventTime=[]; eventInd= [];
    eventTime= interp1(T.raw(session).cutTime, T.raw(session).cutTime, T.periNS{session}.NS, 'nearest');   
    eventInd= find(ismember(fpTable.cutTime,eventTime)&(fpTable.fileID==fileID)==1);
    fpTable.NS(eventInd)= 1; 
    
    %TODO ideally will combine into 2 variables: eventTime and eventType
    %should be able to do this post hoc in python or r though
    
    %TODO: also will need to save pumpID for variable reward sessions

    fileID=fileID+1; %iterate fileID
end

%% save table
test= fpTable(1:5,:)
% writetable(test, strcat('vp-vta-fp','-', date, 'test.csv', 'Delimeter', ',')); 

% writetable(fpTable, strcat('vp-vta-fp','-', date, 'fpTable.xlsx')); 

%% save table as Parquet file?
% https://www.quora.com/When-should-I-use-parquet-file-to-store-data-instead-of-csv

%changing dtype of date, parquet doesn't like cells
% test.date= [test.date{:}]'
fpTable.date= [fpTable.date{:}]';

% datetime(test.date, 'InputFormat', 'dd/MM/yyyy HH')

% parquetwrite('test.parquet', test);

parquetwrite(strcat('vp-vta-fp','-', date), fpTable);
