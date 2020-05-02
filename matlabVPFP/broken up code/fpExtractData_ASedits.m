% Fiber Photometry data extraction
% 11/25/19

clear
clc
close all
%originally adapted from JocelynPhotometryRetro.m

%Make sure you have the vpfpIndex excel sheet filled out properly and paths are correct!
%Make sure experiment name is correct!


profile on; %For optimization/trackin g performance of the code- this starts the Matlab profiler

%% Use excel spreadsheet as index to load all .NEXs along with subject # and experiment details etc.

% TODO: read whole index and analyze >2 rats at a time
% TODO: fix rat names and other sesData (always showing 2 and 3 currently)

metaDataAddress = 'Z:\Ally\GAD-VPFP DS Training\nexFilesVPFP\DS Training All\GADVPFPall_metadata_VP_final.xlsx'; % excel file location 

nexAddress =  'Z:\Ally\GAD-VPFP DS Training\nexFilesVPFP\DS Training All'; % nex file location 
nexFiles=dir([nexAddress,'//*.nex']); %find all .nex files within this address
%note: assembly of this nex file list is case-sensitive (I had a minor issue
%where files with subjects in caps were being loaded before uncapitalized
%subject files- but sorting by training day would fix any of these issues)

% figPath= 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

experimentName= 'GADVPFPall'; %change experiment name for automatic naming of figures

%% Loop through each nex file, extracting data

sesNum= 0;

for file = 1:length(nexFiles) % All operations will be applied to EVERY nexFile  
      
    tic;
    
    clearvars -except fs file nexFiles metaDataAddress nexAddress sesNum sesData subjData figPath runAnalysis experimentName; %% CLEAR ALL VARIABLES between sessions (except a few)- this way we ensure there isn't any data contamination between sessions
    
    fName = nexFiles(file).name; %define the nex file name to load
    data = readNexFile([nexAddress,'//',fName]); %load the nex file data
    disp(strcat(fName, ' file # ', num2str(file), '/', num2str(length(nexFiles))));
    
    sesNum=sesNum+1; %increment the loop
     
    [~,~,excelData] = xlsread(metaDataAddress); %import metadata from excel spreadsheet
    fileIndex= find(strcmp(excelData(:,1),fName)); %search the spreadsheet data for the matching fileName to get index for matching metadata
    
    sesData(file).date= excelData{fileIndex,2}();
    
    sesData(file).ratA= excelData{fileIndex,3}(); %assign appropriate metadata...These values must be changed if the spreadsheet column organization is changed
    sesData(file).ratB = excelData{fileIndex,4}();
    
    sesData(file).boxA= excelData{fileIndex,10}(); %get the actual box identity
    sesData(file).boxB= excelData{fileIndex,11}();
        
    sesData(file).DSidentity = excelData{fileIndex,9}();
    sesData(file).trainStageA = excelData{fileIndex,5}();
    sesData(file).trainStageB = excelData{fileIndex,6}();
    sesData(file).trainDayA = excelData{fileIndex,7}();
    sesData(file).trainDayB = excelData{fileIndex,8}();
    sesData(file).fileName= fName;
    
    %Variable reward info
    sesData(file).pump1= excelData{fileIndex,12}();
    sesData(file).pump2= excelData{fileIndex,13}();
    sesData(file).pump3= excelData{fileIndex,14}();
    
    %NS introduced Data
    sesData(file).NSAintro= excelData{fileIndex,22}();
    sesData(file).NSBintro= excelData{fileIndex,23}();
    
    %NS introduced Data
    sesData(file).Acriteria= excelData{fileIndex,24}();
    sesData(file).Bcriteria= excelData{fileIndex,25}();
    
    disp(strcat('rat A = ', num2str(sesData(file).ratA), ' ; rat B = ', num2str(sesData(file).ratB), '; box A= ', num2str(sesData(file).boxA), '; box B= ', num2str(sesData(file).boxB), ' ;  trainStageA = ', num2str(sesData(file).trainStageA), ' ; trainStageB = ', num2str(sesData(file).trainStageB), ' ; trainDayA = ', num2str(sesData(file).trainDayA))); 
    
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
            
            %Let's define the frequency of sampling (fs) using this channel here!
            fs= data.contvars{i,1}.ADFrequency;
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
    
    %fs is defined with contvars above
    
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
       
       outAindex= contains(data.events{i,1}.name, 'Out1');
       outBindex= contains(data.events{i,1}.name, 'Out2');


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
      
     if(outAindex ==1)
           outA = data.events{i,1}.timestamps;
     end
      
     if(outBindex ==1)
           outB = data.events{i,1}.timestamps;
     end
      
     
    end
      
    %% Preprocessing- downsample to 40Hz and remove some datapoints at beginning & end to remove artifacts
    %Downsample to 40hz from fs (fs is defined with contvars in the beginning)
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

    sesData(file).NS= NS; %will just populate with Nan if not present
    
