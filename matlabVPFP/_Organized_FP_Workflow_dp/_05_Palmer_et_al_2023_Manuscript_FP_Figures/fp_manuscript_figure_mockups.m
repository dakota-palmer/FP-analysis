% og script became cumbserome, so load completely analyzed dataset and
% streamline more final figures below:


%% Set gramm plot defaults
set_gramm_plot_defaults();


%% Plot Settings
figPath= strcat(pwd,'\_figures\_mockups\');

%SVG good for exporting for final edits
% figFormats= {'.svg'} %list of formats to save figures as (for saveFig.m)

%PNG good for quickly viewing many
% figFormats= {'.png'} %list of formats to save figures as (for saveFig.m)
% figFormats= {'.svg','.fig'} %list of formats to save figures as (for saveFig.m)
%pdf for final drafts
figFormats= {'.pdf','.svg','.fig'} %list of formats to save figures as (for saveFig.m)


%-- Master plot linestyles and colors

%thin, light lines for individual subj
linewidthSubj= 0.5;

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;

%thicker lines for reference lines
linewidthReference= 2;

%-- Master plot axes settings
%- set default axes limits between plots for consistency
%default lims for traces 
ylimTraces= [-2,5];
xlimTraces= [-2,10];

%default lims for AUC plots
%note xlims best to calculate dynamically for bar plots based on num x categories
% ylimAUC= [-1,16];
ylimAUC= [-6,16.5];


%% Load periEventTable from fp_manuscript_figs.m --

% for now assume preprocessing experimental all sessions

% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-19-Oct-2022periEventTable.mat";

% %loxDSpoxRel present
% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-08-Nov-2022periEventTable.mat";


% % 2023-03-18 criteriaSes change
% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-18-Mar-2023periEventTable.mat";


% %revised licks- OG MANUSCRIPT DATA
% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-09-Nov-2022periEventTable.mat";

% % added lick count
pathData= ("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-29-Aug-2023periEventTable.mat");




% for now loads as 'data' struct
load(pathData);

% get contents and clear
% periEventTable= data;
% clear data


%% -- 2023-03-19 REDO sesSpecialLabel 
% 
% for subj= 1:numel(subjects);
% %--Save string labels to mark specific days for plotting
% if currentSubj(includedSession).behavior.criteriaSes==1
%    criteriaDayThisStage= criteriaDayThisStage+1; 
% end
% 
% if thisStage==5 && trainDayThisStage==1 
%     sesSpecialLabel(:)= {'stage-5-day-1'};
% elseif thisStage==5 && criteriaDayThisStage==1
%     sesSpecialLabel(:)= {'stage-5-day-1-criteria'};
% elseif thisStage==7 && criteriaDayThisStage==1
%     sesSpecialLabel(:)= {'stage-7-day-1-criteria'};
% 
% %easy mark of final day of stage 5
% elseif thisStage==5 && includedSession == max(includedSessions)
%     sesSpecialLabel(:)= {'stage-5-final-day'};
% 
% 
% %easy mark of final day of stage 7
% elseif thisStage==7 && includedSession == max(includedSessions)
%     sesSpecialLabel(:)= {'stage-7-final-day'};
% end

data= periEventTable;

% reverse cumcount of sessions within stage, mark for exclusion
groupIDs= [];

% data.StartDate= cell2mat(data.StartDate);
groupIDs= findgroups(data.subject, data.stage);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

data(:, 'sesSpecialLabel2')= {''};% table(nan);


for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
        
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data(ind,:);
    
    thisGroupAll= [];
    thisGroupAll= thisGroup; %save prior to subsetting
    thisGroupAll(:, 'sesSpecialLabel2')= {''};% table(nan);

    
% % %     % subset to 1 observation per file (for calculations)
    thisGroup= thisGroup(((thisGroup.DStrialID==1) & (thisGroup.timeLock==1)),:);
    thisGroup(:, 'sesSpecialLabel2')= {''};% table(nan);

    
    % get max trainDayThisStage for this Subject
    maxTrainDayThisStage= [];
    thisGroup(:,'maxTrainDayThisStage')= table(max(thisGroup.trainDayThisStage));
    
    % Check if meeting criteria- cumcount of criteria sessions
%     thisGroup(:,'cumcount')= table(1);
    
%     thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
%     thisGroup(:,'cumcountMax')= table(max(thisGroup.cumcount));

%     %starting with 0, making 1 where criteriaSes to cumulatively count only
% %     %those criteriaSes- nah won't really work as cumsum.
    thisGroup(:,'cumcountCriteriaSes')= table(nan);      

    thisGroup(thisGroup.criteriaSes>0,'cumcountCriteriaSes')= table(1);
    
    % cumsum skipping nan values 
    %- generally works BUT ASSUMES progression
    % if there are gaps where criteriaSes not met, they'll still keep the prior sum so
    % need to backfill
    thisGroup(:,'cumcountCriteriaSes')= table(cumsum(thisGroup.cumcountCriteriaSes, 'omitnan'));
    
%     % replace invalid criteriaSes with nan after cumsum so can just use min()
    thisGroup(thisGroup.cumcountCriteriaSes==0,'cumcountCriteriaSes')= table(nan);
    thisGroup(thisGroup.criteriaSes==0,'cumcountCriteriaSes')= table(nan);

       
    % min() of trainDayThisStage where criteriaSes==1?
    thisGroup(:,'minCriteriaSes')= table(nan);
%     thisGroup(:,'minCriteriaSes')= min(thisGroup((thisGroup.criteriaSes>0), 'trainDayThisStage')); 
        if ~isempty(thisGroup.trainDayThisStage((thisGroup.criteriaSes>0)))
            thisGroup(:,'minCriteriaSes')= table(min(thisGroup.trainDayThisStage((thisGroup.criteriaSes>0)))); 

        end

    
    %assign back into table
%     data(ind, 'testCount')= table(thisGroup.cumcount);
  
    %subtract trainDayThisStage - cumcount max and if 
    
%     % Check if >1 observation here in group
%     % if so, flag for review
%     if height(thisGroup)>1
%        disp('duplicate ses found!')
%         dupes(ind, :)= thisGroup;
% 
%     end

% Add labels for specific sessions, based on stage and criteria

%- Ordered here such that labels overwrite each other

thisStage=[];
thisStage= thisGroup.stage(1);
% 
% %-- Stage 1, first session.. done below %note rat13 missing recording
% from first day
% ind1=[];
% ind1= thisGroup.stage== 1;
% 
% ind2=[];
% ind2= thisGroup.trainDayThisStage==1;
% 
% ind3=[];
% ind3= ind1 & ind2;
% 
% thisGroup(ind3, 'sesSpecialLabel2')= {'stage-1-day-1'};



%-- Stage 5 labels
ind1=[];
ind1= thisGroup.stage== 5;


% - Stage 5, Session 1
ind2=[];
ind2= thisGroup.trainDayThisStage==1;

ind3=[];
ind3= ind1 & ind2;

thisGroup(ind3, 'sesSpecialLabel2')= {'stage-5-day-1'};

% - Stage 5, Final day
ind2=[];
ind2= thisGroup.trainDayThisStage==thisGroup.maxTrainDayThisStage(1);

ind3=[];
ind3= ind1 & ind2;

thisGroup(ind3, 'sesSpecialLabel2')= {'stage-5-final-day'};


% - Stage 5, First criteria session
ind2=[];
ind2= thisGroup.trainDayThisStage==thisGroup.minCriteriaSes(1);

% First criteria session *beyond first session* using min() of cumcountCriteriaSes beyond first day?
if thisGroup.minCriteriaSes(1)==1
    
    %exclude that first session to force beyond first day
    
    %get min and index
    m= [];, i=[];

    [m,i]= min(thisGroup.cumcountCriteriaSes(2:end));

  
%     ind2= thisGroup.trainDayThisStage == min(thisGroup.cumcountCriteriaSes)
end

ind3=[];
ind3= ind1 & ind2;

thisGroup(ind3, 'sesSpecialLabel2')= {'stage-5-day-1-criteria'};

% -- Stage 7 labels
ind1= [];
ind1= thisGroup.stage==7;

% %- Stage 7, session 1
% ind2=[];
% ind2= thisGroup.trainDayThisStage==1;
% 
% ind3=[];
% ind3= ind1 & ind2;
% thisGroup(ind3, 'sesSpecialLabel2')= {'stage-7-day-1'};

% - Stage 7, Final day
ind2=[];
ind2= thisGroup.trainDayThisStage==thisGroup.maxTrainDayThisStage(1);

ind3=[];
ind3= ind1 & ind2;

thisGroup(ind3, 'sesSpecialLabel2')= {'stage-7-final-day'};


%- Stage 7, first criteria session
ind2=[];
ind2= thisGroup.trainDayThisStage==thisGroup.minCriteriaSes(1);

ind3=[];
ind3= ind1 & ind2;

thisGroup(ind3, 'sesSpecialLabel2')= {'stage-7-day-1-criteria'};


% %----assign back to data table

%assumes equal indexing, but calculations were made on subset table
% data(ind,'sesSpecialLabel2')= thisGroup(:,'sesSpecialLabel2');


%- ideally would use another findgroups() but for now slow lazy manual
%assignment per session
    for thisSes= 1:size(thisGroup,1)
        ind1=[];
        ind1= thisGroupAll.fileID== thisGroup.fileID(thisSes);

%         thisGroupAll(ind1,"sesSpecialLabel2") = thisGroup(thisSes,"sesSpecialLabel2");
        thisGroupAll(ind1,"sesSpecialLabel2") = thisGroup{thisSes,"sesSpecialLabel2"};


    end 

% data(ind,'sesSpecialLabel2')= thisGroupAll(:,'sesSpecialLabel2');
data(ind,'sesSpecialLabel2')= thisGroupAll{:,'sesSpecialLabel2'};


end

%- debugging
test= data;

    
% subset to 1 observation per file (good for viz)
test= test(((test.DStrialID==1) & (test.timeLock==1)),:);
    
%first need to be all same type ('' not empty)
%mixture of doubles/ char [] and '' is really causing issues
% notChar_rowIndex = find(~cellfun(@ischar,test.sesSpecialLabel));

% test2= test(notChar_rowIndex,:);

% test(notChar_rowIndex,'sesSpecialLabel')= {'_None'};

test2= groupcounts(test, ["sesSpecialLabel2", "subject"], "IncludeEmptyGroups",true);
test3= test2(ismember(test2.GroupCount,0),:); % should contain empty groups if they exist

   % compare to OG labels
% subset to 1 observation per file (good for viz)
testB=test;    

%first need to be all same type ('' not empty)
%mixture of doubles/ char [] and '' is really causing issues
notChar_rowIndex = find(~cellfun(@ischar,testB.sesSpecialLabel));

test2B= testB(notChar_rowIndex,:);

testB(notChar_rowIndex,'sesSpecialLabel')= {'_None'};

test2B= groupcounts(testB, ["sesSpecialLabel", "subject"], "IncludeEmptyGroups",true);
test3B= test2B(ismember(test2B.GroupCount,0),:); % should contain empty groups if they exist


%% --- OVERWRITE THE ORIGINAL LABELS 

data.sesSpecialLabel= data.sesSpecialLabel2;

periEventTable=data;

% TODO: address combo labels (e.g. first day of stage 5 and also criteria)


% IF subject is missing Criteria session, for plots just make the final
% stage 5 sesssion ?

%% ---MANUAL LABELING OF SPECIAL SESSIONS

data=periEventTable;

%-- Rat13 is missing first stage 1 session recording
%- just exclude that session

%-- Rat14- met stage 5 criteria on day 1, manually label both to prevent
% overwriting. 
%- stage 5 day 1 is 20200903
ind1=[];
ind1= strcmp(data.date, '20200903');

ind2=[];
ind2= strcmp(data.subject, 'rat14');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1'};

%- stage 5 criteria day is 20200905

ind1=[];
ind1= strcmp(data.date, '20200905');

ind2=[];
ind2= strcmp(data.subject, 'rat14');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1-criteria'};



%-- Rat19- ""
%- stage 5 day 1 is 20200824
ind1=[];
ind1= strcmp(data.date, '20200824');

ind2=[];
ind2= strcmp(data.subject, 'rat19');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1'};


%- stage 5 criteria day is 20200826
ind1=[];
ind1= strcmp(data.date, '20200826');

ind2=[];
ind2= strcmp(data.subject, 'rat19');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1-criteria'};


%-- Rat12- missing stage 5 criteria day label
%- stage 5 criteria day approximately 20191220 
ind1=[];
ind1= strcmp(data.date, '20191220');

ind2=[];
ind2= strcmp(data.subject, 'rat12');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1-criteria'};


%-- Rat8- missing stage 5 criteria day label. 
%stage 5 criteria met on day 1 but criteria again approximately 20191223
ind1=[];
ind1= strcmp(data.date, '20191223');

ind2=[];
ind2= strcmp(data.subject, 'rat8');

ind3= [];
ind3= ind1 & ind2;

data(ind3, 'sesSpecialLabel')= {'stage-5-day-1-criteria'};



% reassign / overwrite original table
periEventTable= data;

%% ----------------- LABEL SPECIAL SESSIONS -----------------------------
%label specific sessions for plotting

%- Double checking that every subject has sessions labeled
% test= groupsummary(periEventTable, [periEventTable.sesSpecialLabel, periEventTable.subject]);
% test= groupcounts(periEventTable, [periEventTable.sesSpecialLabel{:},"subject"]);

% group fxns wont take cell as input so converting prior to grouping
test= periEventTable;

    
% subset to 1 observation per file (good for viz)
test= test(((test.DStrialID==1) & (test.timeLock==1)),:);

%first need to be all same type ('' not empty)
%mixture of doubles/ char [] and '' is really causing issues
notChar_rowIndex = find(~cellfun(@ischar,test.sesSpecialLabel));

test2= test(notChar_rowIndex,:);

test(notChar_rowIndex,'sesSpecialLabel')= {'_None'};

test2= groupcounts(test, ["sesSpecialLabel", "subject"], "IncludeEmptyGroups",true);
test3= test2(ismember(test2.GroupCount,0),:); % should contain empty groups if they exist

%overwrite old labels
% periEventTable(:,'sesSpecialLabel')= {''};

%manually find and assign specialSesLabels based on criteria

%--first day of stage 1 - is there an innate cue response?
ind= [];
ind= periEventTable.stage==1;


ind2= [];
ind2= periEventTable.trainDayThisStage==1;

ind3=[];
ind3= ind & ind2;

periEventTable(ind3, 'sesSpecialLabel')= {'First Session-Stage1'};


% %--first day of stage 5 - NS introduced %overwrites criteriaSes if 1
% ind= [];
% ind= periEventTable.stage==5;
% 
% 
% ind2= [];
% ind2= periEventTable.trainDayThisStage==1;
% 
% ind3=[];
% ind3= ind & ind2;
% 
% periEventTable(ind3, 'sesSpecialLabel')= {'NS Introduced-Stage5'};

% i think rat8, rat12 are missing final stage 5 criteria sesSpecialLabel
% subset table to check briefly
test= periEventTable(((periEventTable.DStrialID==1) & (periEventTable.timeLock==1)),:);


%first need to be all same type ('' not empty)
%mixture of doubles/ char [] and '' is really causing issues
notChar_rowIndex = find(~cellfun(@ischar,test.sesSpecialLabel));

test2= test(notChar_rowIndex,:);

test(notChar_rowIndex,'sesSpecialLabel')= {'_None'};


test2= groupcounts(test, ["sesSpecialLabel", "subject"], "IncludeEmptyGroups",true);
test3= test2(ismember(test2.GroupCount,0),:); % should contain empty groups if they exist


test4= test(~cellfun(@isempty,test.sesSpecialLabel),:);

% Redefine criteriaSes to be responding to NS  <50% of DS?

% %-- For Rat8, manually select day for "Stage 5 criteria session" ----
% % 20191223 -- MPC DS Ratio= 0.9, MPC NS Ratio= 0.57, 
%     %10s DS Ratio= 0.87, 10s NS Ratio= 0.55
% % clearly disconnect because of MPC PE contingency and how we dealt with
% % it. ultimately this session has 2/30 unrewarded trials so 93.33%
% % reinforced trials. yet the MPC calculated ratio doesn't match this and
% % neither does our 10s.
% ind=[];
% ind= strcmp(periEventTable.subject,'rat8');
% 
% ind2=[];
% ind2= strcmp(periEventTable.date, '20191223');
% 
% periEventTable((ind & ind2),'criteriaSes')=table(1);
% periEventTable((ind & ind2),'sesSpecialLabel')={'stage-5-day-1-criteria'};
% 



%actually seems the peratio criteria never met (by rat8 at least, rat12 also if not using 10s ratio) so
%criteriaSes =0

%TODO: this complicates bc day differs between animals
%--first day of criteria stage 5- discriminating
% % %for now just keep old labels
% % 
% % ind= [];
% % ind= periEventTable.stage==5;
% % 
% % 
% % ind2= [];
% % ind2= periEventTable.criteriaSes==1;
% % 
% % ind3=[];
% % ind3= ind && ind2;
% % 
% % ind= [];
% % ind= periEventTable.trainDayThisStage
% 
% periEventTable(ind3, 'specialSesLabel')= {'NS Introduced-Stage5'};

% % test2= groupcounts(periEventTable, ["sesSpecialLabel", "subject"], "IncludeEmptyGroups",true);
% % test2= groupsummary(periEventTable, ["sesSpecialLabel", "subject"]);
% % test2= findgroups(periEventTable, ["sesSpecialLabel", "subject"]);


% group fxns wont take cell as input so converting prior to grouping
test= periEventTable;

% subset table to check briefly
test= periEventTable(((periEventTable.DStrialID==1) & (periEventTable.timeLock==1)),:);


%first need to be all same type ('' not empty)
%mixture of doubles/ char [] and '' is really causing issues
notChar_rowIndex = find(~cellfun(@ischar,test.sesSpecialLabel));

test2= test(notChar_rowIndex,:);

test(notChar_rowIndex,'sesSpecialLabel')= {'_None'};

test2= groupcounts(test, ["sesSpecialLabel", "subject"], "IncludeEmptyGroups",true);
test3= test2(ismember(test2.GroupCount,0),:); % should contain empty groups if they exist


%% Remove last day of Stage 5 specialSes?

data= periEventTable;

%search for this label and remove it
labelsToClear= {'stage-5-final-day'};

ind = strcmp(data.sesSpecialLabel,labelsToClear);

%remove label with empty
data(ind,'sesSpecialLabel')= {''};

periEventTable= data;



%% --Report # days to reach criteria
% (based on sessions for special criteria sessions in Figure 2)


% test= periEventTable;
% % subset to 1 observation per file (good for viz)
% test= test(((test.DStrialID==1) & (test.timeLock==1)),:);
% 
% % subset to specific special criteria session
% test2= test(strcmp(test.sesSpecialLabel,'stage-5-day-1-criteria'),:);
% 
% test3= mean(test2.trainDay);
% 
% histogram(test2.trainDay);
% 
% test2= test(strcmp(test.sesSpecialLabel,'stage-5-day-1-criteria'),:);
% 
% test3= mean(test2.trainDay);
% 
% histogram(test2.trainDay);

% --groupsummary for stats of # days to criteria
test= periEventTable;
    
% subset to 1 observation per file 
test= test(((test.DStrialID==1) & (test.timeLock==1)),:);

% subset sessions with valid labels (non '')
test= test(~strcmp(test.sesSpecialLabel, ''),:);

%groupsummary descriptive stats
% testGroup= groupsummary(test, ["sesSpecialLabel"], 'all', vartype('numeric'));

daysToCriteriaTable= groupsummary(test, ["sesSpecialLabel"], 'all', "trainDay");

% add an SEM column
daysToCriteriaTable(:,'sem_trainDay')= table(nan);

daysToCriteriaTable(:,'sem_trainDay')= table(daysToCriteriaTable.std_trainDay ./ (sqrt(daysToCriteriaTable.GroupCount)));

% % ggplot histogram of days to criteria
figure;
g=[];
group=[];
g= gramm('x', test.trainDay, 'color', test.sesSpecialLabel, 'group', group);
g.facet_grid(test.sesSpecialLabel,[]);
g.stat_bin();
g.geom_point();
g.draw();


% - boxplot of days to criteria
dataCriteria= [];
dataCriteria= test;

% subset data- relabel 'criteria' for readability

 %make labels matching each 'sesSpecialLabel' and loop thru to search/match
criteriaTypes= {'First Session-Stage1', 'stage-5-day-1', 'stage-5-day-1-criteria', 'stage-7-day-1-criteria', 'stage-7-final-day'};
criteriaLabels= {'0_60s_DS','1_NS Intoduced', '2_DS versus NS Discrimination', '3_Reward Delivery Delay Introduced', '4_Final Session'};


for thisTrialType= 1:numel(criteriaTypes)
    ind= [];
    
    ind= strcmp(string(dataCriteria.sesSpecialLabel), criteriaTypes(thisTrialType));

    dataCriteria(ind, 'sesSpecialLabel')= {criteriaLabels(thisTrialType)};
    
end

% now, subset data- remove first criteria type
ind=[];
ind= strcmp(dataCriteria.sesSpecialLabel, '0_60s_DS');

dataCriteria= dataCriteria(~ind, :);


clear gDaysToCriteria; 
figure;

%- 
group= [];

gDaysToCriteria= gramm('x', dataCriteria.sesSpecialLabel, 'y', dataCriteria.trainDay, 'group', group);

gDaysToCriteria.set_title('Days to Criteria');
gDaysToCriteria.set_names('y','Number of Training Sessions','x','Criteria','color','', 'column', '');



gDaysToCriteria.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

gDaysToCriteria.stat_boxplot;%('dodge', dodge, 'width', 5);
gDaysToCriteria.set_color_options('map',cmapGrand);
gDaysToCriteria.no_legend();

gDaysToCriteria.coord_flip();

% gDaysToCriteria(1,1).set_parent(p2);
% gDaysToCriteria.set_parent(p2);


gDaysToCriteria.draw();
% 
% %- overlay individual subj points
group= dataCriteria.subject;
% gDaysToCriteria.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
gDaysToCriteria.update('y', dataCriteria.trainDay, 'x', dataCriteria.sesSpecialLabel, 'color', dataCriteria.subject, 'group', group);

gDaysToCriteria.geom_point();

% % gDaysToCriteria.update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % gDaysToCriteria.update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % gDaysToCriteria.update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% gDaysToCriteria.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% gDaysToCriteria.geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

% gDaysToCriteria.geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


gDaysToCriteria.set_title('Individual Subjects');


% gDaysToCriteria.axe_property('XLim',[0,10], 'YLim', [0, 10]);

% gDaysToCriteria.axe_property('YLim',[0,70], 'XLim', [0,10]);


gDaysToCriteria.set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
gDaysToCriteria.no_legend();

% gDaysToCriteria.draw();


%-make horizontal
% gDaysToCriteria.coord_flip();

g.set_title('Figure 1 Supplement: Training Criteria');

%- final draw call
gDaysToCriteria.draw();

titleFig='Figure 1 Supplement- Training Criteria';
saveFig(gcf, figPath, titleFig, figFormats, figSize);

% Save the days to criteria table to file
experimentName= 'vp-vta-fp';

%- save this along with figures
titleFile= [];
titleFile= strcat(experimentName,'-days-to-criteria-summary');

%save as .csv
titleFile= strcat(figPath,titleFile,'.csv');

writetable(daysToCriteriaTable,titleFile)

%% --SAVE DATA TABLE FOR MANUSCRIPT DATA REPO

save(fullfile(figPath,strcat(experimentName,'-',date, '-periEventTableManuscript')), 'periEventTable', '-v7.3');


%% load data from manuscript repo
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_mockups\vp-vta-fp-14-Jun-2023-periEventTableManuscript.mat");


%% ----------------- Figure 2---------------------------------------------------
fp_manuscript_fig2_uiPanels();

% %% Figure 2a -- FP Learning on special sessions
% % DS vs NS learning on special days: 2d 
% 
% %- Stage 5 Day 1, Stage 5 Criteria, Stage 7 Criteria
% % --marked as sesSpecialLabel in fpTidyTable.m
% 
% %subset data- only sesSpecial
% data= periEventTable;
% 
% ind=[];
% ind= ~cellfun(@isempty, data.sesSpecialLabel);
% 
% data= data(ind,:);
% 
% %subset data- remove specific sesSpecialLabel
% ind= [];
% ind= ~strcmp('stage-7-day-1-criteria',data.sesSpecialLabel);
% 
% data= data(ind,:);
% 
% %stack() to make trialType variable for faceting
% data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');
% 
% 
% %manually relabel trialType for clarity
% %either simply "DS" or "NS"
% %convert categorical to string then search 
% data(:,"trialTypeLabel")= {''};
% 
%  %make labels matching each 'trialType' and loop thru to search/match
% trialTypes= {'DSblue', 'NSblue'};
% trialTypeLabels= {'DS','NS'};
% 
% for thisTrialType= 1:numel(trialTypes)
%     ind= [];
%     
%     ind= strcmp(string(data.trialType), trialTypes(thisTrialType));
% 
%     data(ind, 'trialTypeLabel')= {trialTypeLabels(thisTrialType)};
%     
% end
% 
% 
% % FacetGrid with sesSpecialLabel = Row
% %2022-12-22 instead of clearing gramm objects, want to copy() them as
% %subplots into single large Figure. To do so, want to save each object
% %instead of clearing between so that single draw call can be made (e.g.
% %instead of i, make i1, i2, i3... etc corresponding to single Fig)
% clear i;
% % h= figure();
% figure;
% 
% cmapGrand= cmapBlueGrayGrand;
% cmapSubj= cmapBlueGraySubj;
% 
% % cmapGrand= cmapCueGrand;
% % cmapSubj= cmapCueSubj;
% 
% 
% % individual subjects means
% i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group', data.subject);
% 
% i.facet_grid([],data.sesSpecialLabel);%, 'column_labels',false);
% 
% 
% i().stat_summary('type','sem','geom','line');
% 
% i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
% 
% i().set_line_options('base_size',linewidthSubj);
% % i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');
% 
% % i.set_names('column','test'); %seems column label needs to come before first draw call
% 
% %- Things to do before first draw call-
% i.set_names('column', '', 'x', 'Time from Cue (s)','y','GCaMP (Z-score)','color','Trial type'); %row/column labels must be set before first draw call
% 
% i.no_legend(); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% i.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles
% 
% titleFig= 'Fig 2a)';   
% i.set_title(titleFig); %overarching fig title must be set before first draw call
% 
% 
% %- first draw call-
% i().draw();
% 
% %mean between subj + sem
% i().update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group',[]);
% 
% i().stat_summary('type','sem','geom','area');
% 
% i().set_color_options('map',cmapGrand);
% 
% i().set_line_options('base_size',linewidthGrand)
% 
% %-set limits
% i().axe_property('YLim',[-1,5]);
% i().axe_property('XLim',[-2,10]);
% 
% i().geom_vline('xintercept',0, 'style', 'k--', 'linewidth', linewidthReference); %overlay t=0
% 
% %-initialize overall Figure for complex subplotting
% % fig2Handle= figure();
% 
% 
% %-copy to overall Figure as subplot
% %this is a soft copy so need to draw before i is cleared/changed... because i is handle type object..., like if i is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
% fig2(1,1)= copy(i);
% 
% figTest(1,:)= copy(i);
% 
% %save drawing til end
% % %copyobj doesn't seem usable for hard copy
% % fig2(1,1)= copyobj(i,fig2Handle);
% 
% % set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing
% % figure(fig2Handle);
% % title('test fig2');
% % fig2(1,1).draw();
% 
% %- final draw call
% % set(0,'CurrentFigure',h)%switch to this figure before drawing
% % figure(h);
% i.draw();
% 
% % titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   
% 
% titleFig= strcat('figure2a-learning-fp-periCue');   
% 
% % for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
% figSize1= [100, 100, 430, 600];
% 
% figSize2= [100, 100, 650, 600];
% 
% %2022-12-16 playing with figure size
% % set(gcf,'Position', figSize1);
% % i.redraw()
% 
% % i.set_layout_options('legend_position',0,0.5,0.5,0.5]);
% % i.draw()
% % 
% % i.set_layout_options('legend_width',0.10);
% % i.redraw()
% 
% %try gramm export 
% i.export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')
% 
% titleFig= strcat(titleFig,'matlab_Saved');
% 
% % saveFig(gcf, figPath, titleFig, figFormats, figSize2);
% 
% %-- TODO: maybe try https://stackoverflow.com/questions/24531402/matlab-scale-figures-for-publishing-exact-dimensions-and-font-sizes
% 
% % - also note white space min here https://interfacegroup.ch/preparing-matlab-figures-for-publication/
% 
% 
% %-- Try embedding in 1 big figure?
% %will need all subplots to fit within whole fig
% 
% % fig1(1,1)= i;
% 
% % .copy() should work, see here- https://github.com/piermorel/gramm/issues/23
% % i think .copy() needs to happen before draw() or update() calls... so
% % would need to copy to figure and update prior to each of those
% % 
% %seems to work if you put it before the final draw call!
% % but soft copy, see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
% 
% % fig1= copy(i);
% % figure;
% % 
% % fig1.draw();
% % 
% % fig1(1,1)= copy(i);
% % 
% % fig1(1,1).draw();
% 
% %% Fig 2a ----- Bar plots of AUC ------
% clear i1; 
% % h= figure;
% figure;
% 
% dodge= 	1; %if dodge constant between point and bar, will align correctly
% width= 1.8; %good for 2 bars w dodge >=1
% 
% 
% %subset data- only sesSpecial
% data2= periEventTable;
% 
% ind=[];
% ind= ~cellfun(@isempty, data2.sesSpecialLabel);
% 
% data2= data2(ind,:);
% 
% %subset data- remove specific sesSpecialLabel
% ind= [];
% ind= ~strcmp('stage-7-day-1-criteria',data2.sesSpecialLabel);
% 
% data2= data2(ind,:);
% 
% %stack() to make trialType variable for faceting
% data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');
% 
% %manually relabel trialType for clarity
% %either simply "DS" or "NS"
% %convert categorical to string then search 
% data2(:,"trialTypeLabel")= {''};
% 
%  %make labels matching each 'trialType' and loop thru to search/match
% trialTypes= {'aucDSblue', 'aucNSblue'};
% trialTypeLabels= {'DS','NS'};
% 
% for thisTrialType= 1:numel(trialTypes)
%     ind= [];
%     
%     ind= strcmp(string(data2.trialType), trialTypes(thisTrialType));
% 
%     data2(ind, 'trialTypeLabel')= {trialTypeLabels(thisTrialType)};
%     
% end
% 
% %mean between subj
% group=[];
% i1= gramm('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);
% 
% i1.facet_grid([],data.sesSpecialLabel);
% 
% i1.set_color_options('map',cmapGrand);
% 
% %mean bar for trialType
% i1.stat_summary('type','sem','geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);
% 
% i1.set_line_options('base_size',linewidthGrand)
% 
% 
% %- Things to do before first draw call-
% i1.set_names('column', '', 'x','Trial Type','y','GCaMP (Z-score)','color','Trial Type');
% 
% i1.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles
% 
% titleFig= 'Fig 2a) inlay';   
% i1.set_title(titleFig); %overarching fig title must be set before first draw call
% 
% %- first draw call-
% i1.draw()
% 
% %- Draw lines between individual subject points (group= subject, color=[]);
% group= data2.subject;
% i1.update('x', data2.trialTypeLabel,'y',data2.periCueBlueAuc,'color',[], 'group', group)
% 
% % i1.geom_line('alpha',0.3); %individual trials way too much
% i1.stat_summary('type','sem','geom','line');
% 
% i1.set_line_options('base_size',linewidthSubj);
% 
% i1.set_color_options('chroma', chromaLineSubj); %black lines connecting points
% 
% i1.draw();
% 
% %ind subj mean points
% i1.update('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);
% 
% i1.stat_summary('type','sem','geom','point', 'dodge', dodge);
% 
% i1.set_color_options('map',cmapSubj); 
% 
% i1.no_legend(); %avoid duplicate legend from other plots (e.g. subject  grand colors)
% 
% %-set plot limits-
% 
% %set x lims and ticks (a bit more manual good for bars)
% % lims= [0-.4,(numel(trialTypes)-1)+.4];
% 
% lims= [1-.6,(numel(trialTypes))+.6];
% 
% 
% i1.axe_property('XLim',lims);
% 
% i1.axe_property('YLim',[-1,16]);
% 
% %horz line @ zero
% i1.geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 
% 
% %-copy to overall Figure as subplot
% %this is a soft copy so need to draw before i1 is cleared/changed... because i1 is handle type object..., like if i1 is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
% fig2(2,1)= copy(i1);
% 
% figTest(2,:)= copy(i1);
% %save drawing until end
% 
% % set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing
% 
% % fig2(2,1).draw();
% 
% %- final draw call-
% % set(0,'CurrentFigure',h);%switch to this figure before drawing
% 
% i1().draw();
% 
% 
% % titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
% titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   
% 
% % saveFig(gcf, figPath, titleFig, figFormats);
% 
% %% Draw the Figure2
% 
% %for some reason drawing on separate figures (overwriting i fig and i1 fig
% %respectively) instead of drawing both on new figure...
% 
% %seems to work fine if you don't make new figure() between gramm objects
% %declaring a new figure doens't matter, it will always draw on the first
% %fig.
% % figure();
% fig2.draw();
% 
% %maybe because should be single gramm object instead of 2 nested in fig2
% % 
% % figTest= copy(i);
% % figTest(1,1)= copy(i);
% % 
% % figTest.draw();
% %% Try  copying into single fig and drawing at end (post final draw call)
% 
% % %doesn't work, i think needs to be copied before each gramm object is
% % %finally drawn...
% % figure();
% % 
% % fig22(1,1)= copy(i);
% % fig22(2,1)= copy(i1);
% % 
% % fig22.draw();

%% ----- FIGURE 3--- 

% fp_manuscript_fig3_uiPanels();

fp_manuscript_fig3_uiPanels_2events();



%% FIG3 HEATPLOTS ---

% tried in gramm, not really supported or at least not intuitive and not worth effort
%going with  matlab imagesc heatplots

% clear i; figure;

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1

% subset data
data= periEventTable;

% subset data- by stage
stagesToPlot= [1:11];

ind=[];
ind= ismember(data.stage, stagesToPlot);

data= data(ind,:);

%subset data- simply require DS trial
ind=[];
ind= ~isnan(data.DStrialID);

data= data(ind,:);

% subset data- by PE outcome; only include trials with PE or inPort
% ind=[];
% % ind= data.DStrialOutcome==1 | data.DStrialOutcome==3;
% ind= (data.DStrialOutcome==1) | (data.DStrialOutcome==3);
% 
% data= data(ind,:);


% subset data- by PE outcome; only include trials with valid PE post-cue
% ind=[];
% ind= data.DStrialOutcome==1;
% 
% data= data(ind,:);

% % subset data- only include trials with licks (valid, non-nan lick peri
% % signal)
% ind=[];
% ind= ~isnan(data.DSblueLox);
% 
% data= data(ind,:);

% %subset data- only include trials where lick happens after PE 
% %TODO: CORRECT THE LICK TIMESTAMPS !!!!
% %2022-11-03
% ind=[];
% ind= data.poxDSrel>=data.loxDSrel;
% 
% data= data(ind,:);


% TODO: subset only specific encoding model input?

%subset data- only sesSpecial
% 
% ind=[];
% ind= ~cellfun(@isempty, data.sesSpecialLabel);
% 
% data= data(ind,:);

%subset data- remove specific sesSpecialLabel
% ind= [];
% ind= ~strcmp('stage-7-day-1-criteria',data.sesSpecialLabel);
% 
% data= data(ind,:);

% % subset data- retain only periDS
% ind= [];
% ind= ~isnan(data2.DSblue);
% 
% data2= data2(ind,:);

% --Sort Trials by PE Latency

% maybe can use sortrows to do this very easily?d
%sorting by PE latency within-subject and within-stage
data2 = sortrows(data,{'subject','stage','poxDSrel','fileID','trialIDcum','timeLock'});


%-- add simple cumcount of trials in these subset data
id= [];
id= unique(data2.DStrialIDcum, 'stable'); %stable to prevent sorting

idCount= [];
idCount= 1:numel(id);

%initialize
data2(:,'DStrialIDcumcount')= table(nan);

for thisID= 1:numel(id)
     
    ind=[];
    ind= data2.DStrialIDcum==id(thisID);
    
    
    data2(ind,'DStrialIDcumcount')= table(idCount(thisID)); 

    
end

% make another dataset for plotting sorted by Lick latency from PE
%sorting by Lick latency within-subject and within-stage

% %could be precalculated in tidyTable but manual reassign quickly 2022-11-08
% loxDSpoxRel should be loxDSrel - poxDSrel (PE latency)
%compared with stored values plots look same 
data(:,'loxDSpoxRel')= table(nan);
data.loxDSpoxRel= data.loxDSrel- data.poxDSrel;


data4=table;
% data4 = sortrows(data,{'subject','stage','loxDSrel','fileID','trialIDcum','timeLock'});
data4 = sortrows(data,{'subject','stage','loxDSpoxRel','fileID','trialIDcum','timeLock'});


%-- add simple cumcount of trials in these subset data
id= [];
id= unique(data4.DStrialIDcum, 'stable'); %stable to prevent sorting

idCount= [];
idCount= 1:numel(id);

%initialize
data4(:,'DStrialIDcumcount')= table(nan);

for thisID= 1:numel(id)
     
    ind=[];
    ind= data4.DStrialIDcum==id(thisID);
    
    
    data4(ind,'DStrialIDcumcount')= table(idCount(thisID)); 

    
end

% %-- heatplot figure
% 
top= 5;%15;
bottom= -5;

% % For each subject
subjects= unique(data2.subject);
for subj= 1:numel(subjects);

    ind=[];
    ind= strcmp(data2.subject, subjects{subj});
    data3= table;
    data3= data2(ind,:);
    
    
    ind=[];
    ind= strcmp(data4.subject, subjects{subj});
    
    data5=table;
    data5= data4(ind,:);
    
%     %make figure
%     figure(); hold on;
%     imagesc(data3.timeLock,data3.DStrialIDcumcount,data3.DSblue);

%     %overlay Cue Onset (-poxDSrel) 
%     scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
%     
%     caxis manual;
%     caxis([bottom,top]); %use a shared color axis to encompass all values
% 
%     c= colorbar; %colorbar legend
% 
%     xlabel('seconds from PE');

    %x is just wrong... timelock should end at +10
    %test individual trial
%     test= data3(data3.DStrialIDcumcount<=3,:);

    test=data3;

%     figure(); hold on;
%     imagesc(test.timeLock,test.DStrialIDcumcount,test.DSblue);

%     %bad, should be flipped
%     figure;
%     imagesc(test.DStrialIDcumcount,test.timeLock,test.DSblue); %doesnt work?

    %get rid of table format
    x=[], y=[], c=[];
    x= (test.timeLock);
    y= (test.DStrialIDcumcount);
    c= (test.DSblue);
    
%     figure;
%     imagesc(x,y,c);
%     view([90 -90]) %// instead of normal view, which is view([0 90])
% 
%     
%     figure;
%     imagesc(y,x,c);
%     
%     view([90 -90]) %// instead of normal view, which is view([0 90])

    %looking at old code, input to imagesc is in columns. try this
    %and the c is 601x100 so one column per trial..probs needs to be
    %pivoted/stacked...
    x2= x';
    y2= y';
    c2= c';
%         
%     figure;
%     imagesc(y,x,c);
    
    % need to transform c...
    %unstack 
%     data4= stack(data3, {'DSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');
%     data4= unstack(data3, {'DSblue'}, {'trialType', 'NewDataVariableName', 'periCueBlue');
    bins= [];
    bins= numel(unique(x));
    
    %reshape to have specific # of columns (num trials)
    trials= [];
    trials= numel(unique(y));
    
    c2= reshape(c, [], trials);
    
%     figure;
%     imagesc(x,y,c2);
% 
%     figure;
%     imagesc(y,x,c2);
%     
%     %this one looks ok but axes wrong
%     figure;
%     imagesc(y,x,c2);
%     view([-90, 90]) %// instead of normal view, which is view([0 90])

    %% ---- this one looks good ---
%         
    overlayAlpha= .2;
    overlayPointSize= 10; %default i think is 10
    
    
%     figure;
%     %- heatplot
%     imagesc(y,x,c2);
%     set(gca,'YDir','normal') %increasing latency from top to bottom
%     view([90, 90]) %// instead of normal view, which is view([0 90])
% 
%     
% %     caxis manual;
% %     caxis([bottom, top]);
%     c= colorbar; %colorbar legend
%     
%     colormap parula;
%     
%     hold on;
% 
%     
%     %- scatter overlays
%     %overlay cue
%     s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'k');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     %overlay first PE
%     s= scatter(data3.DStrialIDcumcount ,data3.poxDSrel, 'filled', 'm');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     %overlay first lick
%     s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel, 'filled', 'g');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     titleFig= 'test';
%     
    %% Subplot peri heatplot of 3 events
    figure();
    
    
    %1 ---- peri cue
    subplot(1,3,1);
    
    
    %get data; not in table format
    x=[], y=[], c=[];
    x= (data3.timeLock);
    y= (data3.DStrialIDcumcount);
    c= (data3.DSblue);
    
        
    %reshape to have specific # of columns (num trials)
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    imagesc(y,x,c);
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
    cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

    title('Peri-DS (sorted by PE latency)');

    
    %- scatter overlays
    %overlay cue
    s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'k');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first PE
    s= scatter(data3.DStrialIDcumcount ,data3.poxDSrel, 'filled', 'm');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first lick
    s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel, 'filled', 'g');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    

    %--- 2 peri DS PE ---
    
    subplot(1,3,2);
    
    
     %get data; not in table format
    x=[], y=[], c=[];
    x= (data3.timeLock);
    y= (data3.DStrialIDcumcount);
    c= (data3.DSbluePox);
    
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    imagesc(y,x,c);    
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
    cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

    title('Peri-PE (sorted by PE latency)');

    
    %- scatter overlays
    %overlay cue (- poxDSrel)
    s= scatter(data3.DStrialIDcumcount,-data3.poxDSrel, 'filled', 'k');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first PE (0)
    s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'm');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first lick (relative to PE= lox-pox)
    s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel-data3.poxDSrel, 'filled', 'g');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
     %--- 3 peri DS Lick ---
     
     %**have this data sorted by Lick Latency from PE**
    
    subplot(1,3,3);
    
    
     %get data; not in table format
    x=[], y=[], c=[];
    x= (data5.timeLock);
    y= (data5.DStrialIDcumcount);
    c= (data5.DSblueLox);
    
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    imagesc(y,x,c);    
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
    cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

    title('Peri-Lick (sorted by lick latency)');

    
    %- scatter overlays
    %overlay cue (- loxDSrel)
    s= scatter(data5.DStrialIDcumcount,-data5.loxDSrel, 'filled', 'k');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first PE (relative to lick= -lox +pox?)
