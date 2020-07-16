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
    time_back_orig=2; %dp 
    time_forward_orig=6;
    
    type1= 'time_shift';  %'spline','time_shift'
    
    shift_con=1;   %Should we shift the stimulus events so they start at 0? %~~~TODO: unclear what this means
    
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
            files{folders_ind}=allitems(ind).name; %contains name of each individual .mat
        end 
    end
    
    
    %Load one file corresponding to this neuron
    file_name=char(files(neuron)); 
    file_name=strcat(condition,'/',file_name);
    load(file_name);
    
    %Convert seconds to hertz (by multiplying timestamp by sampling rate) + isolates conditions 
    TrialStart=output.TrialStart.*g_output.samp_rate; %trial start times 
    
    NPTimes=output.NosePokeEnter.*g_output.samp_rate; %all nosepoke times
    NPTimesL=output.NosePokeEnter(output.LeftPress==1).*g_output.samp_rate; %only left nosepoke times
    NPTimesR=output.NosePokeEnter(output.RightPress==1).*g_output.samp_rate; %only right nosepoke times
    NPTimesI=output.NosePokeEnter(output.IpsPress==1).*g_output.samp_rate; %only ipsi 
    NPTimesC=output.NosePokeEnter(output.IpsPress==-1).*g_output.samp_rate; %only contra
    NPTimesP=output.NosePokeEnter(output.Reward==1).*g_output.samp_rate; %only rewarded ??
    NPTimesN=output.NosePokeEnter(output.Reward==0).*g_output.samp_rate; %only nonrewarded ??
    
    LeverPresent=output.LeverPresentation.*g_output.samp_rate; %all lever presentations
    LeverPresentL=output.LeverPresentation(output.LeftPress==1).*g_output.samp_rate; %only left lever presentation
    LeverPresentR=output.LeverPresentation(output.RightPress==1).*g_output.samp_rate; %only right
    LeverPresentI=output.LeverPresentation(output.IpsPress==1).*g_output.samp_rate; %only ipsi
    LeverPresentC=output.LeverPresentation(output.IpsPress==-1).*g_output.samp_rate; %only contra
    LeverPresentP=output.LeverPresentation(output.Reward==1).*g_output.samp_rate; %only rewarded ??
    LeverPresentN=output.LeverPresentation(output.Reward==0).*g_output.samp_rate; %only nonrewarded ??
    
    LeverTimes=output.LeverTimes.*g_output.samp_rate; %all lever press times
    LeverTimesL=output.LeverTimes(output.LeftPress==1).*g_output.samp_rate; %only left
    LeverTimesR=output.LeverTimes(output.RightPress==1).*g_output.samp_rate; %only right
    LeverTimesI=output.LeverTimes(output.IpsPress==1).*g_output.samp_rate; %only ipsi
    LeverTimesC=output.LeverTimes(output.IpsPress==-1).*g_output.samp_rate; %only contra
    LeverTimesP=output.LeverTimes(output.Reward==1).*g_output.samp_rate; %only rewarded ?? 
    LeverTimesN=output.LeverTimes(output.Reward==0).*g_output.samp_rate; %only nonrewarded ??
    
    CS=output.RewardPresentation.*g_output.samp_rate; %all CS presentations ??
    
    CSRew=output.RewardPresentation(output.RewardEnter~=0).*g_output.samp_rate; %only reward CS (CS+?)
    CSRewL=output.RewardPresentation(output.RewardEnter~=0 & output.LeftPress==1).*g_output.samp_rate; %only rewarded left lever press
    CSRewR=output.RewardPresentation(output.RewardEnter~=0 & output.RightPress==1).*g_output.samp_rate; %only rewarded right lever press
    CSRewI=output.RewardPresentation(output.RewardEnter~=0 & output.IpsPress==1).*g_output.samp_rate; %only rewarded ipsi press
    CSRewC=output.RewardPresentation(output.RewardEnter~=0 & output.IpsPress==-1).*g_output.samp_rate; %only rewarded contra press
    
    CSNoRew=output.RewardPresentation(output.RewardEnter==0).*g_output.samp_rate; %only nonrewarded CS (CS-?)
    CSNoRewL=output.RewardPresentation(output.RewardEnter==0 & output.LeftPress==1).*g_output.samp_rate; %only nonrewarded left press
    CSNoRewR=output.RewardPresentation(output.RewardEnter==0 & output.RightPress==1).*g_output.samp_rate; %only nonrewarded right press
    CSNoRewI=output.RewardPresentation(output.RewardEnter==0 & output.IpsPress==1).*g_output.samp_rate; %only nonrewarded ipsi press
    CSNoRewC=output.RewardPresentation(output.RewardEnter==0 & output.IpsPress==-1).*g_output.samp_rate; %only nonrewarded contra press
    
    RewardEnter=output.RewardEnter(output.RewardEnter~=0).*g_output.samp_rate; %all reward cup entry? 
    RewardEnterL=output.RewardEnter(output.RewardEnter~=0 & output.LeftPress==1).*g_output.samp_rate; %only reward cup entry after left press
    RewardEnterR=output.RewardEnter(output.RewardEnter~=0 & output.RightPress==1).*g_output.samp_rate; %only reward cup entry after right press
    RewardEnterI=output.RewardEnter(output.RewardEnter~=0 & output.IpsPress==1).*g_output.samp_rate; %only reward cup entry ipsi press
    RewardEnterC=output.RewardEnter(output.RewardEnter~=0 & output.IpsPress==-1).*g_output.samp_rate; %only reward cup entry contra
    
    %DS TASK EVENTS~~~
