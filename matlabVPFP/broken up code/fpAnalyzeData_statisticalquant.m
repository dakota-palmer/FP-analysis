%% ~~~Inferential stats~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% I think the data here will be parametric - at least in latter stages of
% training, there seem to be consistent cue responses 

% Since I'd like to see how the neural cue response changes with training, I would like to
% use n-way ANOVA to look at the main effect of cue, the main effect of session,
% and any interaction

%% ~~~Inferential stats (T-Test & Bar Graph)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% Plot data within the 0.5-1 sec time bin
% here I want to average the z-score of every trial in stage 5,6,7,8 within
% the time frame of 0.5 sec to 1 sec ( the time of which we presume a cue
% response is occurring) for  every animal.  Thus, every animal has one
% number representing it's average calciium activity during the cue.

% First collect data and place into a new structure for every animal and
% every trial

%find indices within timeLock that are between 0.5 and 1 seconds
[~,indexbin]=find(timeLock>=0.5 & timeLock<=1);
%transponse 
indexbin=indexbin';


%initialize
    binidDS=[];
    binidNS=[];
    bindaysDS =[]; 
    bindaysNS =[]; 
    binDSzSessionblueMean=[];
    binNSzSessionblueMean=[];
    binDSzSessionpurpleMean=[];
    binNSzSessionpurpleMean=[];
    bintimeLocktracesDS=[];
    bintimeLocktracesNS=[];
    binNSintroDS=[];
    binNSintroNS=[];
    binCriteriaStage5DS=[];
    binCriteriaStage5NS=[];


