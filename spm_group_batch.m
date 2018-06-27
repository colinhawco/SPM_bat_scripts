

for cdx = 2:26  % loop over contrast numbers
    
    load(['F:\Colin\THESIS\EXPERIMENT1\fMRI data\output\group\repeats\group_c' num2str(cdx-1) '_repeats']);
    
    %output dir, must exist, assumes c1, c2, c3 structures
    matlabbatch{1}.spm.stats.factorial_design.dir = {[ 'F:\Colin\THESIS\EXPERIMENT1\fMRI data\output\group\repeats\c' num2str(cdx) '\']};
    
    %clear scans in current batch
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {};
    
    n=1;
    for pdx = [3 5:8 10:18 20:24]
        
        if cdx < 10
            matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(n) = {['F:\Colin\THESIS\EXPERIMENT1\fMRI data\output\pt' num2str(pdx) '\repeats\con_000' num2str(cdx) '.img,1']}
        else
             matlabbatch{1}.spm.stats.factorial_design.des.t1.scans(n) = {['F:\Colin\THESIS\EXPERIMENT1\fMRI data\output\pt' num2str(pdx) '\repeats\con_00' num2str(cdx) '.img,1']}
        end
        n=n+1;
    end
    
    save(['F:\Colin\THESIS\EXPERIMENT1\fMRI data\output\group\repeats\group_c' num2str(cdx) '_repeats'], 'matlabbatch')
    
end

    