
for subj= 1:numel(subjects) %for each subject
   currentSubj= subjData.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       
       clear cutTime reblue repurple fit
       
       cutTime= currentSubj(session).cutTime';
       reblue= currentSubj(session).reblue;
       repurple= currentSubj(session).repurple;
       
      
       %---- table initialization ----
       
%        % transformation steps
%        signal= []; reference= []; %1= raw
%        signalBaseline= []; referenceBaseline= []; %baseline estimates
%        
%        signalBaselineCorrected= []; referenceBaselineCorrected= []; %2= baseline-corrected (if applicable)
%        
%        referenceFitted; % Fitted reference
%        
%        signalReferenceCorrected= []; % corrected signal - fitted, corrected reference
%        
       %pre initialize table vars
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));
       
       %save list of the vars for dynamic assignment & less code
       tableVars= {'cutTime','signalRaw','referenceRaw','signalBaseline'...,
           'referenceBaseline','signalBaselineCorrected'...,
           'referenceBaselineCorrected','referenceFitted'...,
           'signalReferenceCorrected','signalNorm'};
       
       %initialize tables to store data transformed with different methods
       tableDFF= table();
       tableAirPLS= table();
       
       for var= 1:numel(tableVars)
           tableDFF.(tableVars{var})= eval(tableVars{var});
           tableAirPLS.(tableVars{var})= eval(tableVars{var});
       end
                  
       
      %---- airPLS------
        %clear table vars between methods
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));

       
           % use airPLS to estimate baseline of signal & baseline prior to
           % fitting and subtraction
           signalRaw= reblue;
           referenceRaw=repurple;
           
           
%            signalBaseline= [];
%            referenceBaseline= [];
           
           signalBaseline= airPLS(signalRaw');
         
           [~, signalBaseline] = airPLS(signalRaw');

           [~, referenceBaseline]= airPLS(referenceRaw');
           
           signalBaseline= signalBaseline';
           referenceBaseline= referenceBaseline';
           
%            %- Viz
%            figure();
%            hold on; 
%            plot(reblue,'b');
%            plot(signalBaseline,'k--');
%            plot(repurple,'m');
%            plot(referenceBaseline,'k--');
%            legend('reblue','signal baseline', 'repurple', 'ref baseline');
           
% %            [~, signalBaseline] = airPLS(signalArtifactFreeSmooth', configuration.airPLS{:});
% %             signalBaseline = signalBaseline';
% %             signalCorrected = signalArtifactFree - signalBaseline;
            % how i've seen this used is 
            % 1) use airPLS to estimate 'Baseline' of signal (& reference)
            % 2) subtract 'baseline' from each signal (& reference)
            % 3) if fitting reference signal, fit corrected reference to corrected signal
            % 4) Remove motion artifact by subtracting fitted, corrected reference from corrected signal
            % 5) Some normalization (e.g. df/f or z score)

            %2- subtract 'baseline' shifts/artifact from both signal & reference
            signalBaselineCorrected= []; referenceBaselineCorrected= [];

            signalBaselineCorrected= signalRaw-signalBaseline;
            
            referenceBaselineCorrected= referenceRaw- referenceBaseline;
            
            %3- fit 'corrected' signals
           referenceFitted= [];
           referenceFitted= controlFit(signalBaselineCorrected, referenceBaselineCorrected);

           % 4- motion artifact subtraction (signal-fitted ref) 
           signalReferenceCorrected= signalBaselineCorrected-referenceFitted;
            
           
           %save into table
            for var= 1:numel(tableVars)
                tableAirPLS.(tableVars{var})= eval(tableVars{var});
             end
           
%            airPls= table();
%            airPls.signalBaselineCorrected= signalBaselineCorrected;
%            airPls.referenceBaselineCorrected= referenceBaselineCorrected;
%            airPls.referenceFitted= referenceFitted;
%            
           % 4- motion artifact subtraction (signal-fitted ref) 
           %dff fxn below does this?
%             signalReferenceCorrected= [];
%             signalReferenceCorrected= signalBaselineCorrected-fit;
            
          
            % - - overwriting reblue & fit
%             reblue= signalReferenceCorrected;

            % without assuming dff - - overwriting reblue & fit
%             reblue= signalBaselineCorrected;
            
            %TODO: normalization 
            %5- normalization?
            %dff follows below
            %currently the deltaFF() fxn subtracts AND normalizes...
            
%            fit= airPLS(reblue);
%            subjDataAnalyzed.(subjects{subj})(session).photometry.fit= fit;
%        end

      %--Replace reblue & repurple with airPLS-processed signals if desired dp %2022-08-30
       if strcmp(signalMode, 'airPLS')
           
%           disp('overwriting fp signals based on airPLS');
           
          subjDataAnalyzed.(subjects{subj})(session).raw.reblue= signalReferenceCorrected; %currentSubj(session).photometry.df;
          subjData.(subjects{subj})(session).reblue= signalReferenceCorrected;
     
          %405nm replacement for dff method here is likely going to be
          %weird due to disparate scale of signals
           
          subjDataAnalyzed.(subjects{subj})(session).raw.repurple= referenceFitted; 
          subjData.(subjects{subj})(session).repurple= referenceFitted;
       end


    %-- Clear vars between Methods
       signalRaw= nan(size(reblue)); referenceRaw= nan(size(reblue)); %1= raw
       signalBaseline= nan(size(reblue)); referenceBaseline= nan(size(reblue)); %baseline estimate
       signalBaselineCorrected= nan(size(reblue)); referenceBaselineCorrected= nan(size(reblue)); %2= baseline-corrected (if applicable)
       referenceFitted= nan(size(reblue)); % Fitted reference
       signalReferenceCorrected= nan(size(reblue)); % corrected signal - fitted, corrected reference
       signalNorm= nan(size(reblue));
       
    
    
%        %---- simple linear fit with controlfit function-----
%         % ControlFit (fits 2 signals together) 
%        fitLinear=[];
%        fitLinear= controlFit(reblue, repurple);
       


    %------ Delta F/F  ----------
        signalRaw= reblue;
        referenceRaw= repurple;
        
       %- simple linear fit with controlfit function
       referenceFitted= controlFit(signalRaw, referenceRaw);
       
        % Subtract reference from signal
        %-- note older code uses deltaFF fxn which normalize / F as well.
       signalReferenceCorrected= signalRaw-referenceFitted;
       
       %deltaFF function --
%        df=[];
%        df = deltaFF(reblue,referenceFit); %This is dF for boxA in %, calculated by running the deltaFF function on the resampled blue data from boxA and the fitted data from boxA
       
        %save into table
        for var= 1:numel(tableVars)
            tableDFF.(tableVars{var})= eval(tableVars{var});
         end
       
       
      %--Replace reblue & repurple with dff-processed signals if desired dp %2022-08-30
       if strcmp(signalMode, 'dff')
           
%           disp('overwriting fp signals based on dff');

          subjDataAnalyzed.(subjects{subj})(session).raw.reblue= signalReferenceCorrected; %currentSubj(session).photometry.df;
          subjData.(subjects{subj})(session).reblue= signalReferenceCorrected;
     
          %405nm replacement for dff method here is likely going to be
          %weird due to disparate scale of signals
           
          subjDataAnalyzed.(subjects{subj})(session).raw.repurple= referenceFitted; 
          subjData.(subjects{subj})(session).repurple= referenceFitted;
       end
       
       
   end %end session loop
end %end subj loop