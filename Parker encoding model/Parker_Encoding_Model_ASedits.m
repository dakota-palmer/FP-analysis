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
    

condition = 'Richard_data_to_input';
neurons = [1 2 3 4 5 ];%:278; %only one example file was included- I think there should be 1 file per neuron...I guess in our case it's 1 per subj -dp


for neuron=1:numel(neurons)
    
    clearvars -except curr_dir save_folder condition neurons neuron
    
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
    file_name=char(files(neuron));
    file_name=strcat(condition,'/',file_name);
    load(file_name);
    
    %Convert seconds to hertz + isolates conditions %~~~~~~~~~~Note that
    %'output' & 'g_output' are actually loaded at the beginning of this
    %script -- dp
    % converting into hertz for every event occuring during recording
    DSTimes=data_to_input_GADVPFP.output(1).DSonset.* data_to_input_GADVPFP.g_output(1).samp_rate;
    
    DSPETimes=data_to_input_GADVPFP.output(1).DSpox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    DSLickTimes=data_to_input_GADVPFP.output(1).DSlox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSTimes=data_to_input_GADVPFP.output(1).NSonset.* data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSPETimes=data_to_input_GADVPFP.output(1).NSpox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    NSLickTimes=data_to_input_GADVPFP.output(1).NSlox.*data_to_input_GADVPFP.g_output(1).samp_rate;
    
    %movmean g_camp
    
    gcamp_y_blue=data_to_input_GADVPFP.g_output(1).gcamp_movmean.blue;
    gcamp_y_purple=data_to_input_GADVPFP.g_output(1).gcamp_movmean.purple;
    
    %Normalize gcamp signal by the max -- COMMENT OUT WHEN NOT NEEDED
    % gcamp_y=g_output.gcamp;
    % gcamp_y=g_output.gcamp./max(g_output.gcamp);
    
%     gcamp_y_blue=(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue-mean(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue))./std(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue); fprintf('blue Z-scored \n')
%     gcamp_y_purple=(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple-mean(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple))./std(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple); fprintf('purple Z-scored \n')
%     
    % %Choice/ outcome modulation for initial submission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew'};
    % con_shift=[0 1 0 0 1 1];
    
    % %Choice/ outcome modulation for resubmission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew','RewardEnter'};
    % con_shift=[0 1 0 0 1 1 0];
    
    
    % %Event modulation for initial submission
    cons={'DSTimes','DSPETimes','DSLickTimes'}; %...
%         'NSTimes','NSPETimes','NSLickTimes'};
    con_shift=[1 0 0];% 0 1 1]; %stimulus events time window is 0:8s, action events it is -2:6s, this defines when to time-lock
    
    %---- Regression data prep ----
    
    %Initialize x-matrices
    con_iden=[];
    x_basic=[];    %No interaction terms, simply event times
    event_times_mat=[];
    num_bins=numel(gcamp_y_blue);
    
 
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
            gcamp_temp=gcamp_y;
            
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
            gcamp_temp=gcamp_y_blue;
            
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
    long_name=strcat('lasso','_',char(files(neurons(neuron))));
    dot_stop=find(long_name=='.');
    save_name=long_name;
    samp_rate=data_to_input_GADVPFP.g_output(1).samp_rate;
    
    cd(save_folder)
    save(save_name,'b');
    cd(curr_dir)
    toc

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
        
         %-2:6 sec
        
            %visualize
        timeLock= linspace(-2,size(kernel,1)/data_to_input_GADVPFP.g_output(1).samp_rate, size(kernel,1)); %x axis in s

        figure; hold on;
        title('kernels (time shift)');
        ylabel('regression coefficient b');
        xlabel('time (s)');
        plot(timeLock,kernel(:,2:3));
        legend(cons(2:3));
        
        
    end
    end
