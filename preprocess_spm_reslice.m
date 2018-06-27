function preprocess_spm_reslice(directories,slice_order, timing, prefix)
% preprocess_spm(directories,slice_order, timing, prefix)
% 
% does the preprocessing using SPM8, in the following order:
% Realign, slice time correction, normalize (with the EPI template), smooth 
% directory specifies the input directory where the .img files are found.
% All of the .img files in this directory will be preprocesseed. Note that
% this means if you run the function twice on the same directory, it will
% preprocess again the images which were previously preproced, or it will
% crash. Either way. 
% Default paramters are used for all preprocessing. the smoothing kernel   
% is [8 8 8]
%
% slice_order is the order in which each slice was collected. The first 
% index is slice 1, etc. ec.  
%
% timing has two values. The first is the time between slices, and the
% second is the time between the last slice and onset of the next TR. 
%
% updated dec 2012


if nargin < 4
    prefix = 'f'
end

P=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls([prefix '*. nii']);
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

%spm_realign(P, flag)

%some default values for realignment
flag.mask= 0;
flag.mean= 1;
flag.interp= 4;
flag.which= 2;
flag.wrap= [0 0 0];
flag.prefix= 'r';

%spm_reslice(P, flag)

disp('finished reslicing, starting slice time correction')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

P=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls(['r' prefix '*.nii']);
    dp=[''];
    for jdx = 1:size(p,1)
        dp(jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '\' p(jdx,:)];
    end
    P=[P; dp];
end


cd(directories(1,:))
p=ls('r*.nii');

%spm_slice_timing(P, slice_order, 1, timing, 'a')



disp('finished slice time correction, starting normalization')
disp(' ')
disp(' ')
disp(' ')
disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEED TO CODE AS INPUT VARIABLE %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=ls('ar*.nii');
VG = 'D:\spm8\templates\EPI.nii,1';
VF = [directories(1,:) p(3,:)];
  
matname = [directories(1,:) p(3,1:size(p,2)-4) '_sn.mat'];

% setup paramets for normalization (defaults taken from the batch window
clear flag
flag.smosrc= 8;
flag.smoref= 0;
flag.regtype= 'mni';
flag.cutoff= 25;
flag.nits= 16;
flag.reg= 1;
flag.graphics=0;

%estimate normalization parameters
params = spm_normalise(VG,VF,matname,'','',flag);

% get new filenames for normalization and smoothing
oP=[];
sP=[];
nP=[];
for idx = 1:size(directories,1);
    cd(directories(idx,:))
    p=ls('ar*.nii');
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


% input options for normalize writing
clear flag
flag.preserve= 0;
flag.bb= [ -78  -112   -50;    78    76    85];
flag.vox= [2 2 2];
flag.interp= 1;
flag.wrap= [0 0 0];
flag.prefix= 'w';
        
spm_write_sn(nP,matname,flag);

disp('normalizing done, beginning smoothing')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

%smooth
for idx =1:size(sP,1)
    spm_smooth(sP(idx,:), oP(idx,:), [8 8 8], 0);
end




disp(' ')
disp('preprocessing complete')
disp(' ')

