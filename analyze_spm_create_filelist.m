function files = analyze_spm_create_filelist(directories, f)
% function files = analyze_spm_create_filelist(directories, filt)
%
% creates a list of nifti files (.img) to analyze in the other analize_spm
% programs. 
% Inputes: 
% directories, a list of the directories in which the files are
% found (char array). Should be the full path ('c:/....')
%
% filt, a search filter to indicate which files to include. for example, 
% 'swr' This will prevent the program from selecting all the files in the 
% directory, and only include the correct (i.e. preprocessed files) in 
% the output. Note that there should not be a * at the end of the filt 
% (i.e. 'srf*' is incorrect)
%
% Files in different directories are stored as a 3-dimentional matrix, with
% files in the 3rd dimention being from different directories. 
%
% Colin Hawco, Winter 2011

curdir = pwd;

P=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls([f '*.img']);
    if isempty(p)
        p=ls([f '*.nii']);
    end
    dp=[''];
    
    v=spm_vol(p(1,:));
    
    if size(v,1) > 1 %4D nifit file
        for rdx = 1:size(v,1)
            p = [directories(idx,:) p1(fdx).name ',' num2str(rdx)];
            dp(rdx,1:length(p)) = p;
        end
        files(1:size(dp,1),:,idx)=dp;
    else
        for jdx = 1:size(p,1)
            dp(jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '\' p(jdx,:)];
        end
        files(1:size(dp,1),:,idx)=dp;
    end
end

cd(curdir);
