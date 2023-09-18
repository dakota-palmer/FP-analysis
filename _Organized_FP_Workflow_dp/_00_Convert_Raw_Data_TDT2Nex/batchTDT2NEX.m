%dp 8.5.19
%adapted from https://www.mathworks.com/matlabcentral/answers/437494-how-to-loop-through-all-files-in-subfolders-in-a-main-folder

tankPath= 'H:\TDT Photometry tanks\FP_Mag_Training_withTTL_TDT2-200107-134843\_neednex'; %define the parent folder housing all tank subfolders

tankDir = dir(fullfile(tankPath,'*')); 

tankName= setdiff({tankDir([tankDir.isdir]).name},{'.','..'}); % list of subfolders of tankDir

for i = 1:numel(tankName) %for each tank subfolder, run TDT2NEX
    
      currentPath= strcat(tankPath, '\', tankName{i});
      
      disp(currentPath);
     
      TDT2NEX(currentPath);
     
end


disp('all files done');