%     s= scatter(data4.DStrialIDcumcount ,-data4.loxDSrel+data3.poxDSrel, 'filled', 'm');
%     s= scatter(data5.DStrialIDcumcount ,-data5.loxDSrel+data5.poxDSrel, 'filled', 'm');
    s= scatter(data5.DStrialIDcumcount ,-data5.loxDSpoxRel, 'filled', 'm');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first lick (0)
    s= scatter(data5.DStrialIDcumcount, zeros(size(data5.DStrialIDcumcount)), 'filled', 'g');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;    
    s.SizeData= overlayPointSize;
  
    %TODO: matlab transparency/alpha of scatter not working
   %works in legend but not plot
  
   %legend position may be causing export issues?
%     lgd= legend('DS','PE','Lick');
%     lgd.Location= 'eastoutside';
%     lgd.Position= [.9,.7,005,0.05];
    
    titleFig= strcat('Fig 3a) heatplot',' subj-', subjects{subj});   
    sgtitle(titleFig);
    
    
    %TODO:
    %saveFig fxn doesnt seem to vectorize heatmaps...
    saveFig(gcf, figPath, titleFig, figFormats);
    

%     %'contenttype'= 'vector' here does NOT work, way slow
%     titleFig= strcat(titleFig,'.pdf');
%     exportgraphics(gcf, titleFig,'ContentType','image')

    
%% 
    %     %x and y also need flipping
