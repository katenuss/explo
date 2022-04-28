% Extracting memory data for Explo2 task

clearvars
dataPath = '../data/mat_files/exploTask/';
dataFiles = dir(fullfile(dataPath,'*.mat'));

%% For each subject, create a table of block difficulties
blockNums = [1:10]';
blockDiffTable = table;

for x = 1:length(dataFiles)
  load([dataPath, dataFiles(x).name]);
  subID = str2num(repmat(dataFiles(x).name(1:3), 10, 1));
  data.subID = subID;
  data.blockID = blockNums;
  data.blockDifficulty = taskStruct.blockSpecs.blockDifficulty;
  subData = struct2table(data);
  blockDiffTable= [blockDiffTable; subData];
end

writetable(blockDiffTable,'../data/block_difficulty_final.csv');


