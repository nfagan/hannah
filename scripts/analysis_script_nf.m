%% normalize by scrambled
[norm_look_dur,norm_look_dur_labs] = ...
    normalize_by(storeLookingDuration,lookLabels,'scrambled');


d = 10;

%% normalize by saline
[norm_look_dur_sal,norm_look_dur_labs_sal] = ...
    normalize_by(storeLookingDuration,lookLabels,'saline');

%% normalize eyes:screen + mouth:screen + image:screen
[roi_normed,roi_normed_labs] = ...
    normalize_by_roi(norm_look_dur,norm_look_dur_labs);

%% normalize eyes:screen + mouth:screen values by SALINE

[look_dur_roi_saline,look_dur_roi_saline_lab] = ...
    normalize_by(roi_normed,roi_normed_labs,'saline');


%% collapse across SCR norm
[gazelabels]=collapse_across({'gender','expression'},norm_look_dur_labs);
[genderlabels]=collapse_across({'gaze','expression'},norm_look_dur_labs);
[expressionlabels]=collapse_across({'gender','gaze'},norm_look_dur_labs);
[nogenderlabels]=collapse_across('gender',norm_look_dur_labs);

%collapse across RAW
[gazelabels_raw]=collapse_across({'gender','expression'},lookLabels);
[genderlabels_raw]=collapse_across({'gaze','expression'},lookLabels);
[expressionlabels_raw]=collapse_across({'gender','gaze'},lookLabels);
[nogenderlabels_raw]=collapse_across('gender',lookLabels);
 %%%total collapse
[facelabels] = collapse_across({'gender','expression','gaze'},lookLabels);

%% Remove Outdoor and Scrambled 

%scr norm
[norm_look_dur_gaze, norm_look_dur_labels_gaze] = separate_data_struct(norm_look_dur,gazelabels,'images',{'UADA','UAIA'});
[norm_look_dur_gender, norm_look_dur_labels_gender] = separate_data_struct(norm_look_dur,genderlabels,'images',{'UBAA','UGAA'});
[norm_look_dur_expression, norm_look_dur_labels_expression] = separate_data_struct(norm_look_dur,expressionlabels,'images',{'UAAT','UAAS','UAAL','UAAN'});
[norm_look_dur_nogender, norm_look_dur_labels_nogender] = separate_data_struct(norm_look_dur,nogenderlabels,'images',{'UADT','UADS','UADL','UADN','UAIT','UAIS','UAIL','UAIN'});

%raw
[norm_look_dur_gaze_raw, norm_look_dur_labels_gaze_raw] = separate_data_struct(storeLookingDuration,gazelabels_raw,'images',{'UADA','UAIA'});
[norm_look_dur_gender_raw, norm_look_dur_labels_gender_raw] = separate_data_struct(storeLookingDuration,genderlabels_raw,'images',{'UBAA','UGAA'});
[norm_look_dur_expression_raw, norm_look_dur_labels_expression_raw] = separate_data_struct(storeLookingDuration,expressionlabels_raw,'images',{'UAAT','UAAS','UAAL','UAAN'});
[norm_look_dur_nogender_raw, norm_look_dur_labels_nogender_raw] = separate_data_struct(storeLookingDuration,nogenderlabels_raw,'images',{'UADT','UADS','UADL','UADN','UAIT','UAIS','UAIL','UAIN'});

%%% Pull out individual expressions D/I with gender collapsed SCR 
[SCRthreat,SCRthreat_labs] = separate_data_struct(norm_look_dur_gaze,norm_look_dur_labels_gaze,'expressions',{'T'});
[SCRneutral,SCRneutral_labs] = separate_data_struct(norm_look_dur_gaze,norm_look_dur_labels_gaze,'expressions',{'N'});
[SCRLS,SCRLS_labs] = separate_data_struct(norm_look_dur_gaze,norm_look_dur_labels_gaze,'expressions',{'L'});
[SCRFG,SCRFG_labs] = separate_data_struct(norm_look_dur_gaze,norm_look_dur_labels_gaze,'expressions',{'S'});

%%% Pull out individual expressions D/I with gender collapsed raw 
[rawthreat,rawthreat_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'T'});
[rawneutral,rawneutral_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'N'});
[rawLS,rawLS_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'L'});
[rawFG,rawFG_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'S'});

%Pull out by dose
[rawsaline,rawsaline_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'saline'});
[rawlow,rawlow_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'low'});
[rawhigh,rawhigh_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'high'});

%Pull out complted trials by dose
[rawsaline_num,rawsaline_num_labs] = separate_data_struct(storeNSuccessfulTrials,trialLabels,'doses',{'saline'});
[rawlow_num,rawlow_num_labs] = separate_data_struct(storeNSuccessfulTrials,trialLabels,'doses',{'low'});
[rawhigh_num,rawhigh_num_labs] = separate_data_struct(storeNSuccessfulTrials,trialLabels,'doses',{'high'});
%% plot
%SCRnormgaze
[means,errors] = means_and_errors_plot(norm_look_dur_gaze,norm_look_dur_labels_gaze, ...
    'yLabel','Looking Duration normalized within session by scrambled images','yLimits',[0 4],'xtickLabel',{'Directed','Averted'});
