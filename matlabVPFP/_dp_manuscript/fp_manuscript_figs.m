%% Initialize variables
figPath= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\'
figFormats= {'.fig','.png'} %list of formats to save figures as (for saveFig.m)

%% Load fpAnalyzedData struct
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-17-Dec-2021subjDataAnalyzed.mat")
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-05-Jan-2022subjDataAnalyzed.mat")



%% Create periEventTable and make peri-event 465nm plots
fp_manuscript_periEventTraces();

%% load encoding model output 
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\allSubjResultskernel_Shifted_all.mat")

%% Encoding Model Kernels Figure

%Plot of encoding model kernels alongside peri-DS traces:
%1) Between-subjects and 2) For each individual subject

% Load output from the encoding model for each subject

%Define which Stage/Session to plot
%Want stage 7 (1s pump onset delay) after meeting criteria

%TODO: Review what was actually run through the model, this is just
%grabbing output

stage= 7

%want 465nm
signal= 465

%Parameters we ran through encoding model
%how much time should you shift back (in seconds)
time_back=5;
time_forward=10;

%events corresponding to kernels
cons={'DS','poxDS','loxDS'}; 
k= numel(cons);


if stage==7 && signal==465
    %path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
    pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465'
    
    %just figures:
%     %Figure path to between-subjects mean of all kernels
%     pathMeanLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\_output\output_stage7_465\Avg kernels across animals'
% 
%     %Figure path to latency sorted heatplots
%     pathHeat= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\_output\output_stage7_465\Latencysorted_heatplots'
    
    %loop through files and extract data
    cd(pathLasso);
    mat = dir('*.mat');
    for file= 1:length(mat)
        %load LASSO results
        lassoOutput(file) = load(mat(file).name);
        
        b= lassoOutput(file).b;
        
        %isolate kernels for each eventType
        %make figure for indidivual subj (1 per file)
        figure();
        sgtitle(mat(file).name);
        for eventType = 1:k
            kernel=[];
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
           
           %subplot each kernel
           timeLock= linspace(-time_back, time_forward, size(kernel,1));
           subplot(k,1,eventType);
           plot(timeLock, kernel(:,eventType));
           title(cons(eventType));
        end
        
        saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels'),figFormats);

  
    end
   
    
end


%% Kernels + peri-event plot
stage= 7

%want 465nm
signal= 465

%Parameters we ran through encoding model
%how much time should you shift back (in seconds)
time_back=5;
time_forward=10;

%events corresponding to kernels
cons={'DS','poxDS','loxDS'}; 
k= numel(cons);


if stage==7 && signal==465
    %path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
    pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465'
    
    %loop through files and extract data
    cd(pathLasso);
    mat = dir('*.mat');
    for file= 1:length(mat)
        %load LASSO results
        lassoOutput(file) = load(mat(file).name);
        
        b= lassoOutput(file).b;
        
        %isolate kernels for each eventType
        %make figure for indidivual subj (1 per file)
        figure();
        sgtitle(mat(file).name);
        for eventType = 1:k
%             kernel=[];
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
           
           %subplot each kernel
           timeLock= linspace(-time_back, time_forward, size(kernel,1));
           subplot(k,2,eventType);
           plot(timeLock, kernel(:,eventType));
           title(cons(eventType));
           
           
        end
       
           
           %subset periEvent data for plotting
           data= periEventTable;
           data= data(data.stage==7,:); 
           %find subject from filename
           subject= strfind(mat(file).name, 'rat');
           subject= mat(file).name(subject:end);
           subject= subject(1:strfind(subject,'_')-1);
           %subset data for this subj
           data= data(~cellfun(@isempty,strfind(data.subject,subject)),:);
           
           %now subplot peri-event data!!
           subplot(k,2,4); title('peri-DS');
           hold on;
           plot(data.timeLock, data.DSblue);
         
           subplot(k,2,5); title('peri-DS Pox');
           hold on;
           plot(data.timeLock, data.DSbluePox);
         
           subplot(k,2,6); title('peri-DS Lox');
           hold on;
           plot(data.timeLock, data.DSblueLox);
         

           %nice plot w gramm
           %second column with peri-event traces
           figure(); hold on;
           
           i(1,2)=gramm('x',data.timeLock,'y',data.DSblue);
           i(1,2).set_title('Peri-DS');
           i(1,2).stat_summary('type','sem','geom','area');
           i(1,2).set_names('x','time from event (s)','y','z-score');
           
           i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
           i(2,2).set_title('Peri-DS PE');
           i(2,2).stat_summary('type','sem','geom','area');
           i(2,2).set_names('x','time from event (s)','y','z-score');
           
           i(3,2)=gramm('x',data.timeLock,'y',data.DSblueLox);
           i(3,2).set_title('Peri-DS Lick');
           i(3,2).stat_summary('type','sem','geom','area');
           i(3,2).set_names('x','time from event (s)','y','z-score');
           
           %first column with kernels
           %TODO: check axes
           i(1,1)=gramm('x',timeLock,'y',kernel(:,1));
           i(1,1).set_title('DS Kernel');
           i(1,1).stat_summary('type','sem','geom','area');
           i(1,1).set_names('x','time from event (s)','y','beta');
           
           i(2,1)=gramm('x',timeLock,'y',kernel(:,2));
           i(2,1).set_title('DS PE Kernel');
           i(2,1).stat_summary('type','sem','geom','area');
           i(2,1).set_names('x','time from event (s)','y','beta');
           
           i(3,1)=gramm('x',timeLock,'y',kernel(:,3));
           i(3,1).set_title('DS Lick Kernel');
           i(3,1).stat_summary('type','sem','geom','area');
           i(3,1).set_names('x','time from event (s)','y','beta');
           
           i.set_title(mat(file).name);
           i.draw();
           
           linkaxes();
           
        saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels_w_periEvent'),figFormats);

  
    end
   
    
end
