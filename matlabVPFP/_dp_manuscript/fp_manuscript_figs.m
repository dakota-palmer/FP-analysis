%% Initialize variables
figPath= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\'
figFormats= {'.fig','.png'} %list of formats to save figures as (for saveFig.m)

%% Load fpAnalyzedData struct
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-17-Dec-2021subjDataAnalyzed.mat")

% % with artifacts
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-06-Apr-2022subjDataAnalyzed.mat")

% no artifact version
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-14-Feb-2022subjDataAnalyzedNoArtifacts.mat")

% dp workstation
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-noArtifact-21-Mar-2022subjDataAnalyzed.mat")
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-24-Mar-2022subjDataAnalyzed.mat")


% %ally no artifacts (bu"C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\GADVPFP-22-Feb-2022subjDataAnalyzed.mat"t all trials)
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\GADVPFP-22-Feb-2022subjDataAnalyzed.mat")

%% Create periEventTable
fp_manuscript_tidyTable();

%% make peri-event 465nm plots
fp_manuscript_periEventTraces();

%% FIGURE 2

%-- Peri DS vs. Peri NS 2D traces

%-- Peri DS vs. Peri NS AUC & Stat comparison

%% make variable reward plots
fp_manuscript_variableReward();

%% load encoding model output 


%dp paths
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\allSubjResultskernel_Shifted_all.mat")

%ASSUME only mats with individual stats.b in this folder
%path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
% pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465';

%workstation for ally's data
%ASSUME only mats with individual stats.b in this folder
pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465'

load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\allSubjResultskernel_Shifted_all.mat")

%loop through files and extract data
cd(pathLasso);
mat = dir('*.mat');

% %initialize structure (will collect individual file's (subj) kernels)
% lassoOutput=struct(length(mat)); 
% lassoOutput.b= [];
%% Save kernels into table
% easy for plotting later
kernelTable= table();
kernelTable.file= cell(length(mat)*(periCueFrames+1),1);
kernelTable.subject= cell(length(mat)*(periCueFrames+1),1);
kernelTable.timeLock= nan(length(mat)*(periCueFrames+1),1); 
kernelTable.kernelDS= nan(length(mat)*(periCueFrames+1),1); 
kernelTable.kernelPoxDS= nan(length(mat)*(periCueFrames+1),1); 
kernelTable.kernelLoxDS= nan(length(mat)*(periCueFrames+1),1); 

% fileInd= 1:periCueFrames; %index for table corresponding to this file
for file= 1:length(mat)
    kernel=[]; %clear btwn subjects
    
    %load LASSO results
    lassoOutput(file) = load(mat(file).name);

    b= lassoOutput(file).b;

    %isolate kernels for each eventType
    for eventType = 1:k
         %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
          if eventType==1
            tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
          else
            tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
          end

       sumTerm= []; %clear between event types

       for ts= 1:(numel(b)/k) %loop through ts; using 'ts' for each timestamp instead of 'i'
    %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
            kernel(ts,eventType) = b(tsThisEvent(ts));
       end

       timeLock= linspace(-time_back, time_forward, size(kernel,1));

    end 

    %iterate table index between files and save data in table
    if file==1
        fileInd= 1:periCueFrames+1;
    else
        fileInd= fileInd+ periCueFrames+1;
    end
    
    
    %assume order of eventType columns is DS, DSpox, DSlox
    kernelTable.file(fileInd)={mat(file).name};
    
    subject= strfind(mat(file).name, 'rat');
    subject= mat(file).name(subject:end);
    subject= subject(1:strfind(subject,'_')-1);
    
    kernelTable.subject(fileInd)= {subject};
    
    kernelTable.timeLock(fileInd)=timeLock;
    kernelTable.kernelDS(fileInd)=kernel(:,1);
    kernelTable.kernelPoxDS(fileInd)=kernel(:,2);
    kernelTable.kernelLoxDS(fileInd)=kernel(:,3);
    

end %end file loop (subj)

%% gramm plot all subjects kernels + periEvent traces

%subset periEvent data for plotting
data= periEventTable;
data= data(data.stage==7,:); 

%nice plot w gramm
clear i;
% figure(); hold on;

%Plot Between-Subj Means
i(1,1)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelDS);
i(1,1).set_title('DS Kernel');
i(1,1).stat_summary('type','sem','geom','area');
i(1,1).set_names('x','time shift from event onset (s)','y','beta');
i(1,1).set_color_options('chroma',0,'lightness',30);

