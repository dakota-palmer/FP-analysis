%fp data analysis 
%11/25/19
clear
clc
close all

figPath = 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

%% Load struct containing data organized by subject
% subjData= uigetfile; %choose the subjData file to open for your experiment

subjects= fieldnames(subjData.subjData); %access subjData struct with dynamic fieldnames


%% Within-subjects plots and analysis
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.subjData.(subjects{subj}).trainDay) %for each training session this subject completed
       
       currentSubj= subjData.subjData.(subjects{subj}); %use this for easy indexing into the curret subject within the struct
      
       %% Raw session plots- within subjects
        figure(session)
        hold on
        plot(currentSubj.cutTime, currentSubj.reblue, 'b');
        plot(currentSubj.cutTime, currentSubj.repurple,'m');
        title(strcat('Rat #',num2str(currentSubj.rat),' training day :', num2str(currentSubj.trainDay), ' downsampled '));
        xlabel('time (s)');
        ylabel('mV');
        legend('blue (465)',' purple (405)');
        
        %make figure full screen, save, and close this figure
%         set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
%         saveas(gcf, strcat(figPath, experimentName, '_rat_', num2str(currentSubj.rat),'_&_ ', num2str(sesData(file).trainDay), '.fig')); %save the current figure in fig format
%         close; %close 

   end
end