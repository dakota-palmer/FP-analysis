%% Initialize variables
figPath= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\'
figFormats= {'.fig','.png'} %list of formats to save figures as (for saveFig.m)

%% Load fpAnalyzedData struct
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\VP-VTA-FP-04-Oct-2021subjDataAnalyzed.mat")

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

