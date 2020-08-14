% RICHARD LAB ADAPTATION OF PARKER ENCODING MODEL

% function[answer]=inscopix_spline_regression(condition,neuron)

clear all
close all
clc

%determine if folder exists and if so purge it, if not create it
curr_dir = pwd;
save_folder = 'encoding_results/pl';
if exist(save_folder)==0
    mkdir(save_folder)
else
    cd(save_folder)
    delete('*')
    cd ../..
end
    
figsave_folder='\\files.umn.edu\ahc\MNPI\neuroscience\labs\richard\Ally\Code\FP-analysis-variableReward\FP_analysis\FP-analysis\Parker encoding model\encoding_results\figs\40 Hz\set baseline\';
condition = 'Richard_data_to_input';
subjects = [1 2 3 4 5 ];%:278; %only one example file was included- I think there should be 1 file per neuron...I guess in our case it's 1 per subj -dp


for subj=1:numel(subjects)
    
    clearvars -except curr_dir save_folder figsave_folder condition subjects subj
    
    tic
    %how much time should you shift back (in seconds)
    time_back_orig=2;
    time_forward_orig=10;
    
    type1='time_shift';  %'spline','time_shift'
    
    shift_con=0;   %Should we shift the stimulus events so they start at 0?
    
    %---- Data Extraction-----
    %opens folder to be tested
    file_root=pwd;
    cd(condition)
    
    %creates index of all files in folder
    allitems=dir(pwd);
    f=length(allitems);
    folders_ind=0;
    
    cd(file_root);
    
    for ind=1:f
        if allitems(ind).name(1)~='I' && allitems(ind).name(1)~='.' && allitems(ind).isdir==0
            folders_ind=folders_ind+1;
            files{folders_ind}=allitems(ind).name;
        end
    end
    
    
    %Load file
    file_name=char(files(subj));
    file_name=strcat(condition,'/',file_name);
    load(file_name);
    
    %Convert seconds to hertz + isolates conditions %~~~~~~~~~~Note that
    %'output' & 'g_output' are actually loaded at the beginning of this
    %script -- dp
    % converting into hertz for every event occuring during recording
    DSonsetindex=data_to_input_GADVPFP.output(1).DSonsetindex;
    
     % cutTime
    
    cutTime=data_to_input_GADVPFP.g_output(1).cutTime; 
    
    DSTimes=cutTime(DSonsetindex).*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    DSPETimes=data_to_input_GADVPFP.output(1).DSpox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    DSLickTimes=data_to_input_GADVPFP.output(1).DSlox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    DSPElatency= data_to_input_GADVPFP.output(1).DSPElatencey;
    
    inPortDS= data_to_input_GADVPFP.output(1).inPortDS;
    
    poxDS=data_to_input_GADVPFP.output(1).poxDS;
    
    NSTimes=data_to_input_GADVPFP.output(1).NSTimes.* data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSPETimes=data_to_input_GADVPFP.output(1).NSpox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSLickTimes=data_to_input_GADVPFP.output(1).NSlox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSPElatency= data_to_input_GADVPFP.output(1).NSPElatencey.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    inPortNS= data_to_input_GADVPFP.output(1).inPortNS;
    
    poxNS=data_to_input_GADVPFP.output(1).poxNS;
    
    % frequencey sampling rate (in hZ)
    fs=data_to_input_GADVPFP.g_output(1).samp_rate;
    
    % g_camp
    gcamp_y_blue=data_to_input_GADVPFP.g_output(1).gcamp_raw.blue;
    gcamp_y_purple=data_to_input_GADVPFP.g_output(1).gcamp_raw.purple;
    
    

       %% Moving Z-score
