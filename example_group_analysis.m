function example_group_analysis
%an example of batch code to call an SPM group analysis. Needs to be
%changes on an analysis by analysis basis. 
%
% the folder "basedir" if where the group analysis will be stored, though
% it can have its own sub-folder by specifying in line x to y. 
%within the main folder a separate folder is made for each contrast, with
%the naming format C contrast number. So if we have 3 contrasts we get the
%folder C1 C2 C3. 
%
% Two contrasts will be run, 'pos', saved as spmT_0001 and the opposite
% 'neg', saved as spmT_0002. If the cotnrast is A>B, then 'neg' is the
% contrast 'B>A' 


load group_t.mat

basedir  = 'D:\work\TMS-fMRI\output\group\';

numcontrasts = 12; %the number of contrasts in the analysis. 

for cdx = 1:12  % loop over contrasts. 
    
    cdx
    %output dirs
    matlabbatch{1}.spm.stats.factorial_design.dir = {[basedir 'GLM\C' num2str(cdx) '\']};
    mkdir([basedir 'GLM\C' num2str(cdx) '\']) 
    cd([basedir 'GLM\C' num2str(cdx) '\']);
    
    %clear scans in current batch
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};
    
    n=1; %counter for the contrasts
    
    %pdx is a list of participants. In my studies I try to keep participant
    %folder names as numbers to make loops like this work, although in this 
    %case I have a 'p' prefix (e.g. p101, p102, p103, etc). If you have a
    %different naming structure you can fix this loop by having a txt or cell
    %variable with the names of your subject folders (e.g. subs) and loops
    %through it, calling subs(pdx) instead of 'p' num2str(pdx).
    for pdx = [100 101   104  108  111 112 119 120  122 123 124 125] %   102 109 121 106
        
        if cdx < 10
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(n) = {[basedir 'p' num2str(pdx) '\con_000' num2str(cdx) '.img,1']};
        else
             matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(n) = {[basedir 'p' num2str(pdx) '\con_00' num2str(cdx) '.img,1']};
        end
        n=n+1;
    end
    
    % WARNING: THIS DELETES ANY ANALYSSI IN THE CURRENT DIRECTORY!
    % UNCOMMENT AT YOUR OWN RISK AND BE CAREFUL. This is useful if tyou
    % rerun an analysis and don't want SPM to throw a warning pop-up for
    % each participant. 
%     if ~isempty(ls('SPM.mat'))
%         delete SPM.mat
%     end

%Here si the main code, running the contrasts. 
    spm_jobman('run',matlabbatch)
    load SPM
    %model estimation
    SPM=spm_spm(SPM)
    save('SPM', 'SPM')
   
    % Run the contrasts. Neg flips the contrasts. So if your contrast is
    % A>B, neg is the results for B>A. 
    contrasts = [1; -1];
    names = {'pos', 'neg'};
    curdir = pwd; 
    analyze_spm_contrasts(curdir, contrasts, names);
    
    
end





