%% define function 
%to save and close individual figures

function saveFig(fig, figPath, figName, figFormats) %(time, signal)

    for format= numel(figFormats)
        set(fig,'Position', get(0, 'Screensize')); %make the figure full screen before saving
        saveas(fig, strcat(figPath,figName,figFormats{format})); %save
    end
    
    close(fig);

end


% %% Example use
% figure();
% title('test');
% figPath = 'C:\Users\Dakota\Desktop\testFigs\';
% 
% 
% saveFig(gcf, figPath, strcat('test','_', 'figure'),'.fig');
