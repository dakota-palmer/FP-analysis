%exclude data from periEventTable based on criteria

% -- Mark data for exclusion
periEventTable.exclude= nan(size(periEventTable,1),1);

%% Mark data from specific subjects for 'control' and/or 'exclusion'

%mark 'control' subject type (GFP/no expression)

periEventTable(:,'controlSubj')= table(nan);
controlSubj= {'rat20', 'rat10', 'rat16'};

for subj= 1:numel(controlSubj)
    ind=[];
    ind= strcmp(periEventTable.subject, controlSubj{subj})==1;
    
    periEventTable(ind, 'controlSubj')= table(1);
    
end

%mark subjects for exclusion
subjToExclude= {'rat17', 'rat10', 'rat20', 'rat16'};

for subj= 1:numel(subjToExclude)
    ind=[];
    ind= strcmp(periEventTable.subject, subjToExclude{subj})==1;
    
    periEventTable(ind, 'exclude')= table(1);
    
end

%% Exclue sessions based on PE ratio
% criteriaDS= 0.6;
% 
% criteriaNS= 0.4;
% 
% ind=[];
% 
% ind= periEventTable.DSpeRatio <= criteriaDS;
% 
% ind= ind & (periEventTable.NSpeRatio >= criteriaNS);
% 
% periEventTable(ind, 'exclude')= table(1);

%% Define periEventTable based on subjects included (subjMode flag set in fp_manuscript_figs.m)
ind=[];

if strcmp(subjMode,'experimental')
    
    ind= isnan(periEventTable.controlSubj);
    
    periEventTable= periEventTable(ind,:);
    
elseif strcmp(subjMode,'control')
   
    ind= periEventTable.controlSubj==1;

    periEventTable= periEventTable(ind,:);
    
end

%update subj list
subjects= unique(periEventTable.subject);

%% Remove data marked for exclusion
% 
% ind= [];
% ind= (periEventTable.exclude~=1);
% 
% periEventTable= periEventTable(ind,:);