%% Aggregate age group fits

%determine model to aggregate
modelPathName           = 'smB_rLP_uL';
savePath = 'model_fits/aggregated/';

%add cbm code
addpath(fullfile('.', 'cbm', 'codes'));

%load age groups
sub_ages = readmatrix('ageGroups.csv');

%determine age group names
ageGroups = {'children', 'adolescents', 'adults', 'adults'}; 

%determine IDs in each age group
childIDs = sub_ages(sub_ages(:,2) == 1, 3);
adolescentIDs = sub_ages(sub_ages(:,2) == 2, 3);
%yadultIDs = sub_ages(sub_ages(:,2) == 3, 3);
%postcollegeIDs = sub_ages(sub_ages(:,2) == 4, 3);

adultIDs = sub_ages(sub_ages(:,2) == 3 | sub_ages(:,2) == 4, 3);

%determine which subjects were successfully fit by model
dataPath    = 'model_fits/individual/';
fitDir      = fullfile(dataPath, modelPathName);
subFiles = dir(fullfile(fitDir, 'sub_*.mat'));
fitSubs = zeros(length(subFiles), 1);

for sub = 1:length(subFiles)
    s = subFiles(sub).name;
    fitSubs(sub, :) = sscanf(s, 'sub_%d');
end

%determine subjects in each age group fit successfully
childIDs = intersect(childIDs, fitSubs);
adolescentIDs = intersect(adolescentIDs, fitSubs);
%yadultIDs = intersect(yadultIDs, fitSubs);
%postcollegeIDs = intersect(postcollegeIDs, fitSubs);

adultIDs = intersect(adultIDs, fitSubs);

for i = 1:length(ageGroups)
    
    %determine age group
    ageGroupName = ageGroups{i};
    
    if strcmp(ageGroupName, 'young_adults')
        ageGroupSubs = yadultIDs;
    elseif strcmp(ageGroupName, 'post_college')
        ageGroupSubs = postcollegeIDs;
    elseif strcmp(ageGroupName, 'adults')
        ageGroupSubs = adultIDs;
    elseif strcmp(ageGroupName, 'post_college')
        ageGroupSubs = postcollegeIDs;
    elseif strcmp(ageGroupName, 'adolescents')
        ageGroupSubs = adolescentIDs;
    elseif strcmp(ageGroupName, 'children')
        ageGroupSubs = childIDs;
    end
    
    %create structure to save data
    subDataPath = cell(numel(ageGroupSubs),1);
    
    for sI = 1 : numel(ageGroupSubs)
        subDataPath{sI} = fullfile( subFiles(sI).folder, ['sub_', int2str(ageGroupSubs(sI)) '.mat']);
    end 
    
    cbm_lap_aggregate(subDataPath, fullfile(savePath, [ageGroupName, '_', modelPathName '.mat']));
    
end

