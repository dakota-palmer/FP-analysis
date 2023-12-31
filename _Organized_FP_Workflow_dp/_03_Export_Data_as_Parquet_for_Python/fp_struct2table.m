%Previous nested organization of struct very difficult to work with,
%pulling out data and saving as table for easier analysis (and exporting to python, R)


%% load the subjDataAnalyzed struct
% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-23-Mar-2022subjDataAnalyzed.mat")

% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\vp_vta_fp-13-Apr-2022subjDataAnalyzed.mat");
% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-16-Jun-2022subjDataAnalyzed.mat")

% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-30-Aug-2022subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat");

% data= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-29-Jul-2022subjDataAnalyzed_dff.mat");

% %% Load struct containing data organized by subject
disp('***select a .mat file generated by fpAnalysis.m')

load(uigetfile('*.mat')); %choose the subjData file to open for your experiment %by default only show .mat files

data=data.subjDataAnalyzed;


%% initialize table

%this works well on single level, but the nested info is lost
T=struct2table(struct2array(data));


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
