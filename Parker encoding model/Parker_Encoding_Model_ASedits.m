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
neurons = 1%:278; %only one example file was included- I think there should be 1 file per neuron...I guess in our case it's 1 per subj -dp


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
    DSTimes=data_to_input_GADVPFP.output(neuron).DSonset.* data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    DSPETimes=data_to_input_GADVPFP.output(neuron).DSpox.*data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    DSLickTimes=data_to_input_GADVPFP.output(neuron).DSlox.*data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    NSTimes=data_to_input_GADVPFP.output(neuron).NSonset.* data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    NSPETimes=data_to_input_GADVPFP.output(neuron).NSpox.*data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    NSLickTimes=data_to_input_GADVPFP.output(neuron).NSlox.*data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    %Normalize gcamp signal by the max -- COMMENT OUT WHEN NOT NEEDED
    % gcamp_y=g_output.gcamp;
    % gcamp_y=g_output.gcamp./max(g_output.gcamp);
    gcamp_y_blue=(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue-mean(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue))./std(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.blue); fprintf('blue Z-scored \n')
    gcamp_y_purple=(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple-mean(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple))./std(data_to_input_GADVPFP.g_output(neuron).gcamp_raw.purple); fprintf('purple Z-scored \n')
    
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
            shift_back=data_to_input_GADVPFP.g_output(neuron).samp_rate*time_back;   %how many points to shift forward and backwards in Hz
            shift_forward=data_to_input_GADVPFP.g_output(neuron).samp_rate*time_forward;
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
    long_name=strcat('subject_',string(neuron),'_',char(files(neurons(neuron))));
    dot_stop=find(long_name=='.');
    save_name=long_name;
    samp_rate=data_to_input_GADVPFP.g_output(neuron).samp_rate;
    
    cd(save_folder)
    save(save_name,'b');
    cd(curr_dir)
    toc
end