for subj= 1:numel(subjects)
  for day=1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj}));%for each subject except #8 (#8 is GFP so don't want to average it- need to work on this, have and exclusion variable)
    binrepid= repelem(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).rat,length(indexbin));
    bindays=subjDataAnalyzed.(subjectsAnalyzed{subj})(day).trainDay;
    bindays=repelem(bindays,length(indexbin))';
    binidDS=vertcat(binidDS,binrepid');
    bindaysDS=vertcat( bindaysDS,bindays);
    binDSzSessionblueMean= vertcat(binDSzSessionblueMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzblueMean(indexbin(1):indexbin(end)));
    binDSzSessionpurpleMean= vertcat(binDSzSessionpurpleMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periDS.DSzpurpleMean(indexbin(1):indexbin(end)));
    
     % for DS signal vector, find the days in which NS was introduced (NSintro=1) and repeat that one for the entire signal for that day for each rat 
    if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).NSAintro == 1)
                 binrepNSintroDS = repelem(1, length(indexbin));
             else
                 binrepNSintroDS = repelem(0, length(indexbin));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1)
                binrepNSintroDS = repelem(1, length(indexbin));
             else 
                binrepNSintroDS = repelem(0, length(indexbin));
             end     
    end
      binNSintroDS = vertcat(binNSintroDS, binrepNSintroDS'); 
    %find non zero days where Stage 5 criteria was met (criteria= 1)and
    %repeat that one for the entire calcium signal for that day for each
    %rat
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1)
                 binrepCriteriaStage5DS = repelem(1, length(indexbin));
             else
                 binrepCriteriaStage5DS = repelem(0, length(indexbin));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1)
                binrepCriteriaStage5DS = repelem(1, length(indexbin));
             else 
                binrepCriteriaStage5DS = repelem(0, length(indexbin));
             end
             
       end
     binCriteriaStage5DS = vertcat(binCriteriaStage5DS, binrepCriteriaStage5DS');
     
 %NS has different length vector, so need distinct variables for NS   
    if ~isnan(subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzblueMean);
         bindaysNS=vertcat(bindaysNS,bindays);
         bintimeLocktracesNS= vertcat(bintimeLocktracesNS,indexbin');
         binidNS=vertcat(binidNS,binrepid');
         binNSzSessionblueMean= vertcat(binNSzSessionblueMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzblueMean(indexbin(1):indexbin(end)));
         binNSzSessionpurpleMean= vertcat(binNSzSessionpurpleMean,subjDataAnalyzed.(subjectsAnalyzed{subj})(day).periNS.NSzpurpleMean(indexbin(1):indexbin(end)));
          % find the non zero indicies in NSitroduced column 
         if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).NSAintro == 1)
                 binrepNSintroNS = repelem(1, length(indexbin));
             else
                 binrepNSintroNS = repelem(0, length(indexbin));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).NSBintro == 1)
                binrepNSintroNS = repelem(1, length(indexbin));
             else 
                binrepNSintroNS = repelem(0, length(indexbin));
             end
              
         end  
       binNSintroNS = vertcat(binNSintroNS, binrepNSintroNS'); 
        %find non zero days where criteria was met (Stage 5)
       if subjData.(subjectsAnalyzed{subj})(day).box == 1
             if (subjData.(subjectsAnalyzed{subj})(day).Acriteria == 1)
                 binrepCriteriaStage5NS = repelem(1, length(indexbin));
             else
                 binrepCriteriaStage5NS = repelem(0, length(indexbin));
             end
         elseif subjData.(subjectsAnalyzed{subj})(day).box==2
             if (subjData.(subjectsAnalyzed{subj})(day).Bcriteria== 1)
                binrepCriteriaStage5NS = repelem(1, length(indexbin));
             else 
                binrepCriteriaStage5NS = repelem(0, length(indexbin));
             end
             
       end
         binCriteriaStage5NS = vertcat(binCriteriaStage5NS, binrepCriteriaStage5NS'); 
    end % end loop specific to NS 
         
    
    end
end



%cue type
cuetypeblueDS=repelem({'DS'},length(binDSzSessionblueMean))';
cuetypeblueNS=repelem({'NS'},length(binNSzSessionblueMean))';
cuetypepurpleDS=repelem({'DS'},length(binDSzSessionpurpleMean))';
cuetypepurpleNS=repelem({'NS'},length(binNSzSessionpurpleMean))';
signaltypeblueDS=repelem({'465'},length(binDSzSessionblueMean))';
signaltypeblueNS=repelem({'465'},length(binNSzSessionblueMean))';
signaltypepurpleDS=repelem({'405'},length(binDSzSessionblueMean))';
signaltypepurpleNS=repelem({'405'},length(binNSzSessionblueMean))';
% combine DS and NS vectors to more easily plot data in @gramm
bincuetypeblue=vertcat(cuetypeblueDS,cuetypeblueNS);
bincuetypepurple=vertcat(cuetypepurpleDS,cuetypepurpleNS);
binzblueall=vertcat(binDSzSessionblueMean,binNSzSessionblueMean);
binzpurpleall=vertcat(binDSzSessionpurpleMean,binNSzSessionpurpleMean);
binidall=vertcat(binidDS,binidNS);
bindaysall=vertcat(bindaysDS,bindaysNS);
bincriteriastage5allblue=vertcat(binCriteriaStage5DS,binCriteriaStage5NS);
bincriteriastage5allpurple=vertcat(binCriteriaStage5DS,binCriteriaStage5NS);
binNSintroall=vertcat(binNSintroDS,binNSintroNS);
binsignaltypeblueall=vertcat(signaltypeblueDS,signaltypeblueNS);
binsignaltypepurpleall=vertcat(signaltypepurpleDS,signaltypepurpleNS);

binzall=vertcat(binzblueall,binzpurpleall);
binsignalall=vertcat(binsignaltypeblueall,binsignaltypepurpleall);
bincuetypeall=vertcat(bincuetypeblue,bincuetypepurple);
bincriteriastage5allLED=[];
binidallLED=[];
DScriteria=repmat(binCriteriaStage5DS,2,1);
NScriteria=repmat(binCriteriaStage5NS,2,1);


bincriteriastage5allLED=vertcat(bincriteriastage5allblue,bincriteriastage5allpurple);
binidallLED=repmat(binidall,2,1);





%Overlay bar plotaverage for cue type across all
   %animals and  scatter of each animal mean z-score in 0.5sec to 1 sec
   %time bin
  
   
   
figureCount= figureCount+1; %iterate the figure count   
figure();   
   b=gramm('x',binsignalall,'y', binzall,'color',bincuetypeall,'subset',bincriteriastage5allLED==1);
   b.stat_summary('type','sem','geom',{'bar','black_errorbar'});
   b.set_names('x','Cue Type','y','Mean Z-Score')
   b.set_title(' Average 465 nm Z Score-Citeria')
   b.axe_property('YLim',[0 2])
   b.set_color_options('map','brewer_pastel')
b.draw()


   b.update('x',binsignalall,'y', binzall,'color',binidallLED,'subset',bincriteriastage5allLED==1);
   b.stat_summary('type','sem','geom','point');
   b.set_names('x','Cue Type','y','Mean Z-Score')
   b.set_title(' Average 405 nm Z Score-Citeria')
   b.axe_property('YLim',[-2 3])
   b.set_color_options('map','pm')
b.draw()
%  figure();   
%    c=gramm('x',binsignaltypeblueall,'y', binzblueall,'color',bincuetypeblue,'subset',bincriteriastage5all==1);
%    c.stat_summary('type','sem','geom',{'bar','black_errorbar'});
%    c.set_names('x','Cue Type','y','Mean Z-Score')
%    c.set_title(' Average465 nm Z Score-Citeria')
%    c.axe_property('YLim',[-2 3])
%    c.set_color_options('map','brewer_dark')
% c.draw()   
% % 
%    b(1,1).update('x',binsignaltypepurpleall,'y', binzpurpleall,'color',binidall,'subset',bincriteriastage5all==1);
%    b(1,1).stat_summary('type','sem','geom','point');
%    b(1,1).set_names('x','Cue Type','y','Mean Z-Score')
%    b(1,1).set_title(' Average 405 nm Z Score-Citeria')
%    b(1,1).axe_property('YLim',[-2 3])
%    b(1,1).set_color_options('map','brewer_dark')
%    b.draw()

%    %make figure full screen, save, and close this figure
% set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% saveas(gcf, strcat(figPath,'AvgzscoreBAR_SEM'),'fig');
% %         close; %close

%% Gather data for Repeated Measures ANOVA and GLMM on 465nm DS and NS vs. 405nm DS and NS on day meet criteria

%find the z scores in the binned data that are from the day the animals
%meet criteria
[criteriaindexblue,~]=find(bincriteriastage5allblue==1);
[criteriaindexpurple,~]=find(bincriteriastage5allpurple==1);

% % want a colum in matrix that has strings
% bincuetypeblue=cell2mat(bincuetypeblue);
% bincuetypepurple=cell2mat(bincuetypepurple);


anovacell={binzblueall(criteriaindexblue) binzpurpleall(criteriaindexpurple) binidall(criteriaindexblue) bincuetypeblue(criteriaindexblue) bincuetypepurple(criteriaindexpurple) };

%need to average z-score signal for each animal

rat=unique(anovacell{3});
anovamatrix=[];


%get every animals mean for all responses for anova

%DS loop
for ratid=1:length(rat)
idindex=find(anovacell{3}==rat(ratid));% finding the index of the  DS signal in anova cell
DSidindex=contains(anovacell{4}(idindex),'DS');
DSidindex=idindex(DSidindex);
anovamatrix(ratid,1)=mean(anovacell{1}(DSidindex));%mean DS blue signal
anovamatrix(ratid,2)=mean(anovacell{2}(DSidindex));%mean DS purple signal

end
%NS loop
for ratid=1:length(rat)
idindex=find(anovacell{3}==rat(ratid));% finding the index of the  DS signal in anova cell
NSidindex=contains(anovacell{4}(idindex),'NS');
NSidindex=idindex(NSidindex);
anovamatrix(1+length(anovamatrix(:,1)),1)=mean(anovacell{1}(NSidindex));%mean NS blue signal
anovamatrix(length(anovamatrix(:,2)),2)=mean(anovacell{2}(NSidindex));%mean NS purple signal
end

%get every animals mean for all responses for repeated measures anova
rmanovamatrix=[];
%DS loop
for ratid=1:length(rat)
idindex=find(anovacell{3}==rat(ratid));% finding the index of the  DS signal in anova cell
DSidindex=contains(anovacell{4}(idindex),'DS');
DSidindex=idindex(DSidindex);
rmanovamatrix(1,ratid)=mean(anovacell{1}(DSidindex));%mean DS blue signal
rmanovamatrix(2,ratid)=mean(anovacell{2}(DSidindex));%mean DS purple signal

end
%NS loop
for ratid=1:length(rat)
idindex=find(anovacell{3}==rat(ratid));% finding the index of the  DS signal in anova cell
NSidindex=contains(anovacell{4}(idindex),'NS');
NSidindex=idindex(NSidindex);
rmanovamatrix(3,ratid)=mean(anovacell{1}(NSidindex));%mean NS blue signal
rmanovamatrix(4,ratid)=mean(anovacell{2}(NSidindex));%mean NS purple signal
end


%% Repeated Measures ANOVA

for r=1:size(rmanovamatrix,2)
rmresponsematrix(r,:)=rmanovamatrix(:,r)';%rat "r" four responses
end

rmcuetypeDS=repelem({'D'},size(rmanovamatrix,1)*0.5)';
rmcuetypeNS=repelem({'N'},size(rmanovamatrix,1)*0.5)';
rmcue_type=vertcat(rmcuetypeDS,rmcuetypeNS);
rmblueLED=repelem('B',size(rmanovamatrix,1)*.25)';
rmpurpleLED=repelem('P',size(rmanovamatrix,1)*.25)';
rmLED_type=vertcat(rmblueLED,rmpurpleLED,rmblueLED,rmpurpleLED);

% get responses for each rat (rows) for each group(CueType+LEDType)
rmanovaresponses=table();
rmanovaresponses=array2table(rmresponsematrix,'VariableNames',{'y1','y2','y3','y4'});


% Convert factors to categorical.
rmfactors={'rmcue_type','rmLED_type'};
within=table();
within = table(cellstr(rmcue_type),cellstr(rmLED_type),'VariableNames',rmfactors);
within.rmcue_type = categorical(within.rmcue_type);
within.rmLED_type = categorical(within.rmLED_type);


% Create a formula for fitrm() funtion
rmanovaformula='y1-y4~1';

% fit a repeated measures model to data
rm = fitrm(rmanovaresponses, rmanovaformula, 'WithinDesign', within);

% run a repeated measures anova, indicating wich terms interact within the
% model
[rmanovatbl]=ranova(rm,'WithinModel','rmcue_type*rmLED_type');


%% GLMM(general linear mixed models)

%glmm data must be organized in a table with both response, fixed and random
%variables in colums

%creat components of glmetable, recording 4 types of responses per animal,
%DSCueBlue,DSCuePruple, NSCueBlue and NSCuePurple
rat_ID=repmat(rat,4,1);
cuetypeDS=repelem({'D'},(length(rat_ID))*.5)';
cuetypeNS=repelem({'N'},(length(rat_ID))*.5)';
cue_type=vertcat(cuetypeDS,cuetypeNS);
DSblueLED=repelem('B',(length(rat_ID)*.25))';
DSpurpleLED=repelem('P',(length(rat_ID)*.25))';
NSblueLED=repelem('B',(length(rat_ID)*.25))';
NSpurpleLED=repelem('P',(length(rat_ID)*.25))';
LED_type=vertcat(DSblueLED,DSpurpleLED,NSblueLED,NSpurpleLED);
DSz_blue_response=anovamatrix(1:length(unique(rat)),1);
DSz_purple_response=anovamatrix(length(unique(rat))+1:end,1);
NSz_blue_response=anovamatrix(1:length(unique(rat)),2);
NSz_purple_response=anovamatrix(length(unique(rat))+1:end,2);
Z_response=vertcat(DSz_blue_response,DSz_purple_response,NSz_blue_response,NSz_purple_response);


glmetable=table(rat_ID,cue_type,LED_type,Z_response);
glmeformula='Z_response~1+cue_type*LED_type+(1|rat_ID)';
glme=fitglme(glmetable,glmeformula);
save('GLMM_results.mat','glme');

%% LME
%can more easily adjust covariate structure with fitlme() function so may
%just use this for the rest of data analysis.  Inputs are the same and
%fitglme().

lmetable=glmetable;
lmeformula='Z_response~1+cue_type*LED_type+(1|rat_ID)';
lme=fitlme(lmetable,lmeformula);
save('LME_results.mat','lme');

%% Plot GLMM
observedZvalues=[];
modelZvalues = [];
cueZtype=[];
ratIDZtype=[];
LEDZtype=[];
observedZvalues=glmetable.Z_response;
modelZvalues = fitted(glme);% fitted() function calculates the model estimated responses based on the coefficients the glmefit() function outputs
cueZtype=cell2mat(glmetable.cue_type);
ratIDZtype=glmetable.rat_ID;
LEDZtype=glmetable.LED_type;

%Observed vs. Fitted Values(from model)
%nice to check if more or less a linear relationship
figure(figureCount)
g=gramm('x',observedZvalues,'y',modelZvalues);
g.geom_point();
g.set_title('Observed Values vs. Fitted Values')
g.set_names('x','Fitted Values','y','Observed Values');
g.draw()

%save
g.export('file_name','GLMM_Scatter','export_path',figPath,'file_type','pdf')
figureCount=figureCount+1;

%Want to plot the Observed and Fitted Data by Groups
%Groups: DS+Blue, DS+Purple, NS+Blue, NS+Purple ( the four measures
%recorded for each animal)
%Will plot groups as bar graphs, and observed data as scatter plots, with
%lines connecting the specific rat values from observed data across groups

%use coefficients to calculate 4 response values

yDSBlue=glme.Coefficients(1,2).Estimate; % the intercept is the DSBlue estimated response
yDSPurple=yDSBlue+ glme.Coefficients(3,2).Estimate;% the intercept + the "P" coefficient is the DSPurple estimated response
yNSBlue=yDSBlue+glme.Coefficients(2,2).Estimate;%the intercept + the "N" coefficient is the NSBlue estimated response
yNSPurple=yDSBlue+ glme.Coefficients(2,2).Estimate+glme.Coefficients(3,2).Estimate+glme.Coefficients(4,2).Estimate;%the intercept +the "P" coefficient is the DSPurple estimated response+ the "N" coefficient is the NSPurple estimated response

glmeyaxis=[yDSBlue,yDSPurple,yNSBlue,yNSPurple]';

xDSBlue='DSBlue';
xDSPurple='DSPurple';
xNSBlue='NSBlue';
xNSPurple='NSPurple';

DSBluegroup=repelem({'DSBlue'},(length(rat_ID)*.25))';
DSPurplegroup=repelem({'DSPurple'},(length(rat_ID)*.25))';
NSBluegroup=repelem({'NSBlue'},(length(rat_ID)*.25))';
NSPurplegroup=repelem({'NSPurple'},(length(rat_ID)*.25))';

xaxisgroup=vertcat(DSBluegroup,DSPurplegroup,NSBluegroup,NSPurplegroup);


glmexaxis={xDSBlue;xDSPurple;xNSBlue;xNSPurple};

figure(figureCount)
g=gramm('x',glmexaxis,'y',glmeyaxis);
g.geom_bar();
g.set_title('Fitted Values(Bar) and Observed Values(Scatter)')
g.set_names('x','Response Type','y','Z Response');
g.draw();

g.update('x',xaxisgroup,'y',observedZvalues,'color',ratIDZtype);
g.geom_point();
g.set_title('Fitted Values and Observed Values')
g.set_names('x','Response Type','y','Z Response','color','ratID');
g.set_color_options('map','pm')
g.draw();

g.update('x',xaxisgroup,'y',observedZvalues,'color',ratIDZtype);
g.geom_line();
g.set_names('x','Response Type','y','Z Response');
g.set_layout_options('legend',false)
g.set_color_options('map','pm')
g.draw();

g.export('file_name','GLMM_Bar_Scatter','export_path',figPath,'file_type','pdf');

