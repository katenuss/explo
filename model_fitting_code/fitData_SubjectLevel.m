%% initialization
clearvars;
tic;
RandStream.setGlobalStream(RandStream('mt19937ar','Seed', 'shuffle'));
addpath(fullfile('.', 'cbm', 'codes'));

% point to the director with data files we want to fit
dataFiles = dir(fullfile('.', 'raw_data', 'all_data', '*.mat'));

% set up the priors for each parameter
modelPathName           = 'smB_rLP';
fitOpts.defParamVals    = [0, 0, 0, 0, NaN, 0, 0, NaN, 0];
fitOpts.doFit           = logical([1, 1, 0, 0, 0, 0, 0, 0, 0]); 
%notes: Model included in Jeff's paper had 5 free parameters:
% [1, 1, 1, 0, 0, 1, 1, 0, 0]
% This corresponds to:
% 1. smB - Softmax inv. temp 
% 2. rlP - Learning rate 
% 3. nL - novelty initialization bias
% 4. nU - novelty terminal value (turned off)
% 5. nE - exponential decay of novelty(turned off)
% 6. uL - uncertainty utility intercept 
% 7. uU - uncertainty utility end point 
% 8. uE - exponential decay of uncertainty (turned off)
% 9. uGate - familiarity gate (not fit, just turned to 1 in ParamVals)

prior                   = struct('mean', zeros(sum(fitOpts.doFit),1), 'variance', 6.25);
modelHandle             = @getLLE_nInit_uUtil;

% director to store subject fits
dataPath    = 'model_fits/individual/';
fitDir      = fullfile(dataPath, modelPathName);
mkdir(fitDir);

% start a paralell pool
pool = gcp('nocreate');
if isempty(pool)
    pool = parpool(4);
end

% loop through and fit each subject
parfor sI = 1: size( dataFiles,1 )
    % read in the data
    rawData = load( fullfile(dataFiles(sI).folder, dataFiles(sI).name) );
    
    % define output file name
    fileName = fullfile(fitDir, ['sub_' strtrim(num2str(rawData.taskStruct.subID)) '.mat']);
    disp(fileName);
        
    try
        % fit the subject
        cbm = cbm_lap({rawData.taskStruct.allTrials}, modelHandle, prior, [], [], fitOpts);

        % run the model with specified parameters to compute model signals
        [~, fitData] = modelHandle(cbm.output.parameters, rawData.taskStruct.allTrials, fitOpts);

        % store data in cbm structure
        cbm.input.data = {struct('subID', strtrim(num2str(rawData.taskStruct.subID)), 'rawData', rawData.taskStruct.allTrials, 'fitData', fitData)};
        
        % save data to file
        saveCBMData(fileName, cbm);
        
    catch ME
        % mark subjects that didn't find convergence
        disp('-------------- BAD FIT -------------');
        disp(fileName);
        disp('-------------- BAD FIT -------------');
        
    end
end

delete(pool);

% aggregate all subject fits
subFiles = dir(fullfile(fitDir, 'sub_*.mat'));
subDataPath = cell(numel(subFiles),1);
for sI = 1 : numel(subFiles)
    subDataPath{sI} = fullfile( subFiles(sI).folder, subFiles(sI).name );
end % for each subject
cbm_lap_aggregate(subDataPath, fullfile(dataPath, ['allSubs_' modelPathName '.mat']));
toc;

% helper function to save data 
function [] = saveCBMData(fileName, cbm)
    save(fileName, 'cbm');
    disp(['Saved: ' fileName]);
end