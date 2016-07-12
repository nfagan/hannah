trial_vals = combined_data.trialSuccessIndex.data;
trial_labels = combined_data.trialSuccessIndex.labels;

means_and_errors_plot(trial_vals,trial_labels,'calc','sum');

%%

look_vals = combined_data.lookingDuration.data;
look_labels = combined_data.lookingDuration.labels;

means_and_errors_plot(look_vals,look_labels,'calc','mean');

%%

fix_vals = combined_data.fixEventDuration.data;
fix_labels = combined_data.fixEventDuration.labels;

means_and_errors_plot(fix_vals,fix_labels,'calc','mean');