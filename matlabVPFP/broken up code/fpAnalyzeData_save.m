%% Save the analyzed data 
%save the subjDataAnalyzed struct for later analysis
structpath='C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code'
save(fullfile(structpath,strcat(experimentName,'-', 'subjDataAnalyzed')), 'subjDataAnalyzed', '-v7.3'); %the second argument here is the variable being saved, the first is the filename %v7.3 for files >2gb


%% save data from each stage from each animal for ERT analysis
ERTpath='C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\ERT'
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
       
    
       if Stage==8
       ERTData.DSzStage8pump(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(trial,:);
       ERTData.NSzStage8pump(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(trial,:);  
       end
   end %end trial loop
   
   for trial = 1:size(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue,3) %repeat for NS
       if ~isempty(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean)&& Stage>=5;
           ERTData.(strcat('NSzblueStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblue(:,:,trial)';
           ERTData.(strcat('NSzpurpleStage',Stagestring))(trial,:,subj)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurple(:,:,trial)';
       end
   end %end ns trial loop
   
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
       if subj==1
       ERTData.(strcat('DSzblueallStage',Stagestring))= ERTData.(strcat('DSzblueStage',Stagestring))(:,:,subj);
       ERTData.(strcat('DSzpurpleallStage',Stagestring))= ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj);
       if Stage==8
       ERTData.DSzStage8pumpall= ERTData.DSzStage8pump(:,:,subj);
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
      if ~isempty(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean)&& Stage>=5
      
       if Stage<=5 
       if subj==1
       ERTData.(strcat('NSzblueallStage',Stagestring))= ERTData.(strcat('NSzblueStage',Stagestring));
       ERTData.(strcat('NSzpurpleallStage',Stagestring))= ERTData.(strcat('NSzpurpleStage',Stagestring));
       else   
       ERTData.(strcat('NSzblueallStage',Stagestring))=vertcat(ERTData.(strcat('NSzblueallStage',Stagestring)),ERTData.(strcat('NSzblueStage',Stagestring))(:,:,subj));
       ERTData.(strcat('NSzpurpleallStage',Stagestring))=vertcat(ERTData.(strcat('NSzpurpleallStage',Stagestring)),ERTData.(strcat('DSzpurpleStage',Stagestring))(:,:,subj));
       end
     elseif Stage>5 
       if subj==1
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

% Here, only data from the day each animal reached criteria,last day of stage 7 and 8 will be saved
% to the data to input 

encodinginputpath='C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\data to input';

subjects= fieldnames(subjData);
subj=[];
session=[];

data_to_input_GADVPFP=struct(); 
gcamp_raw=struct();   

for subj=1:numel(subjects)
    fieldname=string(subjects(subj));
    x=0;
    s1=0;
    cutTime_stage7={};
    DSonsetindex_stage7=[];
    DSpox_stage7={};
    DSlox_stage7={};
    DSPElatency_stage7={};
    inPortDS_stage7={};
    poxDS_stage7={};
           
    for session = 1:numel(subjData.(subjects{subj}))
       if subjData.(subjects{subj})(session).box == 1 || subjData.(subjects{subj})(session).box==3
           
     % STAGE 5
           
           if subjData.(subjects{subj})(session).Acriteria==1  %if the animal reached criteria, add this data to the struct
           
            x=1;%use for saving files and not saving subj files that do not meet criteria
            %g_camp_465
           gcamp_raw.blue_criteria=subjData.(subjects{subj})(session).reblue'; 
           gcamp_raw.blue_dayb4criteria=subjData.(subjects{subj})(session-1).reblue';
           gcamp_raw.blue_2dayb4criteria=subjData.(subjects{subj})(session-2).reblue'; 
          
           gcamp_raw_blue_cat=horzcat( gcamp_raw.blue_criteria,gcamp_raw.blue_dayb4criteria,gcamp_raw.blue_2dayb4criteria);
           % use this temp array to elongate the rest of the variables with
           % appropriate time stamps for the full concatenated signal
           temp_gcamp_raw_blue_dayb4criteria=horzcat(gcamp_raw.blue_criteria,gcamp_raw.blue_dayb4criteria);
           
            %g_camp_405
           gcamp_raw.purple_criteria(:)=subjData.(subjects{subj})(session).repurple'; 
           gcamp_raw.purple_dayb4criteria(:)=subjData.(subjects{subj})(session-1).repurple';
           gcamp_raw.purple_2dayb4criteria(:)=subjData.(subjects{subj})(session-2).repurple'; 

            gcamp_raw_purple_cat=horzcat( gcamp_raw.purple_criteria,gcamp_raw.purple_dayb4criteria,gcamp_raw.purple_2dayb4criteria);
           
           %cutTime for moving z-score
           cutTime_criteria=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
           cutTime_dayb4criteria=subjDataAnalyzed.(subjects{subj})(session-1).photometry.cutTime + length(gcamp_raw.blue_criteria(:)); 
           cutTime_2dayb4criteria=subjDataAnalyzed.(subjects{subj})(session-2).photometry.cutTime + length(temp_gcamp_raw_blue_dayb4criteria(:)); 
           
           cutTime_cat=horzcat(cutTime_criteria,cutTime_dayb4criteria,cutTime_2dayb4criteria);
           %DS Index
           DSonsetindex_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
           DSonsetindex_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDS.DSonset(:)+ length(gcamp_raw.blue_criteria(:));
           DSonsetindex_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDS.DSonset(:)+ length(temp_gcamp_raw_blue_dayb4criteria(:));
           
           DSonset_cat=horzcat( DSonsetindex_criteria, DSonsetindex_dayb4criteria,DSonsetindex_2dayb4criteria);
           %DS Times
           DSTimes_criteria(:)=cutTime_cat( DSonsetindex_criteria(:));
           DSTimes_dayb4criteria(:)=cutTime_cat(DSonsetindex_dayb4criteria(:));
           DSTimes_2dayb4criteria(:)=cutTime_cat(DSonsetindex_2dayb4criteria(:));
           
           DSTimes_cat=horzcat(DSTimes_criteria,DSTimes_dayb4criteria,DSTimes_2dayb4criteria);
           %DS Pox
           DSpox_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(:)';
           DSpox_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDSpox.firstPoxind(:)';
           DSpox_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDSpox.firstPoxind(:)';
           
           DSpox_cat=horzcat(DSpox_criteria,DSpox_dayb4criteria,DSpox_2dayb4criteria);
           %DS Lox
           DSlox_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(:)';
           DSlox_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDSlox.firstLoxind(:)';
           DSlox_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDSlox.firstLoxind(:)';
           
           DSlox_cat=horzcat(DSlox_criteria,DSlox_dayb4criteria,DSlox_2dayb4criteria);
           %DS latency
           DSPElatency_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
           DSPElatency_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.DSpeLatency(:);
           DSPElatency_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.DSpeLatency(:);

           DSPElatency_cat=horzcat(DSPElatency_criteria,DSPElatency_dayb4criteria,DSPElatency_2dayb4criteria);
           %inPortDS
           inPortDS_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
           inPortDS_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.inPortDS;
           inPortDS_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.inPortDS;
           
           inPortDS_cat=horzcat(inPortDS_criteria,inPortDS_dayb4criteria,inPortDS_2dayb4criteria);
           
           %poxDS
           poxDS_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
           poxDS_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.poxDS;
           poxDS_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.poxDS;
           
           poxDS_cat=horzcat(poxDS_criteria,poxDS_dayb4criteria,poxDS_2dayb4criteria);
           
           %DS criteria day data- save to struct
           data_to_input_GADVPFP.output(1).DSTimes_criteria(:)=DSTimes_criteria;
           data_to_input_GADVPFP.output(1).DSonsetindex_criteria(:)=DSonsetindex_criteria;
           data_to_input_GADVPFP.output(1).DSpoxind_criteria(:)=DSpox_criteria;
           data_to_input_GADVPFP.output(1).DSloxind_criteria(:)=DSlox_criteria;
           data_to_input_GADVPFP.output(1).DSPElatency_criteria(:)=DSPElatency_criteria;
           data_to_input_GADVPFP.output(1).inPortDS_criteria(:)=inPortDS_criteria;
           data_to_input_GADVPFP.output(1).poxDS_criteria(:)=poxDS_criteria;% all pox not just index of first pox
           
           %DS stage 5 data- 3 days concatenated- save to struct 
           data_to_input_GADVPFP.output(1).DSTimes_cat(:)=DSTimes_cat;
           data_to_input_GADVPFP.output(1).DSonsetindex_cat(:)=DSonset_cat;
           data_to_input_GADVPFP.output(1).DSpoxind_cat(:)=DSpox_cat;
           data_to_input_GADVPFP.output(1).DSloxind_cat(:)=DSlox_cat(:)';
           data_to_input_GADVPFP.output(1).DSPElatency_cat(:)=DSPElatency_cat;
           data_to_input_GADVPFP.output(1).inPortDS_cat(:)=inPortDS_cat;
           data_to_input_GADVPFP.output(1).poxDS_cat(:)= poxDS_cat;
           
           
%TODO: ADD NS DATA
%            %g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
%            
%            %moving median g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
%            
%            %g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
%            
%            %moving median g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
%                      %fitted signal
%           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
%            
%            %df/f signal
%            data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df; 
            
            % save g.ouput data to struct
            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)= gcamp_raw.blue_criteria;
           data_to_input_GADVPFP.g_output(1).gcamp_raw.blue_cat(:)= gcamp_raw_blue_cat;
           
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)= gcamp_raw.purple_criteria;
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple_cat(:)= gcamp_raw_purple_cat;

            %sampling rate
           data_to_input_GADVPFP.g_output(1).samp_rate(:)= 40; % we down sample to 40 Hz for all subjects
           
           %cutTime for moving z-score
           data_to_input_GADVPFP.g_output(1).cutTime_criteria(:)=cutTime_criteria;
           data_to_input_GADVPFP.g_output(1).cutTime_cat(:)=cutTime_cat;
           
           end
           
%      % STAGE 7
%            
%            if subjData.(subjects{subj})(session).trainStage==7 %if the animal reached criteria, add this data to the struct
%            
%             s=s1+1;%use for saving files and not saving subj files that do not meet criteria
%             s1=s1+1
%             %g_camp_465
%            gcamp_raw.blue_stage7{s}=subjData.(subjects{subj})(session).reblue'; 
%         
%             %g_camp_405
%            gcamp_raw.purple_stage7{s}=subjData.(subjects{subj})(session).repurple'; 
%        
%            %cutTime for moving z-score
%            
%            cutTime_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
% 
%            %DS Index
%            
%            DSonsetindex_stage7(:,:,s)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
%            
%  
% %            %DS Times
% %           
% %            DSTimes_stage7{s}=cutTime_stage7( DSonsetindex_stage7(:,:,s));
%            
%            %DS Pox
%            DSpox_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(:)';
%           
%            %DS Lox
%            DSlox_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(:)';
%          
%            %DS latency
%            DSPElatency_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
%          
%            %inPortDS
%            inPortDS_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
%     
%            %poxDS
%            poxDS_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
%           
%            %DS stage 7 data- save to struct
%            %data_to_input_GADVPFP.output(1).DSTimes_stage7{s}=DSTimes_stage7{s};
%            data_to_input_GADVPFP.output(1).DSonsetindex_stage7{s}=DSonsetindex_stage7(:,:,s);
%            data_to_input_GADVPFP.output(1).DSpoxind_stage7{s}=DSpox_stage7{s};
%            data_to_input_GADVPFP.output(1).DSloxind_stage7{s}=DSlox_stage7{s};
%            data_to_input_GADVPFP.output(1).DSPElatency_stage7{s}=DSPElatency_stage7{s};
%            data_to_input_GADVPFP.output(1).inPortDS_stage7{s}=inPortDS_stage7{s};
%            data_to_input_GADVPFP.output(1).poxDS_stage7{s}=poxDS_stage7{s};% all pox not just index of first pox
%            

           
           
%TODO: ADD NS DATA
%            %g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
%            
%            %moving median g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
%            
%            %g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
%            
%            %moving median g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
%                      %fitted signal
%           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
%            
%            %df/f signal
%            data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df; 
%             
%             % save g.ouput data to struct
%             data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.blue{s}= gcamp_raw.blue_stage7{s};
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.blue{s}= gcamp_raw.blue_stage7{s};
%            
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.purple{s}= gcamp_raw.purple_stage7{s};
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.purple{s}= gcamp_raw.purple_stage7{s};
% 
%             %sampling rate
%            data_to_input_GADVPFP.g_output_stage7(1).samp_rate(:)= 40 % we down sample to 40 Hz for all subjects
%            
%            %cutTime for moving z-score
%            data_to_input_GADVPFP.g_output(1).cutTime_stage7{s}=cutTime_stage7{s};
%            
%            
% 
%            end
       
       elseif subjData.(subjects{subj})(session).box == 2 || subjData.(subjects{subj})(session).box==4
           if subjData.(subjects{subj})(session).Bcriteria==1  
           x=1;
       % STAGE 5        
           %g_camp_465
           gcamp_raw.blue_criteria(:)=subjData.(subjects{subj})(session).reblue'; 
           gcamp_raw.blue_dayb4criteria(:)=subjData.(subjects{subj})(session-1).reblue';
           gcamp_raw.blue_2dayb4criteria(:)=subjData.(subjects{subj})(session-2).reblue'; 

           gcamp_raw_blue_cat=horzcat( gcamp_raw.blue_criteria,gcamp_raw.blue_dayb4criteria,gcamp_raw.blue_2dayb4criteria);
           % use this temp array to elongate the rest of the variables with
           % appropriate time stamps for the full concatenated signal
           temp_gcamp_raw_blue_dayb4criteria=horzcat(gcamp_raw.blue_criteria,gcamp_raw.blue_dayb4criteria);
           
            %g_camp_405
           gcamp_raw.purple_criteria(:)=subjData.(subjects{subj})(session).repurple'; 
           gcamp_raw.purple_dayb4criteria(:)=subjData.(subjects{subj})(session-1).repurple';
           gcamp_raw.purple_2dayb4criteria(:)=subjData.(subjects{subj})(session-2).repurple'; 

            gcamp_raw_purple_cat=horzcat( gcamp_raw.purple_criteria,gcamp_raw.purple_dayb4criteria,gcamp_raw.purple_2dayb4criteria);
           %cutTime for moving z-score
           cutTime_criteria=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
           cutTime_dayb4criteria=subjDataAnalyzed.(subjects{subj})(session-1).photometry.cutTime + length(gcamp_raw.blue_criteria(:)); 
           cutTime_2dayb4criteria=subjDataAnalyzed.(subjects{subj})(session-2).photometry.cutTime + length(temp_gcamp_raw_blue_dayb4criteria(:)); 
           
           cutTime_cat=horzcat(cutTime_criteria,cutTime_dayb4criteria,cutTime_2dayb4criteria);
           %DS Index
           DSonsetindex_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
           DSonsetindex_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDS.DSonset(:)+ length(gcamp_raw.blue_criteria(:));
           DSonsetindex_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDS.DSonset(:)+ length(temp_gcamp_raw_blue_dayb4criteria(:));
           
           DSonset_cat=horzcat( DSonsetindex_criteria, DSonsetindex_dayb4criteria,DSonsetindex_2dayb4criteria);
           %DS Times
           DSTimes_criteria(:)=cutTime_cat( DSonsetindex_criteria(:));
           DSTimes_dayb4criteria(:)=cutTime_cat(DSonsetindex_dayb4criteria(:));
           DSTimes_2dayb4criteria(:)=cutTime_cat(DSonsetindex_2dayb4criteria(:));
           
           DSTimes_cat=horzcat(DSTimes_criteria,DSTimes_dayb4criteria,DSTimes_2dayb4criteria);
           %DS Pox
           DSpox_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(:)';
           DSpox_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDSpox.firstPoxind(:)';
           DSpox_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDSpox.firstPoxind(:)';
           
           DSpox_cat=horzcat(DSpox_criteria,DSpox_dayb4criteria,DSpox_2dayb4criteria);
           %DS Lox
           DSlox_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(:)';
           DSlox_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).periDSlox.firstLoxind(:)';
           DSlox_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).periDSlox.firstLoxind(:)';
           
           DSlox_cat=horzcat(DSlox_criteria,DSlox_dayb4criteria,DSlox_2dayb4criteria);
           %DS latency
           DSPElatency_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
           DSPElatency_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.DSpeLatency(:);
           DSPElatency_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.DSpeLatency(:);

           DSPElatency_cat=horzcat(DSPElatency_criteria,DSPElatency_dayb4criteria,DSPElatency_2dayb4criteria);
           %inPortDS
           inPortDS_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
           inPortDS_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.inPortDS;
           inPortDS_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.inPortDS;
           
           inPortDS_cat=horzcat(inPortDS_criteria,inPortDS_dayb4criteria,inPortDS_2dayb4criteria);
           
           %poxDS
           poxDS_criteria(:)=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
           poxDS_dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-1).behavior.poxDS;
           poxDS_2dayb4criteria(:)=subjDataAnalyzed.(subjects{subj})(session-2).behavior.poxDS;
           
           poxDS_cat=horzcat(poxDS_criteria,poxDS_dayb4criteria,poxDS_2dayb4criteria);
           
           %DS criteria day data- save to struct
           data_to_input_GADVPFP.output(1).DSTimes_criteria(:)=DSTimes_criteria;
           data_to_input_GADVPFP.output(1).DSonsetindex_criteria(:)=DSonsetindex_criteria;
           data_to_input_GADVPFP.output(1).DSpoxind_criteria(:)=DSpox_criteria;
           data_to_input_GADVPFP.output(1).DSloxind_criteria(:)=DSlox_criteria;
           data_to_input_GADVPFP.output(1).DSPElatency_criteria(:)=DSPElatency_criteria;
           data_to_input_GADVPFP.output(1).inPortDS_criteria(:)=inPortDS_criteria;
           data_to_input_GADVPFP.output(1).poxDS_criteria(:)=poxDS_criteria;% all pox not just index of first pox
           
           %DS stage 5 data- 3 days concatenated- save to struct 
           data_to_input_GADVPFP.output(1).DSTimes_cat(:)=DSTimes_cat;
           data_to_input_GADVPFP.output(1).DSonsetindex_cat(:)=DSonset_cat;
           data_to_input_GADVPFP.output(1).DSpoxind_cat(:)=DSpox_cat;
           data_to_input_GADVPFP.output(1).DSloxind_cat(:)=DSlox_cat(:)';
           data_to_input_GADVPFP.output(1).DSPElatency_cat(:)=DSPElatency_cat;
           data_to_input_GADVPFP.output(1).inPortDS_cat(:)=inPortDS_cat;
           data_to_input_GADVPFP.output(1).poxDS_cat(:)= poxDS_cat;
           
           