% Here we are calculating the z-score 10 seconds before the DS for each DS   
% 
    z_gcamp_y_blue=[];
    z_gcamp_y_purple=[];
    tb=10; % how many seconds back from DS you want to normalize to
    for DS=1:size(DSTimes,2)
            DSonset=DSonsetindex(DS);
            %DSonset=max(DSonset);
            if DS<30
            DSonset_b=DSonsetindex(DS+1);
            %DSonset_b=max(DSonset_b);
           %DSonset_y=gcamp_y_blue(DSonset);
           %DSonset_b_y=gcamp_y_blue(DSonset_b);
            z_blue_baseline=mean(gcamp_y_blue(DSonset-(tb*fs):DSonset));%basline to use until next DS cue
            z_blue_std=std(gcamp_y_blue(DSonset-(tb*fs):DSonset));
            z_purple_baseline=mean(gcamp_y_purple(DSonset-(tb*fs):DSonset));%basline to use until next DS cue
            z_purple_std=std(gcamp_y_purple(DSonset-(tb*fs):DSonset));
        
             % need to store z_score of time points before 1st DS
             if DS==1
            z_gcamp_y_blue_first(:)=((gcamp_y_blue(1:DSonset-(tb*fs)-1))-z_blue_baseline)/z_blue_std;
            z_gcamp_y_purple_first(:)=((gcamp_y_purple(1:DSonset-(tb*fs)-1))-z_purple_baseline)/z_purple_std;
             end
            
             %Z-score of time points between each DS
            z_gcamp_y_blue_temp=[];
            z_gcamp_y_purple_temp=[];
            
            z_gcamp_y_blue_temp(:,:)=(gcamp_y_blue(DSonset-(tb*fs): DSonset_b-(tb*fs)-1)-z_blue_baseline)/z_blue_std; fprintf('blue Z-scored \n')
            z_gcamp_y_purple_temp(:,:)=(gcamp_y_purple(DSonset-(tb*fs): DSonset_b-(tb*fs)-1)-z_purple_baseline)/z_purple_std; fprintf('purple Z-scored \n')
            
            z_gcamp_y_blue= cat(2,z_gcamp_y_blue(:,:),z_gcamp_y_blue_temp(:,:));
            z_gcamp_y_purple= cat(2,z_gcamp_y_purple(:,:),z_gcamp_y_purple_temp(:,:));
            
            else
                % z-score for time points from last DS until the end
            DSonset_y=gcamp_y_blue(DSonset);
            
            z_blue_baseline=mean(gcamp_y_blue(DSonset-(tb*fs):DSonset));%basline to use until next DS cue
            z_blue_std=std(gcamp_y_blue(DSonset-(tb*fs):DSonset));
            z_purple_baseline=mean(gcamp_y_purple(DSonset-(tb*fs):DSonset));%basline to use until next DS cue
            z_purple_std=std(gcamp_y_purple(DSonset-(tb*fs):DSonset));
            
            z_gcamp_y_blue_temp=[];
            z_gcamp_y_purple_temp=[];
            
            z_gcamp_y_blue_temp(:,:)=(gcamp_y_blue(DSonset-(tb*fs):end)-z_blue_baseline)/z_blue_std; fprintf('blue Z-scored \n')
            z_gcamp_y_purple_temp(:,:)=(gcamp_y_purple(DSonset-(tb*fs):end)-z_purple_baseline)/z_purple_std; fprintf('purple Z-scored \n')
            
            z_gcamp_y_blue= cat(2,z_gcamp_y_blue(:,:),z_gcamp_y_blue_temp(:,:));
            z_gcamp_y_purple= cat(2,z_gcamp_y_purple(:,:),z_gcamp_y_purple_temp(:,:));
            
            end
    end
    
    z_gcamp_y_blue=horzcat( z_gcamp_y_blue_first,z_gcamp_y_blue);
    z_gcamp_y_purple=horzcat( z_gcamp_y_purple_first,z_gcamp_y_purple);
 