toc

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
                subjData.(subjField)(i).experiment= experimentName;
                
                subjData.(subjField)(i).date= sesData(i).date;
                
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).fileName= sesData(i).fileName;
                subjData.(subjField)(i).DSidentity= sesData(i).DSidentity;
                subjData.(subjField)(i).trainDay= sesData(i).trainDayA; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageA;
                subjData.(subjField)(i).box= sesData(i).boxA;
                
                %Variable reward
                 subjData.(subjField)(i).pump1= sesData(i).pump1;
                 subjData.(subjField)(i).pump2= sesData(i).pump2;
                 subjData.(subjField)(i).pump3= sesData(i).pump3;
                
                 %NS Introduced
                 subjData.(subjField)(i).NSAintro= sesData(i).NSAintro;
            
                
                %Criteria Reached
                 subjData.(subjField)(i).Acriteria= sesData(i).Acriteria;
                
                %Photometry signals
                subjData.(subjField)(i).cutTime= sesData(i).cutTime;
                subjData.(subjField)(i).reblue= sesData(i).reblueA;
                subjData.(subjField)(i).repurple= sesData(i).repurpleA;

                
                subjData.(subjField)(i).DS= sesData(i).DS;
             	subjData.(subjField)(i).pox= sesData(i).poxA;
                subjData.(subjField)(i).out= sesData(i).outA;
                subjData.(subjField)(i).lox= sesData(i).loxA;
                
                subjData.(subjField)(i).NS= sesData(i).NS; %will just populate with nan if not present
                
        %BOX B
            elseif subj ==sesData(i).ratB %if this rat was in boxB, associate session data from boxB with it
                 trialCount= trialCount+1; %increment counter

                %Metadata
                subjData.(subjField)(i).experiment= experimentName;
                
                subjData.(subjField)(i).date= sesData(i).date;

                
                subjData.(subjField)(i).rat= subj;
                subjData.(subjField)(i).fileName= sesData(i).fileName;
                subjData.(subjField)(i).DSidentity= sesData(i).DSidentity;
                subjData.(subjField)(i).trainDay= sesData(i).trainDayB; 
                subjData.(subjField)(i).trainStage= sesData(i).trainStageB;
                subjData.(subjField)(i).box= sesData(i).boxB;
                
                %Variable reward
                 subjData.(subjField)(i).pump1= sesData(i).pump1;
                 subjData.(subjField)(i).pump2= sesData(i).pump2;
                 subjData.(subjField)(i).pump3= sesData(i).pump3;

                 %NS Introduced
                 subjData.(subjField)(i).NSBintro= sesData(i).NSBintro;
                 
                 %Criteria Reached 
                 subjData.(subjField)(i).Bcriteria= sesData(i).Bcriteria;
     
                %Photometry signals
                subjData.(subjField)(i).cutTime= sesData(i).cutTime;
                subjData.(subjField)(i).reblue= sesData(i).reblueB;
                subjData.(subjField)(i).repurple= sesData(i).repurpleB;

                %events

                subjData.(subjField)(i).DS= sesData(i).DS;
                subjData.(subjField)(i).pox= sesData(i).poxB;
                subjData.(subjField)(i).out= sesData(i).outB;
                subjData.(subjField)(i).lox= sesData(i).loxB;

                
                subjData.(subjField)(i).NS= sesData(i).NS;

            end 
        end %end session loop

    % remove empty cells from subjData
    if ~isnan(subj)
    subjData.(subjField)= subjData.(subjField)(~cellfun(@isempty,{subjData.(subjField).trainDay})); %Remove empty cells from subjData (TODO: apply this method to SubjData itself)
    end  
end %end subject loop

%% Sort struct by training day for each subject before saving
%at times files are loaded out of order, this will organize everything by training day (each row in the struct = 1 session) 

subjects= fieldnames(subjData); %access subjData struct with dynamic fieldnames

for subj = 1:numel(subjects)
 currentSubj= subjData.(subjects{subj}); 
 subjTable = struct2table(currentSubj); % convert the struct array to a table
 subjTableSorted = sortrows(subjTable, 'trainDay'); % sort the table by 'trainDay'
 subjData.(subjects{subj}) = table2struct(subjTableSorted);
end


%% Match raw timestamps with closest downsampled timestamps

