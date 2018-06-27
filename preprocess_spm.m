function preprocess_spm(directories, prefix, smooth)
% preprocess_spm(directories, [prefix], [smooth])
%
% does the preprocessing using SPM8, in the following order:
% Realign, normalize (with the EPI template), smooth (8mm)
% direcdtory specifies the input directory where the .img files are found.
% All of the .img files in this directory will be preprocesseed. Note that
% this means if you run the function twice on the same directory, it will
% preprocess again the images which were previously preproced, or it will
% crash. Either way.
% Default paramters are used for all preprocessing. the smoothing kernel
% is [8 8 8]

if nargin ==1
    prefix = 'f';
end
if nargin < 3
    smooth = 8;
end

nifit = 0;

P=[];
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
                dp(rdx,1:length(p)) = p;
            end
            P=[P; dp];
        end
    else
        dp=[''];
        for jdx = 1:size(p1,1)
            p(jdx,:) = p1(jdx).name;
            dp(jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '/' p(jdx,:)];
        end
        P=[P; dp];
    end
    
end

disp('beginning reslicing of images')
disp(' ')
disp(' ')
disp('Calculating transforms')
disp(' ')
disp(' ')

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

disp('Applying transforms, creating resliced images')
disp(' ')
disp(' ')

spm_realign(P, flag)
spm_reslice(P, flag2)

disp('finished reslicing, starting normalization')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

clear p
cd(directories(1,:))
if nifit
    p1=dir(['r' prefix '*' ext]);
    VF = [directories(1,:) p1(1).name ',3'];
    mp = p1(1).name;
    matname = [directories(1,:) mp(1,1:size(mp,2)-4) '_sn.mat'];
else
    p1=dir(['r'  prefix '*' ext]);
    for jdx = 1:size(p1,1)
        p(jdx,:) = p1(jdx).name;
    end
    VF = [directories(1,:) '/' p(3,:)];
    matname = [directories(1,:) '/' p(3,1:size(p,2)-4) '_sn.mat'];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEED TO CODE AS INPUT VARIABLE %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sd = which('spm')
VG = [sd(1:length(sd)-5) '/templates/EPI.nii,1'];

% setup paramets for normalization (defaults taken from the batch window
clear flag
flag.smosrc= 8;
flag.smoref= 0;
flag.regtype= 'mni';
flag.cutoff= 25;
flag.nits= 16;
flag.reg= 1;

%estimate normalization parameters
params = spm_normalise(VG,VF,matname,'','',flag);

% get new filenames for normalization and smoothing
oP=[];
sP=[];
nP=[];
% clear p
for idx = 1:size(directories,1);
    
    cd(directories(idx,:))
    if nifit
        p1=dir(['r'  prefix '*'  ext])
        p=[];
        clear dp
        for fdx = 1:size(p1,1)
            for rdx = 1:size(v,1)
                pp = [p1(fdx).name ',' num2str(rdx)];
                dp(rdx,1:length(pp)) = pp;
            end
            p = [p; dp];
        end
    else
        p1=dir(['r'  prefix '*' ext]);
        for jdx = 1:size(p1,1)
            p(jdx,:) = p1(jdx).name;
        end
        VF = [directories(1,:) '/' p(3,:)];
        matname = [directories(1,:) '/' p(3,1:size(p,2)-4) '_sn.mat'];
    end
    np=[''];
    sp=[''];
    op=[''];
    for jdx = 1:size(p,1)
        np(jdx,1:size(p,2)+size(directories,2)+1)= [directories(idx,:) '\' p(jdx,:)];
        sp(jdx,1:size(p,2)+size(directories,2)+2)= [directories(idx,:) '\w' p(jdx,:)];
        op(jdx,1:size(p,2)+size(directories,2)+3)= [directories(idx,:) '\sw' p(jdx,:)];
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
for idx =1:size(P,1)
    if mod(idx,100) ==1; idx; end
    spm_smooth(sP(idx,:), oP(idx,:), [smooth smooth smooth], 0);
end

disp(' ')
disp('preprocessing complete')
disp(' ')