% %%  Moving mean g camp z-score;
%     
%     kb1=15;
%     kb2=5;
% 
%     
%     
%     gcamp_y_blue_movmean=rmovmean( gcamp_y_blue,(kb1*fs),(kb2*fs));
%     gcamp_y_purple_movmean=rmovmean( gcamp_y_purple,(kb1*fs),(kb2*fs));
% 
%     blue_movestd=rmovstd( gcamp_y_blue,(kb1*fs),(kb2*fs));
%     purple_movestd=rmovstd( gcamp_y_purple,(kb1*fs),(kb2*fs));
%     
%     
%     %Normalize gcamp signal by the max -- COMMENT OUT WHEN NOT NEEDED
%     % gcamp_y=g_output.gcamp;
%     % gcamp_y=g_output.gcamp./max(g_output.gcamp);
%     
%     z_blue= ( gcamp_y_blue-gcamp_y_blue_movmean)./blue_movestd; fprintf('blue Z-scored \n') 
%     z_purple= ( gcamp_y_purple-gcamp_y_purple_movmean)./purple_movestd; fprintf('purple Z-scored \n') 
%     
%     % find where nans are and exclude them from the z_score and cutTime
%     blue_notnanind=~isnan(z_blue);
%     z_blue_nonan=z_blue(blue_notnanind);
%     z_blue_cutTime=cutTime(blue_notnanind);
%     
% %     % exclusion criteria
% %     criteria=3;
% %     exind=find(z_blue>criteria*nanmean(z_blue));
% 
% %      z_blue= (gcamp_y_blue-mean(gcamp_y_blue))./std(gcamp_y_blue); fprintf('Z-scored \n')

    
%% Plot z-scores
        
    % by trials, in order to do this need to perform event triggured
    % analysis on current data 
    
    % ~~~Event-Triggered Analyses ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %In these sections, we will do an event-triggered analyses by extracting data 
    %from the photometry traces immediately surrounding relevant behavioral events (e.g. cue onset, port entry, lick)
    %To do so, we'll find the onset timestamp for each event (eventTime) and use this
    %timestamp to extract photometry data surrounding it
    %(preEventTime:postEventTime). This will be saved to the subjDataAnalyzed
    %struct. 


    %here we are establishing some variables for our event triggered-analysis
        fs=data_to_input_GADVPFP.g_output(1).samp_rate;
    
        preCueTime= 5; %t in seconds to examine before cue
        postCueTime=10; %t in seconds to examine after cue

        preCueFrames= preCueTime*fs;
        postCueFrames= postCueTime*fs;

        periCueFrames= preCueFrames+postCueFrames;

        slideTime = fs*10; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)

        [filepath,name,ext] = fileparts(file_name);
        subj_name=name;
                % periCueTime = 10;% t in seconds to examine before/after cue (e.g. 20 will get data 20s both before and after the cue) %TODO: use cue length to taper window cueLength/fs+10; %20;        
                % periCueFrames = periCueTime*fs; %translate this time in seconds to a number of 'frames' or datapoints  
                % 
                % slideTime = 400; %define time window before cue onset to get baseline mean/stdDev for calculating sliding z scores- 400 for 10s (remember 400/40hz ~10s)


    % TIMELOCK TO DS

    %In this section, go cue-by-cue examining how fluorescence intensity changes in response to cue onset (either DS or NS)
    %Use an event-triggered sort of approach viewing data before and after cue onset where time 0 = cue onset time
    %Also, a sliding z-score will be calculated for each timepoint like in (Richard et al., 2018)- using data comprising 10s prior to that timepoint as a baseline  
    
    disp(strcat('running DS-triggered analysis subject_',  string(subjects(subj))));

        DSskipped= 0;  %counter to know how many cues were cut off/not analyzed (since those too close to the end will be chopped off- this shouldn't happen often though)

        for cue=1:length(DSTimes) %DS CUES %For each DS cue, conduct event-triggered analysis of data surrounding that cue's onset

            %each entry in DS is a timestamp of the DS onset 
            DSonset = DSonsetindex(1,cue);

            %define the frames (datapoints) around each cue to analyze
            preEventTimeDS = DSonset-preCueFrames; %earliest timepoint to examine is the shifted DS onset time - the # of frames we defined as periDSFrames (now this is equivalent to 20s before the shifted cue onset)
            postEventTimeDS = DSonset+postCueFrames; %latest timepoint to examine is the shifted DS onset time + the # of frames we defined as periDSFrames (now this is equivalent to 20s after the shifted cue onset)

            if preEventTimeDS< 1 %if cue onset is too close to the beginning to extract preceding frames, skip this cue
                disp(strcat('****DS cue ', num2str(cue), ' too close to beginning, continuing'));
                DSskipped= DSskipped+1;
                continue
            end

            if postEventTimeDS> length(cutTime)-slideTime %%if cue onset is too close to the end to extract following frames, skip this cue; if the latest timepoint to examine is greater than the length of our time axis minus slideTime (10s), then we won't be able to collect sufficient basline data within the 'slideTime' to calculate our sliding z score- so we will just exclude this cue
                disp(strcat('****DS cue ', num2str(cue), ' too close to end, continuing'));
                DSskipped= DSskipped+1;  %iterate the counter for skipped DS cues
                continue %continue out of the loop and move onto the next DS cue
            end

            % Calculate average baseline mean&stdDev 10s prior to DS for z-score
            %blueA
            baselineMeanblue= nanmean(gcamp_y_blue((DSonset-slideTime):DSonset)); %baseline mean blue 10s prior to DS onset for boxA
            baselineStdblue=std(gcamp_y_blue((DSonset-slideTime):DSonset)); %baseline stdDev blue 10s prior to DS onset for boxA
            %purpleA
            baselineMeanpurple=nanmean(gcamp_y_purple((DSonset-slideTime):DSonset)); %baseline mean purple 10s prior to DS onset for boxA
            baselineStdpurple=std(gcamp_y_purple((DSonset-slideTime):DSonset)); %baseline stdDev purple 10s prior to DS onset for boxA

            %save all of the following data in the subjDataAnalyzed struct under the periDS field

%             subjDataAnalyzed.(subjects{subj})(session).periDS.DS(cue) = currentSubj(session).DS(cue); %this way only included cues are saved
%             subjDataAnalyzed.(subjects{subj})(session).periDS.DSonset(cue)= DSonset;% DS onset index in cutTime
%             subjDataAnalyzed.(subjects{subj})(session).periDS.periDSwindow(:,:,cue)= currentSubj(session).cutTime(preEventTimeDS:postEventTimeDS);

%             subjDataAnalyzed.(subjects{subj})(session).periDS.DSblue(:,:,cue)= currentSubj(session).reblue(preEventTimeDS:postEventTimeDS);
%             subjDataAnalyzed.(subjects{subj})(session).periDS.DSpurple(:,:,cue)= currentSubj(session).repurple(preEventTimeDS:postEventTimeDS);
                
                %z score calculation: for each timestamp, subtract baselineMean from current photometry value and divide by baselineStd
            subjDataPEM.(subj_name).periDSRichard.DSzblue(:,:,cue)= (((gcamp_y_blue(1,preEventTimeDS:postEventTimeDS))-baselineMeanblue))/(baselineStdblue); 
            subjDataPEM.(subj_name).periDSRichard.DSzpurple(:,:,cue)= (((gcamp_y_purple(1,preEventTimeDS:postEventTimeDS))- baselineMeanpurple))/(baselineStdpurple);

            subjDataPEM.(subj_name).periDSParker.DSzblue(:,:,cue)= z_gcamp_y_blue(1,preEventTimeDS:postEventTimeDS); 
            subjDataPEM.(subj_name).periDSParker.DSzpurple(:,:,cue)= z_gcamp_y_purple(1,preEventTimeDS:postEventTimeDS);
 

            
            subjDataAnalyzed.(subj_name).periDSRichard.timeLock= [-preCueFrames:postCueFrames]/fs;
            subjDataAnalyzed.(subj_name).periDSParker.timeLock= [-preCueFrames:postCueFrames]/fs;
       
        end %end DS cue loop

    %collect all z score responses to every single DS across all sessions
           
    currentSubj(1).DSzblueAllTrials= squeeze(subjDataPEM.(subj_name).periDSParker.DSzblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
    currentSubj(1).DSzpurpleAllTrials= squeeze(subjDataPEM.(subj_name).periDSParker.DSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue

    
    %Transpose these data for readability
    currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials';
    currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';    

    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzblueAllTrials,1); 
    
 
    
     %Color axes   
     
     %First, we'll want to establish boundaries for our colormaps based on
     %the std of the z score response. We want to have equidistant
     %color axis max and min so that 0 sits directly in the middle

     %define DS color axes
     
     %get the avg std in the blue and purple z score responses to all cues,
     %get absolute value and then multiply this by some factor to define a color axis max and min
     
     stdFactor= 4; %multiplicative factor- how many stds away do we want our color max & min?
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
  
     bottomAllShared= 2/3*(bottomAllDS);
     topAllShared= 2/3*(topAllDS);

    
    %Heatplots!  
    
    %DS z plot
    
    figureCount=1;
    figure();
    hold on;
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %plot blue DS

    subplot(2,1,1); %subplot for shared colorbar
    
    heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
    title(strcat(string(subjects(subj)),' blue z score response surrounding every DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,1,2);
    heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat(string(subjects(subj)),' purple z score response surrounding every DS ')); %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

     
        figsave_name=strcat('ZTrials_Parker',subj_name,'.fig');
        cd(figsave_folder);
        saveas(gcf,figsave_name);


%         %remove nans
%     blue_nan=~isnan(z_blue);
%     purple_nan=~isnan(z_purple);
%     
%     cutTime_Parker=cutTime(blue_nan);
%     z_blue= z_blue(blue_nan); 
%     z_purple= z_purple(purple_nan); 
    
   % Full traces
    figure();
    plot(cutTime,z_gcamp_y_blue);
    title('blue Z-score');
    
         
        figsave_name=strcat('ZFullTrace_Parker',subj_name,'.fig');
        cd(figsave_folder);
        saveas(gcf,figsave_name);
 

% Full traces
    figure();
    plot(cutTime,gcamp_y_blue);
    title('blue raw');        
        
        

%% LATENCY SORTED HEAT PLOT OF RESPONSE TO EVERY INDIVIDUAL CUE PRESENTATION

%Same as before, but now sorted by PE latency


        %initialize arrays for convenience
        currentSubj(1).DSzblueAllTrials= [];
        currentSubj(1).DSzpurpleAllTrials= [];
        currentSubj(1).DSpeLatencyAllTrials= [];
        
        currentSubj(1).NSzblueAllTrials= [];
        currentSubj(1).NSzpurpleAllTrials= [];
        currentSubj(1).NSpeLatencyAllTrials= [];

    
       
        clear NSselected
        
        %We can only include trials that have a PE latency, so we need to
        %selectively extract these data first
        
            %get the DS cues
        DSselected= cutTime(DSonsetindex);  % all the DS cues

        %First, let's exclude trials where animal was already in port
        %to do so, find indices of subjDataAnalyzed.behavior.inPortDS that
        %have a non-nan value and use these to exclude DS trials from this
        %analysis (we'll make them nan)
            
        %We have to throw in an extra conditional in case we've excluded
        %cues in our peri cue analysis due to being too close to the
        %beginning or end. Otherwise, we can get an out of range error
        %because the inPortDS array doesn't exclude these cues.
        for inPortTrial = find(~isnan(inPortDS))
            if inPortTrial < numel(DSselected) 
                DSselected(~isnan(inPortDS)) = nan;
            end
        end
        %Then, let's exclude trials where animal didn't make a PE during
        %the cue epoch. To do so, get indices of empty cells in
        %subjDataAnalyzed.behavior.poxDS (these are trials where no PE
        %happened during the cue epoch) and then use these to set that DS =
        %nan
        
        %same here, we need an extra conditional in case cues were excluded
        for noPEtrial = find(cellfun('isempty',poxDS))
            if noPEtrial < numel(DSselected)
                DSselected(cellfun('isempty',poxDS)) = nan;
            end
        end
        
        %this may create some zeros, so let's make those nan as well
        DSselected(DSselected==0) = nan;
        
        %lets convert this to an index of trials with a valid value 
        DSselected= find(~isnan(DSselected));
        
%             %Repeat above for NS 
%         
%              NSselected= cutTime(NSonsetindex);  
% 
%             %First, let's exclude trials where animal was already in port
%             %to do so, find indices of subjDataAnalyzed.behavior.inPortNS that
%             %have a non-nan value and use these to exclude NS trials from this
%             %analysis (we'll make them nan)
% 
%             NSselected(~isnan(inPortNS)) = nan;
% 
%             %Then, let's exclude trials where animal didn't make a PE during
%             %the cue epoch. To do so, get indices of empty cells in
%             %subjDataAnalyzed.behavior.poxNS (these are trials where no PE
%             %happened during the cue epoch) and then use these to set that NS =
%             %nan
%             NSselected(cellfun('isempty', poxNS)) = nan;
% 
%        
%             %lets convert this to an index of trials with a valid value 
%             NSselected= find(~isnan(NSselected));
%            
%         
        %collect all z score responses to every single DS across all sessions
        %we'll use DSselected and NSselected as indices to pull only data
        %from trials with port entries
        
            currentSubj(1).DSzblueAllTrials= squeeze(subjDataPEM.(subj_name).periDSParker.DSzblue); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue
            currentSubj(1).DSzpurpleAllTrials= squeeze(subjDataPEM.(subj_name).periDSParker.DSzpurple); %squeeze the 3d matrix into a 2d array, with each coumn containing response to 1 cue


    
    %Sort PE latencies and retrieve an index of the sorted order that
    %we'll use to sort the photometry data
    [DSpeLatencySorted,DSsortInd] = sort(DSPElatency);       

%     [NSpeLatencySorted,NSsortInd] = sort(NSpeLatency);
    
    %Sort all trials by PE latency
    currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials(:,DSsortInd);
    currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials(:,DSsortInd);
    
    %Transpose these data for readability
    currentSubj(1).DSzblueAllTrials= currentSubj(1).DSzblueAllTrials';
    currentSubj(1).DSzpurpleAllTrials= currentSubj(1).DSzpurpleAllTrials';    

    %get a trial count to use for the heatplot ytick
    currentSubj(1).totalDScount= 1:size(currentSubj(1).DSzblueAllTrials,1); 
  
    
    %TODO: split up yticks by session (this would show any clear differences between days)
    
     %Color axes   
     
     %First, we'll want to establish boundaries for our colormaps based on
     %the std of the z score response. We want to have equidistant
     %color axis max and min so that 0 sits directly in the middle
     
     %TODO: should this be a pooled std calculation (pooled blue & purple)?
     
     %define DS color axes
     
     %get the avg std in the blue and purple z score responses to all cues,
     %get absolute value and then multiply this by some factor to define a color axis max and min
     
    stdFactor= 4; %multiplicative factor- how many stds away do we want our color max & min?
     
     topDSzblue= stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     topDSzpurple= stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor

     bottomDSzblue = -stdFactor*abs(mean((std(currentSubj(1).DSzblueAllTrials, 0, 2))));%std calculated for each cue (across all timestamps), then averaged, absolute valued, then multiplied by factor
     bottomDSzpurple= -stdFactor*abs(mean((std(currentSubj(1).DSzpurpleAllTrials, 0, 2))));
     
     %now choose the most extreme of these two (between blue and
     %purple)to represent the color axis 
     bottomAllDS= min(bottomDSzblue, bottomDSzpurple);
     topAllDS= max(topDSzblue, topDSzpurple);
  
     bottomAllShared= 2/3*(bottomAllDS);
     topAllShared= 2/3*(topAllDS);

    
    %Heatplots!  
    
    %DS z plot
    figure();
    hold on;
    
    timeLock = [-preCueFrames:postCueFrames]/fs;  %define a shared common time axis, timeLock, where cue onset =0
    
    %plot blue DS

    subplot(2,1,1); %subplot for shared colorbar
    
    heatDSzblueAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzblueAllTrials);
    title(strcat(subj_name, ' blue z score response surrounding DS trials with valid PE - sorted  by PE latency (Lo-Hi)')); %'(n= ', num2str(unique(trialDSnum)),')')); %display the possible number of cues in a session (this is why we used unique())
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));
%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately
    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS blue z-score calculated from', num2str(slideTime/fs), 's preceding cue');


    %   plot purple DS (subplotted for shared colorbar)
    subplot(2,1,2);
    heatDSzpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpurpleAllTrials); 

    title(strcat(subj_name, ' purple z score response surrounding DS trials with valid PE - sorted by PE latency (Lo-Hi) ')) %'(n= ', num2str(unique(trialDSnum)),')')); 
    xlabel('seconds from cue onset');
    ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));


    caxis manual;
    caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values
    
    c= colorbar; %colorbar legend
    c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding cue');

    set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving

 
    %Overlay scatter of PE latency
   subplot(2,1,1) %DS blue
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
   subplot(2,1,2) %DS purple
   hold on
   scatter(DSpeLatencySorted,currentSubj(1).totalDScount', 'm.');
 

    
        
    figsave_name=strcat('ZTrials_latencysorted_Parker',subj_name,'.fig');
        cd(figsave_folder);
        saveas(gcf,figsave_name);
   



 cd(curr_dir);
 
    %% %Event modulation for initial submission
    cons={'DSTimes','DSPETimes'};%,'DSLickTimes'}; %...
