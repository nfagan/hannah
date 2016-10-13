clearvars -except trialLabels lookLabels storeLookingDuration

labels = lookLabels;

label_names = {...
    'rois','monkeys','doses','images','sessions','genders','gazes','expressions'...
    ,'days'};

labels = make_struct(labels,label_names);

%%

tic
[new_vals, new_labs] = separate_data_struct(storeLookingDuration,lookLabels,'monkeys',{'ephron'},'doses',{'high'},'gazes',{'direct'});
toc


%%

[storeValues,storeLabs] = normalize_by_roi(storeLookingDuration,lookLabels);

%%

[storeValues,storeLabs] = normalize_by(storeLookingDuration,lookLabels,'scrambled');

%%

[means,errors] = means_and_errors_plot(storeValues,storeLabs);

%%

% binned = time_course(storeNSuccessfulTrials,trialLabels,start_times);
binned = time_course(storeNSuccessfulTrials,trialLabels,start_times,'binBy','mean');