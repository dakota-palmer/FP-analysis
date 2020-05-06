%% Save the analyzed data 
%save the subjDataAnalyzed struct for later analysis
structpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\FP-analysis\matlabVPFP\broken up code\'
save(structpath,strcat(experimentName,'-', 'subjDataAnalyzed'), 'subjDataAnalyzed'); %the second argument here is the variable being saved, the first is the filename

%% save data from each stage from each animal for ERT analysis
ERTpath='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\PhotometryEventDetection\ERTsimulation-master\ERTsimulation-master\'
ERTData=struct();
subj=[];
session=[];
Stage=[];
for subj=1:numel(subjects);
   for session = 1:numel(subjData.(subjects{subj}));
       Stage=string((subjDataAnalyzed.(subjects{subj})(session).trainStage));
       
       ERTData.(strcat('DSzblueMeanStage',Stage))(subj,:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSzblueMean';
       ERTData.(strcat('DSzpurpleMeanStage',Stage))(subj,:)=subjDataAnalyzed.(subjects{subj})(session).periDS.DSzpurpleMean';
       
       if ~isempty(subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean);
       ERTData.(strcat('NSzblueMeanStage',Stage))(subj,:)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzblueMean';
       ERTData.(strcat('NSzpurpleMeanStage',Stage))(subj,:)=subjDataAnalyzed.(subjects{subj})(session).periNS.NSzpurpleMean';
       end
       
   end    
end

ERTData.timeLock=timeLock;

%save 
save(ERTpath,strcat(experimentName,'-', 'ERTData'), 'ERTData');