%         'NSTimes','NSPETimes','NSLickTimes'};
    con_shift=[1 0]; %0];% 0 1 1]; %stimulus events time window is 0:8s, action events it is -2:6s, this defines when to time-lock
    
    %---- Regression data prep ----
    
    %Initialize x-matrices
    con_iden=[];
    x_basic=[];    %No interaction terms, simply event times
    event_times_mat=[];
    num_bins=numel(z_gcamp_y_blue);
    
 
    % for each event ( aka con) 
    for con=1:numel(cons) 
        
        if con_shift(con)==1 & shift_con==1
            time_back=0;
            time_forward=time_back_orig+time_forward_orig;
        else
            time_back=time_back_orig;
            time_forward=time_forward_orig;
        end
        
        %gets matrix of event times (in hertz)
        con_times=eval(cons{con});
        
        %Gets rid of abandonded trials
        con_times(find(isnan(con_times)))=[];
        
        %Creates vector with binary indication of events
        con_binned=zeros(1,num_bins);
        con_binned(int32(con_times))=1;%align event time (represented by 1) with the g_camp signal
        
        if strcmp(type1,'spline')==1
            con_binned=circshift(con_binned,[0,-time_back*g_output.samp_rate]);% shift con binned zero positions in the first dimension and -timeback*fs in the second dimension ( shifting signal to to align event times to window specified)
            event_times_mat=vertcat(event_times_mat,con_binned);
            gcamp_temp=z_gcamp_y_blue;
            
            %preloads basis set
            load('ben_81x25.mat')
            
            %OR
            
            %makes basis_set