i(1,2)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelPoxDS);
i(1,2).set_title('DS PE Kernel');
i(1,2).stat_summary('type','sem','geom','area');
i(1,2).set_names('x','time shift from event onset (s)','y','beta');
i(1,2).set_color_options('chroma',0,'lightness',30);

i(1,3)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelLoxDS);
i(1,3).set_title('DS Lick Kernel');
i(1,3).stat_summary('type','sem','geom','area');
i(1,3).set_names('x','time shift from event onset (s)','y','beta');
i(1,3).set_color_options('chroma',0,'lightness',30);



%second column with peri-event traces
i(2,1)=gramm('x',data.timeLock,'y',data.DSblue);
i(2,1).set_title('Peri-DS');
i(2,1).stat_summary('type','sem','geom','area');
i(2,1).set_names('x','time from event (s)','y','z-score');
i(2,1).set_color_options('chroma',0,'lightness',30);


i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
i(2,2).set_title('Peri-DS PE');
i(2,2).stat_summary('type','sem','geom','area');
i(2,2).set_names('x','time from event (s)','y','z-score');
i(2,2).set_color_options('chroma',0,'lightness',30);
i(2,2).set_line_options('base_size',2);


i(2,3)=gramm('x',data.timeLock,'y',data.DSblueLox);
i(2,3).set_title('Peri-DS Lick');
i(2,3).stat_summary('type','sem','geom','area');
i(2,3).set_names('x','time from event (s)','y','z-score');
i(2,3).set_color_options('chroma',0,'lightness',30);
i(2,3).set_line_options('base_size',2);


i.draw();

%plot Individual Subjects overlay~~~
i(1,1).update('color',kernelTable.subject);
% i(1,1).set_title('DS Kernel');
% i(1,1).stat_summary('type','sem','geom','area');
i(1,1).geom_line('alpha',0.5);
i(1,1).set_color_options();
i(1,1).set_line_options('base_size',0.5);


i(1,2).update('color',kernelTable.subject);
% i(1,2).set_title('DS PE Kernel');
% i(1,2).stat_summary('type','sem','geom','area');
i(1,2).geom_line('alpha',0.5);
i(1,2).set_color_options();
i(1,2).set_line_options('base_size',0.5);


i(1,3).update('color',kernelTable.subject);
% i(1,3).set_title('DS Lick Kernel');
% i(1,3).stat_summary('type','sem','geom','area');
i(1,3).geom_line('alpha',0.5);
i(1,3).set_color_options();
i(1,3).set_line_options('base_size',0.5);



%second column with peri-event traces
i(2,1).update('color',data.subject);
i(2,1).stat_summary('type','sem','geom','area');
i(2,1).set_color_options();
i(2,1).set_line_options('base_size',0.5);


i(2,2).update('color',data.subject);
i(2,2).stat_summary('type','sem','geom','area');
i(2,2).set_color_options();
i(2,2).set_line_options('base_size',0.5);


i(2,3).update('color',data.subject);
i(2,3).stat_summary('type','sem','geom','area');
i(2,3).set_color_options();
i(2,3).set_line_options('base_size',0.5);



% i.set_title('all subj');

%manually set axes limits before drawing
i(1,:).axe_property('YLim',[-2, 5]);
i(2,:).axe_property('YLim',[-2, 5]);

i.draw();

linkaxes(gca,'x');

saveFig(gcf, figPath, strcat('_allSubj_encoding_kernels_w_periEvent'),figFormats);

%% Individual subj figs

