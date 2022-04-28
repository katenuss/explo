%% Export PXPs and model frequencies %%

clear all;

% load for children
load('model_fits/comparison/hbi_children_baseline_nL_uL_nLuL_uLfG_nLuLfG.mat');
pxp = cbm.output.protected_exceedance_prob;
freq = cbm.output.model_frequency;

%adolescents
load('model_fits/comparison/hbi_adolescents_baseline_nL_uL_nLuL_uLfG_nLuLfG.mat');
pxp = [pxp; cbm.output.protected_exceedance_prob];
freq = [freq; cbm.output.model_frequency];

%adults
load('model_fits/comparison/hbi_adults_baseline_nL_uL_nLuL_uLfG_nLuLfG.mat');
pxp = [pxp; cbm.output.protected_exceedance_prob];
freq = [freq; cbm.output.model_frequency];

%save
csvwrite('../data/pxps.csv', pxp);
csvwrite('../data/model_freq.csv', freq);
