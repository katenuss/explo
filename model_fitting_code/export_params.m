%% Export parameter estimates %%

clear all;

%specify model
model = 'nL';

%load data
data_name = ['model_fits/aggregated/allSubs_smB_rlP_', model];
load(data_name)

%get params
params = cbm.output.parameters;

%transform first two parameters
for p = 1:length(cbm.input.data)
    trans_smB(1,p) =  20/(1+exp(-params(p,1)));
end

for p = 1:length(cbm.input.data)
    trans_rlP(1,p) =  1/(1+exp(-params(p,2)));
end

%swap into params
params(:,1) = trans_smB';
params(:,2) = trans_rlP';


%get sub_ids
for sub = 1:length(cbm.input.data)
    subID(sub) = str2double(cbm.input.data{sub}.subID);
end

%determine param names
param_names = split(data_name, '_');
param_names = param_names(3:5);

%determine headers
headers{1} = 'subID';

for column = 1:size(params,2)
    headers{column+1} = param_names{column};
end
    

csvwrite_with_headers(['../data/params_' , model, '.csv'], [subID', params], headers);