%we downsampled to 40hz, but our behavioral timestamps don't correspond
%cleanly to our cutTime axis. Here, we shift these timestamps to fit the
%40hz sampling rate. To do so, we'll use the interp() function which is very efficient

%This may not be approporiate for many analyses, but if we do decide to
%conduct a peri-event analysis we may need every timestamp to have a
%corresponding photometry value, so we'll want to find the nearest
%cutTime timestamp eventually anyway

disp('aligning event timestamps to cutTime axis');

for subj= 1:numel(subjects) %for each subject
      
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
  
   for session = 1:numel(currentSubj) %for each training session this subject completed    
        clear cutTime timeDiffDS timeDiffNS timeDiffpox timeDifflox timeDiffout  %this is cleared between sessions to prevent spillover

        cutTime= currentSubj(session).cutTime; %save this as an array, greatly speeds things up because we have to go through each timestamp to find the closest one to the cues

    %Shift DS
        currentSubj(session).DSshifted= interp1(cutTime,cutTime, currentSubj(session).DS, 'nearest');

        %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
        timeShift= abs(currentSubj(session).DS-currentSubj(session).DSshifted);
        if abs(timeShift) >0.02 %this will flag cues whose time shift deviates above a threshold (in seconds)
            disp(strcat('>>Error *big DS time shift ', num2str(timeShift(timeShift>0.02)), 'shifted DS ', num2str(currentSubj(session).cutTime(DSonsetShifted))));
        end           

    %Shift NS
       currentSubj(session).NSshifted= interp1(cutTime,cutTime, currentSubj(session).NS, 'nearest');

        %calculate the difference between the shifted onset time and the actual onset time (just for QA- we wouldn't want this to be too large)
        timeShift= abs(currentSubj(session).NS-currentSubj(session).NSshifted);
        if abs(timeShift) >0.02 %this will flag cues whose time shift deviates above a threshold (in seconds)
            disp(strcat('>>Error *big NS time shift ', num2str(timeShift(timeShift>0.02)), 'shifted NS ', num2str(currentSubj(session).cutTime(NSonsetShifted))));
        end         

%     %Shift pox
%         currentSubj(session).poxShifted= interp1(cutTime, cutTime, currentSubj(session).pox, 'nearest');
% 
%         %quality control
%         timeShift= abs(currentSubj(session).pox-currentSubj(session).poxShifted);
%         if timeShift > 0.02% >0.02 %this will flag events whose time shift deviates above a threshold (in seconds)
%             disp(strcat('>>Error *big pox time shift ', num2str(timeShift(timeShift>0.02)), ' subj ',num2str(subj), '; session ', num2str(session)));
%         end     
% 
%     %Shift lox
%         currentSubj(session).loxShifted= interp1(cutTime, cutTime, currentSubj(session).lox, 'nearest');
% 
%         %quality control
%         timeShift= abs(currentSubj(session).lox-currentSubj(session).loxShifted);
%         if timeShift > 0.02% >0.02 %this will flag events whose time shift deviates above a threshold (in seconds)
%         disp(strcat('>>Error *big lox time shift ', num2str(timeShift(timeShift>0.02)), ' subj ',num2str(subj), '; session ', num2str(session)));
%         end   
% 
%     %Shift outs
%         currentSubj(session).outShifted= interp1(cutTime, cutTime, currentSubj(session).out, 'nearest');
% 
%         %quality control
%         timeShift= abs(currentSubj(session).out-currentSubj(session).outShifted);
%         if timeShift > 0.02% >0.02 %this will flag events whose time shift deviates above a threshold (in seconds)
%         disp(strcat('>>Error *big out time shift ', num2str(timeShift(timeShift>0.02)), ' subj ',num2str(subj), '; session ', num2str(session)));
%         end  
%           
    subjData.(subjects{subj})(session).DSshifted= currentSubj(session).DSshifted;
    subjData.(subjects{subj})(session).NSshifted= currentSubj(session).NSshifted;
%     subjData.(subjects{subj})(session).poxShifted= currentSubj(session).poxShifted;
%     subjData.(subjects{subj})(session).loxShifted= currentSubj(session).loxShifted;
%     subjData.(subjects{subj})(session).outShifted= currentSubj(session).outShifted;    
%       
%       
    end %end session loop
end %end subj loop
 

%% Save .mat
%save the subjData struct for later analysis
save(strcat(experimentName,'-', date, 'subjDataRaw'), 'subjData'); %the second argument here is the variable saved, the first is the filename


disp('all done')


%%  Speed test /optimizing

profile viewer;
% %things that should be optimized: cleavars takes awhile ; timeDifflox
% takes awhile (prob bc lots of licks happen) took like 7/20min for 42
% sessions