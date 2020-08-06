%% Save the analyzed data 
%save the subjDataAnalyzed struct for later analysis
structpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\FP_analysis\FP-analysis\matlabVPFP\broken up code\'
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

%% Save variables to input into Parker encoding model

% Here, only data from the day each animal reached criteria will be saved
% to the data to input 

encodinginputpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\FP_analysis\FP-analysis\Parker encoding model\Richard_data_to_input\';

subj=[];
session=[];
data_to_input_GADVPFP=struct(); 
   

for subj=1:numel(subjects);
    fieldname=string(subjects(subj));
    x=0;
    for session = 1:numel(subjData.(subjects{subj}));
       if subjData.(subjectsAnalyzed{subj})(session).box == 1
           if subjData.(subjects{subj})(session).Acriteria==1  %if the animal reached criteria, add this data to the struct
            x=1;
            
           %cutTime for moving z-score
           cutTime=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
            
           %DS data
           data_to_input_GADVPFP.output(1).DSTimes(:)=cutTime(subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:));
           data_to_input_GADVPFP.output(1).DSonsetindex(:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
           data_to_input_GADVPFP.output(1).DSpox(:)=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPox(:)';
           data_to_input_GADVPFP.output(1).DSlox(:)=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLox(:)';
           data_to_input_GADVPFP.output(1).DSPElatencey(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
           data_to_input_GADVPFP.output(1).inPortDS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
           data_to_input_GADVPFP.output(1).poxDS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
           
          %NS data- TODO: NSpox and NSlox cut off the nan's at the end of
          %the vectors, but nans exist at the end of the vectors shorter
          %than 30 to fill in the missing values to make the vector length
          %30
           data_to_input_GADVPFP.output(1).NSTimes(:)=cutTime(subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset(:));
           data_to_input_GADVPFP.output(1).NSonsetindex(:)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset(:);
           data_to_input_GADVPFP.output(1).NSpox(:)=subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox(:)';
           data_to_input_GADVPFP.output(1).NSlox(:)=subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox(:)';
           data_to_input_GADVPFP.output(1).NSPElatencey(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.NSpeLatency(:);
           data_to_input_GADVPFP.output(1).inPortNS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS;
           data_to_input_GADVPFP.output(1).poxNS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS;
           %g_camp_465
           data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
           
           %moving median g_camp_465
           data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
           
           %g_camp_405
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
           
           %moving median g_camp_405
           data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
           
           %sampling rate
           data_to_input_GADVPFP.g_output(1).samp_rate(:)= 40 % we down sample to 40 Hz for all subjects
           
           %cutTime for moving z-score
           data_to_input_GADVPFP.g_output(1).cutTime(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime;
           
           %fitted signal
           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
           
           %df/f signal
           data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df;
           end
       
       elseif subjData.(subjectsAnalyzed{subj})(session).box == 2
           if subjData.(subjects{subj})(session).Bcriteria==1  
           x=1;
           
           %cutTime for moving z-score
           cutTime=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
           
           %DS data
           data_to_input_GADVPFP.output(1).DSTimes(:)=cutTime(subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:));
           data_to_input_GADVPFP.output(1).DSonsetindex(:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
           data_to_input_GADVPFP.output(1).DSpox(:)=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPox(:)';
           data_to_input_GADVPFP.output(1).DSlox(:)=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLox(:)';
           data_to_input_GADVPFP.output(1).DSPElatencey(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
           data_to_input_GADVPFP.output(1).inPortDS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
           data_to_input_GADVPFP.output(1).poxDS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
          %NS data- TODO: NSpox and NSlox cut off the nan's at the end of
          %the vectors, but nans exist at the end of the vectors shorter
          %than 30 to fill in the missing values to make the vector length
          %30
           data_to_input_GADVPFP.output(1).NSTimes(:)=cutTime(subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset(:));
           data_to_input_GADVPFP.output(1).NSonsetindex(:)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSonset(:);
           data_to_input_GADVPFP.output(1).NSpox(:)=subjDataAnalyzed.(subjects{subj})(session).periNSpox.firstPox(:)';
           data_to_input_GADVPFP.output(1).NSlox(:)=subjDataAnalyzed.(subjects{subj})(session).periNSlox.firstLox(:)';
           data_to_input_GADVPFP.output(1).NSPElatencey(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.NSpeLatency(:);
           data_to_input_GADVPFP.output(1).inPortNS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortNS;
           data_to_input_GADVPFP.output(1).poxNS(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxNS;
           
           %g_camp_465
           data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
           
           %moving median g_camp_465
           data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
           
           %g_camp_405
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
           
           %moving median g_camp_405
           data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
           
           %sampling rate
            data_to_input_GADVPFP.g_output(1).samp_rate(:)= 40 % we down sample to 40 Hz for all subjects
            
           %cutTime for moving z-score
           data_to_input_GADVPFP.g_output(1).cutTime(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
           
           %fitted signal
           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
           
           %df/f signal
           data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df;
           
           
           
           end
       end
    end

 
if x==1
%save 
save(fullfile(encodinginputpath,strcat(experimentName,'_',fieldname,'_', 'data_to_input_GADVPFP')), 'data_to_input_GADVPFP');
end 

data_to_input_GADVPFP=struct();
end