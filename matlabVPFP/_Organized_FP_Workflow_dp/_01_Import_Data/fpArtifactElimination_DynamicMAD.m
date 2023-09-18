%% define function
%adapted from https://www.mathworks.com/matlabcentral/answers/358022-how-to-remove-artifacts-from-a-signal
%ImageAnalyst: You can detect "bad" elements either by computing the MAD and then thresholding to identify them, and then replacing them with zero or NAN (whichever you want)    
function [fixedSignal, fixedReference] = fpArtifactElimination_DynamicMAD(signal, reference, fs, refConvWindow, MADwindow, thresholdWindow, thresholdFactor)
    %Inputs:
    % reference % 405nm
    % signal %465nm
    % fs %sampling frequency
    % refConvWindow %t in seconds to smooth reference signal baseline
    % MADwindow %t in seconds to smooth MAD calculation
    % thresholdWindow %t in seconds to smooth threshold
    % thresholdFactor %# of MAD stds to set threshold at

    %Intermediates:
    % blurredReference %smoothed reference (baseline estimate)
    % blurredReferenceNoPad % remove 0 padding from convolution (make nan)
    % kernel %kernel to be convolved with reference signal to generate blurredReference
    % MAD %median absolute deviation of reference to baseline
    % badIndex %indices that exceed threshold (should be removed)

    %Outputs
    % fixedSignal %signal with artifacts removed
    % fixedReference %reference with artifacts removed

    %--first, let's determine direction of changes in 465nm and 405nm signal...
    %artifacts should be limited to times when 405nm and 465nm are trending in the same direction
    %else, we might accidentally remove some calcium events (where ca++ is driving a dip in the 405nm signal)
    dSignal= diff(signal);
    dReference= diff(reference);


    %I think if this is done over a rolling window it will work better, instantaeous change is too quick 
    dSignal= movmean(dSignal, 2*fs);
    dReference= movmean(dReference, 2*fs);

    trendAgrees= zeros(size(dSignal));

    trendAgrees(dSignal>0 & dReference>0)= 1; 
    trendAgrees(dSignal<0 & dReference<0)=1; 

    %%plot TrendAgrees
    % figure;
    % subplot(3,1,1); hold on; title('diff reblue');
    % plot(dSignal, 'b');
    % subplot(3,1,2); hold on; title('diff repurple');
    % plot(dReference, 'm');
    % subplot(3,1,3); hold on; title('trend agrees');
    % plot(trendAgrees);
    % plot([trendAgrees,trendAgrees],[zeros(size(trendAgrees)), ones(size(trendAgrees))]);

    %--begin artifact id & removal
    reference = controlFit(signal, reference); %currentSubj(session).repurple;

    %two versions of this, original uses convolution to "blur"/smoothen the
    %signal and gets the mean absolute difference between actual signal
    %and this "blurred" version... I think the "blurred" version is
    %acting as a rough moving baseline in this way. Instead of doing
    %this I also made a version that uses the movmad() function to
    %compute a moving median absolute deviation of the signal. Whatever
    %method is used, then check if MAD is above some threshold and
    %remove timestamps where it is.

    %-calculate moving MAD
%     %new method, using movmad()
    MAD= movmad(reference, MADwindow*fs); 
% 
%     %original method, using conv()
%    kernel = ones(1, refConvWindow) / refConvWindow;
%    blurredReference = conv(reference, kernel, 'same');
%    MAD = abs(reference - blurredReference); %original method, using conv()

    %-define threshold beyond which to ID as 'artifact'
    threshold= movmean(MAD, thresholdWindow*fs)+nanstd(MAD)*thresholdFactor; 
    %         yline(threshold, 'r--'); %plot static threshold

    badIndexes= MAD>threshold;%MAD(trendAgrees==1)>threshold(trendAgrees==1);

    %-replace values during artifact with nan
    fixedReference= reference;
    fixedReference(badIndexes)=nan;

    fixedSignal= signal;
    fixedSignal(badIndexes)= nan;

%     %-Visualize Plots
%     figure; sgtitle(strcat('artifact removal'));
%     ax1= subplot(4, 1, 1);
%     plot(reference, 'm-'); hold on; title('raw');
%     plot(signal, 'b');
%     grid on;
%  
%     ax2= subplot(4, 1, 2); hold on; title('inactive. blurredReference (could be used in alternate method to get MAD. would be subtracted from ref)');
% %     plot(blurredReference, 'm-');
%     grid on;
% 
%     ax3= subplot(4, 1, 3);
%     plot(MAD, 'k-'); hold on; title('Median Absolute Deviation MAD (reference-baseline estimate)')
%     grid on;
% 
%     plot(threshold, 'r-') %plot dynamic threshold
% 
%     ax4= subplot(4, 1, 4); hold on; title('artifacts removed');
%     plot(fixedReference, 'm-');
%     grid on;
%     plot(fixedSignal,'b');
%     linkaxes([ax1,ax2, ax3,ax4],'x'); linkaxes([ax1,ax2,ax4],'y');

end

