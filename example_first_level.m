function example_first_level(pt)
% runs a first level analysis on a participant. I culled this example from
% ym TMS-fMRi data, where participants were coded (and folderrts names) int
% he format p100, p101, p102, etc. So pt is the participant number (a
% double, e.g. 100 for p100). This can be changes 

% first load an file with fMRI event onsets, as described under the helpd
% for the function analyze_spm_design.m it has a variable calles onsets,
% which could also be coded as an inoput variable if that is easier. 
load TMSfMRI_onsets

%base folder where data for this participant is stroed
basedir = ['D:\work\TMS-fMRI\output\p' num2str(pt) '\'];
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
direc(1,:) = [d2 '\run1\'];
direc(2,:) = [d2 '\run2\'];
numruns = 2 ;

% this function makes a file list to pass to analyze_spm_design.m. All my
% preprocessed files started with wmrtf, so that is the prefix I specified. 
% This should change for your code.  
files = analyze_spm_create_filelist(direc, 'wmrtf');

% I have one text file of motion regressors because of the way I ran the
% preocessing. These two lines load and read that text file which is
% presumed to be in the folder for the first run, direc(1,:). 
r = dir([direc(1,:) '/*.txt'])
mregress = textread([direc(1,:) '\' r(1).name])

%here it is, we specify the design and estimate the beta paramters for the
%first level analysis. 
%READ THE HELP FOR THIS FUNCTION!!!!!! This is the first critical part of
%the pipeline. 
analyze_spm_design([basedir], files, 3, 3, onsets, mregress);

% CONTRASTS for analysis. See help in .m for details on this. Note that I
% have siomplified things, and now you only need to specify values for each
% event type (I have 9), and the code below will sort out columns for the
% dispersion and derivative if included, motion regeressors and run
% regressors. 
contrasts = [...
1	0	0	0	-1	0	0	0	0
0	1	0	0	0	-1	0	0	0
0	0	1	0	0	0	-1	0	0
0	0	0	1	0	0	0	-1	0
1	-1	0	0	0	0	0	0	0
1	0	-1	0	0	0	0	0	0
1	0	0	-1	0	0	0	0	0
0	0	0	0	1	-1	0	0	0
0	0	0	0	1	0	-1	0	0
0	0	0	0	1	0	0	-1	0
0	1	-1	0	0	0	0	0	0
0	1	0	-1	0	0	0	0	0
0	0	1	-1	0	0	0	0	0
0	0	0	0	0	1	-1	0	0
0	0	0	0	0	1	0	-1	0
0	0	0	0	0	0	1	-1	0
-1	1	0	0	-1	1	0	0	0
-1	0	1	0	-1	0	1	0	0
-1	0	0	1	-1	0	0	1	0
0	-1	1	0	0	-1	1	0	0
0	-1	0	1	0	-1	0	1	0
0	0	-1	1	0	0	-1	1	0
1	0	0	0	0	0	0	0	0
0	1	0	0	0	0	0	0	0
0	0	1	0	0	0	0	0	0
0	0	0	1	0	0	0	0	0
0	0	0	0	1	0	0	0	0
0	0	0	0	0	1	0	0	0
0	0	0	0	0	0	1	0	0
0	0	0	0	0	0	0	1	0
1	-1	0	0	-1	1	0	0	0
1	0	-1	0	-1	0	1	0	0
1	0	0	-1	-1	0	0	1	0
1	1	1	1	-1	-1	-1	-1	0];

numtypes = 9; %number of event types
regress = 6; %number of regressors
basis = 3; %nuber of basis functions, 3 = HRF plus deriv plus dispersion

% check the help for this function for details. 
contrast_matrix = create_contrast_matrix(contrasts, numtypes, numruns, regress, basis)

% names for each contrast in cell format. One value (semicolon separated)
% per contrast. you can actually exclude this if you want, but I think it
% is best to have specific names here (which are stored in the SPM.mat file
% and make it easier to go back and see what contrast is what). 
names ={ 'noTMS related vs unrelated','200ms related vs unrelated', '600ms related vs unrelated',...
'1000 ms related vs unrelated', 'related noTMS vs 200ms', 'related noTMS vs 600', ...
'related noTMS vs 1000', 'unrelated noTMS vs 200ms', 'unrelated noTMS vs 600', 'unrelated noTMS vs 1000', ...
'related 200ms vs 600ms', 'related 200ms vs 1000ms', 'related 600ms vs 10000ms' ...
'unrelated 200ms vs 600ms','unrelated 200ms vs 1000ms', 'unrelated 600ms vs 10000ms'...
'overall noTMS vs 200',  'overall noTMS vs 600',  'overall noTMS vs 1000', ...
 'overall 200 vs 600',  'overall 200  vs 1000',  'overall 600 vs 1000'...
'beta type1', 'beta type2', 'beta type3', 'beta type4', 'beta type5', 'beta type6', 'beta type7','beta type8',...
 'crossover 200ms', 'crossover 600ms', 'crossover 1000ms', 'overall rel > unrel', ...
};

% RUN CONTRAST ANALYSIS. See the help for details on how you can change
% inputs if you want. 
analyze_spm_contrasts( [basedir], contrast_matrix, names)

cd(curdir)
