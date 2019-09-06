% Fiber Photometry Analysis
% 9/5/19
clear
clc
close all
%originally adapted from JocelynPhotometryRetro.m

%Make sure you have the vpfpIndex excel sheet filled out properly and paths are correct

%% Use excel spreadsheet as index to load all .NEXs along with subject # and experiment details etc.

% TODO: read whole index and analyze >2 rats at a time
% TODO: fix rat names and other sesData (always showing 2 and 3 currently)

indexAddress = 'C:\Users\Dakota\Desktop\FP-analysis-master\nexFilesVPFP\vpfpIndex_template.xlsx'; % excel file location 

nexAddress =  'C:\Users\Dakota\Desktop\FP-analysis-master\nexFilesVPFP'; % nex file location 
nexFiles=dir([nexAddress,'//*.nex']); %find all .nex files within this address

figPath= 'C:\Users\Dakota\Desktop\FP-analysis-master\matlabVPFP\figures\'; %location for output figures to be saved

runAnalysis= 1; %logic gate for running typical DS training analysis... will not run if an atypical DS training session is loaded (e.g. magazine training session where stage =0)

%% load nex data
sesNum = 0; %for looping- simply analyzing all data from a given session simultaneously (currently 2 boxes per session- A and B)

for file = 1:length(nexFiles) % All operations will be applied to EVERY nexFile  
    
    clearvars -except file nexFiles indexAddress nexAddress sesNum sesData subjData figPath runAnalysis; %% CLEAR ALL VARIABLES between sessions (except a few)- this way we ensure there isn't any data contamination between sessions
    
    fName = nexFiles(file).name; %define the nex file name to load
    data = readNexFile([nexAddress,'//',fName]); %load the nex file data
    disp(strcat(fName, ' file # ', num2str(file), '/', num2str(length(nexFiles))));
    
    sesNum=sesNum+1; %increment the loop
     
    [~,~,excelData] = xlsread(indexAddress); %import metadata from excel spreadsheet
    fileIndex= find(strcmp(excelData(:,1),fName)); %search the spreadsheet data for the matching fileName to get index for matching metadata
    
    sesData(file).ratA= excelData{fileIndex,2}(); %assign appropriate metadata...These values must be changed if the spreadsheet column organization is changed
    sesData(file).ratB = excelData{fileIndex,3}();
    sesData(file).trainStage = excelData{fileIndex,4}();
    sesData(file).trainDay = excelData{fileIndex,5}();

    
    disp(strcat('rat A = ', num2str(sesData(file).ratA), ' ; rat B = ', num2str(sesData(file).ratB), ' ; trainStage = ', num2str(sesData(file).trainStage), ' ; trainDay = ', num2str(sesData(file).trainDay))); 
    
%% define contvars (photometer data)

%find the appropriate 465nm and 405nm data from each box (by name) and assign it to the correct variable
for i= 1:numel(data.contvars)
   blueAindex= contains(data.contvars{i,1}.name, 'Dv1A');
   purpleAindex= contains(data.contvars{i,1}.name, 'Dv2A');
   
   blueBindex= contains(data.contvars{i,1}.name, 'Dv3B');
   purpleBindex= contains(data.contvars{i,1}.name, 'Dv4B');
   
   if(blueAindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
       blueA = data.contvars{i,1}.data;
%        disp(strcat('465A contvar index= ', num2str(i))); %keep for debugs
   end
   
   
   if(purpleAindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
       purpleA = data.contvars{i,1}.data;
%        disp(strcat('405A contvar index= ', num2str(i))); %keep for debugs
   end
   
   
  if(blueBindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
       blueB = data.contvars{i,1}.data;
%        disp(strcat('465B contvar index= ', num2str(i))); %keep for debugs
   end
   
   if(purpleBindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
        purpleB = data.contvars{i,1}.data;
%        disp(strcat('405B contvar index= ', num2str(i))); %keep for debugs
   end     
end


% %Flag any change in the contvar nex file structure for photometer data-
% %this should not be an issue now that these are assigned programatically(see below)
% if contains(data.contvars{1,1}.name, 'Dv4B') ~=1
%    disp('***********CHECK THE CONTVARS 1*************');
% elseif contains(data.contvars{2,1}.name, 'Dv3B') ~=1
%    disp('***********CHECK THE CONTVARS 2*************');
% elseif contains(data.contvars{3,1}.name, 'Dv2A') ~=1
%    disp('***********CHECK THE CONTVARS 3*************');
% elseif contains(data.contvars{4,1}.name, 'Dv1A') ~=1
%    disp('***********CHECK THE CONTVARS 4*************');   
% end
% 
% if contains(data.contvars{1,1}.name, 'Dv4B') ~=1
%    disp('***********CHECK THE CONTVARS 1*************');
% elseif contains(data.contvars{2,1}.name, 'Dv3B') ~=1
%    disp('***********CHECK THE CONTVARS 2*************');
% elseif contains(data.contvars{3,1}.name, 'Dv2A') ~=1
%    disp('***********CHECK THE CONTVARS 3*************');
% elseif contains(data.contvars{4,1}.name, 'Dv1A') ~=1
%    disp('***********CHECK THE CONTVARS 4*************');   
% end
% 
% disp(strcat(data.contvars{1,1}.name, ' ', data.contvars{2,1}.name, ' ', data.contvars{3,1}.name, ' ', data.contvars{4,1}.name));

%% define events; Since nexfile organization differs, search the nexfile and define events programmatically
%Define timescale for each event in seconds
fs = data.contvars{1,1}.ADFrequency; %Frequency of sampling- todo: double check this (should not be a fraction?)
sesData(file).fs = fs; %may be useful for debugging/comparing fs between sessions

rawTime = linspace(data.tbeg, data.tend, length(blueA)); %define a time axis based on the beginning time and end time with length(blueA) timestamps

%TODO: If you have an input missing on a given day in Synapse (e.g. a camera went out), the shape of data.events will be off and you will need to add some kind of exception here (see below for example rat2 day 14)

%Search NEX file for events- MUST search because their location differs between files
for i = 1:numel(data.events) %search through all event channels for matching name
   
   %contains() will return 0 or 1 (false or true) based on whether the string of interest (e.g. 'DS') is within the event series name
   DSindex= contains(data.events{i,1}.name, 'DS');
   NSindex= contains(data.events{i,1}.name, 'NS');
   
   poxAindex= contains(data.events{i,1}.name, 'Pox1');
   loxAindex= contains(data.events{i,1}.name, 'Lox1');
   
   poxBindex= contains(data.events{i,1}.name, 'Pox2');
   loxBindex= contains(data.events{i,1}.name, 'Lox2');
   
   if(DSindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
       DS = data.events{i,1}.timestamps;
%        disp(strcat('DS event index= ', num2str(i))); %keep for debugs
   end
   
   
   if(NSindex ==1)
       NS = data.events{i,1}.timestamps;
%        disp(strcat('NS event index= ', num2str(i)));
   end
   
   
   if(poxAindex ==1)
       poxA = data.events{i,1}.timestamps;
%        disp(strcat('poxA event index= ', num2str(i)));
   end
   
   if(loxAindex ==1)
       loxA = data.events{i,1}.timestamps;
%        disp(strcat('loxA event index= ', num2str(i)));
   end
   
   if(poxBindex ==1)
       poxB = data.events{i,1}.timestamps;
%        disp(strcat('poxB event index= ', num2str(i)));
   end
   
  if(loxBindex ==1)
       loxB = data.events{i,1}.timestamps;
%        disp(strcat('loxB event index= ', num2str(i)));
  end
    
   
end

%%%%%%%%%%%%%%%Analysis start; comment up to this point to debug .nex data import/assignment

%% Downsample signals
%Downsample to 40hz from fs
reblueA=resample(blueA,40,round(fs));       %Downsample to 40Hz from fs %consider using downsample() function here instead of resample()?
repurpleA=resample(purpleA,40,round(fs));

reblueB=resample(blueB,40,round(fs));
repurpleB=resample(purpleB,40,round(fs));

reTime= linspace(data.tbeg, data.tend, length(reblueA));     %Create time axis in seconds based on this resampling- so that each intensity value has a corresponding timestamp
 
% figure;
% plot(reTime, rePurpleA, 'm'); %plot the resampled control (405nm; purple) signal over the resampled time axis
% hold on
% plot(reTime, reBlueA, 'b');
% title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' Downsampled box A'));
% 
% figure; 
% plot(reTime, rePurpleB, 'm');
% hold on
% plot(reTime, reBlueB, 'b');
% title(strcat('Rat #',num2str(sesData(file).ratB),' training day :', num2str(sesData(file).trainDay), ' Downsampled box B'));

%% remove several initial and final data points to eliminate artifacts
numExclude = 400;                                   % define the number of data points to exclude- here 400 = 10s of data(remember, 40Hz downsample so 400/40 = 10s)
repurpleA = repurpleA(numExclude:end-numExclude);    % 405nm data from box A ; here I simply redefined repurpleA as rePurpleA minus the number of excluded data points from both the beginning and end defined above (400)
reblueA = reblueA(numExclude:end-numExclude);       % 470nm data from box A

repurpleB = repurpleB(numExclude:end-numExclude);   % 405nm data from box B
reblueB = reblueB(numExclude:end-numExclude);       % 470nm data from box B

cutTime = reTime(numExclude:end-numExclude);        % define cutTime as a new time axis w/o removed points- remember each intensity value should have a corresponding timestamp
fs=40;      

%Based on training stage, define cue length - may consider adding this into the spreadsheet itself in case training protocol changes
if sesData(file).trainStage==1
    cueLength= 60*fs;
elseif sesData(file).trainStage==2
    cueLength= 30*fs;
elseif sesData(file).trainStage==3
    cueLength=20*fs;
else
    cueLength=10*fs; %cue is 10s on both stage 4 and 5
end


%% Raw plots (downsampled and cut data - so not really raw here, but prior to fitting the 465nm and 405nm signals together/subtraction/dF calc) %%% figure(sesNum)
% subplot (4,1,1)
% plot(cutTime,repurpleA, 'm');
% hold on
% plot(cutTime,reblueA, 'b');
% % % plot(DS, 100, 'rx'); %You can plot DS, PEs and licks here but it's not very helpful
% % % plot(poxA, 150, 'go');
% % % plot(loxA, 200, 'k*');
% title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' downsampled box A'));
% 
% figure(sesNum)
% subplot (4,1,2)
% plot(cutTime,repurpleB, 'm');
% hold on
% plot(cutTime,reblueB, 'b');
% % % plot(DS, 100, 'rx');
% % % plot(poxB, 150, 'go');
% % % plot(loxB, 200, 'k*');
% title(strcat('Rat #',num2str(sesData(file).ratB),' training day :', num2str(sesData(file).trainDay), ' downsampled box B'));

%% ControlFit (fits 2 signals together)
fitA= controlFit(reblueA, repurpleA);
fitB= controlFit(reblueB, repurpleB);

%% Fitted plots %%
% figure(sesNum)
% subplot (4,1,1) %fitted overlaid on same subplot as blue&purple
%hold on
% plot(cutTime, fitA,'g');
% title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' ControlFit box A'));
% legend('purple','blue','controlfit')
% figure(sesNum)
% subplot (4,1,2)
%hold on
% plot(cutTime, fitB,'g');
% title(strcat('Rat #',num2str(sesData(file).ratB),' training day :', num2str(sesData(file).trainDay), ' ControlFit box B'));
% legend('purple','blue','controlfit')

