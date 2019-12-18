%dp 8.5.19
%adapted from https://www.mathworks.com/matlabcentral/answers/437494-how-to-loop-through-all-files-in-subfolders-in-a-main-folder

tankPath= 'E:\Photometry\DP_DSTrainingv02_TDT2-191203-124106\VP-VTA-FP round 2\_needNex'; %define the parent folder housing all tank subfolders

tankDir = dir(fullfile(tankPath,'*')); 

tankName= setdiff({tankDir([tankDir.isdir]).name},{'.','..'}); % list of subfolders of tankDir

for i = 1:numel(tankName) %for each tank subfolder, run TDT2NEX
    
      currentPath= strcat(tankPath, '\', tankName{i});
      
      disp(currentPath);
     
      TDT2NEX(currentPath);
     
end


disp('all files done');