%     DS= output.DS; %.*g_output.samp_rate;
%     NS= output.NS; %.*g_output.samp_rate;
%     
%     pox= output.pox; %.*g_output.samp_rate; %consider breaking into rewarded/unrewarded 
%     lox= output.lox; %.*g_output.samp_rate;
%     out= output.lox; %.*g_output.samp_rate;
    
    %Normalize gcamp signal by the max -- COMMENT OUT WHEN NOT NEEDED
    %TODO: dp- looks like the third option here uses a simple mean and std for
    %the whole GCaMP trace... we could use a rolling
    %calculation instead?
    
    % gcamp_y=g_output.gcamp;
    % gcamp_y=g_output.gcamp./max(g_output.gcamp);
    gcamp_y=(g_output.gcamp-mean(g_output.gcamp))./std(g_output.gcamp); fprintf('Z-scored \n')
    
    %visualizing normalized trace- dp
    figure; 
    subplot(2,1,1); hold on; title('raw'); 
    plot(g_output.gcamp);
    subplot(2,1,2); hold on; title('z scored');
    plot(gcamp_y);
    
    % %Choice/ outcome modulation for initial submission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew'};
    % con_shift=[0 1 0 0 1 1];
    
    % %Choice/ outcome modulation for resubmission
    % cons={'NPTimes','LeverPresent','LeverTimes','LeverTimesI'...
    %     'CS','CSRew','RewardEnter'};
    % con_shift=[0 1 0 0 1 1 0];
    
    
    % %Event modulation for initial submission % ~looks like this is where
    % events to be included in the model are defined (and what time window
    % should be used for timelocking (1 for stimulus, 0 for action event?)
    cons={'NPTimes','LeverPresent','LeverTimesI','LeverTimesC'...
        'CSRew','CSNoRew','RewardEnter'};
    con_shift=[0 1 0 0 1 1 0]; %stimulus events time window is 0:8s, action events it is -2:6s, this defines when to time-lock
    
    %---- Regression data prep ----
    
    %Initialize x-matrices
    con_iden=[];
    x_basic=[];    %No interaction terms, simply event times
    event_times_mat=[];
    num_bins=numel(gcamp_y); %number of time bins
    
    %VISUALIZING CON TIMES & CON BINNED
    figure; 
    subplot(2,1,1); hold on; title('con times');
    plot(gcamp_y);
    plot(NPTimes, ones(size(NPTimes)*1), 'k.')
    plot(LeverPresent, ones(size(LeverPresent))*2, 'g.')
    plot(LeverTimesI, ones(size(LeverTimesI))*3, 'c.')
    plot(LeverTimesC, ones(size(LeverTimesC))*4, 'r.')
    plot(CSRew, ones(size(CSRew))*5, 'm.')
    plot(CSNoRew, ones(size(CSNoRew))*6, 'y.')
    plot(RewardEnter, ones(size(RewardEnter))*7, 'w.')

    
    
    legend([{'465'},cons]);
    
    subplot(2,1,2); hold on; title('con binned'); %FOR VISUALIZING CON_TIMES %dp
    plot(gcamp_y);
    conColors= {'k','g','c','r','m','y', 'w'};
    
    
    
    
    for con=1:numel(cons) %for each event type (condition) included in the model
        
        if con_shift(con)==1 & shift_con==1 %if this is a STIMULUS event (con_shift==1), don't include timestamps before stimulus
            time_back=0;
            time_forward=time_back_orig+time_forward_orig;
        else %Otherwise, if this is an ACTION event (con_shift==0), include both before and after timestamps 
            time_back=time_back_orig;
            time_forward=time_forward_orig;
        end
        
        %gets matrix of event times (in hertz)
        con_times=eval(cons{con}); %Retrieve event timings for this event type (con) by evaluating the variable (with the same name as cons{con}) that was created above in this script
        
        %Gets rid of abandonded trials
        con_times(con_times==0)=[]; %~~TODO- dp; Not sure when this be 0
        
        %Creates vector with binary indication of events (reset between event types (con))
        con_binned=zeros(1,num_bins); %create empty matrix with 0 for all timestamps
            %make =1 when event occurs
        con_binned(int32(con_times))=1; %~~dp unclear why int32() was used here-maybe to save memory, maybe rounding? results seem same as below
%         con_binned(con_times)=1;
        

    %visualizing binary coded event times
        plot(find(con_binned==1), ones(size(find(con_binned==1)))*con, strcat(conColors{con},'.'))      
        

        if strcmp(type1,'spline')==1 %IF running in spline mode
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
        elseif strcmp(type1,'time_shift')==1 %IF running in time shifted mode
            x_con=[];
            shift_back=g_output.samp_rate*time_back;   %how many timestamps do I shift backwards
            shift_forward=g_output.samp_rate*time_forward; %how many timestamps do I shift forwards
            %             gcamp_temp=gcamp_y(shift_forward+1:end-shift_back);
            gcamp_temp=gcamp_y;
            
            %             for shifts = 1:shift_back+shift_forward+1
            %                 x_con=horzcat(x_con,con_binned(shift_back+shift_forward+2-shifts:end-shifts+1)').
            %~~~~TODO ; dp this part doesn't make sense
            circTest= 1:36609; %trying to visualize circshift() process; this is analogous to con_binned
            circShiftTest= [];%trying to visualize circshift() process; this is analogous to x_con
             for shifts = -shift_back:shift_forward %Loop over each relative timestamp index (shift) 
                 %I think circularly shifting (circshift()) is  used as way
                 %to implement time shifts relative to event onset...
                 %Basically if shift=0, event times = actual event onset, if
                 %shift= -1, event times= actual event onsets-1 etc....
                 %So at the end of all of this, we're running a regression
                 %for every SHIFT of event timings?
                 ...start with a 1x 36609 (1x num_bins) binary coded vector of
                 %event timings, After 1 event type loop end with an 81 x 36609 (num shifts x num_bins) binary coded
                 %matrix... 81 = number of shifts 
                 %of event timings 
                 %recall that con_binned is a binary vector of event timings (1 where event occurs, otherwise 0)
                x_con=horzcat(x_con,circshift(con_binned,[0,shifts])');
                circShiftTest= horzcat(circShiftTest, circshift(circTest,[0,shifts])'); %just visualizing
             end
            
            %collect all event type data together by cat() this event type's binary coded data (x_con) with previous (x_basic)
            x_basic=horzcat(x_basic,x_con); %x_con ((num event types x num shifts) x num_bins binary matrix of event timings)
            con_iden=[con_iden ones(1,size(x_con,2))*con]; % 1 x (num shifts * num event types) vector ; simply a label of event type (con)
        end
    end
    
        legend([{'465'},cons]); %for visualizing binary coded event times

    
    %Merges CS+ and Rew
    if max(con_iden)==7 && strcmp(cons{5},'CS')==1
        con_iden(con_iden==7)=6;
    end
    
        %the mean_center() function here goes through every column (every time shift) of x_basic, gets a mean value for that shift (should be the same for every shift of the same event type?) then goes through every row (time bin) and subtracts this mean from actual value (0 or 1) of x_basic
        %so there should be + values only when event occurred (1-mean)??
    x_all=mean_center(x_basic); %num time bins x (num event types*num shifts) matrix 
    gcamp_y=gcamp_temp;
    
    %run regression
    %result of LASSO here is (num event types * num shifts) x lambda matrix of b coefficients, stats.beta 
    [stats.beta,stats.p]= lasso(x_all,gcamp_y','cv',5);    %Lasso with cross-validation
    sum_betas=max(stats.beta(:,stats.p.IndexMinMSE));    %Selects betas that minimize MSE
    if sum_betas==0; stats.p.IndexMinMSE=max(find(max(stats.beta)>0.0001)); end  %Makes sure there are no all zero betas
    %cat ing intercept here , so size= (num event types * num shifts) +1 x 1 column vector of betas 
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
    %above code calculates b, which we can use to calculate event kernels
    
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
%         timeLock= linspace(0,size(kernel,1)/g_output.samp_rate, size(kernel,1)); %x axis in s
        timeLock= (-shift_back:shift_forward)/g_output.samp_rate; %x axis in s


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
        
        %visualize
%         timeLock= linspace(0,size(kernel,1)/g_output.samp_rate, size(kernel,1)); %x axis in s
        timeLock= (-shift_back:shift_forward)/g_output.samp_rate; %x axis in s

%         figure; hold on;
%         title('kernels (time shift)');
%         ylabel('regression coefficient b');
%         xlabel('time (s)');
%         plot(timeLock,kernel);
%         legend(cons);
        
        %maybe this is the appropriate way to visualize?
%         timeLock= (-shift_back:shift_forward)/g_output.samp_rate;

        %each point really represents regression coefficient of a shifted
        %version of event timestamps with the same GCaMP signal. For example,
        %a high regression coefficient at +4s means that if you shift all
        %of this event's timestamps forward by +4s the correlation with
        %GCaMP is high. This might suggest an event-induced change in GCaMP activity
        %observed 4s after event onset
        
        figure; hold on;
        title('kernels (time shift)');
        ylabel('regression coefficient b');
        xlabel('time shift of events relative to actual event onsets (s)');
        plot(timeLock,kernel);
        legend(cons);

    end
    
end