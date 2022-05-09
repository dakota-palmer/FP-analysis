%exclude data from periEventTable based on criteria

% -- Mark data for exclusion
periEventTable.exclude= nan(size(periEventTable,1),1);

%% Mark data from specific subjects for 'control' and/or 'exclusion'

%- TODO: more specific exclusion based on session? rat10 is fine before
%stage 6. even some stage 7 trials look real.


% if ~strcmp(subjMode, 'all')

    %mark subjects for exclusion
%     subjToExclude= {'rat17', 'rat10', 'rat20', 'rat16'};
    subjToExclude= {'rat17', 'rat10'}; %exclude these due to either dynamic loss of signal or behavior


    for subj= 1:numel(subjToExclude)
        ind=[];
        ind= strcmp(periEventTable.subject, subjToExclude{subj})==1;

        periEventTable(ind, 'exclude')= table(1);

    end

% end

    %mark 'control' subject type (GFP/no expression)

    periEventTable(:,'controlSubj')= table(nan);
    controlSubj= {'rat20', 'rat16'}; %exclude these due to no signal ever or GFP control

    for subj= 1:numel(controlSubj)
        ind=[];
        ind= strcmp(periEventTable.subject, controlSubj{subj})==1;

        periEventTable(ind, 'controlSubj')= table(1);

        %reverse exclusion of controlSubj if in control mode and they were previously marked
        if strcmp(subjMode,'control')
            %check if this control subj was marked for exclusion
             if any(strcmp(subjToExclude,controlSubj{subj}))
                %revert 1 to nan
                ind=[];
                ind= strcmp(periEventTable.subject, controlSubj{subj})==1;

                periEventTable(ind, 'exclude')= table(nan);
             end
        end

    end
    

%% Exclue sessions based on PE ratio

% criteriaDS= 0.6;
% 
% criteriaNS= 0.4;

ind=[];

if strcmp(criteriaMode, 'criteriaSes')
%     ind= periEventTable.DSpeRatio <= criteriaDS; %dp 5/6/22 moved this to tidyTable and behaviorAnalysis script
% 
%     ind= ind & (periEventTable.NSpeRatio >= criteriaNS);

    ind= periEventTable.criteriaSes ~=1;

    periEventTable(ind, 'exclude')= table(1);
    
%     figPath= "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_criteriaSes\"
    figPath= strcat(pwd,'\_figures\_criteriaSes\');

elseif strcmp(criteriaMode, 'allSes')
    figPath= strcat(pwd,'\_figures\_allSes\');
    
end

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

% if strcmp(subjMode,'experimental')
    
ind= [];
ind= (periEventTable.exclude~=1); 

periEventTable= periEventTable(ind,:);
    
% end

subjects= unique(periEventTable.subject);
