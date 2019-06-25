function preprocess_stc_spm12(func, t1, tr, sliceorder, smooth)
% preprocess_stc_spm12(func, t1, tr, ta, sliceorder, smooth)
%
% Inputs: func: a series of 4D functional nii files (full path). If
% multiple files are entered they are assumed to be different runs for the
% same partiipant. Accepts string and cell inputs
% t1 THe T1 anatomical scan (full path)
% tr The TR osthe squisition
% sliceorder: the order of aquisition of slices. 
% Smooth: an alternative smoPoPoothing kernal, such as [10 10 10]. Defaults to
% [8 8 8]
% 
% does the preprocessing using SPM12, in the following order:
% slice time correction
% Realign images (motion correct)
% Coregister EPI and T1
% calculate nonlinear registration on T1 scan
% Apply warp field to EPI scan.
% Smooth the data, defauls [8 8 8]
%
% outputs are prefexed with swcr
%
%

if nargin < 3
    smooth = [8 8 8];
end

if iscell(func)
    func = func{:};
end

[funcpath, fname1, n ] = fileparts(func(1,:));
funcpath = [funcpath '/'];
VF = [funcpath 'mean' fname1 n]; % mean image from motion correction

cnt = 0; 
% file names setup structures

for fdx = 1:size(func,1)
    dp={''};
    ff = deblank(func(fdx,:));
    [fp, ffn, ex]  = fileparts(ff);
    
    aff = [fp '/a' ffn ex];
%     cfile(fdx,1:length(aff)+2) = [aff ',1']; 
    
    rff = [fp '/ra' ffn ex];
%     cfile(fdx,1:length(rff)+2) = [rff ',1']; 

    nff= [fp '/wra' ffn ex];
    sff= [fp '/swra' ffn ex];
    
    v=spm_vol(ff);
    
    for rdx = 1:size(v,1)
        % raw inuts, for slice timing
        p = [ff ',' num2str(rdx)];
        dp(rdx,1) = {p};
        
        % Slice correction output files, for motion correct
        p2 = [aff ',' num2str(rdx)];
        ap(cnt+rdx, 1:length(p2)) = p2;
        
        % Motion correction output files, for coreg
        p2 = [rff ',' num2str(rdx)];
        crp{1,cnt+rdx} = p2;
        
        % coreged files, for normalize
        p3 = [rff ',' num2str(rdx)];
        np(cnt+rdx,1:length(p3)) = p3;
        nnp{1,cnt+rdx} = p3;
        
        % normalized files, for smooth
        p4 = [nff ',' num2str(rdx)];
        sp(cnt+rdx,1:length(p4)) = p4;
        
        %smoothing files output
        p5 = [sff ',' num2str(rdx)];
        sop(cnt+rdx,1:length(p5)) = p5;
        
    end

    Rfiles(fdx) = {ap};
    cnt = cnt+size(v,1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% flags for various calls
%%%%%%%%%%%%%%%%%%%%%%%%%

%slice time
stc.so = sliceorder;
stc.tr=tr;
stc.nslices = v(1).dim(3); 
stc.refslice = floor(stc.nslices/2);
stc.ta=tr-(tr/stc.nslices);
stc.prefix='a'
stc.scans = dp; 

%%%%%
flag.quality= 0.9000;
flag.fwhm= 5;
flag.sep= 4;
flag.rtm= 1;
flag.PW= '';
flag.interp= 4;
flag.wrap= [0 0 0];

%some default values for realignment
flag2.mask= 1;
flag2.mean= 1;
flag2.interp= 4;
flag2.which= 2;
flag2.wrap= [0 0 0];
flag2.prefix= 'r';

%flags for coreg of mean motion (EPI) to T1
coreg.eoptions.cost_fun= 'nmi';
coreg.eoptions.sep= [4 2];
coreg.eoptions.tol= [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coreg.eoptions.fwhm= [7 7];

coreg.ref = {t1}; 
coreg.source = {VF}; %mean motion correct file to calc coreg
coreg.other = crp';

% job data structures for normalize
job.subj.vol= {[t1 ',1']};
job.subj.resample= crp;

job.eoptions.biasreg= 0.0001;
job.eoptions.biasfwhm= 60;
sd = which('spm');
job.eoptions.tpm= {[sd(1:end-5) 'tpm/TPM.nii']};
job.eoptions.affreg= 'mni';
job.eoptions.reg= [0 0.001 0.5 0.05 0.2];
job.eoptions.fwhm= 0;
job.eoptions.samp= 3;

job.woptions.bb = [-78  -112   -70; 78    76    85]; 
job.woptions.vox= [2 2 2];
job.woptions.interp= 4;
job.woptions.prefix = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second pass old coreg, does better, corrects minor issues in normalizing

%flags for coreg of mean motion (EPI) to T1
coreg2.eoptions.cost_fun= 'nmi';
coreg2.eoptions.sep= [4 2];
coreg2.eoptions.tol= [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coreg2.eoptions.fwhm= [7 7];

sd = which('spm');
VG = [sd(1:end-5) '/canonical/avg305T1.nii,1'];

coreg2.ref ={VG}  
coreg2.source = nnp(10); %mean motion correct file to calc coreg
coreg2.other = nnp';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DO the Preprocs %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('beginning slice time correction')
disp(' ')
disp(' ')
disp(' ')
spm_run_st(stc)

disp('beginning reslicing of images')
disp(' ')
disp(' ')
disp('Calculating transforms')
disp(' ')
disp(' ')
spm_realign(Rfiles, flag);

disp(' ')
disp(' ')
disp('Applying transforms, creating resliced images')
disp(' ')
disp(' ')
spm_reslice(Rfiles, flag2);

disp(' ')
disp(' ')
disp('finished reslicing, starting coreg')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

% coreg each file to T1
spm_run_coreg(coreg)

disp(' ')
disp(' ')
disp('finished coreg, starting normalization')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
spm_run_norm(job);


% second coreg, normalizes to MNI template

disp(' ')
disp(' ')
disp('finished normalize, starting coreg part 2')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
spm_run_coreg(coreg2)

disp(' ')
disp(' ')
disp('starting smoothing')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
%smooth
for idx =1:size(sp,1)
    if mod(idx,100) ==1; idx; end
    spm_smooth(sp(idx,:), sop(idx,:), [smooth], 0);
end


disp(' ')
disp('preprocessing complete')
disp(' ')



