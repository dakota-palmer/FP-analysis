% Fiber Photometry data extraction
% 11/25/19

clear
clc
close all
%originally adapted from JocelynPhotometryRetro.m

%Make sure you have the vpfpIndex excel sheet filled out properly and paths are correct!
%Make sure experiment name is correct!

%% Use excel spreadsheet as index to load all .NEXs along with subject # and experiment details etc.

% TODO: read whole index and analyze >2 rats at a time
% TODO: fix rat names and other sesData (always showing 2 and 3 currently)

metaDataAddress = 'C:\Users\capn1\Desktop\nexFiles_VPFP\vpfp_metadata.xlsx'; % excel file location 

nexAddress =  'C:\Users\capn1\Desktop\nexFiles_VPFP\'; % nex file location 
nexFiles=dir([nexAddress,'//*.nex']); %find all .nex files within this address

% figPath= 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

experimentName= 'VPFP-QuantNeuro'; %change experiment name for automatic naming of figures

%% Loop through each nex file, extracting data

sesNum= 0;

for file = 1:length(nexFiles) % All operations will be applied to EVERY nexFile  
    
    clearvars -except file nexFiles metaDataAddress nexAddress sesNum sesData subjData figPath runAnalysis experimentName; %% CLEAR ALL VARIABLES between sessions (except a few)- this way we ensure there isn't any data contamination between sessions
    
    fName = nexFiles(file).name; %define the nex file name to load
    data = readNexFile([nexAddress,'//',fName]); %load the nex file data
    disp(strcat(fName, ' file # ', num2str(file), '/', num2str(length(nexFiles))));
    
    sesNum=sesNum+1; %increment the loop
     
    [~,~,excelData] = xlsread(metaDataAddress); %import metadata from excel spreadsheet
    fileIndex= find(strcmp(excelData(:,1),fName)); %search the spreadsheet data for the matching fileName to get index for matching metadata
    
    sesData(file).ratA= excelData{fileIndex,2}(); %assign appropriate metadata...These values must be changed if the spreadsheet column organization is changed
    sesData(file).ratB = excelData{fileIndex,3}();
    sesData(file).trainStageA = excelData{fileIndex,4}();
    sesData(file).trainStageB = excelData{fileIndex,5}();
    sesData(file).trainDay = excelData{fileIndex,6}();

    
    disp(strcat('rat A = ', num2str(sesData(file).ratA), ' ; rat B = ', num2str(sesData(file).ratB), ' ; trainStageA = ', num2str(sesData(file).trainStageA), ' ; trainStageB = ', num2str(sesData(file).trainStageB), ' ; trainDay = ', num2str(sesData(file).trainDay))); 
    
    %% Extract contvars (photometer data)

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
           
     
       else %if the data isn't present, just make it nan
           
           poxA= nan;
           poxB= nan;
           DS= nan;
           NS= nan;
           loxA= nan;
           loxB= nan;
           outA= nan;
           outB= nan;
        end
    end

    %% Extract events; Since nexfile organization differs, search the nexfile and define events programmatically
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
      
    %% Preprocessing- downsample to 40Hz and remove some datapoints at beginning & end to remove artifacts
    %Downsample to 40hz from fs
    fs = data.contvars{1,1}.ADFrequency; %Frequency of sampling- todo: double check this (should not be a fraction?)

    reblueA=resample(blueA,40,round(fs));       %Downsample to 40Hz from fs %consider using downsample() function here instead of resample()?
    repurpleA=resample(purpleA,40,round(fs));

    reblueB=resample(blueB,40,round(fs));
    repurpleB=resample(purpleB,40,round(fs));
    
    fs=40;    
    
    reTime= linspace(data.tbeg, data.tend, length(reblueA));     %Create time axis in seconds based on this resampling- so that each intensity value has a corresponding timestamp

    % remove several initial and final data points to eliminate artifacts
    numStartExclude= 400;  % define the number of data points to exclude from end- here 400 = 10s of data(remember, 40Hz downsample so 400/40 = 10s)
    numEndExclude = 400; % define the number of data points to exclude from beginning- here 400 = 10s of data(remember, 40Hz downsample so 400/40 = 10s)
    repurpleA = repurpleA(numStartExclude:end-numEndExclude);    % 405nm data from box A ; here I simply redefined repurpleA as rePurpleA minus the number of excluded data points from both the beginning and end defined above (400)
    reblueA = reblueA(numStartExclude:end-numEndExclude);       % 465nm data from box A

    repurpleB = repurpleB(numStartExclude:end-numEndExclude);   % 405nm data from box B
    reblueB = reblueB(numStartExclude:end-numEndExclude);       % 465nm data from box B

    cutTime = reTime(numStartExclude:end-numEndExclude);        % define cutTime as a new time axis w/o removed points- remember each intensity value should have a corresponding timestamp
    
    %% Save all data for a given session to struct for easy access
    
        %Events
    sesData(file).DS = DS;

    sesData(file).poxA= poxA;
    sesData(file).loxA= loxA;
    sesData(file).outA= outA;
    
    sesData(file).poxB= poxB;
    sesData(file).loxB= loxB;
    sesData(file).outB= outB;
    
        %Photometry signals
    sesData(file).cutTime= cutTime;
    sesData(file).reblueA = reblueA;
    sesData(file).reblueB = reblueB;
    sesData(file).repurpleA = repurpleA;
    sesData(file).repurpleB = repurpleB;

