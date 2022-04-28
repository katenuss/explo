# Novelty and uncertainty differentially drive exploration across development

Tasks, anonymized data, and analysis code for *Novelty and uncertainty differentially drive exploration across development (under review).*


## Task
We collected data from 122 participants on an explore-exploit decision-making task that decouples novelty and uncertainty. The original adult version of the task is described in [Cockburn et al., (2021)](https://www.biorxiv.org/content/10.1101/2021.10.13.464279v1).

The version of the task included in this repository is framed within a child-friendly narrative and includes fewer stimuli and trials per block than the original version. It can be run via Psychtoolbox in Matlab Version 2020. 

## Data
All raw data (stored in mat files) can be found in the [data](https://github.com/katenuss/explo/tree/main/data) folder. This folder also contains processed csv files that were used for analyses.

## Analysis code
Raw data was first processed in Matlab, using the code in the [data_processing_code](https://github.com/katenuss/explo/tree/main/data_processing_code) folder. Processed data was then analyzed in R (see the R markdown file in 'analysis_code').

## Computational modeling
Computational models were fit via the [cbm package](https://github.com/payampiray/cbm). The models used here were originally developed for [Cockburn et al., (2021)](https://www.biorxiv.org/content/10.1101/2021.10.13.464279v1). Modeling code is in the [model_fitting_code](https://github.com/katenuss/explo/tree/main/model_fitting_code) folder. It relies on the raw mat files.
