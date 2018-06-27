function preprocess_spm2(directories, filt, anat)
% preprocess_spm(directory, anat)
% 
% does the preprocessing using SPM8, in the following order:
% Realign, normalize (using the anatomical file), smooth (8mm)
% Note that if you run the function twice on the same directory, it will
% preprocess again the images which were previously preproced and overwrite
% them.
% Default paramters are used for all preprocessing. the smoothing kernel   
% is [8 8 8]
%
% direcdtories specifies the input directories where the image files are found.
% e.g. ['c:/fmri/pt1/run1/'; 'c:/fmri/pt1/run2/'], for a participant with two
% runs/scans. 
%
% filt (string) is a search filter to identify the files which should be loaded into
% SPM, in UNIX/DOS style format. A * wildcard is allowed in the filter, which is
% used as part of an "ls" command in matlab. For example, a filter might be
% '*.img' or 'f*.img' are OK. '*' will work for nii files (selecting all
% files int he directory), but for hdr/img will fail because it will select
% both the .hdr and .img files, while it should select only 1. 
% 
% anat (string) is the full path name of the anatomical t1 scan, which is used for
% normalization. 
%
% Colin Hawco, updated July 2014


P=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls(filt);
    dp=[''];
    for jdx = 1:size(p,1)
        dp(jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '\' p(jdx,:)];
    end
    P=[P; dp];
end

disp('beginning reslicing of images')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

flag.quality= 0.9000;
flag.fwhm= 5;
flag.sep= 4;
flag.rtm= 1;
flag.PW= '';
flag.interp= 2;
flag.wrap= [0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_realign(P, flag)

%some default values for realignment
flag.mask= 1;
flag.mean= 1;
flag.interp= 4;
flag.which= 2;
flag.wrap= [0 0 0];
flag.prefix= 'r';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_reslice(P, flag)

disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('finished reslicing, starting coregistration')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

cd(directories(1,:))
p=ls(['r' filt]);
meanepi=ls('mean*.img')

coreg.ref= {[anat]};
coreg.source= {[meanepi]};
coreg.other= {''};

coreg.eoptions.cost_fun= 'nmi';
coreg.eoptions.sep= [4 2];
coreg.eoptions.tol= [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coreg.eoptions.fwhm= [7 7];

%%%%%% COREGISTRATION STEP, ANAT to EPI
spm_run_coreg_estimate(coreg)


disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('finished coregistration, starting segmentation')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

%call segmentation protocol with all SPM defaults
seg.opts.tpm= ['D:\spm8\tpm\grey.nii '; 'D:\spm8\tpm\white.nii';'D:\spm8\tpm\csf.nii  '];
seg.opts.ngaus= [2 ; 2; 2; 4];
seg.opts.regtype= 'mni';
seg.opts.warpreg= 1;
seg.opts.warpco= 25;
seg.opts.biasreg= 1.0000e-04;
seg.opts.biasfwhm= 60;
seg.opts.samp= 3;
seg.opts.msk='';

seg.output.GM= [0 0 1];
seg.output.WM= [0 0 1];
seg.output.CSF= [0 0 0];
seg.output.biascor= 1;
seg.output.cleanup= 0;

seg.data = {anat};

% Segmentation routine with write%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out = spm_run_preproc(seg)


disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('finished segmentation, starting normnalization')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

% get new filenames for normalization and smoothing
oP=[];
sP=[];
nP=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls(['r' filt]);
    np=[''];
    sp=[''];
    op=[''];
    for jdx = 1:size(p,1)
        op(jdx,1:size(p,2)+size(directories,2)+3)= [directories(idx,:) '\sw' p(jdx,:)];
        np (jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '\' p(jdx,:)];
        sp (jdx,1:size(p,2)+size(directories,2)+2)= [directories(idx,:) '\w' p(jdx,:)];
    end
    nP=[nP; np];
    oP=[oP; op];
    sP=[sP; sp];
end

sflag.preserve= 0;
sflag.bb= [ -78  -112   -50;    78    76    85];
sflag.vox= [2 2 2];
sflag.interp= 1;
sflag.wrap= [0 0 0];
sflag.prefix= 'w';
        
spm_write_sn(nP, out.snfile{1}, sflag);


disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('normalizing done, beginning smoothing')
disp(' ')
disp(' ')
disp(' ')
disp(' ')


%smooth
for idx =1:size(P,1)
    disp(['smoothing file ' num2str(idx) ' out of ' num2str(size(P,1))])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spm_smooth(sP(idx,:), oP(idx,:), [8 8 8], 0);
end

disp(' ')
disp('preprocessing complete')
disp(' ')