%     if sesData(file).trainStageA==5|sesData(file).trainStageB==5 %only stage 5 has the NS
        sesData(file).NS= NS; %will just populate with Nan if not present
%     end   
    
end %End file loop

    %% Reorganize data into struct by subject 
    
    %identify unique rats and associate data from all sessions with rat
    %instead of boxF
    rats= cat(1, sesData.ratA, sesData.ratB);
    rats= unique(rats);

    trialCount = 0; %counter for looping to fill subjData appropriately
    
for rat = 1:numel(rats) 
        subj= rats(rat);

        subjField= (strcat('rat',num2str(subj))); %dynamically assign field name for each subject- This may be problematic

        for i=1:numel(sesData) 
        %BOX A
            if subj == sesData(i).ratA %if this rat was in boxA, associate session data from boxA with it
                trialCount= trialCount+1; %increment counter
                
                %Metadata
                subjData.(subjField)(i).experiment= experimentName
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageA;
                subjData.(subjField)(i).box= 'box A';
                
                %Photometry signals
                subjData.(subjField)(i).cutTime= sesData(i).cutTime;
                subjData.(subjField)(i).reblue= sesData(i).reblueA;
                subjData.(subjField)(i).repurple= sesData(i).repurpleA;

                
                subjData.(subjField)(i).DS= sesData(i).DS;
             	subjData.(subjField)(i).pox= sesData(i).poxA;
                subjData.(subjField)(i).out= sesData(i).outA;
                subjData.(subjField)(i).lox= sesData(i).loxA;

%                 if subjData.(subjField)(i).trainStage== 5 %NS only on stage 5
                
                    subjData.(subjField)(i).NS= sesData(i).NS; %will just populate with nan if not present
%                 end
                
        %BOX B
            elseif subj ==sesData(i).ratB %if this rat was in boxB, associate session data from boxB with it
                 trialCount= trialCount+1; %increment counter

                %Metadata
                subjData.(subjField)(i).experiment= experimentName
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageB;
                subjData.(subjField)(i).box= 'box B';

                %Photometry signals
                subjData.(subjField)(i).cutTime= sesData(i).cutTime;
                subjData.(subjField)(i).reblue= sesData(i).reblueB;
                subjData.(subjField)(i).repurple= sesData(i).repurpleB;

                %events

                subjData.(subjField)(i).DS= sesData(i).DS;
                subjData.(subjField)(i).pox= sesData(i).poxB;
                subjData.(subjField)(i).out= sesData(i).outB;
                subjData.(subjField)(i).lox= sesData(i).loxB;

%                 if subjData.(subjField)(i).trainStage== 5 %NS only on stage 5
                
                    subjData.(subjField)(i).NS= sesData(i).NS;
%                 end

            end 
        end %end session loop

    % remove empty cells from subjData
    if ~isnan(subj)
    subjData.(subjField)= subjData.(subjField)(~cellfun(@isempty,{subjData.(subjField).trainDay})); %Remove empty cells from subjData (TODO: apply this method to SubjData itself)
    end  
end %end subject loop

%save the subjData struct for later analysis
save(strcat(experimentName,'-', date), 'subjData');