%SCRnormgender
[means,errors] = means_and_errors_plot(norm_look_dur_gender,norm_look_dur_labels_gender, ...
    'yLabel','Looking Duration normalized within session by scrambled images','yLimits',[0 4],'xtickLabel',{'Male','Female'});
%SCRnormexpression
[means,errors] = means_and_errors_plot(norm_look_dur_expression,norm_look_dur_labels_expression, ...
    'yLabel','Looking Duration normalized within session by scrambled images','yLimits',[0 4],'xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'});
%SCRnormnogender
[means,errors] = means_and_errors_plot(norm_look_dur_nogender,norm_look_dur_labels_nogender, ...
    'yLabel','Looking Duration normalized within session by scrambled images','yLimits',[0 4],'xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'});

%SCRnorm EXPRESSION
%scrnorm threat
[means,errors] = means_and_errors_plot(SCRthreat,SCRthreat_labs, ...
    'yLabel','Looking Duration normalized within session by scrambled images', 'yLimits',[0 3],'xtickLabel', {'Directed Threat','Averted Threat'});
%scrnorm neutral
[means,errors] = means_and_errors_plot(SCRneutral,SCRneutral_labs, ...
    'yLabel','Looking Duration normalized within session by scrambled images', 'yLimits',[0 3],'xtickLabel', {'Directed Neutral','Averted Neutral'});
%scrnorm LS
[means,errors] = means_and_errors_plot(SCRLS,SCRLS_labs, ...
    'yLabel','Looking Duration normalized within session by scrambled images', 'yLimits',[0 2],'xtickLabel', {'Directed Lip Smack','Averted Lip Smack'});
%scrnorm FG
[means,errors] = means_and_errors_plot(SCRFG,SCRFG_labs, ...
    'yLabel','Looking Duration normalized within session by scrambled images', 'yLimits',[0 3],'xtickLabel', {'Directed Fear Grimace','Averted Fear Grimace'});

%scrnorm all
[means,errors] = means_and_errors_plot(norm_look_dur,norm_look_dur_labs, ...
    'yLabel','Looking Duration normalized within session by scrambled images','xtickLabel', {'Directed Fear Grimace','Averted Fear Grimace'});


%%number of completed trials
[means,errors] = means_and_errors_plot(storeNSuccessfulTrials,triallabels,'yLabel','Completed Trials','xLabel','Drug Dose','title','Average Trials Completed per Session','xtickLabel',' ');

%RAWgaze
[means,errors] = means_and_errors_plot(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw, ...
    'yLabel','Looking Duration','xtickLabel',{'Directed','Averted'});
%RAWgender
[means,errors] = means_and_errors_plot(norm_look_dur_gender_raw,norm_look_dur_labels_gender_raw, ...
    'yLabel','Looking Duration','xtickLabel',{'Male','Female'});
%RAWexpression
[means,errors] = means_and_errors_plot(norm_look_dur_expression_raw,norm_look_dur_labels_expression_raw, ...
    'yLabel','Looking Duration','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'});
%RAWnogender
[means,errors] = means_and_errors_plot(norm_look_dur_nogender_raw,norm_look_dur_labels_nogender_raw, ...
    'yLabel','Looking Duration','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'});

%RAWall
[means,errors] = means_and_errors_plot(storeLookingDuration, lookLabels, ...
    'yLabel','Looking Duration');


%%%%look at raw looking time across social and non social stimuli
[means,errors] = means_and_errors_plot(storeLookingDuration,facelabels, 'xtickLabel', {'Landscapes','Scrambled','Faces'});

% [means,errors] = means_and_errors_plot(roi_normed,roi_normed_labs,'saveString','looking_dur_normed_by_scrambled_and_roi_screen');
% [means,errors] = means_and_errors_plot(norm_look_dur,norm_look_dur_labs,'saveString','looking_dur_normed_by_scrambled');
% [means,errors] = means_and_errors_plot(storeLookingDuration,lookLabels,'saveString','looking_dur_raw');
% [means,errors] = means_and_errors_plot(norm_look_dur_sal,norm_look_dur_labs_sal,'yLimits',[1 2]...
%     ,'saveString','looking_dur_normed_by_saline');

%% Time Course

[rawsaline,rawsaline_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'saline'});
[rawlow,rawlow_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'low'});
[rawhigh,rawhigh_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'high'});

time_course(rawsaline,rawsaline_labs,start_times);
time_course(rawlow,rawlow_labs,start_times);
time_course(rawhigh,rawhigh_labs,start_times);
