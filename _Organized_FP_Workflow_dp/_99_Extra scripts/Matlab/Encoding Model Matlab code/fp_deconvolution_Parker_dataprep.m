%data prep for Parker encoding model (not from Parker, made for Richard lab data)

% First, save data into appropriate format/shape
% Input folder should have a .mat file of every recording that includes an
% 'output' and 'g_output' structure. The 'output' struct contains both the
% time of various task events (in seconds) as well as the choice or outcome
% identities of individual trials (e.g. output.IpsiPress is either 1 for an
% ipsi press or -1 for a contra press). 'The 'g_output' structure contains
% the recorded GCaMP trace (g_output.gcamp) as well as the sampling rate
% (g_output.samp_rate)

%let's load a .mat containing preanalyzed FP data generated by our
%fpAnalyzeData.m
load(uigetfile('*.mat')); %choose the subjDataAnalyzed.mat file to open for your experiment %by default only show .mat files

fs= 40; %make sure the sampling frequency is correct!
savePath= strcat(pwd,'\data_to_input\');

%Exclude subjects here if necessary
% excludedSubjs= {}'%{'rat12','rat13'}; %cell array with strings of excluded subj fieldnames
% 
% excludedSubjs= {'rat12','rat13','rat17'}; %cell array with strings of excluded subj fieldnames
excludedSubjs= {'rat10','rat17', 'rat16','rat20'}; %cell array with strings of excluded subj fieldnames


subjDataAnalyzed= rmfield(subjDataAnalyzed,excludedSubjs);
subjectsAnalyzed= fieldnames(subjDataAnalyzed);

%% Exclude sessions

includedStage= 7; %what stage do you want to isolate?

for subj= 1:numel(subjectsAnalyzed)
    currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj});
    excludedSessions= [];
    for session= 1:numel(currentSubj)
        if currentSubj(session).trainStage ~= includedStage%7 %only include sessions of this stage
           excludedSessions= cat(2,excludedSessions,session);
        end
    end%end session loop
   subjDataAnalyzed.(subjectsAnalyzed{subj})(excludedSessions)= []; 
   
   currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj});
   
   excludedSessions= [];
   for session= 1:numel(currentSubj) %loop through again and get rid of all except final day
       if session<numel(currentSubj)
           excludedSessions= cat(2,excludedSessions,session);
       end
   end%end session loop 2
   
   subjDataAnalyzed.(subjectsAnalyzed{subj})(excludedSessions)= []; 
   
end %end subj loop

%% Visualize photometry data
% for subj= 1:numel(subjectsAnalyzed) %for each subject
%     
%     currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the current subject within the struct
%     
%     disp(strcat('plotting photometry data for_', subjectsAnalyzed{subj}));
%            
%    for session = 1:numel(subjDataAnalyzed.(subjectsAnalyzed{subj})) %for each training session this subject completed
%        
%        
%         figure() %one figure per SESSION       
%        
%        currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %use this for easy indexing into the curret subject within the struct
%       
%        %  session plots- within subject
%        
% %        fitPurple= controlFit(currentSubj(session).raw.reblue, currentSubj(session).raw.repurple);
% 
%        
%         hold on;
%         plot(currentSubj(session).raw.cutTime, currentSubj(session).raw.reblue, 'b'); %plot 465nm trace
%         plot(currentSubj(session).raw.cutTime, currentSubj(session).raw.repurple,'m'); %plot 405nm trace
%         title(strcat('Rat #',num2str(currentSubj(session).rat),' training day :', num2str(currentSubj(session).trainDay), ' downsampled ', ' box ', num2str(currentSubj(session).box)));
%         xlabel('time (s)');
%         ylabel('mV');
%         legend('blue (465)',' purple (405)');
%         
%         
%          %make figure full screen, save, and close this figure
%         set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% %         close; %close
%    end  
%     
% end


