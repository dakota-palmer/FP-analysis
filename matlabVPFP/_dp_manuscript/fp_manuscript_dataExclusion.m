%exclude data from periEventTable based on criteria

% -- Mark data for exclusion
periEventTable.exclude= nan(size(periEventTable,1),1);

%% Exclude data from specific subjects

%TODO: mark 'control' subject type (GFP/no expression)

subjToExclude= {'rat17', 'rat10', 'rat20'};


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


%% Remove data marked for exclusion

ind= [];
ind= (periEventTable.exclude~=1);

periEventTable= periEventTable(ind,:);