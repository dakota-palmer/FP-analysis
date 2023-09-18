clear
clc
close all

%Make sure you have the vpfpIndex excel sheet filled out properly and paths are correct!
%Make sure experiment name is correct!

%This is really data intensive- consider downsampling or just look 1 fig at
%a time

%% Use excel spreadsheet as index to load all .NEXs along with subject # and experiment details etc.

% TODO: read whole index and analyze >2 rats at a time
% TODO: fix rat names and other sesData (always showing 2 and 3 currently)
      
metaDataAddress = 'Z:\Dakota\Photometry\VP-VTA-FP\round2\DS training\nexFilesVP-VTA-FP-round2\VP-VTA-FP_round2_Metadata.xlsx'; % excel file location 
 
nexAddress =  'Z:\Dakota\Photometry\VP-VTA-FP\round2\DS training\nexFilesVP-VTA-FP-round2'; % nex file location 
nexFiles=dir([nexAddress,'//*.nex']); %find all .nex files within this address

% figPath= 'C:\Users\Dakota\Desktop\testFigs\'; %location for output figures to be saved

experimentName= 'VP-VTA-FP-round2'; %change experiment name for automatic naming of figures



%establish photometer clip thresholds (in V)- TODO: now that we have 3
%boxes, use metadata to check which photometers are used 
thresholdA= 5.3 %5.4 is actual limit for photometer 1
thresholdB= 6.9 %7 is actual limit for photometer 2


%% Loop through each nex file, extracting data

sesNum= 0;

for file = 1:length(nexFiles) % All operations will be applied to EVERY nexFile  
        
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

    
    
    for i= 1:numel(data.contvars)
       broadbandAindex= contains(data.contvars{i,1}.name, 'Fi1r_5');
       broadbandBindex= contains(data.contvars{i,1}.name, 'Fi1r_6');

       if(broadbandAindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
%            sesData(file).broadbandA = data.contvars{i,1}.data;
            broadbandA= data.contvars{i,1}.data;
       end
       if(broadbandBindex ==1)  %e.g. if DSindex returns true (1), then define DS as the timestamps within this data.events series
%            sesData(file).broadbandB = data.contvars{i,1}.data;
            broadbandB= data.contvars{i,1}.data;
       end
    end 
            
        %if one of the broadband signals had a high voltage value, let's
        %plot it for further examination 
        
%         disp(strcat('max A= ', num2str(max(broadbandA)), ' max B= ', num2str(max(broadbandB)))); 
    if max(broadbandA) >thresholdA
        disp('high voltage in photometer A !!!!!!!!!')
        figure();
        hold on
        plot(broadbandA);
        plot([0, numel(broadbandA)], [thresholdA, thresholdA], 'r--');
        title(strcat(experimentName, ' rat ', num2str(sesData(file).ratA), ' day ', num2str(sesData(file).trainDay),  ' broadband signal A', '(file= ', fName,')'));
        ylabel('voltage (V)');

        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
        saveas(gcf, strcat(experimentName,'_', 'rat_',num2str(sesData(file).ratA),'photometer_A_high_V','.tiff'));
        close;
    end
    
    if  max(broadbandB) > thresholdB
        disp('high voltage in photometer B !!!!!!!!!')
        figure();
        hold on;
        plot(broadbandB);
        plot([0, numel(broadbandB)], [thresholdB, thresholdB], 'r--');
        title(strcat(experimentName, ' rat ', num2str(sesData(file).ratB), ' day ', num2str(sesData(file).trainDay),  ' broadband signal B','(file= ', fName,')'));
        ylabel('voltage (V)');
        
        set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
        saveas(gcf, strcat(experimentName,'_', 'rat_',num2str(sesData(file).ratB),'photometer_B_high_V','.tiff'));
        close;
    end
end
% %% plot broadband signals
% figureCount=1;
% for session = 1:numel(sesData) %for each training session this subject completed
%        
%         figure(figureCount);
%         figureCount= figureCount+1;
%         
%        %% Broadband photometer session plots
%        subplot(2,1,1)
%         hold on
%         plot(sesData(session).broadbandA);
%         title('broadband signal A');
%         subplot(2,1,2)
%         plot(sesData(session).broadbandB);
%         title('broadband signal B')
%         ylabel('V');
%    end  


disp('done');