%% Delta F/F 
dfA = deltaFF(reblueA,fitA); %This is dF for boxA in %, calculated by running the deltaFF function on the resampled blue data from boxA and the fitted data from boxA
dfB = deltaFF(reblueB,fitB);

%% dF plots %%
% figure(sesNum)
% subplot (4,1,3)
%hold on
% plot(cutTime, dfA);
% title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' dF/F box A'));
% ylabel('% dF');
% 
% figure(sesNum)
% subplot (4,1,4)
%hold on
% plot(cutTime, dfB);
% title(strcat('Rat #',num2str(sesData(file).ratB),' training day :', num2str(sesData(file).trainDay), ' dF/F box B'));
% ylabel('% dF');

%% SAVE PLOTS OF overlaid fitted 405nm signal and 465nm signal - should be easier to see dynamic Ca2+ events, saves plots as .fig
figure()
plot(cutTime,reblueA, 'b');
hold on
plot (cutTime, fitA, 'm');
title(strcat('Rat #',num2str(sesData(file).ratA),' training day :', num2str(sesData(file).trainDay), ' downsample box A & fit A'));
legend('blue','controlfit')

%Save the figure and close
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'VPFP_rat_ ', num2str(sesData(file).ratA),'photometry traces', 'day ', num2str(sesData(file).trainDay), 'box A', '.fig')); %save the current figure in fig format
close; %close 

figure()
plot(cutTime,reblueB, 'b');
hold on
plot (cutTime, fitB, 'm');
title(strcat('Rat #',num2str(sesData(file).ratB),' training day :', num2str(sesData(file).trainDay), ' downsample box B & fit B'));
legend('blue','controlfit')

%Save the figure and close
set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
saveas(gcf, strcat(figPath,'VPFP_rat_ ', num2str(sesData(file).ratB),'photometry traces', 'day ', num2str(sesData(file).trainDay), 'box B', '.fig')); %save the current figure in fig format
close; %close 

%% If this is not active DS training session (e.g. if it's magazine training) - Break out here 

if sesData(file).trainStage ==0
    disp('loaded magazine training session- loading next session, wont run any analysis');
    runAnalysis=0;
    continue
end

%% Event-triggered analysis of dF & z-score timelocked to cue presentation 
%In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or NS)
%Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
%Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  

%here we are establishing some variables for our event triggered-analysis
periCueTime = 20;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  

slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)

% disp(strcat('cueLength= ', num2str(cueLength))); %debug

   DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)


for cue=1:length(DS) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset
    
    DSonset = DS(cue,1); %each entry in DS is a timestamp of the DS onset before downsampling- this needs to be aligned with our current time axis   
    
    %find closest value (min difference) in cutTime (the current time axis) to DSonset by subtraction
    for ts = 1:length(cutTime) %for each timestamp in cutTime 
        timeDiff(1,ts) = abs(DSonset-cutTime(ts)); %get the absolute difference between this cue's actual timestamp and each resampled timestamp- define this as timeDiff
    end
    
    [~,DSonsetShifted] = min(timeDiff); %Find the timestamp with the minimum difference- this is the index of the closest timestamp in cutTime to the actual DSonset- define this as DSonsetShifted
    
    
    timeShift= cutTime(DSonsetShifted)-DS(cue,1);  %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
    if abs(timeShift) >0.5 %this will flag cues whose time shift deviates above a threshold (in seconds- 0.5s)
    disp(strcat('>>Error *big cue time shift cue# ', num2str(cue), 'shifted DS ', num2str(cutTime(DSonsetShifted)), ' - actual DS ', num2str(DS(cue,1)), ' = ', num2str(timeShift), '*'));
    end
    
    %define the frames (datapoints) around each cue to analyze
    preEventTime = DSonsetShifted-periCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periCueFrames (now this is equivalent to 20s before the shifted cue onset)
    postEventTime = DSonsetShifted+periCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periCueFrames (now this is equivalent to 20s after the shifted cue onset)
        
   if preEventTime< 1 %TODO: Double check this
      disp(strcat('****DS cue ', num2str(cue), ' too close to beginning, breaking out'));
      DSskipped= DSskipped+1;
      break
   end
  
   if postEventTime> length(cutTime)-slideTime %if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
      disp(strcat('****DS cue ', num2str(cue), ' too close to end, breaking out'));
      DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
      break %break out of the loop and move onto the next DS cue
   end
       
    % Classify PEs and licks occuring during the DS 
    %this is placed here because we're doing this analysis for every single cue (we are still in the DS cue loop)
    %also worth noting that cues come on for both boxes at the same time
     
    %first, find all the PEs during that cue
    %poxA
    for i= 1:numel(poxA) %for every port entry made in boxA
       if (cutTime(DSonsetShifted)<poxA(i)) && (poxA(i)<cutTime(DSonsetShifted+cueLength))%if the port entry occurs between this cue's onset and this cue's offset, assign it to this cue
           poxADS(i,cue)= poxA(i); %poxADS will contain all of the port entries made during each cue (if any)
%            disp(strcat('cue ', num2str(cue), 'pox ',num2str(poxADS(i,cue)), ' = ', num2str(poxA(i)))); %debug
       else
           poxADS(i,cue)= NaN; %if the port entry doesn't belong to this DS cue, assign it as NaN          
       end
    end
    
    %poxB
    for i= 1:numel(poxB)
       if (cutTime(DSonsetShifted)<poxB(i)) && (poxB(i)<cutTime(DSonsetShifted+cueLength)) %if the port entry occurs between cue onset and cue offset, assign it to that cue
           poxBDS(i,cue)= poxB(i);
