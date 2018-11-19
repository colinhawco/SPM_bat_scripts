function dicom_conversion_nii(input_dir, output_dir)
% dicom_conversion(input_dir, output_dir)
%converts dicom files to single nii files, 1 file per run
% colin hawco, Nov 2010
%
% input value input_dir is the directory with the DICOM files, in the format
% such as 'c:/data/dicom/' Note the '/' at the end of the pathname
% output_dir is the root difectory for the output nifti files, with the
% same formatting restrictions. Not that spm's conversion program will
% create a directory structure for the output files
%
% Note there must be only DICOM files in the directory, or the program will
% crash. All files in the directory will be converted. 

wd=cd; % save current diectory
cd(output_dir);
fdir = dir([input_dir '\' ]); %list of DICOM files in the directory

%read dicom headers for all files
for idx = 3:length(fdir)
    disp(['reading header ' num2str(idx-2) ' of ' num2str(length(fdir)-2)])
    hdr(idx-2) = spm_dicom_headers([input_dir '/' fdir(idx).name]);
end
% 
% for idx = 1:length(fdir)
%     disp(['reading header ' num2str(idx) ' of ' num2str(length(fdir))])
%     hdr(idx) = spm_dicom_headers([input_dir '/' fdir(idx).name]);
% end
% 

spm_dicom_convert(hdr,'all','patid_date','nii');

cd(wd)
