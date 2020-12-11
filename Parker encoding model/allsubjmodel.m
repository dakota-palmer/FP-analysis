%% Create graph of all subjects ( SEM area)
% 
% %load regression data from all animals and squeeze into one matrix
cd(save_folder);
clear all
files = dir('*.mat');

for r=1:length(files)
file = files(r)
b_all= load(file.name);
b_all_rats(:,r)= ball.b(2:end);% skip intercept
bDS_all_rats
end





for n=1:5,
  filename = sprintf('log_%d.mat',n) 
  S = load(filename)
  % S is a structure with the variables inside the mat file as its fields.
  % If you expect a variable called V, you can check this using ISFIELD
  if isfield(S,V)
    % ...
  else
    disp(['The file "' filename '" did not contain the variable "' V '"']) ;
  end
end


%reorganise z-score data for all animals


%same as above but model mean across animals instead of trials
%     figure; hold on; title(strcat('Mean across all DS trials- modeled gcamp trace vs. actual peri-DS trace'));
%     plot(timeLock,nanmean(gcamp_model_sum,2), 'k');
%     plot(timeLock,currentSubj(session).periDS.DSzblueMean, 'b');
%     legend('mean modeled trace (sum kernels)', 'mean actual trace (z scored based on pre-cue baseline)');
    
    %Let's do one big figure with mean of each kernel and sum separately
    %subplotted
    figure; hold on; sgtitle('DS trials- mean event kernels and mean modeled GCaMP');
    for con= 1:numel(cons) %loop through event types (cons)
        subplot(numel(cons)+1, 1, con); hold on; title(cons{con}); %subplot of this event's kernel
        plot(timeLock, nanmean(kernels_DStrials(:,:,con),2), conColors{con});
    end %end con loop
    subplot(numel(cons)+1, 1, con+1); hold on; title('modeled vs. actual GCaMP');
    plot(timeLock,nanmean(gcamp_model_sum,2), 'k');
    plot(timeLock,currentSubj(1).DSzblueMean, 'b');
    legend('mean modeled trace (sum kernels)', 'mean actual trace (z scored based on pre-cue baseline)');

        gcf;
        [filepath,name,ext] = fileparts(file_name);
        figsave_name=strcat('DSonset_PoxDS_ModelMean',name);
        cd(strcat(figsave_folder,'\Mean_Model\'));;
        savefig(figsave_name);