%     figure;
%     imagesc(x2,y2,c2);
% 
%   
%     %actually in old code not plotting true unique x for each trial. only
%     %constant timeLock array
% 
%     
%     %should have 1x601 x, 1x100 y, 100x601 c
%     x3= data3.timeLock(1:bins);
%     x3= x3';
%     
%     y3= [1:trials];
%     
%     c3= reshape(c, [], bins);
%     
%     figure();
%     imagesc(x3,y3,c3);
% 
%     xlabel('seconds from cue onset');
%     ylabel('trial');
%     set(gca, 'ytick', y3); %label trials appropriately
%  
%     
%     figure();
%     imagesc(y3,x3,c3);
%     
%     %still messed up try pcolor
%     figure;
% %     pcolor(x3,y3,c3);
%    
%     h = pcolor(x3,y3,c3);
%     set(h, 'EdgeColor', 'none');
%     
%     %try heatmap
%     %- This works! but needs aesthetic modification
%     % BUT this doesn't support hold so can't plot over.
%     figure(); 
%     h= heatmap(data3,'timeLock','DStrialIDcumcount','ColorVariable','DSblue')
% 
%     h.Colormap= parula;
%     
%     %overlay Cue Onset (-poxDSrel) 
%     scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
%     
    
    
    %seems that each row is constant, not changing as fxn of time
    %also rows are time bins regardless of x,y...
    % i think it's automatically making a range of 'trial' values between 1
    % and 2 even though they should be discrete
    
    
    %try pcolor?
