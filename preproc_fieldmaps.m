function vdm_name = preproc_fieldmaps(EPI, phase, mag, echo, readtime)

% readtime = 1.33*64/3


[direc, epiname, nii] = fileparts(EPI);

epiname = [epiname nii];

cudir = pwd;
cd(direc)

% scale phase map to radians
V=spm_vol(phase);
vol = spm_read_vols(V);

mn   = min(vol(:));
mx   = max(vol(:));
svol = -pi+(vol-mn)*2*pi/(mx-mn);


% Output image struct
oV = struct(...
    'fname',   spm_file(V.fname,'prefix','sc'),...
    'dim',     V.dim(1:3),...
    'dt',      [4 spm_platform('bigend')],...
    'mat',     V.mat,...
    'descrip', 'Scaled phase');

spm_write_vol(oV,svol);

sphase = oV.fname;

% epidir = 'D:\work\CAMH_TMS_fMRI\study1\data\P120\2015-11-05_10-12\fieldmap_test\epi\'
% 
% fm_dir='D:\work\CAMH_TMS_fMRI\study1\data\P120\2015-11-05_10-12\fieldmap_test\fm\'
% VDM = FieldMap_preprocess(fm_dir,epidir, [echo(1), echo(2), 0, 28.373, -1, 1, 1] );

fm_imgs(1,:) = sphase;
fm_imgs(2,1:length(mag))=mag;

pm_defs.TOTAL_EPI_READOUT_TIME= readtime;
pm_defs.SHORT_ECHO_TIME= echo(1);
pm_defs.LONG_ECHO_TIME= echo(2);

pm_defs.INPUT_DATA_FORMAT= 'PM';
pm_defs.MASKBRAIN= 1;
pm_defs.UNWRAPPING_METHOD= 'Mark3D';
pm_defs.FWHM= 10;
pm_defs.PAD= 0;
pm_defs.WS= 1;

pm_defs.EPI_BASED_FIELDMAPS= 0;
pm_defs.K_SPACE_TRAVERSAL_BLIP_DIR= -1;
pm_defs.DO_JACOBIAN_MODULATION= 0;
pm_defs.sessname= 'session';
pm_defs.pedir= 2;
pm_defs.defaultsfilename= {'d:\spm12\toolbox\FieldMap\pm_defaults.m'};
pm_defs.match_vdm= 1;
pm_defs.write_unwarped= 1;


pm_defs.MFLAGS.TEMPLATE= 'd:\spm12\toolbox\FieldMap\T1.nii'
pm_defs.MFLAGS.FWHM= 5
pm_defs.MFLAGS.NERODE= 2
pm_defs.MFLAGS.NDILATE= 4
pm_defs.MFLAGS.THRESH= 0.5
pm_defs.MFLAGS.REG= 0.02
pm_defs.MFLAGS.GRAPHICS= 0

VDM = FieldMap_create(fm_imgs,{EPI},pm_defs);
vdm_name = VDM{1}.fname; 
                
