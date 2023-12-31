%

%% Fig format change

%dp 2022-04-28 suddenly hitting errors when saving .figs
% Error using save
% Error closing file

%could save as  mat v 7.3 but seems to makes very large files and takes forever

figFormats = {'.svg'}

%% Use GRAMM to make plots

%% Mean peri-DS by stage
%subset specific data to plot
data= periEventTable;

%define variables to plot and grouping 
i=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);

% i.geom_line();

i.facet_wrap(data.stage);

%define stats to show
i.stat_summary('type','sem','geom','area');


%define labels for plot axes
i.set_names('x','time from event (s)','y','z-score','color','subject');
i.set_title('Peri-DS');

%set y axes limits manually
i.axe_property('YLim',[-1,4]);

%draw the actual plot
i.draw();

title= strcat(subjMode, 'allSubj-periDS-allStages');

saveFig(gcf, figPath, title, figFormats);


%% Mean DS vs NS by stage
%subset specific data to plot
data= periEventTable;

%temp subset for testing
% data= periEventTable(periEventTable.stage==5,:);
   
%transform to have trialType variable
%ideally want to melt() from wide to long 3 eventTypes into single col
%matlab lacks good tidying functions like melt() but we have stack
%which is quite helpful!
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');


%mean between subj
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType);

i.facet_wrap(data.stage);

i.stat_summary('type','sem','geom','area');

i().set_line_options('base_size',2)

i().set_color_options('lightness', 60)

i.draw();

%define variables to plot and grouping 
%ind subjects
i.update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'lightness', data.subject);
% i=gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType);


%define stats to show
% Mean line for individual subj w/o SEM
% i.stat_summary('type','sem','geom','area'); %mean + sem shade
i.stat_summary('type','sem','geom','line'); %mean line only?

%TODO: i think ind subjects x trialtype may require separate, sequential
%subplotting? ideally low alpha idk how to do this with gramm without
%manually calculating mean

%just do in illustrator later!

% i().set_color_options('chroma',0,'lightness',30); % define color for ind subjs

%color_options : Lower chroma = darker, lower lightness= darker
%lightness 0:100 (white) , color range unclear, beyond 255 possible
%chroma 10, lightness 90 = very dull, kinda similar to a low alpha?
%chroma 40, lightness 90/60 good

% The values are Hue (defines the color, [0-360]), Chroma (defines the colorness; restricted to [0-100] here) and Luminance (defines the brightness, [0-100]). 

% i().set_color_options('chroma', 40, 'lightness',60); % define color for ind subjs

% flat range of lightness? still has some variability. Just tune later in
% illustrator
i().set_color_options('lightness_range', [20,20])

i().set_line_options('base_size',0.5)

%define labels for plot axes
i.set_names('x','time from event (s)','y','z-score','color','trialType','lightness','subject');
i.set_title('Peri-Cue');

%set y axes limits manually
i.axe_property('YLim',[-2,5]);

%draw the actual plot
i.draw();

% 
% i.update('x',dataniot.timeLock,'y',data.NSblue);
% i.stat_summary('type','sem','geom','area');
% i.draw();

title= strcat(subjMode, 'allSubj-periDSvsNS-allStages');

% hitting error specifically with this fig 4/27/22
saveFig(gcf, figPath, title, figFormats); 




%% --- Compute AUC of peri-cue ---
%TODO: Move to tidyTable script

data= periEventTable;

%---This METHOD seems WAY TOO SLOW, consider another solution elsewhere?
%ran longer than over night still running
% seems just like matlab is very inefficient doing this... cpu, ram, disk
% usage all very low 

%Overnight made it to NS subj 4 thisDate 3, trial 2386

%--running AUC on all individual trials within loop of table


%-------peri DS AUC

%string of signal column(s)
signalCol= 'DSblue'

%string of trialID col
trialIDCol= 'DStrialID'

%preallocate new columns with nan (otherwise matlab may autofill blanks with 0)
data(:, append('auc',signalCol))= table(nan); %single AUC value for trial
data(:, append('aucAbs',signalCol))= table(nan); %single AUC value for abs(signal) 
data(:, append('aucCum',signalCol))= table(nan); %cumulative AUC across time within trial 
data(:, append('aucCumAbs',signalCol))= table(nan); %cumulative AUC of abs(signal) across time within trial 


subjects= unique(data.subject);

for subj= 1:numel(subjects)
%  %    dataTemp= data(strcmp(data.subject,subjects{subj}),:);
   
   %create a conditional index which we'll cumulatively combine for
   %reassignment into original table
   ind=[]; ind2=[]; ind3=[]; ind4=[]; ind5=[]; ind6= [];

   ind= (strcmp(data.subject,subjects{subj}));
   
%    dates= unique(dataTemp.date);

   dates= unique(data(ind, 'date'));
   
   for thisDate= 1:numel(dates)
%        dataTemp2= dataTemp(strcmp(dataTemp.date,dates{date}),:);
       
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate})));
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate,:})));

        %kinda slow but likely faster than ismember
        ind2= (ind & (strcmp(data{:,'date'},dates{thisDate,:})));


      
       %TODO: ~~ismember is super slow!
%        ind2= (ind & (ismember(data(:,'date'),dates(thisDate,:))));

       
       
        %retain only those with valid trialIDs 
        ind5= (ind2 & (~ismissing(data(:,trialIDCol))));

       
%        trials= unique(dataTemp2(:,trialIDCol))
    
%        trials= unique(table2array(data(ind2, trialIDCol))); %if run unique() on table doesn't actually get unique values of column
       
       %for some reason ind2 w/ nan trialID returns a unique nan for every row
       trials= unique(data(ind5,trialIDCol));

       trials= table2array(trials);
       
       for trial= 1:numel(trials)
            
%            dataTemp3= dataTemp2((ismember(dataTemp2(:,trialID),trial)),:);
           
%            ind3= (ind2 & (ismember(data(:,trialID),trials(trial))));

%              ind3= (ind5 & (ismember(data(:,trialIDCol),trials(trial,:)))); %this line takes awhile?
%              ind3= (ind5 & (data(:,trialIDCol)==trials(trial,:))); %this line takes awhile?
             ind3= (ind5 & (data.(trialIDCol))==trials(trial,:)); %this line takes awhile?




           %compute AUC of signal within this trial
           auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
           
           
           
           %Only include post-cue portion of signal in AUC (timeLock >=0)
           ind6= data.timeLock>=0;
           
           ind3= (ind3 & ind6);
           
           signal= data(ind3, signalCol);
           
           signal= table2array(signal);
           
           

           %for auc and aucAbs, single value for trials so retain only one
           %observation (for correct plotting & stats; easy w/o changing later)
           ind4= find(ind3==1);

           auc= nan(size(ind4));
           aucAbs= nan(size(ind4));
           
           [auc(1), aucAbs(1), aucCum, aucCumAbs] = fp_AUC(signal);
          
           
        % -- Eliminate redundant auc values
        