%     % c needs to be x-by-y matrix
%     figure;
%     pcolor(x,y,c);
    
    %imagesc by default apparently sets y to reverse
%     imagesc(test.timeLock,test.DStrialIDcumcount,test.DSblue);
%     set(gca,'YDir','normal') 

    
%     %data viz 2d with gramm for debugging
%     figure(); hold on;
%     clear g;
%     g=gramm('x',data3.timeLock,'lightness',data3.DStrialIDcumcount,'y',data3.DSblue, 'group', data3.DStrialIDcumcount);
% 
%     g.geom_line()
%     g.draw();


end

close all;


%% dp 2022-11-07 examining invalid licks (licks before pe) / lick cleaning
% 
%subset data
data= periEventTable;


% subset data- by stage
stagesToPlot= [7];

ind=[];
ind= ismember(data.stage, stagesToPlot);

data= data(ind,:);



%-- add simple cumcount of trials in these subset data
id= [];
id= unique(data.DStrialIDcum, 'stable'); %stable to prevent sorting

idCount= [];
idCount= 1:numel(id);

%initialize
data(:,'DStrialIDcumcount')= table(nan);

for thisID= 1:numel(id)
     
    ind=[];
    ind= data.DStrialIDcum==id(thisID);
    
    
    data(ind,'DStrialIDcumcount')= table(idCount(thisID)); 

    
