%% Save the analyzed data 
%save the subjDataAnalyzed struct for later analysis
structpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\FP-analysis\matlabVPFP\broken up code\'
save(fullfile(structpath,strcat(experimentName,'-', 'subjDataAnalyzed')), 'subjDataAnalyzed'); %the second argument here is the variable being saved, the first is the filename

%% save data from each stage from each animal for ERT analysis
ERTpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\PhotometryEventDetection\ERTsimulation-master\ERTsimulation-master\'
ERTData=struct();
subj=[];
session=[];
Stage=[];
Stagestring=[];
for subj=1:numel(subjects);
   for session = 1:numel(subjData.(subjects{subj}));
       Stagestring=string((subjDataAnalyzed.(subjects{subj})(session).trainStage));
       Stage=(subjDataAnalyzed.(subjects{subj})(session).trainStage);
       
   for trial=1:size(subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue,3)
        
       ERTData.(strcat('DSzblueStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblue(:,:,trial)';
       ERTData.(strcat('DSzpurpleStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurple(:,:,trial)';
       
       if ~isempty(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean)&& Stage>=5;
       ERTData.(strcat('NSzblueStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue(:,:,trial)';
       ERTData.(strcat('NSzpurpleStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple(:,:,trial)';
       end
    
       if Stage==8
       ERTData.DSzStage8pump(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(trial,:);
       ERTData.NSzStage8pump(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(trial,:);  
       end
   end %end trial loop
   
   %organize all data from last day of each stage into one matrix which is
   %how photometry event detection reads data
       %for DSz trials
        

     if Stage<=5 
       if subj==1
       ERTData.(strcat('DSzblueallStage',Stagestring))= ERTData.(strcat('DSzblueStage',Stagestring));
       ERTData.(strcat('DSzpurpleallStage',Stagestring))= ERTData.(strcat('DSzpurpleStage',Stagestring));
       else   
       ERTData.(strcat('DSzblueallStage',Stagestring))=vertcat(ERTData.(strcat('DSzblueallStage',Stagestring)),ERTData.(strcat('DSzblueStage',Stagestring))(:,:,subj));
       ERTData.(strcat('DSzpurpleallStage',Stagestring))=vertcat(ERTData.(strcat('DSzpurpleallStage',Stagestring)),ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj));
       end
     elseif Stage>5 
       if subj==3
       ERTData.(strcat('DSzblueallStage',Stagestring))= ERTData.(strcat('DSzblueStage',Stagestring))(:,:,subj);
       ERTData.(strcat('DSzpurpleallStage',Stagestring))= ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj);
       if Stage==8
       ERTData.DSzStage8pumpall= ERTData.DSzStage8pump(:,:,subj)
       end
       else   
       ERTData.(strcat('DSzblueallStage',Stagestring))=vertcat(ERTData.(strcat('DSzblueallStage',Stagestring)),ERTData.(strcat('DSzblueStage',Stagestring))(:,:,subj));
       ERTData.(strcat('DSzpurpleallStage',Stagestring))=vertcat(ERTData.(strcat('DSzpurpleallStage',Stagestring)),ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj));
       if Stage==8
       ERTData.DSzStage8pumpall=vertcat(ERTData.DSzStage8pumpall,ERTData.DSzStage8pump(:,:,subj));
       end
       end
     end
       

%        ERTData.(strcat('NSzblueallStage',Stage))= [];
%        ERTData.(strcat('NSzpurpleallStage',Stage))=[];
       
       %for NSz trials
      if ~isempty(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean)&& Stage>=5;
      
       if Stage<=5 
       if subj==1
       ERTData.(strcat('NSzblueallStage',Stagestring))= ERTData.(strcat('NSzblueStage',Stagestring));
       ERTData.(strcat('NSzpurpleallStage',Stagestring))= ERTData.(strcat('NSzpurpleStage',Stagestring));
       else   
       ERTData.(strcat('NSzblueallStage',Stagestring))=vertcat(ERTData.(strcat('NSzblueallStage',Stagestring)),ERTData.(strcat('NSzblueStage',Stagestring))(:,:,subj));
       ERTData.(strcat('NSzpurpleallStage',Stagestring))=vertcat(ERTData.(strcat('NSzpurpleallStage',Stagestring)),ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj));
       end
     elseif Stage>5 
       if subj==3
       ERTData.(strcat('NSzblueallStage',Stagestring))=[];
       ERTData.(strcat('NSzpurpleallStage',Stagestring))= [];    
       ERTData.(strcat('NSzblueallStage',Stagestring))= ERTData.(strcat('NSzblueStage',Stagestring))(:,:,subj);
       ERTData.(strcat('NSzpurpleallStage',Stagestring))= ERTData.(strcat('NSzpurpleStage',Stagestring))(:,:,subj);
       else   
       ERTData.(strcat('NSzblueallStage',Stagestring))=vertcat(ERTData.(strcat('NSzblueallStage',Stagestring)),ERTData.(strcat('NSzblueStage',Stagestring))(:,:,subj));
       ERTData.(strcat('NSzpurpleallStage',Stagestring))=vertcat(ERTData.(strcat('NSzpurpleallStage',Stagestring)),ERTData.(strcat('NSzpurpleStage',Stagestring))(:,:,subj));
       end
     end  
      end 
      
  
      
   end %end session loop
end %end subj loop

%seperate stage 8 trials into reward(pump1) and probe trials(pump2)
[pump1indrow]=find(ERTData.DSzStage8pumpall==1);
[pump2indrow]=find(ERTData.DSzStage8pumpall==2);

    %DSzblue
    ERTData.DSzblueStage8pump1=ERTData.DSzblueallStage8(pump1indrow,:);
    ERTData.DSzblueStage8pump2=ERTData.DSzblueallStage8(pump2indrow,:);
    %DSzpurple
    ERTData.DSzpurpleStage8pump1=ERTData.DSzpurpleallStage8(pump1indrow,:);
    ERTData.DSzpurpleStage8pump2=ERTData.DSzpurpleallStage8(pump2indrow,:);
     %NSzblue
    ERTData.NSzblueStage8pump1=ERTData.NSzblueallStage8(pump1indrow,:);
    ERTData.NSzblueStage8pump2=ERTData.NSzblueallStage8(pump2indrow,:);
    %NSzpurple
    ERTData.NSzpurpleStage8pump1=ERTData.NSzpurpleallStage8(pump1indrow,:);
    ERTData.NSzpurpleStage8pump2=ERTData.NSzpurpleallStage8(pump2indrow,:);
    
    

%establish x axis
ERTData.timeLock=timeLock;

%save 
save(fullfile(ERTpath,strcat(experimentName,'-', 'ERTData')), 'ERTData');