%         %for auc and aucAbs, single value for trials so retain only one
%         %observation (for correct plotting & stats; easy w/o changing later)
%         ind4= find(ind3==1);
% %         
% %         
% %         auc(1)= auc;
% % 
% %         auc(2:,:)= nan;
% %         aucAbs(2:,:)=nan;

           
           data(ind3, append('auc',signalCol))= table(auc); %single AUC value for trial
           data(ind3, append('aucAbs',signalCol))= table(aucAbs); %single AUC value for abs(signal) 
           data(ind3, append('aucCum',signalCol))= table(aucCum); %cumulative AUC across time within trial 
           data(ind3, append('aucCumAbs',signalCol))= table(aucCumAbs); %cumulative AUC of abs(signal) across time within trial 

       end %end trial loop
   end %end ses loop
    
end %end subj loop


%-------Repeat for NS
%

%string of signal column(s)
signalCol= 'NSblue'

%string of trialID col
trialIDCol= 'NStrialID'

%preallocate new columns with nan (otherwise matlab may autofill blanks with 0)
data(:, append('auc',signalCol))= table(nan); %single AUC value for trial
data(:, append('aucAbs',signalCol))= table(nan); %single AUC value for abs(signal) 
data(:, append('aucCum',signalCol))= table(nan); %cumulative AUC across time within trial 
data(:, append('aucCumAbs',signalCol))= table(nan); %cumulative AUC of abs(signal) across time within trial 


subjects= unique(data.subject);

for subj= 1:numel(subjects)
%    dataTemp= data(strcmp(data.subject,subjects{subj}),:);
   
   %create a conditional index which we'll cumulatively combine for
   %reassignment into original table
   ind=[]; ind2=[]; ind3=[]; ind4=[]; ind5=[]; ind6=[];

   ind= (strcmp(data.subject,subjects{subj}));
   
%    dates= unique(dataTemp.date);

   dates= unique(data(ind, 'date'));
   
   for thisDate= 1:numel(dates)
%        dataTemp2= dataTemp(strcmp(dataTemp.date,dates{date}),:);
       
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate})));
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate,:})));

        %kinda slow but likely faster than ismember
        ind2= (ind & (strcmp(data{:,'date'},dates{thisDate,:})));


      
       %TODO: ~~ismember is super slow!
%        ind2= (ind & (ismember(data(:,'date'),dates(thisDate,:))));

       
       
        %retain only those with valid trialIDs 
        ind5= (ind2 & (~ismissing(data(:,trialIDCol))));

       
%        trials= unique(dataTemp2(:,trialIDCol))
    
%        trials= unique(table2array(data(ind2, trialIDCol))); %if run unique() on table doesn't actually get unique values of column
       
       %for some reason ind2 w/ nan trialID returns a unique nan for every row
       trials= unique(data(ind5,trialIDCol));

       trials= table2array(trials);
       
       for trial= 1:numel(trials)
            
%            dataTemp3= dataTemp2((ismember(dataTemp2(:,trialID),trial)),:);
           
%            ind3= (ind2 & (ismember(data(:,trialID),trials(trial))));

%              ind3= (ind5 & (ismember(data(:,trialIDCol),trials(trial,:)))); %this line takes awhile?
%              ind3= (ind5 & (data(:,trialIDCol)==trials(trial,:))); %this line takes awhile?
             ind3= (ind5 & (data.(trialIDCol))==trials(trial,:)); %this line takes awhile?




           %compute AUC of signal within this trial
           auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
           
           %Only include post-cue portion of signal in AUC (timeLock >=0)
           ind6= data.timeLock>=0;
           
           ind3= (ind3 & ind6);
           
           signal= data(ind3, signalCol);
                      
           signal= table2array(signal);
           
           

           %for auc and aucAbs, single value for trials so retain only one
           %observation (for correct plotting & stats; easy w/o changing later)
           ind4= find(ind3==1);

           auc= nan(size(ind4));
           aucAbs= nan(size(ind4));
           
           [auc(1), aucAbs(1), aucCum, aucCumAbs] = fp_AUC(signal);
          
%            %auc(1) == aucCum(end)
%            
%            x= 401; %tbins
%            
%            %default x = 1
%            test= trapz(signal);
%            
%            x= 401/fs;
%            test2= trapz(x, signal); 
%            
%            x= 401*fs;
%            test3= trapz(x, signal); 
% 
%            %each of these makes more extreme trapz?
%            %still get 401 values
%            % but ~10x larger each time
%           % x= 401; %tbins
%            test= cumtrapz(signal);
%            
%            x= 2; %401/fs;
%            test2= cumtrapz(x, signal); 
%            
%            x= 0.5;%401*fs;
%            test3= cumtrapz(x, signal); 
% 
%            
%            %looks like 1/fs is pretty reasonable?
%            x= 1/fs;%401*fs;
%            test= cumtrapz(x, signal);
%            
%            figure;
%            subplot(1,2,1); hold on;
%            plot(signal, 'b');
%            subplot(1,2,2); hold on;
%            plot(test, 'k');
%            
                
        % -- Eliminate redundant auc values
        
%         %for auc and aucAbs, single value for trials so retain only one
%         %observation (for correct plotting & stats; easy w/o changing later)
%         ind4= find(ind3==1);
% %         
% %         
% %         auc(1)= auc;
% % 
% %         auc(2:,:)= nan;
% %         aucAbs(2:,:)=nan;

           
           data(ind3, append('auc',signalCol))= table(auc); %single AUC value for trial
           data(ind3, append('aucAbs',signalCol))= table(aucAbs); %single AUC value for abs(signal) 
           data(ind3, append('aucCum',signalCol))= table(aucCum); %cumulative AUC across time within trial 
           data(ind3, append('aucCumAbs',signalCol))= table(aucCumAbs); %cumulative AUC of abs(signal) across time within trial 

           
       end
   end %end ses loop
end %end subj loop
       
       
%----405nm AUCs 
    %-------peri DS AUC

%string of signal column(s)
signalCol= 'DSpurple'

%string of trialID col
trialIDCol= 'DStrialID'

%preallocate new columns with nan (otherwise matlab may autofill blanks with 0)
data(:, append('auc',signalCol))= table(nan); %single AUC value for trial
data(:, append('aucAbs',signalCol))= table(nan); %single AUC value for abs(signal) 
data(:, append('aucCum',signalCol))= table(nan); %cumulative AUC across time within trial 
data(:, append('aucCumAbs',signalCol))= table(nan); %cumulative AUC of abs(signal) across time within trial 


subjects= unique(data.subject);

for subj= 1:numel(subjects)
%  %    dataTemp= data(strcmp(data.subject,subjects{subj}),:);
   
   %create a conditional index which we'll cumulatively combine for
   %reassignment into original table
   ind=[]; ind2=[]; ind3=[]; ind4=[]; ind5=[]; ind6= [];

   ind= (strcmp(data.subject,subjects{subj}));
   
%    dates= unique(dataTemp.date);

   dates= unique(data(ind, 'date'));
   
   for thisDate= 1:numel(dates)
%        dataTemp2= dataTemp(strcmp(dataTemp.date,dates{date}),:);
       
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate})));
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate,:})));

        %kinda slow but likely faster than ismember
        ind2= (ind & (strcmp(data{:,'date'},dates{thisDate,:})));


      
       %TODO: ~~ismember is super slow!
