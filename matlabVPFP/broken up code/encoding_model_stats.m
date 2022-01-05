%dp 12/14/21 
%instead of LASSO, exploring alternatives

%load regression input data

%example
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\lasso_vp_vta_fp_rat11_data_to_input_GADVPFP_input.mat")

%model gcamp_y based on x_all (event times)

%glmfit
[b, dev, stats]= glmfit(input.x_all,input.gcamp_y);

%% dp getting warning
 
% Warning: X is ill conditioned, or the model is overparameterized, and
% some coefficients are not identifiable.  You should use caution
% in making predictions.

%I think this is due to multicolinearity? The timing of these events are
%correlated so are not independent/can be used to predict each other?


%% what about x_basic? 
[b2, dev2, stats2]= glmfit(input.x_basic,input.gcamp_y);

%same error

%compare visually beta results from x_basic and x_all
figure();
hold on; 
plot(b);
plot(b2);
legend('b','b2');

%first 601 values are slightly different? correspond to first event (DS)?
%why?

%% visually compare x_basic v x_all
% % figure();
% % hold on; 
% % plot(input.x_basic, 'k');
% % plot(input.x_all, 'b');
% % legend('x_basic','x_all');
% 
% % plot(input.x_basic(:), input.x_all(:));

%no values are equivalent?
sum(input.x_basic(:)==input.x_all(:))

% figure();
% hold on; 
% histogram(input.x_basic(:));
% histogram(input.x_all(:));
% legend('x_basic','x_all');


unique(input.x_basic)
unique(input.x_all)
%% Vis- regression input

figure();
for eventType = 1:k
%     kernelAll=[]; %clear 'kernel' between event types
    xThisEvent= [];
     %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
      if eventType==1
        tsThisEvent= 2:(size(x_all,2)/k)+1; %skip first index (intercept)
      else
        tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(size(x_all,2)/k); 
      end

   sumTerm= []; %clear between event types

   for ts= 1:round(size(x_all,2)/k)-1 %loop through ts; using 'ts' for each timestamp instead of 'i'
%                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
%         kernelAll(ts,:) = stats.beta(tsThisEvent(ts),:); %all iterations of LASSO
%         kernel(ts,:)= b(tsThisEvent(ts),:); %single beta with lowest lambda MSE
          xThisEvent(ts,:)= x_all(:,tsThisEvent(ts)); %all shifted permutations of timestamps for this eventType

   end

   %subplot each kernel
   %all possible beta values from all LASSO iterations + overlay of
   %single beta with lowest lambda MSE
%    timeLock= linspace(-time_back, time_forward, size(kernelAll,1));
   subplot(k,1,eventType);
   hold on;
%    plot(timeLock, kernelAll);
%    plot(timeLock, kernel, 'k', 'LineWidth', 2);
%    hist(xThisEvent);
   title(cons(eventType));
end

%% Vis- regression output- Compare Spline vs Time_Shift versions
%load regression output data, compare time_shift to spline

%DP 12/16/21- spline data isn't using applicable basis_set so shouldn't be
%used yet

timeShiftOutput= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\lasso_vp_vta_fp_rat11_data_to_input_GADVPFP_timeShiftVersion_b.mat")
splineOutput= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\lasso_vp_vta_fp_rat11_data_to_input_GADVPFP_splineVersion_b.mat")

%string of which to examine, 'spline' or 'time_shift'
type1= 'time_shift'

%spline version:

if strcmp(type1, 'spline')==1
    %spline version:
%     b= splineOutput.stats.beta;
    b= splineOutput.b;

    figure();
    sgtitle('spline b');
    k= numel(cons);
    for eventType = 1:k
    %     kernelAll=[]; %clear 'kernel' between event types
        kernel= [];
         %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
          if eventType==1
            tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
          else
            tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
          end

       sumTerm= []; %clear between event types

       for ts= 1:round((numel(b)/k))-1 %loop through ts; using 'ts' for each timestamp instead of 'i'
    %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
    %         kernelAll(ts,:) = stats.beta(tsThisEvent(ts),:); %all iterations of LASSO
            kernel(ts,:)= b(tsThisEvent(ts),:); %single beta with lowest lambda MSE
       end
% 
%        %subplot each kernel
%        %all possible beta values from all LASSO iterations + overlay of
%        %single beta with lowest lambda MSE
       timeLock= linspace(-time_back, time_forward, size(kernelAll,1));
       subplot(k,1,eventType);
       hold on;
    %    plot(timeLock, kernelAll);
       plot(timeLock, kernel, 'k', 'LineWidth', 2);
       title(cons(eventType));
    end
    % figure();
    % plot(b)
end

    %time_shift version:

if strcmp(type1, 'time_shift')==1
%     b= timeShiftOutput.stats.beta;
    b= timeShiftOutput.b;
    figure();
    sgtitle('time-shift b');
    k= numel(cons);
    for eventType = 1:k
        kernelAll=[]; %clear 'kernel' between event types
        kernel= [];
         %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
          if eventType==1
            tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
          else
            tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
          end

       sumTerm= []; %clear between event types

       for ts= 1:round((numel(b)/k))-1 %loop through ts; using 'ts' for each timestamp instead of 'i'
    %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
            kernelAll(ts,:) = stats.beta(tsThisEvent(ts),:); %all iterations of LASSO
            kernel(ts,:)= b(tsThisEvent(ts),:); %single beta with lowest lambda MSE
       end

       %subplot each kernel
       %all possible beta values from all LASSO iterations + overlay of
       %single beta with lowest lambda MSE
       timeLock= linspace(-time_back, time_forward, size(kernel,1));
       subplot(k,1,eventType);
       hold on;
       plot(timeLock, kernelAll);
       plot(timeLock, kernel, 'k', 'LineWidth', 2);
       title(cons(eventType));
    end
    % figure();
    % plot(b)
end