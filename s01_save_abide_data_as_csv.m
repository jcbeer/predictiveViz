%% load and save data as CSV
% add SPM directories to path
addpath(genpath('/Applications/MatlabAddOns/SPM/'));
addpath(genpath('/Users/Psyche/spm12/'));

%% load data
% combine training and test data into one
trainx = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/trainX_69880.txt');
testx = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/testX_69880.txt');

%% create mask for data
brainmask = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/MNI152maskbinary3mm.csv'); 
ROImask = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/cortical_mask_new.txt');
brainROImask = ROImask(brainmask==1);
sum(brainROImask)
% mask data
X = vertcat(trainx, testx);
X_masked = X(:,brainROImask==1);

%% extract outcome variable
trainy = readtable('/Users/Psyche/neurohack2018/predictiveViz/data/srs_train.txt');
testy = readtable('/Users/Psyche/neurohack2018/predictiveViz/data/srs_test.txt');
Y = vertcat(trainy.SRS_RAW_TOTAL, testy.SRS_RAW_TOTAL);
ID = vertcat(trainy.SUB_ID, testy.SUB_ID);

%% combine and save data
data = [ID, Y, X_masked];
dlmwrite('/Users/Psyche/neurohack2018/predictiveViz/data/abide_5252.csv', data, 'delimiter', ',', 'precision', '%.4f');



% %% create nifti file of mask 
% % reshape to 3D array
% brainROImask_3D = brainmask;
% brainROImask_3D(brainmask==1) = brainROImask;
% brainROImask_3D = reshape(brainROImask_3D, 61, 73, 61);
% % convert to nii file
% % take header information from previous file with similar dimensions 
% % and voxel sizes and change the filename in the header
% HeaderInfo = spm_vol('/Users/Psyche/neurohack2018/predictiveViz/data/ICgroups.nii');
% % fill in the new filename
% HeaderInfo.fname = '/Users/Psyche/neurohack2018/predictiveViz/data/brainmask.nii'; 
% % replace the old filename in another location within the header
% HeaderInfo.private.dat.fname = HeaderInfo.fname;  
% % prevent rescaling
% HeaderInfo.pinfo = [1;0;0];
% HeaderInfo.dt = [64 0];
% % use spm_write_vol to write out the new data
% % give spm_write_vol the new header information and corresponding data matrix
% spm_write_vol(HeaderInfo, brainROImask_3D); 