%                         num_set=15;
%                         set_length=(time_back+time_forward)*g_output.samp_rate+1;
%                         basistest=create_bspline_basis([0,set_length],num_set,4);  %Nathan says old fxn -- dp
%                         basis_set=getbasismatrix(1:set_length,basistest); basis_set=full(basis_set); %Nathan says old fxn -- dp
            
            %convolves time series of events with basis sets
            for num_sets=1:numel(basis_set(1,:));
                temp_conv_vec=conv(con_binned,basis_set(:,num_sets));
                x_basic=horzcat(x_basic,temp_conv_vec(1:numel(con_binned))');
            end
            con_iden=[con_iden ones(1,size(basis_set,2))*con];
            
            %NORMAL REGRESSION
        elseif strcmp(type1,'time_shift')==1
            x_con=[];
            shift_back=data_to_input_GADVPFP.g_output(1).samp_rate*time_back;   %how many points to shift forward and backwards in Hz
            shift_forward=data_to_input_GADVPFP.g_output(1).samp_rate*time_forward;
            %             gcamp_temp=gcamp_y(shift_forward+1:end-shift_back);
            gcamp_temp=z_gcamp_y_blue;
            
            %             for shifts = 1:shift_back+shift_forward+1
            %                 x_con=horzcat(x_con,con_binned(shift_back+shift_forward+2-shifts:end-shifts+1)')
            for shifts = -shift_back:shift_forward
                x_con=horzcat(x_con,circshift(con_binned,[0,shifts])');% create a column for each shift of event indication vectors
            end
            
            x_basic=horzcat(x_basic,x_con);% create matrix of x_con
            con_iden=[con_iden ones(1,size(x_con,2))*con];% create vector for idetifing event that is denoted by "1" in x_basic
        end
    end
    
%     %Merges CS+ and Rew
%     if max(con_iden)==7 && strcmp(cons{5},'CS')==1
%         con_iden(con_iden==7)=6;
%     end
    
    x_all=mean_center(x_basic); %todo: missing fxn % the mean is calculated and the lasso regression shrinks values toward this cental point
    gcamp_y=gcamp_temp;
    
    [stats.beta,stats.p]=lasso(x_all,gcamp_y','cv',5);    %Lasso with cross-validation % Nathan says we can use glmfit instead
    sum_betas=max(stats.beta(:,stats.p.IndexMinMSE));    %Selects betas that minimize MSE
    if sum_betas==0; stats.p.IndexMinMSE=max(find(max(stats.beta)>0.0001)); end  %Makes sure there are no all zero betas
    b=[stats.p.Intercept(stats.p.IndexMinMSE) ; stats.beta(:,stats.p.IndexMinMSE)];  %selects betas based on lambda
    
    %Save file
    long_name=strcat('lasso','_',char(files(subjects(subj))));
    dot_stop=find(long_name=='.');
    save_name=long_name;
    samp_rate=data_to_input_GADVPFP.g_output(1).samp_rate;
    
    cd(save_folder)
    save(save_name,'b');
    cd(curr_dir)
    

%% Visualize
        
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Kernel calculation & vis~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %dp trying to implement equation 4 from 2019 preprint
    %above code calculates b, so we should be able to calculate event
    %kernels using this equation
    
    %if in spline mode, use eq 4 from 2019 preprint
    %if in time shift mode, simply use regression coefficients as kernel (I think that's what they did in 2016 paper)
        
    k= con; %the number of event types
    
    if strcmp(type1,'spline')==1 %if in spline mode
         % Bjk = regression coeff for jth spline basis fxn and kth behavioral event
         % Sj= jth spline basis fxn at time point i with length of 81 time bins
        for eventType = 1:k

             %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
              if eventType==1
                splineThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
              else
                splineThisEvent= splineThisEvent(end)+1:splineThisEvent(end)+(numel(b)/k); 
              end

           sumTerm= []; %clear between event types
               
           %summation loop over all degrees of freedom (Nsp) of each spline basis
           %set; on each iteration take product of Bjk * Sj(ts) ; sum the
           %results
           for ts= 1:size(basis_set,1)  %loop through ts; using 'ts' for each timestamp instead of 'i' in formula
               for j= 1:size(basis_set,2) %loop over each df of spline basis function
                   sumTerm(ts,j)= b(splineThisEvent(j))*basis_set(ts,j); %save data to be summed at end of loop
               end
           end
          kernel(:,eventType)= (sum(sumTerm,2));  %kernel with row=ts (or spline set) ; column=event type           
        end
        
        %visualize
        timeLock= linspace(0,size(kernel,1)/g_output.samp_rate, size(kernel,1)); %x axis in s

        figure; hold on;
        title('kernels (spline)');
        plot(timeLock,kernel);
        ylabel('regression coefficient b?');
        xlabel('time (s)');
        legend(cons);

    elseif strcmp(type1, 'time_shift')==1
            %if in timeshift mode, references to 'ts' below are timestamps
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
        end
        
        %0:8 sec
        %visualize
        timeLock= linspace(0,size(kernel,1)/data_to_input_GADVPFP.g_output(1).samp_rate, size(kernel,1)); %x axis in s

        figure; hold on;
        title('kernels (time shift)');
        ylabel('regression coefficient b');
        xlabel('time (s)');
        plot(timeLock,kernel(:,1));
        legend(cons(1));
        
        gcf;
        [filepath,name,ext] = fileparts(file_name);
        figsave_name=strcat('DSonset_',name);
        cd(figsave_folder);
        savefig(figsave_name);
%         
         %-2:6 sec
        
            %visualize
        timeLock= linspace(-2,size(kernel,1)/data_to_input_GADVPFP.g_output(1).samp_rate, size(kernel,1)); %x axis in s

        figure; hold on;
        title('kernels (time shift)');
        ylabel('regression coefficient b');
        xlabel('time (s)');
        plot(timeLock,kernel(:,2));
        legend(cons(2));
        
        gcf;
        [filepath,name,ext] = fileparts(file_name);
        figsave_name=strcat('onlyDSPE_',name);
        cd(figsave_folder);
        savefig(figsave_name);
        cd(curr_dir);
        

     
        
    end

 toc
    end