for file=1:length(mat)
    %subset periEvent data for plotting
    data= periEventTable;
    data= data(data.stage==7,:); 
    %find subject from filename
    subject= strfind(mat(file).name, 'rat');
    subject= mat(file).name(subject:end);
    subject= subject(1:strfind(subject,'_')-1);
    %subset data for this subj
    data= data(~cellfun(@isempty,strfind(data.subject,subject)),:);

    %subset kernel data for plotting
    dataKernel= kernelTable;
    dataKernel= dataKernel(~cellfun(@isempty,strfind(dataKernel.subject,subject)),:);



    %nice plot w gramm
    clear i;
    % figure(); hold on;

    %Plot Between-Subj Means
    i(1,1)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelDS);
    i(1,1).set_title('DS Kernel');
    i(1,1).stat_summary('type','sem','geom','area');
    i(1,1).set_names('x','time shift from event onset (s)','y','beta');
    i(1,1).set_color_options('chroma',0,'lightness',30);

    i(1,2)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelPoxDS);
    i(1,2).set_title('DS PE Kernel');
    i(1,2).stat_summary('type','sem','geom','area');
    i(1,2).set_names('x','time shift from event onset (s)','y','beta');
    i(1,2).set_color_options('chroma',0,'lightness',30);

    i(1,3)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelLoxDS);
    i(1,3).set_title('DS Lick Kernel');
    i(1,3).stat_summary('type','sem','geom','area');
    i(1,3).set_names('x','time shift from event onset (s)','y','beta');
    i(1,3).set_color_options('chroma',0,'lightness',30);



    %second column with peri-event traces
    i(2,1)=gramm('x',data.timeLock,'y',data.DSblue);
    i(2,1).set_title('Peri-DS');
    i(2,1).stat_summary('type','sem','geom','area');
    i(2,1).set_names('x','time from event (s)','y','z-score');
    i(2,1).set_color_options('chroma',0,'lightness',30);


    i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
    i(2,2).set_title('Peri-DS PE');
    i(2,2).stat_summary('type','sem','geom','area');
    i(2,2).set_names('x','time from event (s)','y','z-score');
    i(2,2).set_color_options('chroma',0,'lightness',30);
    i(2,2).set_line_options('base_size',2);


    i(2,3)=gramm('x',data.timeLock,'y',data.DSblueLox);
    i(2,3).set_title('Peri-DS Lick');
    i(2,3).stat_summary('type','sem','geom','area');
    i(2,3).set_names('x','time from event (s)','y','z-score');
    i(2,3).set_color_options('chroma',0,'lightness',30);
    i(2,3).set_line_options('base_size',2);


%     i.draw();
% 
%     %plot Individual Subjects overlay~~~
%     i(1,1).update('color',kernelTable.subject);
%     % i(1,1).set_title('DS Kernel');
%     % i(1,1).stat_summary('type','sem','geom','area');
%     i(1,1).geom_line('alpha',0.5);
%     i(1,1).set_color_options();
%     i(1,1).set_line_options('base_size',0.5);
% 
% 
%     i(1,2).update('color',kernelTable.subject);
%     % i(1,2).set_title('DS PE Kernel');
%     % i(1,2).stat_summary('type','sem','geom','area');
%     i(1,2).geom_line('alpha',0.5);
%     i(1,2).set_color_options();
%     i(1,2).set_line_options('base_size',0.5);
% 
% 
%     i(1,3).update('color',kernelTable.subject);
%     % i(1,3).set_title('DS Lick Kernel');
%     % i(1,3).stat_summary('type','sem','geom','area');
%     i(1,3).geom_line('alpha',0.5);
%     i(1,3).set_color_options();
%     i(1,3).set_line_options('base_size',0.5);
% 
% 
% 
%     %second column with peri-event traces
%     i(2,1).update('color',data.subject);
%     i(2,1).stat_summary('type','sem','geom','area');
%     i(2,1).set_color_options();
%     i(2,1).set_line_options('base_size',0.5);
% 
% 
%     i(2,2).update('color',data.subject);
%     i(2,2).stat_summary('type','sem','geom','area');
%     i(2,2).set_color_options();
%     i(2,2).set_line_options('base_size',0.5);
% 
% 
%     i(2,3).update('color',data.subject);
%     i(2,3).stat_summary('type','sem','geom','area');
%     i(2,3).set_color_options();
%     i(2,3).set_line_options('base_size',0.5);



    i.set_title(subject);

    %manually set axes limits before drawing
    i(1,:).axe_property('YLim',[-2, 5]);
    i(2,:).axe_property('YLim',[-2, 5]);

    i.draw();

    linkaxes(gca,'x');

    saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels_w_periEvent'),figFormats);
end

