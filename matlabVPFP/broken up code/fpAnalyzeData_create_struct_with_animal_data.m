%fp data analysis 
%1/20/20
clear
clc
close all

% Make sure the figPath is correct!
% 
cd('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code');
addpath('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\Figs');
figPath = 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\justrawFigs\VPFP\'; %location for output figures to be saved

% addpath('G:\Shared drives\Richard Lab\Data\Ally\VPLHFP Figs\');
% figPath = 'G:\Shared drives\Richard Lab\Data\Ally\VPLHFP Figs\'; %location for output figures to be saved


% %% Load struct containing data organized by subject
disp('***select a .mat file generated by fpExtractData.m')

load(uigetfile('*.mat')); %choose the subjData file to open for your experiment %by default only show .mat files

profile on; %For optimization/tracking performance of the code- this starts the Matlab profiler

figureCount= 1 ; %keep track of figure # throughout to prevent overwriting

fs= 40; %This is important- if you change sampling frequency of photometry recordings for some reason, change this too! TODO: just save this in subjData as more metadata
%% Remove excluded subjects

excludedSubjs= {'rat16','rat10','rat20'}; 
% excludedSubjs= {'rat19','rat17','rat15','rat14','rat13','rat12','rat11','rat9','rat8'} %cell array with strings of excluded subj fieldnames

subjData= rmfield(subjData,excludedSubjs);

subjects= fieldnames(subjData); %get an updated list of included subjs

subjIncluded= subjects;
%% Create subjDataAnalyzed struct to hold analyzed data
%In this section, we'll initialize a subjDataAnalyzed struct to hold any
%relevant analyzed data separately from raw data. We will populate it with
%some metadata before doing any analyses. This metadata all originates from
%the metadata.xlsx file and the subjData struct generated by
%fpExtractData.m

%Fill with metadata
 for subj= 1:numel(subjects) %for each subject
   for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
       currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
       
       experimentName= currentSubj(session).experiment; 
       
       subjDataAnalyzed.(subjects{subj})(session).experiment= currentSubj(session).experiment;
       
       subjDataAnalyzed.(subjects{subj})(session).date= currentSubj(session).date;
       
       subjDataAnalyzed.(subjects{subj})(session).rat= currentSubj(session).rat;
       subjDataAnalyzed.(subjects{subj})(session).fileName= currentSubj(session).fileName;
       subjDataAnalyzed.(subjects{subj})(session).trainDay= currentSubj(session).trainDay;
       subjDataAnalyzed.(subjects{subj})(session).trainStage= currentSubj(session).trainStage;
       subjDataAnalyzed.(subjects{subj})(session).box= currentSubj(session).box;       
   end %end session loop
end %end subject loop

% %% Number the start dates for each rat and display any errors
% Rat = subjDataAnalyzed.rat{1};% initializing at first animal
% k = 1;
% for i=1:length(subjDataAnalyzed.date)
%     RatinTable=subjDataAnalyzed.rat{i};
%     if RatinTable==Rat% if TrainingData.StartDate and Rat are the same, will give you logical 1, and TraindayData.Day(i,1)=k
%          subjDataAnalyzed.(subjects{subj})(session).trainDay(i,1) = k;
%         k = k + 1;% add one to k everytime there is another day for the same subject
%         if i < length(TrainingData.StartDate) && TrainingData.StartDate{i} == TrainingData.StartDate{i+1} % check if the date in next row is the same as the current one
%             fprintf('repeated date %d with rat %s\n', TrainingData.StartDate{i}, TrainingData.Subject{i});
%         end
%     else
%         k = 1;% reinitialize for another animal
%         Rat = subjDataAnalyzed.rat{i};
%         TrainingData.Day(i,1) = k;
%         k = k + 1;% then  add 1 to k to keep going through if loop
%     end
% end


%% Photobleach correction
 %Going for something like (Patel et al 2019 bioRxiv)
for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       clear cutTime reblue repurple
       
       cutTime= currentSubj(session).cutTime;
       reblue= currentSubj(session).reblue;
       repurple= currentSubj(session).repurple;
   
     %let's fit an exponential function to the blue and purple signals

     %First order exponential fit
% ft=fittype('exp1');
% currentSubj(session).blueFit=fit(cutTime',reblue,ft);
% currentSubj(session).purpleFit=fit(cutTime',repurple,ft);

    %matlab's built in detrend function 
% detrendblue= detrend(reblue, 2);
% detrendpurple= detrend(repurple, 2);
%      
     
         %matlab's built in moving median function
         %inspired by(Patel, McAlinden, Matheison, &
         %Sakata, 2019 BioRxiv) but not really what they did
    medianblue= movmedian(reblue,800);
    medianpurple= movmedian(repurple, 800); %40=1s %800 = 20s
    
    dffblue= (reblue-medianblue)./medianblue;
    dffpurple= (repurple-medianpurple)./medianpurple;
    
    subjDataAnalyzed.(subjects{subj})(session).photometry.bluedff= dffblue;
    subjDataAnalyzed.(subjects{subj})(session).photometry.purpledff= dffpurple;
    subjDataAnalyzed.(subjects{subj})(session).photometry.cutTime= cutTime;
   end %end session loop
end %end subject loop

%% Fitting and df/f 
for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       clear cutTime reblue repurple fit fit
       
       cutTime= currentSubj(session).cutTime;
       reblue= currentSubj(session).reblue;
       repurple= currentSubj(session).repurple;

% ControlFit (fits 2 signals together)
       fit= controlFit(reblue, repurple);
       subjDataAnalyzed.(subjects{subj})(session).photometry.fit= fit;

% Delta F/F 
       df = deltaFF(reblue,fit); %This is dF for boxA in %, calculated by running the deltaFF function on the resampled blue data from boxA and the fitted data from boxA
       subjDataAnalyzed.(subjects{subj})(session).photometry.df= df;
       
   end %end session loop
end %end subject loop
%% ~~~Reward identification ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %fpr stages with variable reward identity (3 pumps, 3 rewards)
    %indicated by 1, 2, or 3 DS TTL pulses in rapid succession
    
    ttlWindow= 2; %time window within which to look for DS TTL pulse bursts ... %2s should be enough
    
    %TODO: consider moving this to fpextractdata.m
    
 for subj= 1:numel(subjects) %for each subject
       for session = 1:numel(subjData.(subjects{subj})) %for each training session this subject completed
           currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
                      
           if ~isnan(currentSubj(session).pump2) %make sure this is a valid stage with multiple rewards
               
                %first lets save reward identity for each pump
               subjDataAnalyzed.(subjects{subj})(session).reward.pump1= currentSubj(session).pump1;
               subjDataAnalyzed.(subjects{subj})(session).reward.pump2= currentSubj(session).pump2;
               subjDataAnalyzed.(subjects{subj})(session).reward.pump3= currentSubj(session).pump3;
               
               %now we've got to classify DS trials as either pump1,2,or 3
               %based on ttl pulses
               
%                DSttl= currentSubj(session).DS;
               
               DScount = 1; %keep track of the actual ds trial count (because we'll have a bunch of extra TTL pulses simply denoting reward identity)
               
               ttlCount= 1; %use this to skip over TTL pulses in the same trial
              
               for cue= 1:numel(currentSubj(session).DS) %for each DS TTL pulse
                   
                   if ttlCount < numel(currentSubj(session).DS) %since we are adding to ttlCount this just prevents us from going beyond the max index
                   
                       ttlWindowStartTime= currentSubj(session).DS(ttlCount)-ttlWindow;
                       ttlWindowEndTime= currentSubj(session).DS(ttlCount)+ttlWindow;

                       ttlPump= currentSubj(session).DS(currentSubj(session).DS > ttlWindowStartTime & currentSubj(session).DS < ttlWindowEndTime);

                       %save the DS onset as the first TTL pulse in this window (the minimum timestamp)
                       subjDataAnalyzed.(subjects{subj})(session).reward.DS(DScount,1)= min(ttlPump); 
                       
                       %get this shifted timestamp too (because its used in timelocking)
                       subjDataAnalyzed.(subjects{subj})(session).reward.DSshifted(DScount,1)= subjData.(subjects{subj})(session).DSshifted(ttlCount);


                       %save the pump identity based on the # of TTL pulses in this window (numel)

                        if numel(ttlPump) == 1
                            subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(DScount,1)= 1;                                                       
                            DScount= DScount+1;
                            ttlCount= ttlCount+1;
                        elseif numel(ttlPump) ==2
                            subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(DScount,1)= 2;
                            DScount= DScount+1;
                            ttlCount = ttlCount+2; %skip over the next cue ttl pulse because it is in the same trial
                        elseif numel(ttlPump) ==3
                            subjDataAnalyzed.(subjects{subj})(session).reward.DSreward(DScount,1)= 3;
                            DScount= DScount+1;
                            ttlCount = ttlCount+3; %skip over the next two cue ttl pulses because these are in the same trial 
                        end
                                               
                   end %end ttlCount conditional
               end %end cue loop
          
                  
               %for simplicity let's overwrite the original DS trial record with
               %the updated one %TODO: think about other ways to address this
               subjData.(subjects{subj})(session).DS= subjDataAnalyzed.(subjects{subj})(session).reward.DS;
               subjData.(subjects{subj})(session).DSreward= subjDataAnalyzed.(subjects{subj})(session).reward.DSreward;
               subjData.(subjects{subj})(session).DSshifted= subjDataAnalyzed.(subjects{subj})(session).reward.DSshifted;

         
               
            else %if there's no variable reward in this session, make empty
                       
                subjDataAnalyzed.(subjects{subj})(session).reward= [];              
               
            end %end if pump 2 isnan conditional (alternative to stage conditional)

       
       end %end session loop

       
end %end subject loop


 