%        ind2= (ind & (ismember(data(:,'date'),dates(thisDate,:))));

       
       
        %retain only those with valid trialIDs 
        ind5= (ind2 & (~ismissing(data(:,trialIDCol))));

       
%        trials= unique(dataTemp2(:,trialIDCol))
    
%        trials= unique(table2array(data(ind2, trialIDCol))); %if run unique() on table doesn't actually get unique values of column
       
       %for some reason ind2 w/ nan trialID returns a unique nan for every row
       trials= unique(data(ind5,trialIDCol));

       trials= table2array(trials);
       
       for trial= 1:numel(trials)
            
%            dataTemp3= dataTemp2((ismember(dataTemp2(:,trialID),trial)),:);
           
%            ind3= (ind2 & (ismember(data(:,trialID),trials(trial))));

%              ind3= (ind5 & (ismember(data(:,trialIDCol),trials(trial,:)))); %this line takes awhile?
%              ind3= (ind5 & (data(:,trialIDCol)==trials(trial,:))); %this line takes awhile?
             ind3= (ind5 & (data.(trialIDCol))==trials(trial,:)); %this line takes awhile?




           %compute AUC of signal within this trial
           auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
           
           
           
           %Only include post-cue portion of signal in AUC (timeLock >=0)
           ind6= data.timeLock>=0;
           
           ind3= (ind3 & ind6);
           
           signal= data(ind3, signalCol);
           
           signal= table2array(signal);
           
           

           %for auc and aucAbs, single value for trials so retain only one
           %observation (for correct plotting & stats; easy w/o changing later)
           ind4= find(ind3==1);

           auc= nan(size(ind4));
           aucAbs= nan(size(ind4));
           
           [auc(1), aucAbs(1), aucCum, aucCumAbs] = fp_AUC(signal);
          
           
        % -- Eliminate redundant auc values
        
%         %for auc and aucAbs, single value for trials so retain only one
%         %observation (for correct plotting & stats; easy w/o changing later)
%         ind4= find(ind3==1);
% %         
% %         
% %         auc(1)= auc;
% % 
% %         auc(2:,:)= nan;
% %         aucAbs(2:,:)=nan;

           
           data(ind3, append('auc',signalCol))= table(auc); %single AUC value for trial
           data(ind3, append('aucAbs',signalCol))= table(aucAbs); %single AUC value for abs(signal) 
           data(ind3, append('aucCum',signalCol))= table(aucCum); %cumulative AUC across time within trial 
           data(ind3, append('aucCumAbs',signalCol))= table(aucCumAbs); %cumulative AUC of abs(signal) across time within trial 

       end %end trial loop
   end %end ses loop
    
end %end subj loop


%-------Repeat for NS
%

%string of signal column(s)
signalCol= 'NSpurple'

%string of trialID col
trialIDCol= 'NStrialID'

%preallocate new columns with nan (otherwise matlab may autofill blanks with 0)
data(:, append('auc',signalCol))= table(nan); %single AUC value for trial
data(:, append('aucAbs',signalCol))= table(nan); %single AUC value for abs(signal) 
data(:, append('aucCum',signalCol))= table(nan); %cumulative AUC across time within trial 
data(:, append('aucCumAbs',signalCol))= table(nan); %cumulative AUC of abs(signal) across time within trial 


subjects= unique(data.subject);

for subj= 1:numel(subjects)
%    dataTemp= data(strcmp(data.subject,subjects{subj}),:);
   
   %create a conditional index which we'll cumulatively combine for
   %reassignment into original table
   ind=[]; ind2=[]; ind3=[]; ind4=[]; ind5=[]; ind6=[];

   ind= (strcmp(data.subject,subjects{subj}));
   
%    dates= unique(dataTemp.date);

   dates= unique(data(ind, 'date'));
   
   for thisDate= 1:numel(dates)
%        dataTemp2= dataTemp(strcmp(dataTemp.date,dates{date}),:);
       
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate})));
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate,:})));

        %kinda slow but likely faster than ismember
        ind2= (ind & (strcmp(data{:,'date'},dates{thisDate,:})));


      
       %TODO: ~~ismember is super slow!
%        ind2= (ind & (ismember(data(:,'date'),dates(thisDate,:))));

       
       
        %retain only those with valid trialIDs 
        ind5= (ind2 & (~ismissing(data(:,trialIDCol))));

       
%        trials= unique(dataTemp2(:,trialIDCol))
    
%        trials= unique(table2array(data(ind2, trialIDCol))); %if run unique() on table doesn't actually get unique values of column
       
       %for some reason ind2 w/ nan trialID returns a unique nan for every row
       trials= unique(data(ind5,trialIDCol));

       trials= table2array(trials);
       
       for trial= 1:numel(trials)
            
%            dataTemp3= dataTemp2((ismember(dataTemp2(:,trialID),trial)),:);
           
%            ind3= (ind2 & (ismember(data(:,trialID),trials(trial))));

%              ind3= (ind5 & (ismember(data(:,trialIDCol),trials(trial,:)))); %this line takes awhile?
%              ind3= (ind5 & (data(:,trialIDCol)==trials(trial,:))); %this line takes awhile?
             ind3= (ind5 & (data.(trialIDCol))==trials(trial,:)); %this line takes awhile?




           %compute AUC of signal within this trial
           auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
           
           %Only include post-cue portion of signal in AUC (timeLock >=0)
           ind6= data.timeLock>=0;
           
           ind3= (ind3 & ind6);
           
           signal= data(ind3, signalCol);
                      
           signal= table2array(signal);
           
           

           %for auc and aucAbs, single value for trials so retain only one
           %observation (for correct plotting & stats; easy w/o changing later)
           ind4= find(ind3==1);

           auc= nan(size(ind4));
           aucAbs= nan(size(ind4));
           
           [auc(1), aucAbs(1), aucCum, aucCumAbs] = fp_AUC(signal);
          
%            %auc(1) == aucCum(end)
%            
%            x= 401; %tbins
%            
%            %default x = 1
%            test= trapz(signal);
%            
%            x= 401/fs;
%            test2= trapz(x, signal); 
%            
%            x= 401*fs;
%            test3= trapz(x, signal); 
% 
%            %each of these makes more extreme trapz?
%            %still get 401 values
%            % but ~10x larger each time
%           % x= 401; %tbins
%            test= cumtrapz(signal);
%            
%            x= 2; %401/fs;
%            test2= cumtrapz(x, signal); 
%            
%            x= 0.5;%401*fs;
%            test3= cumtrapz(x, signal); 
% 
%            
%            %looks like 1/fs is pretty reasonable?
%            x= 1/fs;%401*fs;
%            test= cumtrapz(x, signal);
%            
%            figure;
%            subplot(1,2,1); hold on;
%            plot(signal, 'b');
%            subplot(1,2,2); hold on;
%            plot(test, 'k');
%            
                
        % -- Eliminate redundant auc values
        
