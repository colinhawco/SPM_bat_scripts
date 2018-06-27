function context_first_level(pt)
% runs a first level analysis on a participant. I culled this example from
% ym TMS-fMRi data, where participants were coded (and folderrts names) int
% he format p100, p101, p102, etc. So pt is the participant number (a
% double, e.g. 100 for p100). This can be changes 

% first load an file with fMRI event onsets, as described under the helpd
% for the function analyze_spm_design.m it has a variable calles onsets,
% which could also be coded as an inoput variable if that is easier. 
load context_ons

%base folder where data for this participant is stroed
basedir = ['D:\work\context\output\p' num2str(pt) '\'];
curdir = pwd

cd(basedir);
d2=pwd;

% If SPM.mat exists, just over write it to prevent the SPM popup. UNCOMMENT
% AT OWN RISK!!!!!!!!!
% if ~isempty(ls('SPM.mat'))
%     delete SPM.mat
% end

% a variable with one line for each directory of images, which should
% each correspond to a run to be included in the analysis. 
l = ls; 
d = pwd;

switch pt
    case 111
        direc(1,:) = [d '\' l(3,:)]; %[d '\BOLDMOSAIC64iPAT2_0001'];
        numruns = 1;
    case 114
        direc(1,:) = [d '\' l(3,:)]; %[d '\BOLDMOSAIC64iPAT2_0001'];
        numruns = 1;
    otherwise
        direc(1,:) = [d '\' l(3,:)]; %[d '\BOLDMOSAIC64iPAT2_0001'];
        direc(2,:) = [d '\' l(4,:)]; %[d '\BOLDMOSAIC64iPAT2_0002'];
        numruns=2
end

% this function makes a file list to pass to analyze_spm_design.m. All my
% preprocessed files started with wmrtf, so that is the prefix I specified. 
% This should change for your code.  
files = analyze_spm_create_filelist(direc, 'swarf');

% I have one text file of motion regressors because of the way I ran the
% preocessing. These two lines load and read that text file which is
% presumed to be in the folder for the first run, direc(1,:). 
r = dir([direc(1,:) '/*.txt'])
mregress = textread([direc(1,:) '\' r(1).name])

%here it is, we specify the design and estimate the beta paramters for the
%first level analysis. 
%READ THE HELP FOR THIS FUNCTION!!!!!! This is the first critical part of
%the pipeline. 

onsets = eval(['ons_' num2str(pt)]);
numtypes =10;

%concatinating runs
if numruns==2
    % if there are two runs included, we need to change the event times in
    % run2 to account for concatination, by adding 1016 seconds (the
    % duration of the first run) to the event osnets time
    onsets(onsets(:,1) == 2,3) = onsets(onsets(:,1) == 2,3)+ 1016;
    onsets(onsets(:,1) == 2,1)=1; 
    
    %additional regressoers needed to concatinate runs
    sess_regress1 = [ones(1,312) zeros(1,312)]';
    %each block requires a separate linear regressor
    lineregress1 = [(linspace(-1,1,312)) zeros(1,312)]';
    lineregress2 = [ zeros(1,312) (linspace(-1,1,312))]';
    
    regressors = [mregress sess_regress1  lineregress1 lineregress2]
    
    %finally, change the file lsit to concatinate the runs
    files = [files(:,:,1); files(:,:,2)]; 
end %end of concatination

%add a dummy event at the very end of the experiment, so the HRF goes
%outside the length of the experiment and has no wieght in the analysis.
%This is to satisfy SPM which willcomplain if there is a missing event
%type. 
for tdx = 1:numtypes
    if sum(onsets(:,2) == tdx) == 0;
        onsets(size(onsets,1)+1, 1:4) = [1 tdx 2032 0];
    end
end

% Colin's script to run the first level analysis
analyze_spm_design([basedir], files, 1, 2, onsets, regressors);

% CONTRASTS for analysis. See help in .m for details on this. Note that I
% have simplified things, and now you only need to specify values for each
% event type (I have 9), and the code below will sort out columns for the
% dispersion and derivative if included, motion regeressors and run
% regressors. 
contrasts = [...
1	1	-1	-1	0	0	0	0	0	0
1	-1	1	-1	0	0	0	0	0	0
0	0	-1	1	0	0	0	0	0	0
-1	1	0	0	0	0	0	0	0	0
1	0	-1	0	0	0	0	0	0	0
0	1	0	-1	0	0	0	0	0	0
0	0	0	0	1	1	-1	-1	0	0
0	0	0	0	1	-1	1	-1	0	0
0	0	0	0	0	0	-1	1	0	0
0	0	0	0	-1	1	0	0	0	0
0	0	0	0	1	0	-1	0	0	0
0	0	0	0	0	1	0	-1	0	0
0	0	0	0	1	-1	-1	1	0	0
1	-1	-1	1	0	0	0	0	0	0
1	1	1	1	1	1	1	1	0	-8
1	1	1	1	0	0	0	0	0	-4
0	0	0	0	1	1	1	1	0	-4
1	0	0	0	0	0	0	0	0	-1
0	1	0	0	0	0	0	0	0	-1
0	0	1	0	0	0	0	0	0	-1
0	0	0	1	0	0	0	0	0	-1
0	0	0	0	1	0	0	0	0	-1
0	0	0	0	0	1	0	0	0	-1
0	0	0	0	0	0	1	0	0	-1
0	0	0	0	0	0	0	1	0	-1
0	0	0	0	1	0	0	0	0	0
1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	1	0	0	0	0
0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0
0	0	1	0	0	0	0	0	0	0
0	0	0	0	0	0	0	1	0	0
0	0	0	1	0	0	0	0	0	0
];


regress = 9; %number of regressors
basis = 1; %nuber of basis functions, 3 = HRF plus deriv plus dispersion

% check the help for this function for details. 
contrast_matrix = create_contrast_matrix(contrasts, numtypes, 1, regress, basis)

% names for each contrast in cell format. One value (semicolon separated)
% per contrast. you can actually exclude this if you want, but I think it
% is best to have specific names here (which are stored in the SPM.mat file
% and make it easier to go back and see what contrast is what). 
names ={ 'c1_N3-A3';    'c2 A3-U3';    'c3 NU3-NA3';    'c4 CA3-CU3';...
    'c5 CA3-NA3';    'c6 CU3-NU3';    'c7_N12-A12';    'c8 A12-U12';...
    'c9 NU12-NA12';    'c10 CA12-CU12';    'c11 CA12-NA12';...
    'c12 CU12-NU12';    'c13 interaction12';    'c14 interaction3';...
    'c15 all conditions - blank';    'c16 all 3 - blank';    'c17 all12 - blank'; ...
    'c18 CA3 - blank';    'c19 CU3 - blank';    'c20 NA3 - blank'; ...
    'c21 NU3 - blank';    'c22 CA12 - blank';    'c23 CU12 - blank'; ...
    'c24 NA12 - blank';    'c25 NU12 - blank';    'c26 main effects CA12'; ...
    'c27 main effects CA3';    'c28 main effects CU12';    'c29 main effects CU3'; ...
    'c30 main effects NA12';    'c31 main effects NA3'; ...
    'c32 main effects NU12';     'c33 main effects NU3';
 };

% RUN CONTRAST ANALYSIS. See the help for details on how you can change
% inputs if you want. 
analyze_spm_contrasts( [basedir], contrast_matrix, names)

cd(curdir)
