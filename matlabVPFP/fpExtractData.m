% Fiber Photometry data extraction
% 11/25/19

clear
clc
close all
%originally adapted from JocelynPhotometryRetro.m

%Make sure you have the vpfpIndex excel sheet filled out properly and paths are correct

%% Use excel spreadsheet as index to load all .NEXs along with subject # and experiment details etc.

% TODO: read whole index and analyze >2 rats at a time
% TODO: fix rat names and other sesData (always showing 2 and 3 currently)

metaDataAddress = 'Z:\Dakota\Photometry\VP-VTA-FP\round2\Magazine training\nexFilesVP-VTA-FP-round2\VP-VTA-FP_round2_Metadata.xlsx'; % excel file location 

nexAddress =  'Z:\Dakota\Photometry\VP-VTA-FP\round2\Magazine training\nexFilesVP-VTA-FP-round2\'; % nex file location 
nexFiles=dir([nexAddress,'//*.nex']); %find all .nex files within this address

figPath= 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

experimentName= 'VP-VTA-FP'; %change experiment name for automatic naming of figures

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
      
    %% could add preprocessing here - e.g. downsample to 40hz to save space
    
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
    sesData(file).blueA = blueA;
    sesData(file).blueB = blueB;
    sesData(file).purpleA = purpleA;
    sesData(file).purpleB = purpleB;

    if sesData(file).trainStageA==5|sesData(file).trainStageB==5 %only stage 5 has the NS
        sesData(file).NS= NS;
    end   
    
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
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageA;
                subjData.(subjField)(i).box= 'box A';
                
                %Photometry signals
                subjData.(subjField)(i).blue= sesData(i).blueA;
                subjData.(subjField)(i).purple= sesData(i).purpleA;

                
                subjData.(subjField)(i).DS= sesData(i).DS;
             	subjData.(subjField)(i).pox= sesData(i).poxA;
                subjData.(subjField)(i).out= sesData(i).outA;
                subjData.(subjField)(i).lox= sesData(i).loxA;

                if subjData.(subjField)(i).trainStage== 5 %NS only on stage 5
                
                    subjData.subjField(i).NS= sesData(i).NS;
                end
                
        %BOX B
            elseif subj ==sesData(i).ratB %if this rat was in boxB, associate session data from boxB with it
                 trialCount= trialCount+1; %increment counter

                %Metadata
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).trainDay= sesData(i).trainDay; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageB;
                subjData.(subjField)(i).box= 'box B';

                %Photometry signals
                subjData.(subjField)(i).blue= sesData(i).blueB;
                subjData.(subjField)(i).purple= sesData(i).purpleB;

                %events


                subjData.(subjField)(i).pox= sesData(i).poxB;
                subjData.(subjField)(i).out= sesData(i).outB;
                subjData.(subjField)(i).lox= sesData(i).loxB;

                if subjData.(subjField)(i).trainStage== 5 %NS only on stage 5
                
                    subjData.(subjField)(i).NS= sesData(i).NS;
                end

            end 
        end %end session loop

    % remove empty cells from subjData
    if ~isnan(subj)
    subjData.(subjField)= subjData.(subjField)(~cellfun(@isempty,{subjData.(subjField).trainDay})); %Remove empty cells from subjData (TODO: apply this method to SubjData itself)
    end  
end %end subject loop