end



ind= []

ind= data.poxDSrel < data.loxDSrel;

test= data(ind,:);

unique(test.DStrialOutcome)

% trials here include both 1) port entry and 3) inPort

figure(); title('examining pre-PE licks');


 %get data; not in table format
x=[], y=[], c=[];
x= (test.timeLock);
y= (test.DStrialIDcumcount);%cumcount);
c= (test.DSblue);

trials= [];
trials= numel(unique(y));

c= reshape(c, [], trials);

%make heatplot
imagesc(y,x,c);    
set(gca,'YDir','normal') %increasing latency from top to bottom
view([90, 90]) %// instead of normal view, which is view([0 90])


%     caxis manual;
%     caxis([bottom, top]);
cbar= colorbar; %colorbar legend

colormap parula;

% % overlays pretty slow , lots of data
% hold on; %scatter overlays
% 
% overlayAlpha=0.8;
% overlayPointSize=5;
%  %overlay cue (0)
% s= scatter(test.DStrialIDcumcount,zeros(size(test.DStrialIDcum)), 'filled', 'b');
% s.MarkerFaceAlpha= overlayAlpha;
% s.AlphaData= overlayAlpha;
% s.SizeData= overlayPointSize;
% 
% %overlay first PE
% s= scatter(test.DStrialIDcumcount ,test.poxDSrel, 'filled', 'm');
% s.MarkerFaceAlpha= overlayAlpha;
% s.AlphaData= overlayAlpha;
% s.SizeData= overlayPointSize;
% 
% %overlay first lick 
% s= scatter(test.DStrialIDcumcount,test.loxDSrel, 'filled', 'k');
% s.MarkerFaceAlpha= overlayAlpha;
% s.AlphaData= overlayAlpha;
% s.SizeData= overlayPointSize;