%% loop through each session and save a .mat of events & photometry data
%the .mat will contain 'output' and 'g_output' structs
for subj= 1:numel(subjectsAnalyzed)
   currentSubj= subjDataAnalyzed.(subjectsAnalyzed{subj}); %save for easy indexing
   
    %Clear structs between subjects 
       output.DS= []; output.NS= [];
       metadata.subject= []; metadata.date=[];
       g_output= [];
       output= [];

       
   for session= 1:numel(currentSubj)       
       experimentName= currentSubj(session).experiment;
       
       %save metadata field for easy recovery of other analyzed data from this subj & session
       metadata.subject{1,session}= subjectsAnalyzed(subj); %{} because this is a string
       metadata.date(:,session)= currentSubj(session).date;

       %fill output struct with task event timestamps
       output.DS(:,session)=currentSubj(session).periDS.DS;
       output.NS(:,session)= currentSubj(session).periNS.NS;

       %        output.poxDS= currentSubj(session).behavior.poxDS; %note this would be ALL PEs during cue (not just first)

       %first initialize output.firstPox and output.firstLox with a nan value
       %for every trial (so this way if we loop over trials later we won't
       %get an error)
       output.firstPoxDS(:,session)= nan(size(currentSubj(session).periDS.DS,2),1);
       output.firstLoxDS(:,session)= nan(size(currentSubj(session).periDS.DS,2),1);
       output.firstPoxNS(:,session)= nan(size(currentSubj(session).periNS.NS));
       output.firstLoxNS(:,session)= nan(size(currentSubj(session).periNS.NS));
       
       %to get only first lox & pox during cue, using cellfun (since poxDS and loxDS are saved in a cell array and we only want the first value       
       index= ~cellfun('isempty',currentSubj(session).behavior.poxDS); %using this index accounts for empty cells
       output.firstPoxDS(index,session)= cellfun(@(v)v(1),currentSubj(session).behavior.poxDS(index));
       
       index= ~cellfun('isempty',currentSubj(session).behavior.loxDS); %using this index accounts for empty cells
       output.firstLoxDS(index,session)= cellfun(@(v)v(1),currentSubj(session).behavior.loxDS(index));

       index= ~cellfun('isempty',currentSubj(session).behavior.poxNS); %using this index accounts for empty cells
       output.firstPoxNS(index,session)= cellfun(@(v)v(1),currentSubj(session).behavior.poxNS(index));
       
       index= ~cellfun('isempty',currentSubj(session).behavior.loxNS); %using this index accounts for empty cells
       output.firstLoxNS(index,session)= cellfun(@(v)v(1),currentSubj(session).behavior.loxNS(index));
       
       
%        output.pox= currentSubj(session).raw.pox;
%        output.lox= currentSubj(session).raw.lox;
%        output.out= currentSubj(session).raw.out;
       
       %fill g_output struct with photometry signal
       g_output.reblue{1,session}= currentSubj(session).raw.reblue;
       g_output.samp_rate(1,session)= fs; 
       
       %save one file per session
%        save(strcat(savePath,experimentName,'-',subjectsAnalyzed{subj},'-ses-',num2str(currentSubj(session).date),'.mat'), 'g_output', 'output', 'metadata'); %the second argument here is the variable being saved, the first is the filename 
       

    %save peri-DS signals so we don't need to recalculate
    g_output.periDS.DSzblue{1,session}= currentSubj(session).periDS.DSzblue;
    g_output.periDS.DSzpurple{1,session}= currentSubj(session).periDS.DSzpurple;

    g_output.periNS.NSzblue{1,session}= currentSubj(session).periNS.NSzblue;
    g_output.periNS.NSzpurple{1,session}= currentSubj(session).periNS.NSzpurple;
    
   end %end session loop
            %save one file per subj containing all sessions of interest
          save(strcat(savePath,experimentName,'-',subjectsAnalyzed{subj},'-stage-',num2str(includedStage),'.mat'), 'g_output', 'output', 'metadata'); %the second argument here is the variable being saved, the first is the filename 

end%end subj loop