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
    fittingData{sI} = cbm.input.data{sI}.rawData;
end

%specify models to compare
numModels = 6;
fitOpts     = cell(numModels,1);    % will hold fitting options for each model
models      = cell(numModels,1);    % model for each individual fit
fcbm_maps   = cell(numModels,1);    % first-level maps


% path to the maps
fname_hbi = ['hbi_', age_group, '_baseline_nL_uL_nLuL_uLfG_nLuLfG'];
disp(['Saving data to: ' fullfile('.', fname_hbi)]);

mI = 1;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 0, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP.mat']);

mI = 2;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 0, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP_nL.mat']);

mI = 3;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP_uL.mat']);

mI = 4;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP_nL_uL.mat']);

mI = 5;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 1];
fitOpts_m.doFit         = logical([1, 1, 0, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP_uL_fG.mat']);

mI = 6;
fitOpts_m.defParamVals  = [0, 0, 0, 0, NaN, 0, 0, NaN, 1];
fitOpts_m.doFit         = logical([1, 1, 1, 0, 0, 1, 0, 0, 0]);
fitOpts{mI}             = fitOpts_m;
models{mI}              = @getLLE_nInit_uUtil;
fcbm_maps{mI}           = fullfile('model_fits/aggregated/', [age_group, '_smB_rlP_nL_uL_fG.mat']);


% name to save end results to
cbm_hbi(fittingData, models, fcbm_maps, fullfile('model_fits/comparison/', fname_hbi), [], [], fitOpts);
toc;

