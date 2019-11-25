%fp data analysis 
%11/25/19


%% Load struct containing data organized by subject
subjData= uigetfile; %choose the subjData file to open for your experiment

subjects= fieldnames(subjData); %access subjData struct with dynamic fieldnames


%% Within-subjects plots and analysis
for subj= 1:numel(subjects)
   for session = 1:numel(subjData.subj.trainDay) %for each training session this subject completed
       %% Raw session plots- within subjects
        figure(session)
        hold on
        plot(cutTime, reblueA, 'b');
        plot(cutTime, fitA,'m');
        title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' ControlFit box A'));
        legend('blue (465)','fitted purple (405)')
        figure(sesNum)
      
        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
        saveas(gcf, strcat(figPath, experimentName, '_rat_', num2str(sesData(file).ratA),'_&_ ', num2str(sesData(file).ratB), '_Fitted_signal_day_', num2str(sesData(file).trainDay), '.fig')); %save the current figure in fig format
        close; %close 

   end
end