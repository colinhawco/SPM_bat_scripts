function preprocess_unwarp(directories, prefix, phase, mag, echo, readtime)
%  preprocess_unwarp(directories, prefix, phase, mag, echo, readtime)

nifit = 0;

P={};
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p1=dir([prefix '*.img']);
    ext = '.img';
    if isempty(p1); p1=dir([prefix '*.nii']); ext = '.nii'; end;
    
    v=spm_vol(p1(1).name);
    
    if size(v,1) > 1 %4D nifit file
        nifit = 1;
        for fdx = 1:size(p1,1) %if there are multiple 4D nifit files
            clear dp
            for rdx = 1:size(v,1)
                p = [directories(idx,:) p1(fdx).name ',' num2str(rdx)];
                dp(rdx,1) = {p};
            end
            P=[P; dp];
        end
    else
        dp=[''];
        for jdx = 1:size(p1,1)
            p(jdx,:) = p1(jdx).name;
            dp(jdx,1)= {[directories(idx,:) '/' p(jdx,:)]};
        end
        P=[P; dp];
    end
end

disp('beginning realignment of with unwarp')
disp(' '); disp(' '); disp(' '); disp(' '); disp(' '); 

%calculate field maps unwapring image
vdm_name = preproc_fieldmaps(P(1), phase, mag, echo, readtime)

job.data.scans= {P};
job.data.pmscan= {vdm_name};

job.eoptions.quality= 0.9000;
job.eoptions.sep= 4;
job.eoptions.fwhm=5;
job.eoptions.rtm= 0;
job.eoptions.einterp= 4;
job.eoptions.ewrap= [0 0 0];
job.eoptions.weight= '';

job.uweoptions.basfcn= [12 12];
job.uweoptions.regorder= 1;
job.uweoptions.lambda= 100000;
job.uweoptions.jm= 0;
job.uweoptions. fot= [4 5];
job.uweoptions.sot= []
job.uweoptions.uwfwhm= 4
job.uweoptions.rem= 1
job.uweoptions.noi= 5
job.uweoptions.expround= 'Average'

job.uwroptions.uwwhich= [2 1];
job.uwroptions.rinterp= 4;
job.uwroptions.wrap= [0 0 0];
job.uwroptions.mask= 1;
job.uwroptions.prefix= 'u';

spm_run_realignunwarp(job);