%% old
% %% Kernels + peri-event plot
% %individual subjects
% stage= 7;
% 
% %want 465nm
% signal= 465;
% 
% %Parameters we ran through encoding model
% %how much time should you shift back (in seconds)
% time_back=5;
% time_forward=10;
% 
% %events corresponding to kernels
% cons={'DS','poxDS','loxDS'}; 
% k= numel(cons);
% 
% 
% if stage==7 && signal==465
%     %path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
%     pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465';
%     
%     %loop through files and extract data
%     cd(pathLasso);
%     mat = dir('*.mat');
%     for file= 1:length(mat)
%         %load LASSO results
%         lassoOutput(file) = load(mat(file).name);
%         
%         b= lassoOutput(file).b;
%         
%         %isolate kernels for each eventType
%         %make figure for indidivual subj (1 per file)
% %         figure();
% %         sgtitle(mat(file).name);
%         for eventType = 1:k
% %             kernel=[];
%              %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
%               if eventType==1
%                 tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
%               else
%                 tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
%               end
% 
%            sumTerm= []; %clear between event types
% 
%            for ts= 1:(numel(b)/k) %loop through ts; using 'ts' for each timestamp instead of 'i'
%         %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
%                 kernel(ts,eventType) = b(tsThisEvent(ts));
%            end
%            
%            %subplot each kernel
%            timeLock= linspace(-time_back, time_forward, size(kernel,1));
% %            subplot(k,2,eventType);
% %            plot(timeLock, kernel(:,eventType));
% %            title(cons(eventType));
%            
%            
%         end
%        
%            
%            %subset periEvent data for plotting
%            data= periEventTable;
%            data= data(data.stage==7,:); 
%            %find subject from filename
%            subject= strfind(mat(file).name, 'rat');
%            subject= mat(file).name(subject:end);
%            subject= subject(1:strfind(subject,'_')-1);
%            %subset data for this subj
%            data= data(~cellfun(@isempty,strfind(data.subject,subject)),:);
%            
%            %now subplot peri-event data!!
% %            subplot(k,2,4); title('peri-DS');
% %            hold on;
% %            plot(data.timeLock, data.DSblue);
% %          
% %            subplot(k,2,5); title('peri-DS Pox');
% %            hold on;
% %            plot(data.timeLock, data.DSbluePox);
% %          
% %            subplot(k,2,6); title('peri-DS Lox');
% %            hold on;
% %            plot(data.timeLock, data.DSblueLox);
%          
% 
%            %nice plot w gramm
%            clear i;
%            figure(); hold on;
% 
%            %first column with kernels
%            %TODO: check axes
%            i(1,1)=gramm('x',timeLock,'y',kernel(:,1));
%            i(1,1).set_title('DS Kernel');
%            i(1,1).stat_summary('type','sem','geom','area');
%            i(1,1).set_names('x','time from event (s)','y','beta');
%            
%            i(2,1)=gramm('x',timeLock,'y',kernel(:,2));
%            i(2,1).set_title('DS PE Kernel');
%            i(2,1).stat_summary('type','sem','geom','area');
%            i(2,1).set_names('x','time from event (s)','y','beta');
%            
%            i(3,1)=gramm('x',timeLock,'y',kernel(:,3));
%            i(3,1).set_title('DS Lick Kernel');
%            i(3,1).stat_summary('type','sem','geom','area');
%            i(3,1).set_names('x','time from event (s)','y','beta');
%            
%            
%            %second column with peri-event traces
% 
%            i(1,2)=gramm('x',data.timeLock,'y',data.DSblue);
%            i(1,2).set_title('Peri-DS');
%            i(1,2).stat_summary('type','sem','geom','area');
%            i(1,2).set_names('x','time from event (s)','y','z-score');
%            
%            i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
%            i(2,2).set_title('Peri-DS PE');
%            i(2,2).stat_summary('type','sem','geom','area');
%            i(2,2).set_names('x','time from event (s)','y','z-score');
%            
%            i(3,2)=gramm('x',data.timeLock,'y',data.DSblueLox);
%            i(3,2).set_title('Peri-DS Lick');
%            i(3,2).stat_summary('type','sem','geom','area');
%            i(3,2).set_names('x','time from event (s)','y','z-score');
%            
%            
%            i.set_title(mat(file).name);
%                       
%            %manually set axes limits before drawing
%            i(:,1).axe_property('YLim',[-0.5, 1.5]);
%            i(:,2).axe_property('YLim',[-2, 5]);
% 
%            i.draw();
%                     
%            linkaxes(gca,'x');
%            
%         saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels_w_periEvent'),figFormats);
% 
%   
%     end
%    
%     
% end
