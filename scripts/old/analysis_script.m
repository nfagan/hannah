%% create male distribution

[male_values,male_labels] = separate_data_hannah(storeLookingDuration,lookLabels,...
    'expressions',{'male'});

%%

newLabels = collapse_across({'gender'},lookLabels);


%% normalize by scrambled
[norm_look_dur,norm_look_dur_labs] = ...
    normalize_by(male_values,male_labels,'scrambled');

%% normalize by saline
[norm_look_dur_sal,norm_look_dur_labs_sal] = ...
    normalize_by(storeLookingDuration,lookLabels,'saline');

%% normalize eyes:screen + mouth:screen
[roi_normed,roi_normed_labs] = ...
    normalize_by_roi(storeLookingDuration,lookLabels);

%% normalize eyes:screen + mouth:screen values by SALINE

[look_dur_roi_saline,look_dur_roi_saline_lab] = ...
    normalize_by(roi_normed,roi_normed_labs,'saline');


%% plot
[means,errors] = means_and_errors_plot(storeLookingDuration,newLabels,'saveString',[]);
% [means,errors] = means_and_errors_plot(norm_look_dur,norm_look_dur_labs,'saveString','looking_dur_normed_by_scrambled');
% [means,errors] = means_and_errors_plot(storeLookingDuration,lookLabels,'saveString','looking_dur_raw');
% [means,errors] = means_and_errors_plot(norm_look_dur_sal,norm_look_dur_labs_sal,'yLimits',[1 2]...
%     ,'saveString','looking_dur_normed_by_saline');

%% create a distribution

roi = roi_normed_labs{1};
monkeys = roi_normed_labs{2};
dose = roi_normed_labs{3};
category = roi_normed_labs{4};
session = roi_normed_labs{5};
gender = roi_normed_labs{6};
gaze = roi_normed_labs{7};
expression = roi_normed_labs{8};

nestingMatrix(1,:) = [0,0,0]; %don't nest FIRST grouping variable in anything
nestingMatrix(2,:) = [1,0,0]; %nest SECOND grouping variable in first, only
nestingMatrix(3,:) = [1,1,0]; %nest THIRD grouping variable in first AND second

[p,tbl,stats] = anovan(roi_normed,{},... %add grouping variables here
    'model','interaction','varnames',{''},'nested',nestingMatrix); %change variable names here