%            disp(strcat('cue ', num2str(cue), 'pox ',num2str(poxADS(i,cue)), ' = ', num2str(poxA(i)))); %debug
       else
           poxBDS(i,cue)= NaN;       
       end
    end
    
    %Create a cell array of poxADS, retaining only PEs for that cue (or nan if none)
    %poxA 
    if find(~isnan(poxADS(:,cue)))  
    poxADScell{:,cue}= poxADS(~isnan(poxADS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxADS
    else
    poxADScell{:,cue}=nan;
    end
    
    %poxB
    if find(~isnan(poxBDS(:,cue)))  
    poxBDScell{:,cue}= poxBDS(~isnan(poxBDS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxADS
    else
    poxBDScell{:,cue}=nan;
    end
    
    %Now, calculate and store PE latency for each individual cue presentation (using poxADScell)
    %box A
    poxADSlatencyCell(1,cue)= min(poxADScell{1,cue}()); %get the lowest PE timestamp after each cue
    poxADSlatencyCell(1,cue) = poxADSlatencyCell(1,cue)-cutTime(DSonsetShifted); %calculate latency by subtracting PE timestamp from cue onset? 
     
    if poxADSlatencyCell(1,cue)<0 || abs(poxADSlatencyCell(1,cue))>cueLength/fs %flag abnormal latency values
       disp(strcat('>>Error ***PE Latency miscalc cue # ', num2str(cue), '_', num2str(poxADSlatencyCell(1,cue)),' minus ', num2str(cutTime(DSonsetShifted)), ' = ', num2str(lat), '******'));
    end
    
    %box B
    poxBDSlatencyCell(1,cue)= min(poxBDScell{1,cue}()); %get the lowest PE timestamp after each cue
    poxBDSlatencyCell(1,cue) = poxBDSlatencyCell(1,cue)-cutTime(DSonsetShifted); 
     
    if poxBDSlatencyCell(1,cue)<0 || abs(poxBDSlatencyCell(1,cue))>cueLength/fs %flag abnormal latency values
       disp(strcat('>>Error ***PE Latency miscalc cue # ', num2str(cue), '_', num2str(poxBDSlatencyCell(1,cue)),' minus ', num2str(cutTime(DSonsetShifted)), ' = ', num2str(lat), '******'));
    end
       
    %calculate average baseline mean&stdDev 10s prior to cue for z-score calculation later
    baselineMeanA=mean(dfA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
    baselineStdA=std(dfA((DSonsetShifted-slideTime):DSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA
    
    baselineMeanB=mean(dfB((DSonsetShifted-slideTime):DSonsetShifted)); %'' for boxB
    baselineStdB=std(dfB((DSonsetShifted-slideTime):DSonsetShifted));

    %loxADS
    %Extract licks that occur within the peri-event window of interest 
    for i=1:numel(loxA) %TODO: lox stuff is in progress
        if (cutTime(preEventTime)<loxA(i)) && (loxA(i)<cutTime(postEventTime)) %if the lick entry occurs between preEventTime and postEventTime, assign it to that cue
           loxADS(i,cue)= loxA(i);
           %Convert lick timestamp to timestamp relative to cue onset
           loxADS(i,cue)= loxADS(i,cue)-cutTime(DSonsetShifted); %calculate relative timestamp by subtracting lick timestamp from cue onset 
         else
           loxADS(i,cue)= NaN; %if the lick doesn't occur within the time window of interest, assign it as NaN          
        end        
    end
    
    %Create a cell array with licks, retaining only licks in the peri-event window of interest
    if find(~isnan(loxADS(:,cue)))  
        loxADScell{:,cue}= loxADS(~isnan(loxADS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxADS
    else
        loxADScell{:,cue}=nan;
    end

    %loxBDS
    %Extract licks that occur within the peri-event window of interest 
    for i=1:numel(loxB) %TODO: lox stuff is in progress
        if (cutTime(preEventTime)<loxB(i)) && (loxB(i)<cutTime(postEventTime)) %if the lick entry occurs between preEventTime and postEventTime, assign it to that cue
           loxBDS(i,cue)= loxB(i);
          %Convert lick timestamp to timestamp relative to cue onset
           loxBDS(i,cue)= loxBDS(i,cue)-cutTime(DSonsetShifted); %calculate relative timestamp by subtracting lick timestamp from cue onset 
         else
           loxBDS(i,cue)= NaN; %if the lick doesn't occur within the time window of interest, assign it as NaN          
        end        
    end
    
    %Create a cell array with licks, retaining only licks in the peri-event window of interest
    if find(~isnan(loxBDS(:,cue)))  
        loxBDScell{:,cue}= loxBDS(~isnan(loxBDS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxADS
    else
        loxBDScell{:,cue}=nan;
    end
     
    %Extract dF data from the peri-event window of interest
    %for the first cue, initialize arrays for dF and time surrounding cue
    if cue==1
        
        eventTime = cutTime(preEventTime:postEventTime); %define the time axis for the event (cue onset +/- periCueTime)

        DSdfA = dfA(preEventTime:postEventTime);  %extract the df data corresponding to this time window
        DSdfB = dfB(preEventTime:postEventTime);      
       
       %calculate zscore for each point in the peri-event period based on baseline mean and stdDev in the preceding 10s 
       DSzA=(((dfA(preEventTime:postEventTime))-baselineMeanA))/(baselineStdA);  
       DSzB=(((dfB(preEventTime:postEventTime))-baselineMeanB))/(baselineStdB);        
        
    else        %for subsequent cues (~=1), add onto these arrays as new 3d pages        
        eventTime = cat(3,eventTime,cutTime(preEventTime:postEventTime)); %concatenate in the 3rd dimension (such that each cue has its own 2d page with the surrounding cue-related data)
        DSdfA = cat(3, DSdfA, dfA(preEventTime:postEventTime));
        DSdfB = cat(3,DSdfB, dfB(preEventTime:postEventTime));
        
        DSzA= cat(3,DSzA,(((dfA(preEventTime:postEventTime))-baselineMeanA)/(baselineStdA)));  
        DSzB= cat(3,DSzB,(((dfB(preEventTime:postEventTime))-baselineMeanB)/(baselineStdB)));
    end    
end

if sesData(file).trainStage== 5 %If the NS is present, calculate and plot NS-triggered avgs and z score as well
       NSskipped= 0; %counter to know how many cues were cut off/not analyzed    
    for cue =1:length(NS) %NS CUES ; For each NS presentation
         NSonset = NS(cue,1); %each entry in NS is a timestamp of the NS onset before downsampling   
    
        %find closest value (min difference) in cutTime to eventOnset by subtraction
        for ts = 1:length(cutTime) 
            timeDiff(1,ts) = abs(NSonset-cutTime(ts));
        end

        [~,NSonsetShifted] = min(timeDiff); %this is the index of the closest timestamp in cutTime to the actual DSonset

        
        timeShift= cutTime(NSonsetShifted)-NS(cue,1); 
        if abs(timeShift) >.5 %flag cues whose time shift is larger than a threshold (in seconds)
        disp(strcat('>>Error *big cue time shift cue# ', num2str(cue), 'shifted NS ', num2str(cutTime(NSonsetShifted)), ' - actual NS ', num2str(NS(cue,1)), ' = ', num2str(timeShift), '*'));
        end
        
        %define the frames around each cue to analyze
        preEventTime = NSonsetShifted-periCueFrames; 
        postEventTime = NSonsetShifted+periCueFrames;


        %calculate average baseline mean&stdDev 10s prior to cue for z-score calculation later
        baselineMeanA=mean(dfA(preEventTime:NSonsetShifted)); %baseline mean df 10s prior to DS onset for boxA
        baselineStdA=std(dfA(preEventTime:NSonsetShifted)); %baseline stdDev 10s prior to DS onset for boxA

        baselineMeanB=mean(dfB(preEventTime:NSonsetShifted)); %'' for boxB
        baselineStdB=std(dfB(preEventTime:NSonsetShifted));

       %If cue is too close to end of recording, want to remove to prevent error
       %TODO: this should probably be reexamined/optimized
       if preEventTime< 1 %Double check this
           disp(strcat('****NS cue ', num2str(cue), ' too close to beginning, breaking out'));
           NSskipped= NSskipped+1;
           break
       end
       
       if postEventTime> length(cutTime)-slideTime
          disp(strcat('****NS cue ', num2str(cue), ' too close to end, breaking out'));
          NSskipped= NSskipped+1;
          break
       end

    % Classify PEs and licks occuring during NS   
    %first, find all the PEs during that NS
    %poxA
    for i= 1:numel(poxA) %for every port entry made in boxA
       if (cutTime(NSonsetShifted)<poxA(i)) && (poxA(i)<cutTime(NSonsetShifted+cueLength))%if the port entry occurs between this cue's onset and this cue's offset, assign it to this cue
           poxANS(i,cue)= poxA(i); %poxANS will contain all of the port entries made during each NS (if any)
%            disp(strcat('cue ', num2str(cue), 'pox ',num2str(poxANS(i,cue)), ' = ', num2str(poxA(i)))); %debug
       else
           poxANS(i,cue)= NaN; %if the port entry doesn't belong to this NS cue, assign it as NaN          
       end
    end
    
    %poxB
    for i= 1:numel(poxB)
       if (cutTime(NSonsetShifted)<poxB(i)) && (poxB(i)<cutTime(NSonsetShifted+cueLength)) %if the port entry occurs between cue onset and cue offset, assign it to that cue
           poxBNS(i,cue)= poxB(i);
%            disp(strcat('cue ', num2str(cue), 'pox ',num2str(poxBNS(i,cue)), ' = ', num2str(poxA(i)))); %debug
       else
           poxBNS(i,cue)= NaN;       
       end
    end
    
    
    for i=1:numel(loxA) %TODO: lox stuff is in progress
        if (cutTime(NSonsetShifted)<loxA(i)) && (loxA(i)<cutTime(NSonsetShifted+cueLength)) %if the port entry occurs between cue onset and cue offset, assign it to that cue
           loxANS(i,cue)= loxA(i);
       end
    end
    
%  This is simply another method of achieving the above code- but retains only PEs for that cue (or nan if none)
    %poxA 
    if find(~isnan(poxANS(:,cue)))  
    poxANScell{:,cue}= poxANS(~isnan(poxANS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxANS
    else
    poxANScell{:,cue}=nan;
    end
    
    %poxB
    if find(~isnan(poxBNS(:,cue)))  
    poxBNScell{:,cue}= poxBNS(~isnan(poxBNS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxBNS
    else
    poxBNScell{:,cue}=nan;
    end
       
    
    %Now, calculate and store PE latency for each individual cue presentation (using poxANScell)
    %box A
    poxANSlatencyCell(1,cue)= min(poxANScell{1,cue}()); %get the lowest PE timestamp after each cue
    poxANSlatencyCell(1,cue) = poxANSlatencyCell(1,cue)-cutTime(NSonsetShifted); 
     
    if poxANSlatencyCell(1,cue)<0 || abs(poxANSlatencyCell(1,cue))>cueLength/fs %flag abnormal latency values
       disp(strcat('>>Error ***PE Latency miscalc NS # ', num2str(cue), '_', num2str(poxANSlatencyCell(1,cue)),' minus ', num2str(cutTime(NSonsetShifted)), ' = ', num2str(lat), '******'));
    end
    
    %box B
    poxBNSlatencyCell(1,cue)= min(poxBNScell{1,cue}()); %get the lowest PE timestamp after each cue
    poxBNSlatencyCell(1,cue) = poxBNSlatencyCell(1,cue)-cutTime(NSonsetShifted); 
     
    if poxBNSlatencyCell(1,cue)<0 || abs(poxBNSlatencyCell(1,cue))>cueLength/fs %flag abnormal latency values
       disp(strcat('>>Error ***PE Latency miscalc NS # ', num2str(cue), '_', num2str(poxBNSlatencyCell(1,cue)),' minus ', num2str(cutTime(NSonsetShifted)), ' = ', num2str(lat), '******'));
    end

     %loxANS
    %Extract licks that occur within the peri-event window of interest 
    for i=1:numel(loxA) %TODO: lox stuff is in progress
        if (cutTime(preEventTime)<loxA(i)) && (loxA(i)<cutTime(postEventTime)) %if the lick entry occurs between preEventTime and postEventTime, assign it to that cue
           loxANS(i,cue)= loxA(i);
           %Convert lick timestamp to timestamp relative to cue onset
           loxANS(i,cue)= loxANS(i,cue)-cutTime(NSonsetShifted); %calculate relative timestamp by subtracting lick timestamp from cue onset 
         else
           loxANS(i,cue)= NaN; %if the lick doesn't occur within the time window of interest, assign it as NaN          
        end        
    end
    
    %Create a cell array with licks, retaining only licks in the peri-event window of interest
    if find(~isnan(loxANS(:,cue)))  
        loxANScell{:,cue}= loxANS(~isnan(loxANS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxANS
    else
        loxANScell{:,cue}=nan;
    end

    %loxBNS
    %Extract licks that occur within the peri-event window of interest 
    for i=1:numel(loxB) %TODO: lox stuff is in progress
        if (cutTime(preEventTime)<loxB(i)) && (loxB(i)<cutTime(postEventTime)) %if the lick entry occurs between preEventTime and postEventTime, assign it to that cue
           loxBNS(i,cue)= loxB(i);
          %Convert lick timestamp to timestamp relative to cue onset
           loxBNS(i,cue)= loxBNS(i,cue)-cutTime(NSonsetShifted); %calculate relative timestamp by subtracting lick timestamp from cue onset 
         else
           loxBNS(i,cue)= NaN; %if the lick doesn't occur within the time window of interest, assign it as NaN          
        end        
    end
    
    %Create a cell array with licks, retaining only licks in the peri-event window of interest
    if find(~isnan(loxBNS(:,cue)))  
        loxBNScell{:,cue}= loxBNS(~isnan(loxBNS(:,cue)),cue); %create a cell array with all port entries made per cue presentation- containing only non-nan values in poxANS
    else
        loxBNScell{:,cue}=nan;
    end
    
       
        %for the first cue, build arrays for data and time surrounding cue
        if cue==1
            
            if NSskipped ~= 0 %if the first cue is skipped (b/c too early) break out or an error will be thrown
            break
            end
        
            eventTime = cutTime(preEventTime:postEventTime);

            NSdfA = dfA(preEventTime:postEventTime);
            NSdfB = dfB(preEventTime:postEventTime);


           %calculate zscore for each point in the peri-event period based on baseline mean and stdDev in the preceding 10s 
           NSzA=(((dfA(preEventTime:postEventTime))-baselineMeanA))/(baselineStdA);  
           NSzB=(((dfB(preEventTime:postEventTime))-baselineMeanB))/(baselineStdB);   

        %for subsequent cues, add onto these arrays as new 3d pages
        else
            eventTime = cat(3,eventTime,cutTime(preEventTime:postEventTime));
            NSdfA = cat(3, NSdfA, dfA(preEventTime:postEventTime));
            NSdfB = cat(3,NSdfB, dfB(preEventTime:postEventTime));

            NSzA= cat(3,NSzA,(((dfA(preEventTime:postEventTime))-baselineMeanA)/(baselineStdA)));  
            NSzB= cat(3,NSzB,(((dfB(preEventTime:postEventTime))-baselineMeanB)/(baselineStdB)));
        end
    end
end

%Avg dF across all events and timelock to cue onset @ t=0
meanDSdfA = mean(DSdfA, 3); %avg across 3rd dimension (across each page) %this just gives us an average response to all cues 
meanDSdfB = mean(DSdfB, 3);

meanDSzA = mean(DSzA, 3);
meanDSzB = mean(DSzB, 3);

DSincluded = numel(DS)-DSskipped; %keep track of how many cues were excluded from analysis

if sesData(file).trainStage==5 %run NS related analyses only if on stage 5
    meanNSdfA = mean(NSdfA, 3);
    meanNSdfB = mean(NSdfB, 3);

    meanNSzA = mean(NSzA, 3);
    meanNSzB = mean(NSzB, 3);
    
    NSincluded = numel(NS)-NSskipped;
end

timeLock = [-periCueFrames:periCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0

%calc std error - double check this *TODO: Jocelyn recommends different sem calc
semA = std(dfA)/sqrt(length(dfA));
semB = std(dfB)/sqrt(length(dfB));

%calculate pox ratio- TODO: still in progress

%poxA
if find(isnan(poxADSlatencyCell))
    DSpoxRatioA= numel(find(isnan(poxADSlatencyCell)))/numel(poxADSlatencyCell(1,:)); %number of DS trials in which a PE occurred / total number of DS trials
    DSpoxRatioA= 1-DSpoxRatioA;
else 
    DSpoxRatioA= 1;
end
%     disp(strcat('DSpoxRatioA= ', num2str(DSpoxRatioA)));
DSpoxtrial= 30-numel(find(isnan(poxADSlatencyCell))); %number of DS trials in which a PE occurred
sesData(file).DSpoxtrial= DSpoxtrial;

% poxB
if find(isnan(poxBDSlatencyCell))
    DSpoxRatioB= numel(find(isnan(poxBDSlatencyCell)))/numel(poxBDSlatencyCell(1,:)); %number of DS trials in which a PE occurred / total number of DS trials
    DSpoxRatioB= 1-DSpoxRatioB; 
else 
    DSpoxRatioB= 1;
end
%     disp(strcat('DSpoxRatioB= ', num2str(DSpoxRatioB)));

DSpoxtrialB= 30-numel(find(isnan(poxBDSlatencyCell))); %number of DS trials in which a PE occurred
sesData(file).DSpoxtrialB= DSpoxtrialB;

%% Session event-triggered avg plots- avg response to cue per session
% Plot dF event triggered avg to DS for each animal for each day... 
%TODO: plot dF along with patch showing shape of standard error

    %dF plots- not really useful without std error
% % figure;
% % plot(timeLock, meanDSdfA);
% % hold on
% % % plot(timeLock, [(meanDSdfA-semA)';(meanDSdfA+semA)'], 'Color','k'); %sem line
% % title(strcat('Rat #',num2str(sesData(file).ratA),' training day : ', num2str(sesData(file).trainDay), ' avg dF response to cue'));
% % legend(strcat('DS (n= ',num2str(DSincluded),')'));
% % if sesData(file).trainStage ==5
% %     plot(timeLock, meanNSdfA);
% %     legend(strcat('DS (n= ',num2str(NSincluded),')'),strcat('NS (n= ',num2str(NSincluded),')'));
% % end
% 
% % figure;
% % plot(timeLock, meanDSdfB);
% % hold on
% % % plot(timeLock, [(meanDSdfB-semB)';(meanDSdfB+semB)'], 'Color','k');
% % title(strcat('Rat #',num2str(sesData(file).ratB),' training day : ', num2str(sesData(file).trainDay), ' avg dF response to cue'));
% % legend(strcat('DS (n= ',num2str(DSincluded),')'));
% % if sesData(file).trainStage ==5
% %     plot(timeLock, meanNSdfB);
% %     legend(strcat('DS (n= ',num2str(NSincluded),')'),strcat('NS (n= ',num2str(NSincluded),')'));
% % end

    %%z score plots- useful but heat plots seem better
% figure;
% hold on
% plot(timeLock, meanDSzA);
% title(strcat('Rat #',num2str(sesData(file).ratA),' training day : ', num2str(sesData(file).trainDay), ' avg z score response to cue'));
% legend(strcat('DS (n= ',num2str(DSincluded),')'));
% if sesData(file).trainStage ==5
%     plot(timeLock, meanNSzA);
%     legend(strcat('DS (n= ',num2str(NSincluded),')'),strcat('NS (n= ',num2str(NSincluded),')'));
% end
% 
% figure;
% hold on
% plot(timeLock, meanDSzB);
% title(strcat('Rat #',num2str(sesData(file).ratB),' training day : ', num2str(sesData(file).trainDay), ' avg z score response to cue'));
% legend(strcat('DS (n= ',num2str(DSincluded),')'));
% if sesData(file).trainStage ==5
%     plot(timeLock, meanNSzB);
%     legend(strcat('DS (n= ',num2str(NSincluded),')'),strcat('NS (n= ',num2str(NSincluded),')'));
% end

%% Save all data for a given session to struct for easy access

sesData(file).cutTime= cutTime;

sesData(file).DS = DS;

sesData(file).poxA= poxA;
sesData(file).poxB= poxB;

sesData(file).poxADS= poxADScell;
sesData(file).poxBDS= poxBDScell;

sesData(file).loxADS= loxADScell;
sesData(file).loxBDS= loxBDScell;

sesData(file).loxADSmat= loxADS;
sesData(file).loxBDSmat= loxBDS;

sesData(file).dfA = dfA;
sesData(file).dfB = dfB;


sesData(file).DSdfA= DSdfA;
sesData(file).DSdfB= DSdfB;
sesData(file).meanDSdfA= meanDSdfA;
sesData(file).meanDSdfB= meanDSdfB;
sesData(file).DSzA= DSzA;
sesData(file).DSzB= DSzB;
sesData(file).meanDSzA= meanDSzA;
sesData(file).meanDSzB= meanDSzB;

sesData(file).poxADSlatency = poxADSlatencyCell;
sesData(file).poxBDSlatency = poxBDSlatencyCell;
sesData(file).meanpoxADSlatency= nanmean(poxADSlatencyCell);
sesData(file).meanpoxBDSlatency= nanmean(poxBDSlatencyCell);
sesData(file).DSpoxRatioA= DSpoxRatioA;
sesData(file).DSpoxRatioB= DSpoxRatioB;

sesData(file).numDS= DSincluded;

if sesData(file).trainStage==5 %only stage 5 has the NS
    sesData(file).numNS= NSincluded; 

    sesData(file).NS= NS;

    sesData(file).poxANS= poxANScell;
    sesData(file).poxBNS= poxBNScell;
    
    sesData(file).loxANS= loxANScell;
    sesData(file).loxBNS= loxBNScell;
    
    sesData(file).loxANSmat= loxANS;
    sesData(file).loxBNSmat= loxBNS;
    
    sesData(file).NSdfA= NSdfA;
    sesData(file).NSdfB= NSdfB;
    sesData(file).NSzA= NSzA;
    sesData(file).NSzB= NSzB;
    sesData(file).meanNSdfA= meanNSdfA;
    sesData(file).meanNSdfB= meanNSdfB;
    sesData(file).meanNSzA= meanNSzA;
    sesData(file).meanNSzB= meanNSzB;

    sesData(file).poxANSlatency = poxANSlatencyCell;
    sesData(file).poxBNSlatency = poxBNSlatencyCell;
    sesData(file).meanpoxANSlatency= nanmean(poxANSlatencyCell);
    sesData(file).meanpoxBNSlatency= nanmean(poxBNSlatencyCell);
end

%% Grand Average z score response to cue across both animals for a given day %TODO: use this as a basis for grand avg across every animal
%     grandDSz = cat(3, sesData(file).meanDSzA, sesData(file).meanDSzB);
%     meanGrandDSz = mean(grandDSz, 3);
% 
% % %     %TODO: use different way calculate SEM-probably just std(semGrand) to capture variance between subjects
% % %     if semA > semB
% % %        semGrand = semA; 
% % %     else
% % %         semGrand = semB;
% % %     end
%     figure;
%     plot(timeLock,meanGrandDSz);
%     hold on
% % %     plot(timeLock, [(grandMean-semGrand)';(grandMean+semGrand)'], 'Color','k'); %sem line
%     title(strcat('Grand average dF response to cue across animals- training day :', num2str(sesData(file).trainDay)));
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of file loop

if runAnalysis ==1 %only run this if all sessions loaded are from valid DS training stages (w


    %% Reorganize data by subject instead of by box

    %Heatmap of z score cue response across trials

    %identify unique rats and associate data from all sessions with rat instead of box
    rats= cat(1, sesData.ratA, sesData.ratB);
    rats= unique(rats);

    trialCount = 0; %counter for looping to fill subjData appropriately

    %create a new struct, subjData, containing all subject's data and session metadata
    for rat = 1:numel(rats) 
        subj= rats(rat);

        subjField= (strcat('rat',num2str(subj))); %dynamically assign field name for each subject- This may be problematic

        for i=1:numel(sesData) 

            subjData.(subjField)(i).cutTime= cutTime;

            if subj == sesData(i).ratA %if this rat was in boxA, associate session data from boxA with it
                trialCount= trialCount+1; %increment counter

                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStage;
                subjData.(subjField)(i).box= 'box A';

                subjData.(subjField)(i).DSdf= sesData(i).DSdfA;
                subjData.(subjField)(i).DSz= sesData(i).DSzA;
                subjData.(subjField)(i).meanDSz = sesData(i).meanDSzA;

                subjData.(subjField)(i).numDS= sesData(i).numDS;


                subjData.(subjField)(i).poxDS= sesData(i).poxADS;

                subjData.(subjField)(i).loxDS= sesData(i).loxADS;

                subjData.(subjField)(i).loxDSmat= sesData(i).loxADSmat;

                subjData.(subjField)(i).poxDSlatency= sesData(i).poxADSlatency;
                subjData.(subjField)(i).meanpoxDSlatency= sesData(i).meanpoxADSlatency;


                if subjData.(subjField)(i).trainStage== 5 %NS only on stage 5
                subjData.(subjField)(i).numNS= sesData(i).numNS;
                subjData.(subjField)(i).NSdf= sesData(i).NSdfA;

                subjData.(subjField)(i).NSz= sesData(i).NSzA;
                subjData.(subjField)(i).meanNSz = sesData(i).meanNSzA;

                subjData.(subjField)(i).poxNS= sesData(i).poxANS;


                subjData.(subjField)(i).loxNS= sesData(i).loxANS;
                subjData.(subjField)(i).loxNSmat= sesData(i).loxANSmat;


                subjData.(subjField)(i).poxNSlatency= sesData(i).poxANSlatency;
                subjData.(subjField)(i).meanpoxNSlatency= sesData(i).meanpoxANSlatency;

                end


            elseif subj ==sesData(i).ratB %if this rat was in boxB, associate session data from boxB with it
                trialCount= trialCount+1;

                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay;
                subjData.(subjField)(i).trainStage= sesData(i).trainStage;
                subjData.(subjField)(i).box= 'box B';
                subjData.(subjField)(i).DSdf= sesData(i).DSdfB;
                subjData.(subjField)(i).DSz= sesData(i).DSzB;

                subjData.(subjField)(i).meanDSz = sesData(i).meanDSzB;

                subjData.(subjField)(i).numDS= sesData(i).numDS;


                subjData.(subjField)(i).poxDS= sesData(i).poxBDS;

                subjData.(subjField)(i).loxDS= sesData(i).loxBDS;

                subjData.(subjField)(i).loxDSmat= sesData(i).loxBDSmat;


                subjData.(subjField)(i).poxDSlatency= sesData(i).poxBDSlatency;

                subjData.(subjField)(i).meanpoxDSlatency= sesData(i).meanpoxBDSlatency;




                if subjData.(subjField)(i).trainStage==5 %NS only on stage 5
                subjData.(subjField)(i).numNS= sesData(i).numNS;
                subjData.(subjField)(i).NSdf= sesData(i).NSdfB;
                subjData.(subjField)(i).NSz= sesData(i).NSzB;

                subjData.(subjField)(i).meanNSz = sesData(i).meanNSzB;

                subjData.(subjField)(i).poxNS= sesData(i).poxBNS;

                subjData.(subjField)(i).loxNS= sesData(i).loxBNS;
                subjData.(subjField)(i).loxNSmat= sesData(i).loxBNSmat;


                subjData.(subjField)(i).poxNSlatency= sesData(i).poxBNSlatency;
                subjData.(subjField)(i).meanpoxNSlatency= sesData(i).meanpoxBNSlatency;

                end
            end
        end 

        % remove empty cells from subjData!
        subjData.(subjField)= subjData.(subjField)(~cellfun(@isempty,{subjData.(subjField).trainDay})); %Remove empty cells from subjData (TODO: apply this method to SubjData itself)


    end

    %% Subject heat plot organization
    subjField= fieldnames(subjData); %access struct with dynamic fieldname
    for i= 1:numel(subjField)

        %reset arrays between subjects to clear any remaining data 
        clearvars -except i sesData subjData subjField timeLock fs slideTime figPath runAnalysis; 

        disp(subjField(i));
        currentSubj= subjData.(subjField{i}); 

        %Exclude data- since cue lengths vary between sessions
        %For now, only do this for trials with cueLength ==10 (stage 4 or 5)... colormap will probably appear off if including irrelevant trials
        for trial = 1:numel(currentSubj)
            if currentSubj(trial).trainStage ~= 4 && currentSubj(trial).trainStage ~=5 %if not stage 4 or 5, exclude data 
                fn = fieldnames(currentSubj);
                for field = 1:numel(fieldnames(currentSubj))
                    currentSubj(trial).(fn{field})= []; %delete the data
               end
            end
        end

        currentSubj= currentSubj(~cellfun(@isempty,{currentSubj.trainDay})); %remove empty cells after defining data to exclude

        ratID= currentSubj(i).rat;

         %%%%%IN PROGRESS- LOX RESHAPE
               %Reshape the lox matrix so that dimensions for each session match (for concatenation)
               for ses = 1:numel(currentSubj) %for each session
                  loxDSmatSize(ses,:)= size(currentSubj(ses).loxDSmat, 1) %get the size of the x dimension of the lick array (how many licks in that session)
                  loxNSmatSize(ses,:) = size(currentSubj(ses).loxNSmat, 1) %repeat for NS
               end

               loxDSmatSize= max(loxDSmatSize); %this is the maximum number of licks out of all sessions
               loxNSmatSize= max(loxNSmatSize); %repeat for NS 

               for ses= 1:numel(currentSubj) %for each session
                   if size(currentSubj(ses).loxDSmat, 1) < loxDSmatSize %if the current # rows is less than the desired # rows
                      currentSubj(ses).loxDSmat(end+1:loxDSmatSize,:)= NaN; %add rows containing all NaN values from the final row until the desired max row to match number of maximum rows 
                   end

                   if size(currentSubj(ses).loxNSmat, 1) < loxNSmatSize %repeat for NS
                      currentSubj(ses).loxNSmat(end+1: loxDSmatSize,:) = NaN;  
                   end
               end



        %Sort trials by PE latency within sessions and collect all cue presentations from across all sessions   
        for ses= 1:numel(currentSubj) %for each session

                %need to sort each cue by PE latency for each session and figure out the sorted order (indices to match up latency with data)
               [currentSubj(ses).poxDSlatencySorted,currentSubj(ses).poxDSlatencySortOrder] = sort(currentSubj(ses).poxDSlatency); %Get the sorted order (the index after sorting) for each cue presentation during this session 
               [currentSubj(ses).poxNSlatencySorted, currentSubj(ses).poxNSlatencySortOrder]= sort(currentSubj(ses).poxNSlatency); %repeat for NS

               %now, use that sorted order to sort cue presentations by PE latency (this isn't actually necessary at this point, just a good way to verify sorted data)
               currentSubj(ses).poxDSsorted = currentSubj(ses).poxDS(currentSubj(ses).poxDSlatencySortOrder);
               currentSubj(ses).poxNSsorted = currentSubj(ses).poxNS(currentSubj(ses).poxNSlatencySortOrder); %repeat for NS

               %now, use that sorted order to sort z score responses to DS by PE latency- remember that each cue is a page in the 3rd dimension of DSz, so the order will define the order of pages
               currentSubj(ses).DSzSorted= currentSubj(ses).DSz(:,:,currentSubj(ses).poxDSlatencySortOrder); 
               currentSubj(ses).NSzSorted= currentSubj(ses).NSz(:,:,currentSubj(ses).poxNSlatencySortOrder); %repeat for NS


               %now, we've sorted within-session but haven't sorted between sessions... this is done later

               %manually calculate mean PE latency per session
               currentSubj(ses).meanpoxDSlatency= nanmean(currentSubj(ses).poxDSlatency);
               currentSubj(ses).meanpoxNSlatency= nanmean(currentSubj(ses).poxNSlatency); %repeat for NS

            %collect all z score responses to every single DS across all sessions (and the latency to PE in response to every single DS)
            if ses==1
            currentSubjDSz= squeeze(currentSubj(ses).DSz); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubjpoxDSlatency= currentSubj(ses).poxDSlatency;

            currentSubjloxDS= currentSubj(ses).loxDS;%collect all licks to every single DS across all sections

            currentSubjloxDSmat= currentSubj(ses).loxDSmat;

            %repeat for NS
            currentSubjNSz= squeeze(currentSubj(ses).NSz); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubjpoxNSlatency= currentSubj(ses).poxNSlatency;

            currentSubjloxNS= currentSubj(ses).loxNS;

            currentSubjloxNSmat= currentSubj(ses).loxNSmat;


            else
            currentSubjDSz = cat(2, currentSubjDSz, (squeeze(currentSubj(ses).DSz))); %this contains z score response to DS from every DS (should have #columns= ~30 cues x #sessions)
            currentSubjpoxDSlatency = cat(2,currentSubjpoxDSlatency,currentSubj(ses).poxDSlatency); %this contains the latency to PE in response to every DS (each column = 1 DS)

            currentSubjloxDS= cat(2, currentSubjloxDS, currentSubj(ses).loxDS); %this contains licks surrounding every DS (each column = 1 DS)
            currentSubjloxDSmat= cat(2, currentSubjloxDSmat, currentSubj(ses).loxDSmat);


            %repeat for NS
            currentSubjNSz = cat(2, currentSubjNSz, (squeeze(currentSubj(ses).NSz))); %this contains z score response to NS from every NS (should have #columns= ~30 cues x #sessions)
            currentSubjpoxNSlatency = cat(2,currentSubjpoxNSlatency,currentSubj(ses).poxNSlatency); %this contains the latency to PE in response to every DS (each column = 1 NS)

            currentSubjloxNS= cat(2, currentSubjloxNS, currentSubj(ses).loxNS); %this contains licks surrounding every NS (each column = 1 NS)

            currentSubjloxNSmat= cat(2, currentSubjloxNSmat, currentSubj(ses).loxNSmat);

            end
        end


        %Sort all DS presentations across sessions by PE latency
        %Similar approach to sorting by latency within-session, but applied to all cues across all trials
        [currentSubjpoxDSlatencySorted,currentSubjpoxDSlatencySortOrder]= sort(currentSubjpoxDSlatency); %sort all latencies and retrieve the sort order for indexing
        currentSubjDSzSorted = currentSubjDSz(:,currentSubjpoxDSlatencySortOrder); %sort DSz by latency using the latency sort order as indices (currently each column in currentSubjDSz corresponds to 1 cue here, so get all rows for that column)

        currentSubjloxDSSorted= currentSubjloxDS(:,currentSubjpoxDSlatencySortOrder); %sort lick data by PE latency

        currentSubjloxDSmatSorted= currentSubjloxDSmat(:,currentSubjpoxDSlatencySortOrder);

        %repeat for NS
        [currentSubjpoxNSlatencySorted,currentSubjpoxNSlatencySortOrder]= sort(currentSubjpoxNSlatency); %sort all latencies and retrieve the sort order for indexing
        currentSubjNSzSorted = currentSubjNSz(:,currentSubjpoxNSlatencySortOrder); %sort DSz by latency using the latency sort order as indices (currently each column in currentSubjDSz corresponds to 1 cue here, so get all rows for that column)

        currentSubjloxNSSorted = currentSubjloxNS(:,currentSubjpoxNSlatencySortOrder); %sort lick data by PE latency

        currentSubjloxNSmatSorted= currentSubjloxNSmat(:, currentSubjpoxNSlatencySortOrder);

        %Now, remove NaNs (trials in which the animal did not make a port entry or was already in the port when the cue came on)
        currentSubjDSzSortedNoNan=  currentSubjDSzSorted(:,~isnan(currentSubjpoxDSlatencySorted)); %Find indices containing a latency (~isnan) from the sorted latencies, then use those indices to retrieve DSz from only those trials in the sorted data
        currentSubjNSzSortedNoNan=  currentSubjNSzSorted(:,~isnan(currentSubjpoxNSlatencySorted)); %repeat for NS

        currentSubjloxDSSortedNoNan = currentSubjloxDSSorted(:, ~isnan(currentSubjpoxDSlatencySorted)); %repeat for licks surrounding DS
        currentSubjloxNSSortedNoNan = currentSubjloxNSSorted(:, ~isnan(currentSubjpoxNSlatencySorted)); %repeat for licks surrounding DS

        currentSubjpoxDSlatencySortedNoNan= currentSubjpoxDSlatencySorted(:,~isnan(currentSubjpoxDSlatencySorted));
        currentSubjpoxNSlatencySortedNoNan= currentSubjpoxNSlatencySorted(:,~isnan(currentSubjpoxNSlatencySorted));


        currentSubjloxDSmatSortedNoNan= currentSubjloxDSmatSorted(:, ~isnan(currentSubjpoxDSlatencySorted));
        currentSubjloxNSmatSortedNoNan= currentSubjloxNSmatSorted(:, ~isnan(currentSubjpoxNSlatencySorted));


        %Unsorted data
        DSzAllTrials= cat(2,currentSubj.meanDSz);
        DSzAllTrials= DSzAllTrials.'; %transpose for better readability

    %     if currentSubj(i).trainStage==5 % May need this 
        NSzAllTrials= cat(2,currentSubj.meanNSz); 
        NSzAllTrials= NSzAllTrials.';
    %     end

        subjTrial= [currentSubj.trainDay];
        trialDSnum = [currentSubj.numDS];


        %define a shared colormap axis for both DS and NS (bottom and top of color range)
        bottom = min(min(min(DSzAllTrials)), min(min(NSzAllTrials)));
        top = max(max(max(DSzAllTrials)), max(max(NSzAllTrials)));

        %define a shared colormap axis for DS/NS excluding NaN trials TODO: decide if this is a good idea
        bottomNoNan= min(min(min(currentSubjDSzSortedNoNan)), min(min(currentSubjNSzSortedNoNan)));
        topNoNan= max(max(max(currentSubjDSzSortedNoNan)), max(max(currentSubjNSzSortedNoNan)));

    %     %PLOT OF AVG CUE RESPONSE PER SESSION
    %     %DS z plot
    %     figure; 
    %     subplot(2,1,1); %subplot for shared colorbar
    %     
    %     trialCount=0; %counter for loop/indexing
    %     for trial= 1:numel(currentSubj)
    %         if currentSubj(trial).trainStage==5
    %             trialCount=trialCount+1;
    %             stage5trial(trialCount) = currentSubj(trial).trainDay;
    %         end
    %     end
    %     
    %     heatDSz= imagesc(timeLock,subjTrial,DSzAllTrials);
    %     title(strcat('rat ', num2str(ratID), 'avg z score response to DS ', '(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    %     xlabel('seconds from cue onset');
    %     ylabel('training day');
    %     set(gca, 'ytick', subjTrial); %label trials appropriately
    %     caxis manual;
    %     caxis([bottom top]);
    %     
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     
    % %     if currentSubj(i).trainStage==5 %NS only on stage 5?
    %     
    %     trialNSnum= [currentSubj.numNS];
    % 
    % %   NSz plot (subplotted for shared colorbar)
    %     subplot(2,1,2);
    %     heatNSz= imagesc(timeLock,stage5trial,NSzAllTrials);
    % 
    %     title(strcat('rat ', num2str(ratID), ' avg z score response to NS ', '(n= ', num2str(unique(trialNSnum)),')')); 
    %     xlabel('seconds from cue onset');
    %     ylabel('training day');
    %   
    %     set(gca, 'ytick', subjTrial); %TODO: NS trial labels must be different, only stage 5 trials
    %         
    %     caxis manual;
    %     caxis([bottom top]);
    %     
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     
    %     %SAVE PLOTS
    %    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    %    saveas(gcf, strcat(figPath,'rat_', num2str(ratID),'_meanZ_perSession','.tiff')); %save the current figure in tif format

    % % %     %add annotation with number of cues for each trial included in analysis- probably can delete
    % % %     textPos= 1/numel(subjTrial)/2;
    % % %     for i=1:numel(subjTrial)
    % % %     annotation('textbox', [0, textPos, 0, 0], 'string', strcat(num2str(subjTrial(i)), '(n= ',num2str(trialNSnum(i)),')'));
    % % %         if(textPos+textPos<1)
    % % %             textPos= textPos+textPos;
    % % %         else
    % % %             textPos=.99;
    % % %         end
    % % %     end
    % % %     
    % % %     end

    % % %plot across sessions sorted by latency %missing subplot of NS with this
    % % figure;
    % % imagesc(timeLock,sortedTrial, sortedDSz);
    % % title(strcat('rat ', num2str(ratID), ' avg z score response to DS; day sorted by avg DS PE latency (hi to lo)'));
    % % 
    % % c= colorbar; %colorbar legend
    % % c.Label.String= strcat('z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    % % xlabel('seconds from cue onset');
    % % ylabel('training day');
    % % set(gca,'YTick',[]) %should find a way to label Y values out of order

    % ALL CUE HEAT PLOTS (all cues across all sessions)  
    %     
    %     %PLOT OF ALL INDIVIDUAL CUE RESPONSES- UNSORTED (in order of presentation) 
    %     %plot of all DSz- unsorted
    %     figure; 
    %     subplot(2,1,1); %subplot for shared colorbar
    %     
    %     currentSubjDSz= currentSubjDSz.'; %transpose for readability, each row is now 1 cue! 
    %     imagesc(timeLock, 1:size(currentSubjDSz,1), currentSubjDSz);
    %     
    %     caxis manual;
    %     caxis([bottom top]);
    %     
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('Z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation')
    %     title(strcat('rat ', num2str(ratID), ' z score response to every DS cue'));
    %     
    %     %overlay plot of PE latency 
    % %     for trial= 1:numel(currentSubjpoxDSlatency)
    %     hold on;
    % %     scatter(currentSubjpoxDSlatency(trial), trial, 'm');    
    % %     end
    % 
    %     s= scatter(currentSubjpoxDSlatency, 1:numel(currentSubjpoxDSlatency), 'm');
    %     s.Marker= '.'; %make marker a single small point
    % 
    % % %     %overlay plot of licks surrounding the cue onset
    % % %     hold on;
    % % %     s= scatter(currentSubjloxDS, 1:numel(currentSubjloxDS), 'g');
    % % %     s.Marker= '.';
    % % %     
    %     
    %     %plot of all NSz- unsorted
    %     subplot(2,1,2);
    %     currentSubjNSz= currentSubjNSz.'; %transpose for readability, each row is now 1 cue! 
    %     imagesc(timeLock, 1:size(currentSubjNSz,1), currentSubjNSz);
    %     
    %     caxis manual;
    %     caxis([bottom top]);
    %     
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('Z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation')
    %     title(strcat('rat ', num2str(ratID), ' z score response to every NS cue'));
    %     
    %     
    %     %overlay plot of PE latency 
    %     hold on;
    % %     plot(currentSubjpoxNSlatency, 1:numel(currentSubjpoxNSlatency), 'm');
    %     
    %     s= scatter(currentSubjpoxNSlatency, 1:numel(currentSubjpoxNSlatency), 'm');
    %     s.Marker= '.';
    % 
    %     
    %    %SAVE PLOTS
    %    saveas(gcf, strcat(figPath,'rat_', num2str(ratID),'_Zscore_AllCues','.tiff')); %save the current figure in tif format


        %PLOT OF ALL INDIVIDUAL CUE RESPONSES- TRIALS SORTED BY PE LATENCY, CONTAINING ONLY TRIALS IN WHICH A PE WAS MADE
    %     %plot of all DSz- sorted by latency WITH NaN REMOVED
        figure;
        subplot(2,1,1); %subplot for shared colorbar

        currentSubjDSzSortedNoNan = currentSubjDSzSortedNoNan.';  %transpose for readability, each row is now 1 cue! 
        imagesc(timeLock, 1:size(currentSubjDSzSortedNoNan,1), currentSubjDSzSortedNoNan);

        caxis manual;
        caxis([bottom top]); %TODO: consider using restricted color axis here

        c= colorbar; %colorbar legend
        c.Label.String= strcat('Z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        xlabel('seconds from cue onset');
        ylabel('cue presentation')
        title(strcat('rat ', num2str(ratID), ' z score response to every DS cue SORTED BY LATENCY (Lo-Hi; NaN removed)'));

        %overlay plot of PE latency 
        hold on;    
        s= scatter(currentSubjpoxDSlatencySorted, 1:numel(currentSubjpoxDSlatencySorted), 'm');
        s.Marker= '.';

    %     %overlay plot of licks surrounding DS - a little more complicated because this is a cell array with an unknown number of licks per cue
    %     for trial = 1:numel(currentSubjloxDSSortedNoNan) %for each trial
    %         hold on;
    %         currentTrial = ones([numel(currentSubjloxDSSortedNoNan{trial}),1]); %make an array equal to the size of the number of licks for that trial
    %         currentTrial(:)= trial; %make each entry in this array equal to the current trial number (so we have a correct x value for each lick to scatter plot)
    %         s= scatter(currentSubjloxDSSortedNoNan{trial}, currentTrial, 'k'); %scatter plot the licks for each trial
    %         s.Marker = '.'; %make the marker a small point
    %     end

        %plot of all NSz- sorted by latency WITH NaN REMOVED
        subplot(2,1,2); %subplot for shared colorbar
        currentSubjNSzSortedNoNan = currentSubjNSzSortedNoNan.';  %transpose for readability, each row is now 1 cue! 
        imagesc(timeLock, 1:size(currentSubjNSzSortedNoNan,1), currentSubjNSzSortedNoNan);

        caxis manual;
        caxis([bottom top]);

        c= colorbar; %colorbar legend
        c.Label.String= strcat('Z-score calculated from', num2str(slideTime/fs), 's preceding cue');
        xlabel('seconds from cue onset');
        ylabel('cue presentation')
        title(strcat('rat ', num2str(ratID), ' z score response to every NS cue SORTED BY LATENCY (Lo-Hi; NaN removed)'));

        %overlay plot of PE latency 
        hold on;    
        s= scatter(currentSubjpoxNSlatencySorted, 1:numel(currentSubjpoxNSlatencySorted), 'm');
        s.Marker= '.';

        %overlay plot of licks surrounding NS - a little more complicated because this is a cell array with an unknown number of licks per cue
    %     for trial = 1:numel(currentSubjloxNSSortedNoNan) %for each trial
    %         hold on;
    %         currentTrial = ones([numel(currentSubjloxNSSortedNoNan{trial}),1]); %make an array equal to the size of the number of licks for that trial
    %         currentTrial(:)= trial; %make each entry in this array equal to the current trial number (so we have a correct x value for each lick to scatter plot)
    %         s= scatter(currentSubjloxNSSortedNoNan{trial}, currentTrial, 'k'); %scatter plot the licks for each trial
    %         s.Marker = '.'; %make the marker a small point
    %     end

        %SAVE PLOTS
        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
        saveas(gcf, strcat(figPath,'rat_', num2str(ratID),'_Zscore_AllCuesSorted-WithLicks','.tiff')); %save the current figure in tif format


        %     %%%%%%%%%%%%%%%%%%%%%%%%%%% IN PROGRESS- visualizing lox
    % 
    %     %PLOT OF ALL LICKS SURROUNDING EACH INDIVIDUAL CUE PRESENTATION- TRIALS SORTED BY PE LATENCY, only including trials in which a PE was made
    %     figure;
    %     subplot(2,1,1);
    %      for trial = 1:numel(currentSubjloxDSSortedNoNan) %for each trial
    %         hold on;
    %         currentTrial = ones([numel(currentSubjloxDSSortedNoNan{trial}),1]); %make an array equal to the size of the number of licks for that trial
    %         currentTrial(:)= trial; %make each entry in this array equal to the current trial number (so we have a correct x value for each lick to scatter plot)
    %         s= scatter(currentSubjloxDSSortedNoNan{trial}, currentTrial, 'k'); %scatter plot the licks for each trial
    %         s.Marker = '.'; %make the marker a small point
    %      end
    %      
    %     set(gca,'Ydir','reverse');% flip the y axis, since this scatter is plotting trials in the opposite direction relative to heat plots
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation')
    %     title(strcat('rat ', num2str(ratID), ' licks surrounding DS'));
    %     
    %     subplot(2,1,2);
    %     for trial = 1:numel(currentSubjloxNSSortedNoNan) %for each trial
    %         hold on;
    %         currentTrial = ones([numel(currentSubjloxNSSortedNoNan{trial}),1]); %make an array equal to the size of the number of licks for that trial
    %         currentTrial(:)= trial; %make each entry in this array equal to the current trial number (so we have a correct x value for each lick to scatter plot)
    %         s= scatter(currentSubjloxNSSortedNoNan{trial}, currentTrial, 'k'); %scatter plot the licks for each trial
    %         s.Marker = '.'; %make the marker a small point
    %     end
    %     
    %     set(gca,'Ydir','reverse');% flip the y axis, since this scatter is plotting trials in the opposite direction relative to heat plots
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation')
    %     title(strcat('rat ', num2str(ratID), ' licks surrounding NS'));
    %     
    %     %SAVE PLOTS
    %     set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
    %     saveas(gcf, strcat(figPath,'rat_', num2str(ratID),'_licks_surrounding_cue_sorted','.tiff')); %save the current figure in tif format

    % %plot of all DSz- sorted by latency (seems unnecessary at this point)- delete?
    %     figure;
    %     currentSubjDSzSorted = currentSubjDSzSorted.';  %transpose for readability, each row is now 1 cue! 
    %     imagesc(timeLock, 1:size(currentSubjDSzSorted,1), currentSubjDSzSorted);
    % %     imagesc(timeLock, currentSubjpoxDSlatencySorted, currentSubjDSzSorted); %TODO: trying to show latency on y axis
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation') %TODO: change to latency
    %     title(strcat('rat ', num2str(ratID), ' z score response to every DS cue SORTED BY LATENCY (Lo-Hi-NaN)')); 

    % Within session plots (all cues from a single session)

    %     currentSubj= subjData.(subjField{i});
    % for ses= 1:numel(currentSubj) %for each session
    %     
    %     currentSesDSz= squeeze(currentSubj(ses).DSz); %squeeze the 3d matrix into a 2d array, with each column representing 1 cue
    %     
    %     figure;
    %     currentSesDSz= currentSesDSz.'; %transpose for readability, each row is now 1 cue 
    %     imagesc(timeLock, 1:size(currentSesDSz,1), currentSesDSz);
    %     c= colorbar; %colorbar legend
    %     c.Label.String= strcat('z-score calculated from', num2str(slideTime/fs), 's preceding cue');
    %     xlabel('seconds from cue onset');
    %     ylabel('cue presentation')
    %     title(strcat('rat ', num2str(ratID), ' z score response to DS; training day: ', num2str(currentSubj(ses).trainDay)));
    % end

     %% SPEARMAN CORRELATION - still in the loop through subjects

         %DEFINE DATA FOR SPEARMAN CORRELATION
        postCueCorrWindow= .300; %300ms (as in Richard et al., 2018) - CHANGE this to define the duration of activity after the cue to examine
        postCueCorrFrames= postCueCorrWindow*fs; %multiply by frequency of sampling to get appropriate # datapoints


        postCueDSzSortedNoNan= currentSubjDSzSortedNoNan(:,1:postCueCorrFrames); %extract only z score values in the time window of interest following the cue

        meanPostCueDSzSortedNoNan= mean(postCueDSzSortedNoNan,2); %avg z score within the time window of interest immediately following the cue


        %get the PE and lick onset for each cue for spearman correlation (first + lick)
        %To run the correlation, we need arrays of size= postCueCorrFrames x number of cues
            for trial= 1:numel(currentSubjloxDSSortedNoNan) %for each cue

                %Get the first PE timestamp after cue onset
                postCuepoxOnset(1:postCueCorrFrames, trial)= currentSubjpoxDSlatencySortedNoNan(:,trial); %filling out a row for each frame

                %Get the first positive lick timestamp relative to cue onset
                if any(currentSubjloxDSSortedNoNan{:,trial}>0) ==1 %it's possible (though seems very unlikely) that some trials will only have licks that occur before the cue (- value), just discard these
                postCueloxOnset(1:postCueCorrFrames,trial)= min(currentSubjloxDSSortedNoNan{:,trial}(currentSubjloxDSSortedNoNan{:,trial}>0)); 
                disp(postCueloxOnset(1:postCueCorrFrames,trial));
                else
                    postCueloxOnset(1:postCueCorrFrames,trial)= nan;
                end            
            end        

            %determine spearman correlation between activity just after cue and PE onset
            %X AND Y MUST HAVE SAME # ROWS- consider filling out a cue x postcuecorrframes array where each cue column is populated with the same pe latency/lick latency 
    %         meanPostCueDSzSortedNoNan= meanPostCueDSzSortedNoNan.'; %need to flip this data to make dimensions equal for correlation

            postCueDSzSortedNoNan= postCueDSzSortedNoNan.'; %transpose to make dimensions equal
            [DSpoxLatencyRho, DSpoxLatencyPval]= corrcoef(postCueDSzSortedNoNan, postCuepoxOnset);

            %determine spearman correlation between activity just after cue and lick onset
            [DSloxLatencyRho, DSloxLatencyPval]= corrcoef(postCueDSzSortedNoNan, postCueloxOnset);


    % postCueCorrWindow= .300; %300ms (as in Richard et al., 2018) - CHANGE this to define the duration of activity after the cue to examine
    % 
    % postCueCorrFrames= postCueCorrWindow*fs; %multiply by frequency of sampling to get appropriate # datapoints
    % 
    % for subj= 1:numel(subjField) %for each subj
    %     
    %     clearvars -except subj subjField postCueCorrWindow postCueCorrFrames fs sesData subjData
    % % 
    % %     currentSubj= subjData.(subjField{subj});
    % %     
    % %     for ses= 1:numel(currentSubj)
    % %        
    % %         %Exclude data- since cue lengths vary between sessions
    % %         %For now, only do this for trials with cueLength ==10 (stage 4 or 5)... colormap will probably appear off if including irrelevant trials
    % %         if currentSubj(ses).trainStage ~= 4 && currentSubj(ses).trainStage ~=5 %if not stage 4 or 5, exclude data 
    % %             fn = fieldnames(currentSubj);
    % %             for field = 1:numel(fieldnames(currentSubj))
    % %                 currentSubj(ses).(fn{field})= []; %delete the data
    % %             end
    % %         end
    %         
    %     %Get the z score fluorescence response within the defined time window after the cue 
    %         disp(ses);
    %         if ses==1 %for the first session initialize these arrays 
    %         periDSz= squeeze(currentSubj(ses).DSz); %get all of the z scores surrounding the for this session
    %         periNSz= squeeze(currentSubj(ses).NSz);
    %         
    %         
    %         else %for subsequent sessions, use cat to add on data
    %         periDSz= cat(2, periDSz, squeeze(currentSubj(ses).DSz));
    %         periDSz= cat(2, periNSz, squeeze(currentSubj(ses).NSz));
    %         end
    % %     
    % %     postCueCorrDSz= periDSz(1:postCueCorrFrames,:); %extract only z score values in the time window of interest following the cue
    % %     postCueCorrNSz= periNSz(1:postCueCorrFrames, :);
    % %         
    % %     postCueCorrDSzMean= mean(postCueCorrDSz, 2); %avg across 2nd dimension (across all cues)
    % %     postCueCorrNSzMean= mean(postCueCorrNSz, 2); %avg across 2nd dimension (across all cues)
    % % 
    % %     %Must find the onset time of the first lick AFTER cue onset (first positive value)
    % %     postCueCorrLoxDS= subjData.(subjField{subj}).loxDS; %Must find the onset time of the first lick AFTER cue onset (first positive value)
    % %  
    % %     currentSubj= subjData.(subjField{i}); 
    end
end





