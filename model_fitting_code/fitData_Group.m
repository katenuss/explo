%% initialization
clearvars;
tic;
RandStream.setGlobalStream(RandStream('mt19937ar','Seed', 'shuffle'));
addpath(fullfile('.', 'cbm', 'codes'));

% first level fits
firstLevelPath = fullfile('.', 'allSubs_smB_rlP_uL_fG.mat');
load(firstLevelPath);
rawData = cell(size(cbm.input.data));
for sI = 1 : length(rawData)
    rawData{sI} = cbm.input.data{sI}.rawData;
end
disp(['Loaded: ' firstLevelPath]);

% specify the model
fitOpts.defParamVals    = [0, 0, 0,0,NaN, 0,0,NaN, 1];
fitOpts.doFit           = logical([1, 1, 0, 0, 0, 1, 0, 0, 0]);
modelHandle             = @getLLE_nInit_uUtil;

% path to the maps
fname_hbi = 'hbi_smB_rlP_nL_fGate';
disp(['Saving data to: ' fullfile('.', fname_hbi)]);

% name to save end results to
cbm_hbi(rawData, {modelHandle}, {firstLevelPath}, fullfile('.', fname_hbi), [], [], {fitOpts});
toc;

