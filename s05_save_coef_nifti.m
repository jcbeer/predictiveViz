%% save estimated coefficients as nii
% add SPM directories to path
addpath(genpath('/Applications/MatlabAddOns/SPM/'));
addpath(genpath('/Users/Psyche/spm12/'));

%% load data
% load coefficient data
coefs = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/coefficients.csv',1,0);
% load masks
brainmask = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/MNI152maskbinary3mm.csv'); 
ROImask = csvread('/Users/Psyche/neurohack2018/predictiveViz/data/cortical_mask_new.txt');
bigbrainROImask = (brainmask==1 & ROImask == 1)*1;
% load image template
HeaderInfo = spm_vol('/Users/Psyche/neurohack2018/predictiveViz/data/ICgroups.nii');

%% update header info
% change filenames
HeaderInfo.fname = '/Users/Psyche/neurohack2018/predictiveViz/data/coefficients.nii';
HeaderInfo.private.dat.fname = HeaderInfo.fname; 
% prevent rescaling
HeaderInfo.pinfo = [1;0;0];
HeaderInfo.dt = [64 0];

%% create 3D array for each set of tuning parameters
for i = 1:size(coefs, 2)
    data = bigbrainROImask;
    data(bigbrainROImask==1) = coefs(:,i)*1000;
    data3D(:,:,:,i) = reshape(data, HeaderInfo.dim);
end

spm_write_vol(HeaderInfo, data3D);

    
    