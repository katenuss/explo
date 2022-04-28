% Extracting memory data for Explo2 task

clearvars
dataPath = '../data/mat_files/memoryTask/';
memFiles = dir(fullfile(dataPath,'*.mat'));

%% For each subject, first create a table that maps the images to the stim numbers 
stimNums = [1:12]';
stimDataTable = table;

for x = 1:length(memFiles)
  stimNames = {};
  load([dataPath, memFiles(x).name]);
  subID = str2num(repmat(memFiles(x).name(1:3), 12, 1));
  for ii = 1:12
    stimNames{ii} = ioStruct.allImageFiles(ii).name;
  end
  data.subID = subID;
  data.stimNum = stimNums;
  data.stimNames = stimNames';
  subData = struct2table(data);
  stimDataTable = [stimDataTable; subData];
end

writetable(stimDataTable,'stim_data_final.csv');

%% Concatenate .mat files

memDataTable = table;

for x = 1:length(memFiles)
  load([dataPath, memFiles(x).name]);
  
  %get subject ID from filename
  memData.subID = str2num(repmat(memFiles(x).name(1:3), 10, 1));
  memData.explorationBlock = probeAnalysis.trialnum';
  memData.respKey = probeAnalysis.respKey';
  memData.imageOrder = probeAnalysis.imageOrder;
  memData.highRewImage = probeAnalysis.highRewImage';
  memData.medRewImage = probeAnalysis.medRewImage';
  memData.lowRewImage = probeAnalysis.lowRewImage';
  memData.highRewDiffImage = probeAnalysis.LureListName';
  memData.newImage = probeAnalysis.newImageName';
  
  
  subData = struct2table(memData);
  memDataTable = [memDataTable; subData];
  
end


writetable(memDataTable,'mem_data_final.csv');

