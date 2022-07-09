sesSpecialLabel= cell(periCueFrames,numTrials); %empty cell to store string labels for marking specific days to plot (e.g. first day of st5, first criteria of st 5, first criteria of st 7 for vp-vta-fp manuscript Figure 1)

 %dp 2022-06-19 labelling specific sessions for plotting
            %--Save string labels to mark specific days for plotting
            if currentSubj(includedSession).behavior.criteriaSes==1
               criteriaDayThisStage= criteriaDayThisStage+1; 
            end
            
            if thisStage==5 && trainDayThisStage==1 
                sesSpecialLabel(:)= {'stage-5-day-1'};
            elseif thisStage==5 && criteriaDayThisStage==1
                sesSpecialLabel(:)= {'stage-5-day-1-criteria'};
            elseif thisStage==7 && criteriaDayThisStage==1
%                 sesSpecialLabel(:)= {'stage-7-day-1-criteria'};
            end
            
           