%overall looks like good spread of values, not a systemic weird outlier

%% 

%use findgroups to groupby trial and sort?


%use findgroups to groupby subject,trainPhaseLabel and manually cumcount() for
%sessions within-trainPhaseLabel

%subset to only one ts per trial
ind= [];
ind= data2.timeLock==0;

data3= data2(ind,:);

%sort by latency for this Subject within-stage
groupIDs= [];
groupIDs= findgroups(data3.subject, data3.stage,data3.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

%go through and cumcount the timestamps in each trialID, then sort only
%first observation in each by latency
for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
    
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data3(ind,:);
    
    %now cumulative count of observations in this group
    %make default value=1 for each, and then cumsum() to get cumulative count
    thisGroup(:,'cumcount')= table(1);
    thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
    
    %specific code for trainDayThisPhase
    %assign back into table
    data3(ind, 'cumcountTrialID')= table(thisGroup.cumcount);
    
    
    %Now use this for each 
    %for each groupID, sort the data by PE latency
    indSort= []; trialIDsort=[];
    [~, indSort]= sort(thisGroup.poxDSrel);
   
    %get the sorted trialIDs and use to sort whole data
    
%     %sort this subset
%     data4=[];
%     data4= thisGroup(indSort,:);
    
    %now get the sorted trialIDs
    trialIDsort= thisGroup.trialIDcum;
    
        %dp 2022-10-21 in progress

    %match up these trialIDs with those in the whole dataset?
    
    trialsOG= [];
    
    trialsOG= data2.trialIDcum;
    
    %initialize new 'observation' column for exclusion of repeat
    %observations
    data2(:,'observation')= table(nan);
    
    for thisTrial= 1:numel(trialIDsort)
        ind2=[]; 

        ind2= (trialIDsort(thisTrial)==trialsOG);
        
        data2(ind2,'observation')= table(1);
        
    end
    
    %now get rid of redundant (invalid) observations (nan)
    ind2= [];
    ind2= data2.observation~=1;
    
    data2(ind2, 'poxDSrel')= table(nan);
    
%     ind= find(data.trialIDcum==trialIDsort);
  
end 


%-- heatplot figure

% For each subject
% subjects= unique(data2.subject);
% for subj= 1:numel(subjects);
% 
%     ind=[];
%     ind= strcmp(data2.subject, subjects{subj});
%     
%     data3=[];
%     data3= data2(ind,:);
%     
%     %make figure
%     figure(); hold on;
%     imagesc(data3.timeLock,data3.trialIDcumcount,data3.DSblue);
% 
%     %overlay Cue Onset (-poxDSrel) 
%     scatter(-data3.poxDSrel,data3.trialIDcumcount, 'k.');
%     
% end



% %-- Make Fig
% figure();
% subplot(1,3,1);
% heatDSzpoxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpoxpurpleAllTrials); 
% 
% title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first PE in DS epoch')) %'(n= ', num2str(unique(trialDSnum)),')')); 
% xlabel('seconds from PE');
% ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
% 
% %     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
% 
% caxis manual;
% caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
% 
% c= colorbar; %colorbar legend
% c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding DS');
% 
% set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving



%% ---Supplemental Figure 3 lick correlation


fp_manuscript_supplemental_lickCount_Analysis();
fp_manuscript_supplemental_lickCorrelation();

fp_manuscript_supplement_fig3_uiPanels_3events();
