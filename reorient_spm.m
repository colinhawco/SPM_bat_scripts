
function reorient_spm(file, matfile)

v=spm_vol(file);
trs = size(v,1);

for idx = 1:trs
    job.srcfiles(idx,1) =  {[file ',' num2str(idx)]};
end

job.prefix= 'c';
job.transform.transF = {matfile};

 spm_run_reorient(job);