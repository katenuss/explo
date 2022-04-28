% point to the directory with data
dataPath = '../data/mat_files/exploTask';
dataFiles = dir(fullfile(dataPath, '*.mat'));
[dataFiles(:).folder] = deal(dataPath);

%initialize table
dataTable = [];

% load and collate the data
for fI = 1:length(dataFiles)
    
    % load the data and flatten
    load( fullfile(dataFiles(fI).folder, dataFiles(fI).name), 'taskStruct');
    subData = flattenTaskData(taskStruct);
    
    %add to table
    dataTable = [dataTable; struct2table(subData)];

    %clear subject data 
    clear taskStruct flatData;
end

% write data to csv
outfile = '../data/explo_output_final.csv';
writetable(dataTable, outfile);
disp(['data written to: ' outfile]);