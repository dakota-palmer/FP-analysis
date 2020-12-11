%% Create graph of all subjects ( SEM area)
%reorganise z-score data for all animals

DSkernel_Shifted_all=[];
PEkernel_Shifted_all=[];
Lickkernel_Shifted_all=[]; 
modelsum_Shifted_all=[];
DSzblueAllTrials_Shifted_all=[];

for subject= 1:length(subjects);
% create matrix with all DS onset DSkernels for all animals (1st sheet in
% 3D matrix)
fns = fieldnames(kernel_Shifted_all.kernels_DSTrials);

DSkernel_Shifted_all= cat(2,DSkernel_Shifted_all,kernel_Shifted_all.kernels_DSTrials.(fns{subject})(:,:,1));
% create matrix with all PE DSkernels for all animals(2nd sheet in
% 3D matrix)
PEkernel_Shifted_all= cat(2,PEkernel_Shifted_all,kernel_Shifted_all.kernels_DSTrials.(fns{subject})(:,:,2));

% create matrix with all lick DSkernels for all animals(3rd sheet in
% 3D matrix)

Lickkernel_Shifted_all= cat(2,Lickkernel_Shifted_all,kernel_Shifted_all.kernels_DSTrials.(fns{subject})(:,:,3));


% modelsum matrix
modelsum_Shifted_all= cat(2,modelsum_Shifted_all,kernel_Shifted_all.gcamp_model_sum.(fns{subject})(:,:));

%DSzalltrials matrix
DSzblueAllTrials_Shifted_all= cat(2,DSzblueAllTrials_Shifted_all,kernel_Shifted_all.DSzblueAllTrials.(fns{subject})(:,:)');
end

%% matlab plots
figure();
  plot(timeLock,nanmean(DSkernel_Shifted_all,2), 'k');hold on;
  plot(timeLock,nanmean(PEkernel_Shifted_all,2), 'b');hold on;
  plot(timeLock,nanmean(Lickkernel_Shifted_all,2),'m');hold off;
  legend('average DS trace (sum kernels- across animals)', 'average PE trace (sum kernels- across animals)','average Lick trace (sum kernels- across animals)');
    
figure();
  plot(timeLock,nanmean(modelsum_Shifted_all,2), 'k');hold on;
  plot(timeLock,nanmean(DSzblueAllTrials_Shifted_all,2), 'b');hold off;
  legend('average model trace (sum kernels- across animals)', 'average z-score (across animals)');
    
%% gramm plots

%DS kernel
figure()
g=gramm('x',timeLock,'y',DSkernel_Shifted_all');
g.stat_summary('geom','area','type','sem')
g.set_names('x','Time from DS onset(sec)','y','Regression Coefficient','group','DSonset');
g.axe_property('YLim',[-1 1.8]);
g.set_title('DS Onset Kernel');
g.draw()

%PE kernel
figure()
g=gramm('x',timeLock,'y',PEkernel_Shifted_all')
g.stat_summary('geom','area','type','sem')
g.set_names('x','Time from PE(sec)','y','Regression Coefficient');
g.set_color_options('map','d3_10');
g.axe_property('YLim',[-1 1.8]);
g.set_title('Port Entry Kernel');
g.draw()

%Lick kernel
figure()
g=gramm('x',timeLock,'y',Lickkernel_Shifted_all')
g.stat_summary('geom','area','type','sem')
g.set_names('x','Time from Initial Lick(sec)','y','Regression Coefficient');
g.set_color_options('map','brewer2');
g.axe_property('YLim',[-1 1.8]);
g.set_title('Initial Lick Kernel');
g.draw()


figure()
g=gramm('x',timeLock,'y',modelsum_Shifted_all');
g.stat_summary('geom','area','type','sem')
g.set_color_options('chroma',0);
g.set_names('x','Time from DS onset(sec)','y','regression beta','group','DSonset');
g.draw()
g.update('x',timeLock,'y',DSzblueAllTrials_Shifted_all')
g.stat_summary('geom','area','type','sem')
g.set_color_options('map','matlab');
g.axe_property('YLim',[-1.5 3.5]);
g.draw()


%% same as above but model mean across animals instead of trials
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