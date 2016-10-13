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

[means,errors] = means_and_errors_plot(newWayValues,newWayLabels);

%%

% binned = time_course(storeNSuccessfulTrials,trialLabels,start_times);
binned = time_course(storeNSuccessfulTrials,trialLabels,start_times,'binBy','mean');

%%

field_names = fieldnames(lookLabels);
OldWayLookLabels = cell(1,length(field_names));

for i = 1:length(field_names)
    OldWayLookLabels{i} = lookLabels.(field_names{i});
end


%%

[oldWayValues,oldWayLabels] = normalize_by(storeLookingDuration,OldWayLookLabels,'scrambled');

oldWayValues2 = oldWayValues; oldWayValues2(isnan(oldWayValues2)) = 0;
newWayValues2 = newWayValues; newWayValues2(isnan(newWayValues2)) = 0;

%%
[newWayValues,newWayLabels] = normalize_by(storeLookingDuration,lookLabels,'scrambled');

%%
field_names = fieldnames(newWayLabels);
for i = 1:length(oldWayLabels);
    one_old_way = oldWayLabels{i};
    one_new_way = newWayLabels.(field_names{i});
    
    testcmp(:,i) = strcmp(one_old_way,one_new_way);
    
end

%%

[means,errors] = means_and_errors_plot(values,labels,varargin)