%TODO: ADD NS DATA
%            %g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
%            
%            %moving median g_camp_465
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
%            
%            %g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
%            
%            %moving median g_camp_405
%            data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
%                      %fitted signal
%           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
%            
%            %df/f signal
%            data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df; 
            
            % save g.ouput data to struct
            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)= gcamp_raw.blue_criteria;
           data_to_input_GADVPFP.g_output(1).gcamp_raw.blue_cat(:)= gcamp_raw_blue_cat;
           
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)= gcamp_raw.purple_criteria;
           data_to_input_GADVPFP.g_output(1).gcamp_raw.purple_cat(:)= gcamp_raw_purple_cat;


            %sampling rate
           data_to_input_GADVPFP.g_output(1).samp_rate(:)= 40; % we down sample to 40 Hz for all subjects
           
           %cutTime for moving z-score
           data_to_input_GADVPFP.g_output(1).cutTime_criteria(:)=cutTime_criteria;
           data_to_input_GADVPFP.g_output(1).cutTime_cat(:)=cutTime_cat;
           
           end
           
%                 % STAGE 7
%            
%            if subjData.(subjects{subj})(session).trainStage==7 %if the animal reached criteria, add this data to the struct
%            
%             s=s1+1;%use for saving files and not saving subj files that do not meet criteria
%             s1=s1+1
%             %g_camp_465
%            gcamp_raw.blue_stage7{s}=subjData.(subjects{subj})(session).reblue'; 
%         
%             %g_camp_405
%            gcamp_raw.purple_stage7{s}=subjData.(subjects{subj})(session).repurple'; 
%        
%            %cutTime for moving z-score
%            
%            cutTime_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime; 
% 
%            %DS Index
%            
%            DSonsetindex_stage7(:,:,s)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(:);
%            
%  
% %            %DS Times
% %           
% %            DSTimes_stage7{s}=cutTime_stage7( DSonsetindex_stage7(:,:,s));
%            
%            %DS Pox
%            DSpox_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).periDSpox.firstPoxind(:)';
%           
%            %DS Lox
%            DSlox_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).periDSlox.firstLoxind(:)';
%          
%            %DS latency
%            DSPElatency_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.DSpeLatency(:);
%          
%            %inPortDS
%            inPortDS_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.inPortDS;
%     
%            %poxDS
%            poxDS_stage7{s}=subjDataAnalyzed.(subjects{subj})(session).behavior.poxDS;
%           
%            %DS stage 7 data- save to struct
%            %data_to_input_GADVPFP.output(1).DSTimes_stage7{s}=DSTimes_stage7{s};
%            data_to_input_GADVPFP.output_stage7(1).DSonsetindex_stage7{s}=DSonsetindex_stage7(:,:,s);
%            data_to_input_GADVPFP.output_stage7(1).DSpoxind_stage7{s}=DSpox_stage7{s};
%            data_to_input_GADVPFP.output_stage7(1).DSloxind_stage7{s}=DSlox_stage7{s};
%            data_to_input_GADVPFP.output_stage7(1).DSPElatency_stage7{s}=DSPElatency_stage7{s};
%            data_to_input_GADVPFP.output_stage7(1).inPortDS_stage7{s}=inPortDS_stage7{s};
%            data_to_input_GADVPFP.output_stage7(1).poxDS_stage7{s}=poxDS_stage7{s};% all pox not just index of first pox
%            
% 
%            
%            
% %TODO: ADD NS DATA
% %            %g_camp_465
% %            data_to_input_GADVPFP.g_output(1).gcamp_raw.blue(:)=subjData.(subjects{subj})(session).reblue';
% %            
% %            %moving median g_camp_465
% %            data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff';
% %            
% %            %g_camp_405
% %            data_to_input_GADVPFP.g_output(1).gcamp_raw.purple(:)=subjData.(subjects{subj})(session).repurple';
% %            
% %            %moving median g_camp_405
% %            data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff';
% %                      %fitted signal
% %           data_to_input_GADVPFP.g_output(1).fit(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.fit;
% %            
% %            %df/f signal
% %            data_to_input_GADVPFP.g_output(1).df(:)=subjDataAnalyzed.(subjects{subj})(session).photometry.df; 
%             
%             % save g.ouput data to struct
%             data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.blue{s}= gcamp_raw.blue_stage7{s};
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.blue{s}= gcamp_raw.blue_stage7{s};
%            
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.purple{s}= gcamp_raw.purple_stage7{s};
%            data_to_input_GADVPFP.g_output_stage7(1).gcamp_raw.purple{s}= gcamp_raw.purple_stage7{s};
% 
%             %sampling rate
%            data_to_input_GADVPFP.g_output_stage7(1).samp_rate(:)= 40 % we down sample to 40 Hz for all subjects
%            
%            %cutTime for moving z-score
%            data_to_input_GADVPFP.g_output_stage7(1).cutTime_stage7{s}=cutTime_stage7{s};
%            
%            end
           
       end 
    end %end session loop

 
if x==1
%save 
save(fullfile(encodinginputpath,strcat(experimentName,'_',fieldname,'_', 'data_to_input_GADVPFP')), 'data_to_input_GADVPFP');
end 
gcamp_raw=struct();   
data_to_input_GADVPFP=struct();
end %end subj loop