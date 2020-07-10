% function[answer]=inscopix_spline_regression(condition,neuron)

%determine if folder exists and if so purge it, if not create it
curr_dir = pwd;
save_folder = 'lasso_regression/pl';
if exist(save_folder)==0
    mkdir(save_folder)
else
    cd(save_folder)
    delete('*')
    cd ../..
end
    

condition = 'data_to_input/example';
neurons = 1%:278; %only one example file was included- I think there should be 1 file per neuron...I guess in our case it's 1 per subj -dp


for neuron=1:numel(neurons)
    
    clearvars -except curr_dir save_folder condition neurons neuron
    
    tic
    %how much time should you shift back (in seconds)
    time_back_orig=2;
    time_forward_orig=6;
    
    type1= 'time_shift';  %'spline','time_shift'
    
    shift_con=1;   %Should we shift the stimulus events so they start at 0?
    
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
    TrialStart=output.TrialStart.*g_output.samp_rate;
    
    NPTimes=output.NosePokeEnter.*g_output.samp_rate;
    NPTimesL=output.NosePokeEnter(output.LeftPress==1).*g_output.samp_rate;
    NPTimesR=output.NosePokeEnter(output.RightPress==1).*g_output.samp_rate;
    NPTimesI=output.NosePokeEnter(output.IpsPress==1).*g_output.samp_rate;
    NPTimesC=output.NosePokeEnter(output.IpsPress==-1).*g_output.samp_rate;
    NPTimesP=output.NosePokeEnter(output.Reward==1).*g_output.samp_rate;
    NPTimesN=output.NosePokeEnter(output.Reward==0).*g_output.samp_rate;
    
    LeverPresent=output.LeverPresentation.*g_output.samp_rate;
    LeverPresentL=output.LeverPresentation(output.LeftPress==1).*g_output.samp_rate;
    LeverPresentR=output.LeverPresentation(output.RightPress==1).*g_output.samp_rate;
    LeverPresentI=output.LeverPresentation(output.IpsPress==1).*g_output.samp_rate;
    LeverPresentC=output.LeverPresentation(output.IpsPress==-1).*g_output.samp_rate;
    LeverPresentP=output.LeverPresentation(output.Reward==1).*g_output.samp_rate;
    LeverPresentN=output.LeverPresentation(output.Reward==0).*g_output.samp_rate;
    
    LeverTimes=output.LeverTimes.*g_output.samp_rate;
    LeverTimesL=output.LeverTimes(output.LeftPress==1).*g_output.samp_rate;
    LeverTimesR=output.LeverTimes(output.RightPress==1).*g_output.samp_rate;
    LeverTimesI=output.LeverTimes(output.IpsPress==1).*g_output.samp_rate;
    LeverTimesC=output.LeverTimes(output.IpsPress==-1).*g_output.samp_rate;
    LeverTimesP=output.LeverTimes(output.Reward==1).*g_output.samp_rate;
    LeverTimesN=output.LeverTimes(output.Reward==0).*g_output.samp_rate;
    
    CS=output.RewardPresentation.*g_output.samp_rate;
    CSRew=output.RewardPresentation(output.RewardEnter~=0).*g_output.samp_rate;
    CSRewL=output.RewardPresentation(output.RewardEnter~=0 & output.LeftPress==1).*g_output.samp_rate;
    CSRewR=output.RewardPresentation(output.RewardEnter~=0 & output.RightPress==1).*g_output.samp_rate;
    CSRewI=output.RewardPresentation(output.RewardEnter~=0 & output.IpsPress==1).*g_output.samp_rate;
    CSRewC=output.RewardPresentation(output.RewardEnter~=0 & output.IpsPress==-1).*g_output.samp_rate;
    
    CSNoRew=output.RewardPresentation(output.RewardEnter==0).*g_output.samp_rate;
    CSNoRewL=output.RewardPresentation(output.RewardEnter==0 & output.LeftPress==1).*g_output.samp_rate;
    CSNoRewR=output.RewardPresentation(output.RewardEnter==0 & output.RightPress==1).*g_output.samp_rate;
    CSNoRewI=output.RewardPresentation(output.RewardEnter==0 & output.IpsPress==1).*g_output.samp_rate;
    CSNoRewC=output.RewardPresentation(output.RewardEnter==0 & output.IpsPress==-1).*g_output.samp_rate;
    
    RewardEnter=output.RewardEnter(output.RewardEnter~=0).*g_output.samp_rate;
    RewardEnterL=output.RewardEnter(output.RewardEnter~=0 & output.LeftPress==1).*g_output.samp_rate;
    RewardEnterR=output.RewardEnter(output.RewardEnter~=0 & output.RightPress==1).*g_output.samp_rate;
    RewardEnterI=output.RewardEnter(output.RewardEnter~=0 & output.IpsPress==1).*g_output.samp_rate;
    RewardEnterC=output.RewardEnter(output.RewardEnter~=0 & output.IpsPress==-1).*g_output.samp_rate;
    
    
    %Normalize gcamp signal by the max -- COMMENT OUT WHEN NOT NEEDED
    % gcamp_y=g_output.gcamp;
    % gcamp_y=g_output.gcamp./max(g_output.gcamp);
    gcamp_y=(g_output.gcamp-mean(g_output.gcamp))./std(g_output.gcamp); fprintf('Z-scored \n')
    
    % %Choice/ outcome modulation for initial submission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew'};
    % con_shift=[0 1 0 0 1 1];
    
    % %Choice/ outcome modulation for resubmission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew','RewardEnter'};
    % con_shift=[0 1 0 0 1 1 0];
    
    
    % %Event modulation for initial submission
    cons={'NPTimes','LeverPresent','LeverTimesI','LeverTimesC'...
        'CSRew','CSNoRew','RewardEnter'};
    con_shift=[0 1 0 0 1 1 0]; %stimulus events time window is 0:8s, action events it is -2:6s, this defines when to time-lock
    
    %---- Regression data prep ----
    
    %Initialize x-matrices
    con_iden=[];
    x_basic=[];    %No interaction terms, simply event times
    event_times_mat=[];
    num_bins=numel(gcamp_y);
    
    
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
        con_times(con_times==0)=[];
        
        %Creates vector with binary indication of events
        con_binned=zeros(1,num_bins);
        con_binned(int32(con_times))=1;
        
        if strcmp(type1,'spline')==1
            con_binned=circshift(con_binned,[0,-time_back*g_output.samp_rate]);
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
                temp_conv_vec=conv(con_binned,basis_set(:,num_sets)); %dp 'the predictors in our model, Xjk, were generated by convolving the behavioral events with a spline basis set to enable temporally delayed version of the events
                x_basic=horzcat(x_basic,temp_conv_vec(1:numel(con_binned))');
            end
            con_iden=[con_iden ones(1,size(basis_set,2))*con];
            
            %NORMAL REGRESSION
        elseif strcmp(type1,'time_shift')==1
            x_con=[];
            shift_back=g_output.samp_rate*time_back;   %how many points do I shift forward and backwards
            shift_forward=g_output.samp_rate*time_forward;
            %             gcamp_temp=gcamp_y(shift_forward+1:end-shift_back);
            gcamp_temp=gcamp_y;
            
            %             for shifts = 1:shift_back+shift_forward+1
            %                 x_con=horzcat(x_con,con_binned(shift_back+shift_forward+2-shifts:end-shifts+1)')
            for shifts = -shift_back:shift_forward
                x_con=horzcat(x_con,circshift(con_binned,[0,shifts])');
            end
            
            x_basic=horzcat(x_basic,x_con);
            con_iden=[con_iden ones(1,size(x_con,2))*con];
        end
    end
    
    %Merges CS+ and Rew
    if max(con_iden)==7 && strcmp(cons{5},'CS')==1
        con_iden(con_iden==7)=6;
    end
    
    x_all=mean_center(x_basic); %todo: missing fxn
    gcamp_y=gcamp_temp;
    
    [stats.beta,stats.p]=lasso(x_all,gcamp_y','cv',5);    %Lasso with cross-validation
    sum_betas=max(stats.beta(:,stats.p.IndexMinMSE));    %Selects betas that minimize MSE
    if sum_betas==0; stats.p.IndexMinMSE=max(find(max(stats.beta)>0.0001)); end  %Makes sure there are no all zero betas
    %cat ing intercept here , so size +1 
    b=[stats.p.Intercept(stats.p.IndexMinMSE) ; stats.beta(:,stats.p.IndexMinMSE)];  %selects betas based on lambda
    
    %Save file
    long_name=char(files(neurons(neuron)));
    dot_stop=find(long_name=='.');
    save_name=long_name(1:dot_stop-1);
    samp_rate=g_output.samp_rate;
    
    cd(save_folder)
    save(save_name,'b');
    cd(curr_dir)
    toc
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Kernel calculation & vis~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %dp trying to implement equation 4 from 2019 preprint
    %above code calculates b, so we should be able to calculate event
    %kernels using this equation
    
    %NOTE: this should work for 'spline' mode, not sure yet how 'time_
    %shift' mode will work... seems like ts becomes spline set 
    
    % Bjk = regression coeff for jth spline basis fxn and kth behavioral event
    % Sj= jth spline basis fxn at time point i with length of 81 time bins
    
    k= con; %I think this is the number of event types
    
    if strcmp(type1,'spline')==1 %if in spline mode
        %if in spline mode, references to 'ts' below become spline set I think!
        for eventType = 1:k

             %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
              if eventType==1
                splineThisEvent= 1:(numel(b)/k);
              else
                splineThisEvent= splineThisEvent(end)+1:splineThisEvent(end)+(numel(b)/k); 
              end

           sumTerm= []; %clear between event types

           for ts= 1:81 %81 manually here bc an extra ts is added after LASSO somehow? %numel((b)/k) %loop through ts; using 'ts' for each timestamp instead of 'i'
               %this seems to fit- there should be 81 time bins in the example
               %data x 7 event types ~ 568
               for j= 1:size(basis_set,2) %loop over each df of spline basis function
                   sumTerm(ts,j)= b(splineThisEvent(j))*basis_set(ts,j);
               end
               kernel(ts,eventType)= sum(sum(sumTerm,1));  %kernel with row=ts (or spline set) ; column=event type           
           end
        end
        
        %visualize
        timeLock= linspace(0,size(kernel,1)/g_output.samp_rate, size(kernel,1)); %x axis in s

        figure; 
        title('kernels (spline)');
        plot(timeLock,kernel);
        legend(cons);

        figure;
        hold on;
        title('linear sum kernels (spline)');
        plot(timeLock,sum(kernel,2));
        
    elseif strcmp(type1, 'time_shift')==1
            %if in timeshift mode, references to 'ts' below are timestamps
        for eventType = 1:k
             %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
              if eventType==1
                tsThisEvent= 1:(numel(b)/k);
              else
                tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
              end

           sumTerm= []; %clear between event types

           for ts= 1:81 %manually 81 here bc an extra ts is added after LASSO somehow? %loop through ts; using 'ts' for each timestamp instead of 'i'
%                %this seems to fit- there should be 81 time bins in the example
%                %data x 7 event types ~ 568
%                for j= 1:size(shifts,2) %loop over each df of spline basis function
%                    sumTerm(ts,j)= b(tsThisEvent(j))*shifts(ts,j);
%                end
%                kernel(ts,eventType)= sum(sum(sumTerm,1));  %kernel with row=ts (or spline set) ; column=event type           
                kernel(ts,eventType) = b(tsThisEvent(ts));
           end
        end
        
        %visualize
        timeLock= linspace(0,size(kernel,1)/g_output.samp_rate, size(kernel,1)); %x axis in s

        figure; hold on;
        title('kernels (time shift)');
        ylabel('regression coefficient b');
        xlabel('time (s)');
        plot(timeLock,kernel);
        legend(cons);

        figure; %according to 2016 paper, 'each kernel is time shifted according to time of the corresponding events and then summed together to generate modeled gcamp6f trace' so- need to do the time shifting before summation
        hold on;
        title('linear sum kernels (time shift)');
        plot(timeLock,sum(kernel,2));

    end
    
end