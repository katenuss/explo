%% initialization
clearvars;
tic;
RandStream.setGlobalStream(RandStream('mt19937ar','Seed', 'shuffle'));

%add cbm
addpath(fullfile('cbm', 'codes'));

%age group to fit
age_group = 'adults';

% load and collate the data
dataPath = ['model_fits/aggregated/', age_group, '_smB_rlP.mat']; 
load(dataPath);
rawData = cell(size(cbm.input.data));
for sI = 1 : length(rawData)
    data{sI} = cbm.input.data{sI}.rawData;
end

%determine fit opts
mI = 1;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 0, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

mI = 2;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 0, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

mI = 3;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

mI = 4;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

mI = 5;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 1];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

mI = 6;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 1];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;

%specify model
fname_hbi = ['model_fits/comparison/hbi_', age_group, '_baseline_nL_uL_nLuL_uLfG_nLuLfG'];

% name to save end results to
cbm_hbi_null(data, fname_hbi, fitOpts);
toc;