%         %for auc and aucAbs, single value for trials so retain only one
%         %observation (for correct plotting & stats; easy w/o changing later)
%         ind4= find(ind3==1);
% %         
% %         
% %         auc(1)= auc;
% % 
% %         auc(2:,:)= nan;
% %         aucAbs(2:,:)=nan;

           
           data(ind3, append('auc',signalCol))= table(auc); %single AUC value for trial
           data(ind3, append('aucAbs',signalCol))= table(aucAbs); %single AUC value for abs(signal) 
           data(ind3, append('aucCum',signalCol))= table(aucCum); %cumulative AUC across time within trial 
           data(ind3, append('aucCumAbs',signalCol))= table(aucCumAbs); %cumulative AUC of abs(signal) across time within trial 

           
       end
       
   end %end ses loop
    
end %end subj loop


periEventTable= data; %reassign

% %
% %that took a long time to run, let's save the table
 save(fullfile(figPath,strcat(experimentName,'-',date, 'periEventTable')), 'periEventTable', '-v7.3');
% 

% %% auc plots here v slow and not needed (was simply comparing early on
% %% ------------------------------PLOT of AUC data
% 
% stagesToPlot= [4,5,7];
% 
% data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% %temp subset for testing
% % data= periEventTable(periEventTable.stage==5,:);
%    
% %transform to have trialType variable
% %ideally want to melt() from wide to long 3 eventTypes into single col
% %matlab lacks good tidying functions like melt() but we have stack
% %which is quite helpful!
% 
% %------Cumulative AUC Plot over time
% 
% data= stack(data, {'aucCumDSblue', 'aucCumNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAucCum');
% 
% 
% %mean between subj
% figure();
% i= gramm('x',data.timeLock,'y',data.periCueBlueAucCum, 'color', data.trialType);
% 
% i.facet_wrap(data.stage);
% 
% i.stat_summary('type','sem','geom','area');
% 
% i().set_line_options('base_size',2)
% 
% i().set_color_options('lightness', 60)
% 
% i.draw();
% 
% %ind subjects
% i.update('x',data.timeLock,'y',data.periCueBlueAucCum, 'color', data.trialType, 'lightness', data.subject);
% 
% 
% %define stats to show
% % Mean line for individual subj w/o SEM
% % i.stat_summary('type','sem','geom','area'); %mean + sem shade
% i.stat_summary('type','sem','geom','line'); %mean line only?
% 
% i().set_color_options('lightness_range', [20,20])
% 
% i().set_line_options('base_size',0.5)
% 
% %define labels for plot axes
% i.set_names('x','time from event (s)','y','cumulative AUC (of z-score)','color','trialType','lightness','subject');
% i.set_title('Peri-Cue: Cumulative AUC');
% 
% %set axes limits manually
% i.axe_property('YLim',[-7,6]);
% 
% i.axe_property('XLim',[0,max(data.timeLock)]);
% 
% %draw the actual plot
% i.draw();
% 
% title= strcat(subjMode, '-allSubj-periCueAucCum');
% 
% saveFig(gcf, figPath, title, figFormats);
% 
% %% ------------------------------PLOT of AUC data
% 
% stagesToPlot= [4,5,7];
% 
% data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% %temp subset for testing
% % data= periEventTable(periEventTable.stage==5,:);
%    
% %transform to have trialType variable
% %ideally want to melt() from wide to long 3 eventTypes into single col
% %matlab lacks good tidying functions like melt() but we have stack
% %which is quite helpful!
% 
% %------Cumulative AUC Plot over time
%  
% data= stack(data, {'aucCumAbsDSblue', 'aucCumAbsNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAucCumAbs');
% 
% figure();
% 
% %mean between subj
% i= gramm('x',data.timeLock,'y',data.periCueBlueAucCumAbs, 'color', data.trialType);
% 
% i.facet_wrap(data.stage);
% 
% i.stat_summary('type','sem','geom','area');
% 
% i().set_line_options('base_size',2)
% 
% i().set_color_options('lightness', 60)
% 
% i.draw();
% 
% %ind subjects
% i.update('x',data.timeLock,'y',data.periCueBlueAucCumAbs, 'color', data.trialType, 'lightness', data.subject);
% 
% 
% %define stats to show
% % Mean line for individual subj w/o SEM
% % i.stat_summary('type','sem','geom','area'); %mean + sem shade
% i.stat_summary('type','sem','geom','line'); %mean line only?
% 
% i().set_color_options('lightness_range', [20,20])
% 
% i().set_line_options('base_size',0.5)
% 
% %define labels for plot axes
% i.set_names('x','time from event (s)','y','cumulative Absolute AUC (of z-score)','color','trialType','lightness','subject');
% i.set_title('Peri-Cue: Cumulative AUC');
% 
% %set axes limits manually
% i.axe_property('YLim',[-5,10]);
% 
% i.axe_property('XLim',[0,max(data.timeLock)]);
% 
% %draw the actual plot
% i.draw();
% 
% title= strcat(subjMode, 'allSubj-periCueAucCumAbs');
% 
% saveFig(gcf, figPath, title, figFormats);
% 
% 
% %% --------- Bar plot of single AUC values
% 
% %subset data
% stagesToPlot= [4,5,7];
% 
% data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% 
% data= stack(data, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');
% 
% 
% %mean between subj
% i= gramm('x',data.trialType,'y',data.periCueBlueAuc, 'color', data.trialType);
% 
% i.facet_wrap(data.stage);
% 
% %mean bar for trialType
% i.stat_summary('type','sem','geom',{'bar', 'black_errorbar'});
% 
% i().set_line_options('base_size',2)
% 
% i().set_color_options('lightness', 60)
% 
% i.draw();
% 
% 
% %ind subjects
% i.update('x',data.trialType,'y',data.periCueBlueAuc, 'color', data.trialType, 'lightness', data.subject);
% 
% 
% %define stats to show
% % Mean point for ind subjects
% i.stat_summary('type','sem','geom','line'); %mean line only
% 
% i().set_color_options('lightness_range', [20,20])
% 
% i().set_line_options('base_size',0.5)
% 
% %define labels for plot axes
% i.set_names('x','time from event (s)','y','AUC (of z-score)','color','trialType','lightness','subject');
% i.set_title('Peri-Cue: AUC');
% 
% %set y axes limits manually
% % i.axe_property('YLim',[-6,10]);
% 
% %draw the actual plot
% i.draw();
% 
% title= strcat(subjMode, 'allSubj-periCueAuc-Bar');
% 
% saveFig(gcf, figPath, title, figFormats);


%% Stage 7 peri-Cue vs peri-Pox vs peri-Lox
figure();

clear i
%subset data
data= periEventTable(periEventTable.stage==7,:);


%transform to have eventType variable, refined to 3 events x 2 cues
%ideally want to melt() from wide to long 3 eventTypes into single col
%matlab lacks good tidying functions like melt() but we have stack
%which is quite helpful!
data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox', 'NSblue', 'NSbluePox','NSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');

i=gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'lightness',data.subject);






% i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color', data.EventType, 'lightness',data.subject);
% i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(1,1).set_title('Peri-DS');
% 
% 
% i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(2,1).set_title('Peri-First PE DS');
% 
% i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
% i(3,1).stat_summary('type','sem','geom','area');
% i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(3,1).set_title('Peri-First Lick DS');

i.axe_property('YLim',[-3,8]);
i.set_title('stage 7');

i.draw();

title= strcat(subjMode, 'allSubj-periEvent-stage7');

saveFig(gcf, figPath, title, figFormats);

%% Fig 2aa: DS vs NS learning on special days: 2d 

%- Stage 5 Day 1, Stage 5 Criteria, Stage 7 Criteria
% --marked as sesSpecialLabel in fpTidyTable.m

%subset data 
data= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data.sesSpecialLabel);

data= data(ind,:);

%stack() to make trialType variable for faceting
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');

% FacetGrid with sesSpecialLabel = Row
clear i;
figure();


% individual subjects means
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group', data.subject);

% i= facet_wrap(data.sesSpecialLabel,'ncols',1);
i= i.facet_grid([],data.sesSpecialLabel);


i().stat_summary('type','sem','geom','line');
i().geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i().set_line_options('base_size',linewidthSubj);
i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i().draw();

%mean between subj + sem
i().update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group',[]);

i().stat_summary('type','sem','geom','area');

i().set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i().set_line_options('base_size',linewidthGrand)

i().axe_property('YLim',[-1,5]);
i().axe_property('XLim',[-5,10]);

title= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   
% i().set_title(title);    
i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');

i.draw()

saveFig(gcf, figPath, title, figFormats);

% ----- Bar plots of AUC
clear i;

data2= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data2.sesSpecialLabel);

data2= data2(ind,:);

%stack() to make trialType variable for faceting
data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');



%mean between subj
i= gramm('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType, 'group', []);

i.set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i.stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i.set_line_options('base_size',linewidthGrand)

i.axe_property('YLim',[-1,10]);
title= strcat(subjMode,'-allSubjects-Figure2-learning-periCue-zAUC');   
i.set_title(title);    
i.set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');


%ind subj mean points
i.update('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType, 'group', data2.subject);

i= i.facet_grid([],data.sesSpecialLabel);

i.stat_summary('type','sem','geom','point');

i.set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i.set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

%horz line @ zero
i.geom_hline('yintercept', 0, 'style', 'k--'); 

i().draw()

saveFig(gcf, figPath, title, figFormats);

%% Figure 2aaa: 465 and 405nm peri cue on special days

%- Stage 5 Day 1, Stage 5 Criteria, Stage 7 Criteria
% --marked as sesSpecialLabel in fpTidyTable.m

%subset data 
data= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data.sesSpecialLabel);

data= data(ind,:);

%stack() to make trialType variable for faceting
data= stack(data, {'DSblue', 'NSblue', 'DSpurple', 'NSpurple'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');

% FacetGrid with sesSpecialLabel = Row
clear i;
figure();

cmapSubj= cmapTab10Subj;
cmapGrand= cmapTab10Grand;

% cmapSubj= cmapCueSubj;
% cmapGrand= cmapCueGrand;

% cmapSubj= 'brewer2';
% cmapSubj= 'brewer_dark';


% individual subjects means
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group', data.subject);

% i= facet_wrap(data.sesSpecialLabel,'ncols',1);
i= i.facet_grid([],data.sesSpecialLabel);


i().stat_summary('type','sem','geom','line');
i().geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

% i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapSubj);


i().set_line_options('base_size',linewidthSubj);
i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i().draw();

%mean between subj + sem
i().update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group',[]);

i().stat_summary('type','sem','geom','area');

% i().set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapGrand);


i().set_line_options('base_size',linewidthGrand)

i().axe_property('YLim',[-1,5]);
i().axe_property('XLim',[-5,10]);

title= strcat(subjMode,'aaa-allSubjects-','-Figure2-learning-periCue-zTraces');   
% i().set_title(title);    
i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');

i.draw()

% saveFig(gcf, figPath, title, figFormats);

% ----- Bar plots of AUC
clear i;
figure();

data2= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data2.sesSpecialLabel);

data2= data2(ind,:);

%stack() to make trialType variable for faceting
data2= stack(data2, {'aucDSblue', 'aucNSblue', 'aucDSpurple','aucNSpurple'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueAuc');



%mean between subj
i= gramm('x',data2.trialType,'y',data2.periCueAuc, 'color', data2.trialType, 'group', []);

i.facet_grid([],data2.sesSpecialLabel);


% i.set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapGrand);


%mean bar for trialType
i.stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i.set_line_options('base_size',linewidthGrand)

i.axe_property('YLim',[-1,10]);
title= strcat(subjMode,'-allSubjects-Figure2-learning-periCue-zAUC');   
i.set_title(title);    
i.set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');


%ind subj mean points
i.update('x',data2.trialType,'y',data2.periCueAuc, 'color', data2.trialType, 'group', data2.subject);

i.stat_summary('type','sem','geom','point');

% i.set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapSubj);

i.set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

%horz line @ zero
i.geom_hline('yintercept', 0, 'style', 'k--'); 

i().draw()

%% Fig ?? Time series of auc by day...

stagesToPlot= [1,2,3,4,5,6,7,12];

data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

% ind=[];
% ind= ~cellfun(@isempty, data.sesSpecialLabel);
% 
% data= data(ind,:);

%stack() to make trialType variable for faceting
data= stack(data, {'aucDSblue', 'aucNSblue', 'aucDSpurple','aucNSpurple'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueAuc');


%- plot 
clear i;
figure();


% individual subjects means
i= gramm('x',data.trainDayThisStage,'y',data.periCueAuc, 'color', data.trialType, 'group', data.subject);

% i= facet_wrap(data.sesSpecialLabel,'ncols',1);
% i= i.facet_grid([],data.stage);
i= i.facet_wrap(data.stage, 'ncols',4);


i().stat_summary('type','sem','geom','line');
i().geom_hline('yintercept',0, 'style', 'k--'); %overlay t=0

% i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapSubj);


i().set_line_options('base_size',linewidthSubj);
i().set_names('x','trainDay','y','auc','color','trial type (ind subj mean)');

i().draw();

%mean between subj + sem
i().update('x',data.trainDayThisStage,'y',data.periCueAuc, 'color', data.trialType, 'group',[]);

i().stat_summary('type','sem','geom','area');

% i().set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
i.set_color_options('map',cmapGrand);


i().set_line_options('base_size',linewidthGrand)

i().axe_property('YLim',[-4,10]);
% i().axe_property('XLim',[-5,10]);

title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-learning-periCue-zTraces');   
i().set_title(title);    
i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');

i.draw()





%% Figure 2a: DS vs NS Peri event Z + AUC bar
% dp 2022-05-02 updating w new colormap and aesthetics

stagesToPlot= [7];

%---- i(1) pericue z trace
%subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%transform to have trialType variable
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');

figure();
clear i

% individual subjects means
i(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group', data.subject);

i(1,1).stat_summary('type','sem','geom','line');
i(1,1).geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i(1,1).set_color_options('map', cmapSubj); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

i(1,1).axe_property('YLim',[-1,5]);
i(1,1).axe_property('XLim',[-5,10]);

title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   
i(1,1).set_title(title);    
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');


% i(1,1).draw();

%when making subplots gramm likes a collective i.draw() after creating
%each subplot before updating?

%---- i(2) bar AUC
data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');


%mean between subj
i(2,1)=gramm('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType, 'group', []);

i(2,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i(2,1).stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i(2,1).set_line_options('base_size',linewidthGrand)

i(2,1).axe_property('YLim',[-1,10]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zAUC');   
i(2,1).set_title(title);    
i(2,1).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');

%horz line @ zero
i(2,1).geom_hline('yintercept', 0, 'style', 'k--'); 

i.draw();

%ind subj mean points
i(2,1).update('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType, 'group', data2.subject);

i(2,1).stat_summary('type','sem','geom','point');

i(2,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(2,1).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(2,1).draw()


saveFig(gcf, figPath, title, figFormats);

%% STATS for AUC plot above

%-First need to subset to actual # of observations (1 per trial)

%-Add unique trialIDs
    %data2 currently has 2 values per timestamp per trial (1 per trialType).
    %want to transform such that each timestamp copy belongs to distinct
    %trialID %could simply multiply trialID by -1 if trialType== NS then values %would be unique.
    
    %convert to string (stack made this categorical)
    data2.trialType= string(data2.trialType);
    
    %search for NS trialTypes
    ind=[];
    ind= contains(data2.trialType, 'NS');
    
    %transform trialIDs for these entries to make unique 
    %muliplying by -1
    data2(ind, "trialIDcum") = table(data2.trialIDcum(ind) * -1);
    

%- aggregate to one observation per trial (AUC is aggregated measure)
    
    %columns to group by
groupers= ["subject","trainDay", "fileID", "trialType", "trialIDcum"];

    %simplfy to one observation (using mean)
 data3= groupsummary(data2, [groupers],'mean', ["periCueBlueAuc"]);

    %remove appended 'mean_' name on column
 data3 = renamevars(data3,["mean_periCueBlueAuc"],[,"periCueBlueAuc"]);
       
%Result of groupsummary here is table with one auc value per unique trial

%-- STAT LME
%are mean AUC different by trialType? lme with random subject intercept

%- dummy variable conversion
% converting to dummies(retains only one column, as 2+ is redundant)

%convert trialType to dummy variable 
dummy=[];
dummy= categorical(data3.trialType);
dummy= dummyvar(dummy); 

data3.trialType= dummy(:,1);


%- run LME
lme1=[];

lme1= fitlme(data3, 'periCueBlueAuc~ trialType + (1|subject)');


%print and save results to file
%seems diary keeps running log to same file (e.g. if code rerun seems prior output remains)
diary('fp-figure2-DSvNS-auc-lmeDetails.txt')
lme1
diary off

%% Fig 2 b- Contingency of port entry (PE trial vs noPE trials)

stagesToPlot= [7];

%---- i(1) pericue z trace
%subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%initialize & add binary variable for PE vs noPE

data(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data(:,'poxDSoutcome')= {outcomeLabels{data.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","DStrialID","timeLock"];
data= unstack(data, 'DSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

%transform with stack to have trialOutcome variable
data= stack(data, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlue');

figure();
clear i

% individual subjects means
i(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group', data.subject);

i(1,1).stat_summary('type','sem','geom','line');
i(1,1).geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i(1,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthGrand)

i(1,1).axe_property('YLim',[-1,5]);
i().axe_property('XLim',[-5,10]);

title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   
i(1,1).set_title(title);    
i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');


% i(1,1).draw();

%when making subplots gramm likes a collective i.draw() after creating
%each subplot before updating?

%---- i(2) bar AUC
data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

% data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');

%initialize & add binary variable for PE vs noPE
data2(:,'poxDSoutcome')= {''}; %table(0);
% ind=[];
% ind= ~isnan(data2.poxDSrel);
% 
% data2(ind,'poxDSoutcome')= {'PEtrial'};%table(1);
%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data2(:,'poxDSoutcome')= {outcomeLabels{data2.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","DStrialID","timeLock"];
data2= unstack(data2, 'aucDSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

% 
% data2(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%transform with stack to have trialOutcome variable
data2= stack(data2, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlueAuc');

% figure();
% clear i

%mean between subj
i(2,1)= gramm('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', []);

i(2,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i(2,1).stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i(2,1).set_line_options('base_size',linewidthGrand)

i(2,1).axe_property('YLim',[-1,10]);
title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2b-periCue-byPEoutcome-zAUC');   
i(2,1).set_title(title);    
i(2,1).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');

%horz line @ zero
i(2,1).geom_hline('yintercept', 0, 'style', 'k--'); 

i().draw();

%ind subj mean points
i(2,1).update('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', data2.subject);

i(2,1).stat_summary('type','sem','geom','point');

i(2,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(2,1).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i(2,1).draw()

saveFig(gcf, figPath, title, figFormats);

 %% old fig 2
% stagesToPlot= [5];
% 
% %---- i(1) pericue z trace
% %subset specific data to plot
% data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% %transform to have trialType variable
% data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');
% 
% figure();
% clear i
% 
% 
% %mean between subj
% i(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType);
% 
% i(1,1).stat_summary('type','sem','geom','area');
% 
% i(1,1).set_line_options('base_size',2)
% 
% i(1,1).set_color_options('lightness', 60)
% 
% i.draw();
% 
% 
% %draw the actual plot
% i.draw();
% 
% 
% %---- i(2) bar AUC
% data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');
% 
% 
% %mean between subj
% i(2,1)= gramm('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType);
% 
% % i.facet_wrap(data.stage);
% 
% %mean bar for trialType
% i(2,1).stat_summary('type','sem','geom',{'bar', 'black_errorbar'});
% 
% i(2,1).set_line_options('base_size',2)
% 
% i(2,1).set_color_options('lightness', 60)
% 
% i.draw();
% 
% 
% %-- Subplotting requires single draw call then single update call, Update:
% 
% %define variables to plot and grouping 
% %ind subjects
% i(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'lightness', data.subject);
% 
% 
% %define stats to show
% % Mean line for individual subj w/o SEM
% i(1,1).stat_summary('type','sem','geom','line'); %mean line only
% 
% i(1,1).set_color_options('lightness_range', [20,20])
% 
% i(1,1).set_line_options('base_size',0.5)
% 
% %define labels for plot axes
% i(1,1).set_names('x','time from event (s)','y','z-score','color','trialType','lightness','subject');
% i(1,1).set_title('Peri-Cue');
% 
% %set y axes limits manually
% i(1,1).axe_property('YLim',[-2,5]);
% 
% %ind subjects
% i(2,1).update('x',data2.trialType,'y',data2.periCueBlueAuc, 'color', data2.trialType, 'lightness', data2.subject);
% 
% 
% %define stats to show
% % Mean point for ind subjects
% i(2,1).stat_summary('type','sem','geom','line'); %mean line only
% 
% i(2,1).set_color_options('lightness_range', [20,20])
% 
% i(2,1).set_line_options('base_size',0.5)
% 
% %define labels for plot axes
% i(2,1).set_names('x','time from event (s)','y','AUC (of z-score)','color','trialType','lightness','subject');
% i(2,1).set_title('Peri-Cue: AUC');
% 
% %set y axes limits manually
% i(2,1).axe_property('YLim',[-1,5]);
% 
% %draw the actual plot
% i.draw();
% 
% title= strcat(subjMode, '_figure2-allSubj-periCue');
% 
% % saveFig(gcf, figPath, title, figFormats);


%% Stat comparison of auc conditions
stagesToPlot= [5];
%TODO: restrict analysis to subset data based on criteria/session

%---- i(1) pericue z trace
%subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%transform to have trialType variable
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');

%run anova
% [p, tableAnova, stats, terms]= anovan(data.periCueBlue, {data.trialType, data.subject});

[p, tableAnova, stats, terms]= anovan(data.periCueBlue, {data.trialType});


%% individual subj all stages: peri-Cue vs peri-Pox vs peri-Lox

for subj= 1:numel(subjects)
    clear i;
    figure();
    %subset data
    data=[];
    data= periEventTable(strcmp(periEventTable.subject, subjects{subj})==1,:);
    
    %transform to have eventType variable
    %ideally want to melt() from wide to long 3 eventTypes into single col
    %matlab lacks good tidying functions like melt() but we have stack
    %which is quite helpful!
    data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
    
%     %keep track of a new variable for eventType color
%     %doing this just so I don't have to manipulate orignal dataframe
%     %just make 3 columns and subset separately to map color for each
%     eventType= cell(size(data,1),3); %3 events, 1 type per observation
%     eventType(:,1)= {'DS'};
%     eventType(:,2)= {'PE DS'};
%     eventType(:,3)= {'Lick DS'};
    
    %define variables to plot and grouping 
%     figure();
%     i=gramm('x',data.timeLock,'y',data.DSblue, 'color', 'eventType');
    i=gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType);

    %facet by stage
    i.facet_wrap(data.stage);

    %means
    i.stat_summary('type','sem','geom','area');
    i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
    
    %label and draw
    i.axe_property('YLim',[-5, 10]);
    i.set_names('x','time from event (s)','y','z-score','color','eventType', 'column', 'stage');
    i.set_title(strcat(subjects{subj},'peri-event-allStages'));

    i.draw();

    title= strcat(subjMode,'-subject-', subjects{subj},'-periEvent-allStages');

    saveFig(gcf, figPath, title, figFormats);

end
    
 
    %--old
    
%     i.set_color_options('map','brewer1'); %hacky way to get one color per dataset plotted w/o different column, use 3 distinct maps

%     %periDS pox
% %     i.update('x',data.timeLock,'y',data.DSbluePox);
%     i.stat_summary('type','sem','geom','area'); 
% %     i.set_color_options('map','brewer_dark');
%     i.draw()
% 
%     %periDS lox
%     i.update('x',data.timeLock,'y',data.DSblueLox);
%     i.stat_summary('type','sem','geom','area'); 
%     
%     %label and draw
% %     i.set_color_options('map','matlab');
% 
%     i.set_names('x','Time from Initial Event(sec)','y','GCaMP (z-score)');
% %     i.set_names('color', {'DS','Port Entry DS','Lick DS'});
% 

%     i.draw();


    
% 
%     i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);
%     i(1,1).stat_summary('type','sem','geom','area');
%     i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(1,1).set_title('Peri-DS');
% 
% 
%     i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
%     i(2,1).stat_summary('type','sem','geom','area');
%     i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(2,1).set_title('Peri-First PE DS');
% 
%     i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
%     i(3,1).stat_summary('type','sem','geom','area');
%     i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(3,1).set_title('Peri-First Lick DS');
% 
%     i.axe_property('YLim',[-1,4]);
%     i.set_title('stage 7');

%     i.draw();


% 
%     title= strcat(subjMode,'-subject-', subjects{subj},'-periEvent-allStages');
% 
%     saveFig(gcf, figPath, title, figFormats);
% 
% end


%% --PLOT 465 vs 405 mean peri event for each subj


for subj= 1:numel(subjects)
    clear i;
    figure();
    %subset data
    data=[];
    data= periEventTable(strcmp(periEventTable.subject, subjects{subj})==1,:);
    
    %test subset
%     data= data(data.stage==stagesToPlot,:);
    
    %transform to have eventType variable
    %ideally want to melt() from wide to long 3 eventTypes into single col
    %matlab lacks good tidying functions like melt() but we have stack
    %which is quite helpful!
    data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventTypeBlue', 'NewDataVariableName', 'periEventBlue');
    
    %- stack again for 405nm
    data= stack(data, {'DSpurple', 'DSpurplePox', 'DSpurpleLox'}, 'IndexVariableName', 'eventTypePurple', 'NewDataVariableName', 'periEventPurple');

%     %keep track of a new variable for eventType color
%     %doing this just so I don't have to manipulate orignal dataframe
%     %just make 3 columns and subset separately to map color for each
%     eventType= cell(size(data,1),3); %3 events, 1 type per observation
%     eventType(:,1)= {'DS'};
%     eventType(:,2)= {'PE DS'};
%     eventType(:,3)= {'Lick DS'};
    
    %define variables to plot and grouping 
%     figure();   

    %--individual session means
    i=gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventTypeBlue, 'group', data.fileID);
    
    %facet by stage
    i.facet_wrap(data.stage);

    i.stat_summary('type','sem','geom','line');

    i().set_line_options('base_size',linewidthSubj)
    
    i.draw();

    %--subj means
    i.update('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventTypeBlue, 'group', []);

%     %facet by stage
%     i.facet_wrap(data.stage);

%     %facet by stage & eventType
%     i.facet_wrap(data.stage);


    i.stat_summary('type','sem','geom','area');
    i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
    
    i().set_line_options('base_size',linewidthGrand);

    
    %label and draw
%     i.axe_property('YLim',[-5, 10]);
    i.set_names('x','time from event (s)','y','z-score','color','eventTypeBlue', 'column', 'stage');
    i.set_title(strcat(subjects{subj},'peri-event-allStages'));

    i.draw();
    
    %---- draw 405 purple session means
    i.update('x',data.timeLock,'y',data.periEventPurple, 'color', data.eventTypePurple, 'group', data.fileID);
    
    i.stat_summary('type','sem','geom','line');

    i.set_color_options('map','brewer2'); %subselecting the 2 specific color levels i want from map

    i().set_line_options('base_size',linewidthSubj)
    
    i.draw();
    
    %--- draw 405 purple grand means
    i.update('x',data.timeLock,'y',data.periEventPurple, 'color', data.eventTypePurple, 'group', []);

    title= strcat(subjMode,'-subject-', subjects{subj},'-periEvent-bothSignals-allStages');
    i.set_names('x','time from event (s)','y','z-score','color','eventTypePurple', 'column', 'stage');
    
    i.set_color_options('map','brewer2'); %subselecting the 2 specific color levels i want from map

    i.stat_summary('type','sem','geom','area');

    i.draw();
    saveFig(gcf, figPath, title, figFormats);

end

%% Figure3 variant stage=7 for opto grc poster 

%try diff maps
map= 'brewer2'

   %--- new
        %subset data
    data=[];
    data= periEventTable;
    
    stagesToPlot= 7%
    ind=[];
    ind= ismember(data.stage,stagesToPlot);

    data= data(ind,:);
    
    %transform to have eventType variable
    %ideally want to melt() from wide to long 3 eventTypes into single col
    %matlab lacks good tidying functions like melt() but we have stack
    %which is quite helpful!
    data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
    
    clear i; figure()
    % individual subjects means
    i= gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'group', data.subject);

%     i= i.facet_grid([],data.sesSpecialLabel);
%     i= i.facet_grid(data.eventType,data.sesSpecialLabel);
%     i= i.facet_grid(data.eventType,data.stage);
%     i= i.facet_grid([],data.stage);
%     i= i.facet_grid([],data.eventType);


    i().stat_summary('type','sem','geom','line');
    i().geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

%     i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
    i().set_color_options('map',map); 


    i().set_line_options('base_size',linewidthSubj);
    i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Event type (ind subj mean)');

    i.draw();

    %mean between subj + sem
    i().update('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'group',[]);

    i().stat_summary('type','sem','geom','area');

%     i().set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
    i().set_color_options('map',map); 

    i().set_line_options('base_size',linewidthGrand)

    i().axe_property('YLim',[-1,5]);
    i().axe_property('XLim',[-5,10]);

    title= strcat(subjMode,'Figure3-allSubjects-stage-',num2str(stagesToPlot),'-Figure3-periEvent-allEvents');   
    % i().set_title(title);    
    i().set_names('x','time from event (s)','y','GCaMP (z score)','color','Event type (grand mean)');

    i.draw()
    saveFig(gcf, figPath, title, figFormats);

%% Figure3 eventType plot???
   %--- new
        %subset data
    data=[];
    data= periEventTable;
    
    ind=[];
    ind= ~cellfun(@isempty, data.sesSpecialLabel);

    data= data(ind,:);
    
    %transform to have eventType variable
    %ideally want to melt() from wide to long 3 eventTypes into single col
    %matlab lacks good tidying functions like melt() but we have stack
    %which is quite helpful!
    data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
    
    clear i; figure()
    % individual subjects means
    i= gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'group', data.subject);

    i= i.facet_grid([],data.sesSpecialLabel);
%     i= i.facet_grid(data.eventType,data.sesSpecialLabel);
%     i= i.facet_grid(data.eventType,data.stage);
%     i= i.facet_grid([],data.stage);


    i().stat_summary('type','sem','geom','line');
    i().geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

%     i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

    i().set_line_options('base_size',linewidthSubj);
    i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Event type (ind subj mean)');

    i.draw();

    %mean between subj + sem
    i().update('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType, 'group',[]);

    i().stat_summary('type','sem','geom','area');

%     i().set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

    i().set_line_options('base_size',linewidthGrand)

    i().axe_property('YLim',[-1,5]);
    i().axe_property('XLim',[-5,10]);

    title= strcat(subjMode,'Figure3-allSubjects-specialSesLabel','-Figure3-periEvent-bothSignals-allStages');   
    % i().set_title(title);    
    i().set_names('x','time from event (s)','y','GCaMP (z score)','color','Event type (grand mean)');

    i.draw()
    saveFig(gcf, figPath, title, figFormats);


%% Close examination of sessions prior to encoding model

stagesToPlot= [7];

%subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

for subj= 1:numel(subjects)
    
    data2= data(strcmp(data.subject, subjects{subj})==1,:);

    %transform to have trialType variable
    data2= stack(data2, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');


    %mean between sessions
    i= gramm('x',data2.timeLock,'y',data2.periCueBlue, 'color', data2.trialType);

    i.facet_wrap(data2.stage);

    i.stat_summary('type','sem','geom','area');

    i().set_line_options('base_size',2)

    i().set_color_options('lightness', 60)

    i.draw();

    %define variables to plot and grouping 
    %ind sessions
    i.update('x',data2.timeLock,'y',data2.periCueBlue, 'color', data2.trialType, 'lightness', data2.date);
    % i=gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType);


    %define stats to show
    % Mean line for individual ses w/o SEM
    % i.stat_summary('type','sem','geom','area'); %mean + sem shade
    i.stat_summary('type','sem','geom','line'); %mean line only?

    %TODO: i think ind subjects x trialtype may require separate, sequential
    %subplotting? ideally low alpha idk how to do this with gramm without
    %manually calculating mean

    %just do in illustrator later!

    % i().set_color_options('chroma',0,'lightness',30); % define color for ind subjs

    %color_options : Lower chroma = darker, lower lightness= darker
    %lightness 0:100 (white) , color range unclear, beyond 255 possible
    %chroma 10, lightness 90 = very dull, kinda similar to a low alpha?
    %chroma 40, lightness 90/60 good

    % The values are Hue (defines the color, [0-360]), Chroma (defines the colorness; restricted to [0-100] here) and Luminance (defines the brightness, [0-100]). 

    % i().set_color_options('chroma', 40, 'lightness',60); % define color for ind subjs

    % flat range of lightness? still has some variability. Just tune later in
    % illustrator
%     i().set_color_options('lightness_range', [20,20])

    i().set_line_options('base_size',0.5)

    %define labels for plot axes
    i.set_names('x','time from event (s)','y','z-score','color','trialType','lightness','date');
    i.set_title('Peri-Cue');

    %set y axes limits manually
    i.axe_property('YLim',[-2,5]);

    %draw the actual plot
    i.draw();

    % 
    % i.update('x',data.timeLock,'y',data.NSblue);
    % i.stat_summary('type','sem','geom','area');
    % i.draw();

    title= strcat(subjMode,'-subject-', subjects{subj},'-periDSvsNS-stagesToPlot-allSess');

    saveFig(gcf, figPath, title, figFormats);

    
end


%% Plotting specific subj to compare with kernels
% figure();
% 
% clear i
% %subset data
% data= periEventTable(periEventTable.stage==7,:);
% data= data(strcmp(data.subject,'rat8')==1,:);
% 
% 
% i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);
% i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(1,1).set_title('Peri-DS');
% 
% 
% i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(2,1).set_title('Peri-First PE DS');
% 
% i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
% i(3,1).stat_summary('type','sem','geom','area');
% i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(3,1).set_title('Peri-First Lick DS');
% 
% i.axe_property('YLim',[-1,4]);
% i.set_title('stage 7');
% 
% i.draw();
% 
% saveFig(gcf, figPath, 'rat8-periEvent-stage7', figFormats)

%% TODO: Plot ALL Sessions 

% 
% 
% for subj= 1:numel(subjects)
%     clear i;
%     figure();
%     %subset data
%     data=[];
%     data= periEventTable(strcmp(periEventTable.subject, subjects{subj})==1,:);
%     
%     %transform to have eventType variable
%     %ideally want to melt() from wide to long 3 eventTypes into single col
%     %matlab lacks good tidying functions like melt() but we have stack
%     %which is quite helpful!
%    
% %     data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
%     
% 
%     i=gramm('x',data.timeLock,'y',data.DSblue, 'color', data.DStrialID);
% 
%     
%     %facet by stage
%     i.facet_wrap(data.stage);
% 
%     %means
%     i.stat_summary('type','sem','geom','area');
%     i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
%     
%     %label and draw
%     i.axe_property('YLim',[-5, 10]);
%     i.set_names('x','time from event (s)','y','z-score','color','eventType', 'column', 'stage');
%     i.set_title(strcat(subjects{subj},'peri-event-allStages'));
% 
%     i.draw();
% 
%     
%     
% end
