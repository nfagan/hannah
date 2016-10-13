%% anova script -- define which roi to use

[norm_look_roi,norm_look_roi_labels] = ...
    separate_data_hannah(norm_look_dur,norm_look_dur_labs,'rois',{'image'});

[raw_look_roi,raw_look_roi_labels] = ...
    separate_data_hannah(storeLookingDuration,lookLabels,'rois',{'image'});

%% -- isolate outdoors + scrambled images

allImages = unique(norm_look_roi_labels.images);
allImages = allImages(~(strcmp(allImages,'Out') | strcmp(allImages,'Scr')));

allImages_raw = unique(look_roi_labels.images);
allImages_raw = allImages_raw(~(strcmp(allImages_raw,'Out') | strcmp(allImages_raw,'Scr')));

outImages = unique(lookLabels.images);
outImages = outImages((strcmp(outImages,'Out')));

scrImages = unique(lookLabels.images);
scrImages = scrImages((strcmp(scrImages,'Scr')));

[norm_look_roi,norm_look_roi_labels] = ...
    separate_data_hannah(norm_look_roi,norm_look_roi_labels,'images',allImages);

[raw_look_roi,raw_look_roi_labels] = ...
    separate_data_hannah(raw_look_roi,raw_look_roi_labels,'images',allImages);

[look_roi,look_roi_labels] = ...
    separate_data_hannah(storeLookingDuration,lookLabels,'images',allImages_raw);

[look_roi_out,look_roi_labels_out] = ...
    separate_data_hannah(storeLookingDuration,lookLabels,'images',outImages);

[look_roi_scr,look_roi_labels_scr] = ...
    separate_data_hannah(storeLookingDuration,lookLabels,'images',scrImages);


%% separate by expression type
[threat,threatLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'expressions',{'T'});
[threat_d,threatLabels_d] = separate_data_hannah(threat,threatLabels,'gazes',{'direct'});
[threat_i,threatLabels_i] = separate_data_hannah(threat,threatLabels,'gazes',{'indirect'});

[lipsmack,lipsmackLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'expressions',{'L'});
[lipsmack_d,lipsmackLabels_d] = separate_data_hannah(lipsmack,lipsmackLabels,'gazes',{'direct'});
[lipsmack_i,lipsmackLabels_i] = separate_data_hannah(lipsmack,lipsmackLabels,'gazes',{'indirect'});

[sub,subLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'expressions',{'S'});
[sub_d,subLabels_d] = separate_data_hannah(sub,subLabels,'gazes',{'direct'});
[sub_i,subLabels_i] = separate_data_hannah(sub,subLabels,'gazes',{'indirect'});

[neutral,neutralLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'expressions',{'N'});
[neutral_d,neutralLabels_d] = separate_data_hannah(neutral,neutralLabels,'gazes',{'direct'});
[neutral_i,neutralLabels_i] = separate_data_hannah(neutral,neutralLabels,'gazes',{'indirect'});

%% separate by gaze type
[direct,directLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'gazes',{'direct'});
[indirect,indirectLabels] = separate_data_hannah(norm_look_roi,norm_look_roi_labels,'gazes',{'indirect'});

%% -- pull out grouping variables (for legibility) + create nesting matrix

% %all not separated scr norm
% roi = norm_look_roi_labels.rois;
% monkeys = norm_look_roi_labels.monkeys;
% dose = norm_look_roi_labels.dose;
% category = norm_look_roi_labels.images;
% session = norm_look_roi_labels.sessions;
% gender = norm_look_roi_labels.genders;
% gaze = norm_look_roi_labels.gazes;
% expression = norm_look_roi_labels.expressions;

% %all not separated raw
% roi = raw_look_roi_labels.rois;
% monkeys = raw_look_roi_labels.monkeys;
% dose = raw_look_roi_labels.dose;
% category = raw_look_roi_labels.images;
% session = raw_look_roi_labels.sessions;
% gender = raw_look_roi_labels.genders;
% gaze = raw_look_roi_labels.gazes;
% expression = raw_look_roi_labels.expressions;

% %RAW FACES
% roi = look_roi_labels.rois;
% monkeys = look_roi_labels.monkeys;
% dose = look_roi_labels.dose;
% category = look_roi_labels.images;
% session = look_roi_labels.sessions;
% gender = look_roi_labels.genders;
% gaze = look_roi_labels.gazes;
% expression = look_roi_labels.expressions;

% %RAW OUT
% roi = look_roi_labels_out.rois;
% monkeys = look_roi_labels_out.monkeys;
% dose = look_roi_labels_out.dose;
% category = look_roi_labels_out.images;
% session = look_roi_labels_out.sessions;
% gender = look_roi_labels_out.genders;
% gaze = look_roi_labels_out.gazes;
% expression = look_roi_labels_out.expressions;

%RAW SCR
roi = look_roi_labels_scr.rois;
monkeys = look_roi_labels_scr.monkeys;
dose = look_roi_labels_scr.dose;
category = look_roi_labels_scr.images;
session = look_roi_labels_scr.sessions;
gender = look_roi_labels_scr.genders;
gaze = look_roi_labels_scr.gazes;
expression = look_roi_labels_scr.expressions;

% %NUMBER OF TRIALS
% roi = triallabels_all.rois;
% monkeys = triallabels_all.monkeys;
% dose = triallabels_all.dose;
% category = triallabels_all.images;
% session = triallabels_all.sessions;
% gender = triallabels_all.genders;
% gaze = triallabels_all.gazes;
% expression = triallabels_all.expressions;

% %threat
% roi = threatLabels.rois;
% monkeys = threatLabels.monkeys;
% dose = threatLabels.dose;
% category = threatLabels.images;
% session = threatLabels.sessions;
% gender = threatLabels.genders;
% gaze = threatLabels.gazes;
% expression = threatLabels.expressions;

% %threat direct
% roi = threatLabels_d.rois;
% monkeys = threatLabels_d.monkeys;
% dose = threatLabels_d.dose;
% category = threatLabels_d.images;
% session = threatLabels_d.sessions;
% gender = threatLabels_d.genders;
% gaze = threatLabels_d.gazes;
% expression = threatLabels_d.expressions;

% %threat indirect
% roi = threatLabels_i.rois;
% monkeys = threatLabels_i.monkeys;
% dose = threatLabels_i.dose;
% category = threatLabels_i.images;
% session = threatLabels_i.sessions;
% gender = threatLabels_i.genders;
% gaze = threatLabels_i.gazes;
% expression = threatLabels_i.expressions;

%LS
% roi = lipsmackLabels.rois;
% monkeys = lipsmackLabels.monkeys;
% dose = lipsmackLabels.dose;
% category = lipsmackLabels.images;
% session = lipsmackLabels.sessions;
% gender = lipsmackLabels.genders;
% gaze = lipsmackLabels.gazes;
% expression = lipsmackLabels.expressions;

% %LS_d
% roi = lipsmackLabels_d.rois;
% monkeys = lipsmackLabels_d.monkeys;
% dose = lipsmackLabels_d.dose;
% category = lipsmackLabels_d.images;
% session = lipsmackLabels_d.sessions;
% gender = lipsmackLabels_d.genders;
% gaze = lipsmackLabels_d.gazes;
% expression = lipsmackLabels_d.expressions;

%LS_i
% roi = lipsmackLabels_i.rois;
% monkeys = lipsmackLabels_i.monkeys;
% dose = lipsmackLabels_i.dose;
% category = lipsmackLabels_i.images;
% session = lipsmackLabels_i.sessions;
% gender = lipsmackLabels_i.genders;
% gaze = lipsmackLabels_i.gazes;
% expression = lipsmackLabels_i.expressions;

% %FG
% roi = subLabels.rois;
% monkeys = subLabels.monkeys;
% dose = subLabels.dose;
% category = subLabels.images;
% session = subLabels.sessions;
% gender = subLabels.genders;
% gaze = subLabels.gazes;
% expression = subLabels.expressions;

% %FG direct
% roi = subLabels_d.rois;
% monkeys = subLabels_d.monkeys;
% dose = subLabels_d.dose;
% category = subLabels_d.images;
% session = subLabels_d.sessions;
% gender = subLabels_d.genders;
% gaze = subLabels_d.gazes;
% expression = subLabels_d.expressions;

% %FG averted
% roi = subLabels_i.rois;
% monkeys = subLabels_i.monkeys;
% dose = subLabels_i.dose;
% category = subLabels_i.images;
% session = subLabels_i.sessions;
% gender = subLabels_i.genders;
% gaze = subLabels_i.gazes;
% expression = subLabels_i.expressions;

% %Neutral
% roi = neutralLabels.rois;
% monkeys = neutralLabels.monkeys;
% dose = neutralLabels.dose;
% category = neutralLabels.images;
% session = neutralLabels.sessions;
% gender = neutralLabels.genders;
% gaze = neutralLabels.gazes;
% expression = neutralLabels.expressions;

% %Neutral Direct
% roi = neutralLabels_d.rois;
% monkeys = neutralLabels_d.monkeys;
% dose = neutralLabels_d.dose;
% category = neutralLabels_d.images;
% session = neutralLabels_d.sessions;
% gender = neutralLabels_d.genders;
% gaze = neutralLabels_d.gazes;
% expression = neutralLabels_d.expressions;

%Neutral Indirect
% roi = neutralLabels_i.rois;
% monkeys = neutralLabels_i.monkeys;
% dose = neutralLabels_i.dose;
% category = neutralLabels_i.images;
% session = neutralLabels_i.sessions;
% gender = neutralLabels_i.genders;
% gaze = neutralLabels_i.gazes;
% expression = neutralLabels_i.expressions;

% %Direct
% roi = directLabels.rois;
% monkeys = directLabels.monkeys;
% dose = directLabels.dose;
% category = directLabels.images;
% session = directLabels.sessions;
% gender = directLabels.genders;
% gaze = directLabels.gazes;
% expression = directLabels.expressions;

% %Indirect
% roi = indirectLabels.rois;
% monkeys = indirectLabels.monkeys;
% dose = indirectLabels.dose;
% category = indirectLabels.images;
% session = indirectLabels.sessions;
% gender = indirectLabels.genders;
% gaze = indirectLabels.gazes;
% expression = indirectLabels.expressions;

nestingMatrix(1,:) = [0,0,0,0]; %don't nest FIRST grouping variable in anything              - dose
nestingMatrix(2,:) = [1,0,0,0]; %nest SECOND grouping variable in first, only                - expression
nestingMatrix(3,:) = [1,1,0,0]; %nest THIRD grouping variable in first AND second            - gaze
nestingMatrix(4,:) = [1,1,1,0]; %nest Fourth grouping variable in first AND second AND third - gender

% Number of completed trials
% [p_num, tbl_num, stats_num] = anovan(completetrials_all,{dose},'model','full','varnames',{'Dose'});
% [test_num] = multcompare(stats_num,'dimension',[1],'CType','hsd');

%% run anova

% % OVERALL NORMALIZED ANOVA (2x3x4)
%  [p,tbl,stats] = anovan(norm_look_roi,{dose,expression,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Expression','Gaze'}); %change variable names here

% [test_scr] = multcompare(stats,'dimension',[1,2,3],'CType','hsd');

% % OVERALL NORMALIZED ANOVA (2x3x4)
%  [p_face_scr,tbl_face_scr,stats_face_scr] = anovan(norm_look_roi,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_face_scr] = multcompare(stats_face_scr,'dimension',[1],'CType','hsd');

% % OVERALL RAW ANOVA (2x3x4)
%   [p,tbl,stats] = anovan(norm_look_roi,{dose,expression,gaze},... %add grouping variables here
%      'model','full','varnames',{'Dose','Expression','Gaze'}); %change variable names here

% % JUST DOSE FACE -- RAW (1x3)
% [p_face,tbl_face,stats_face] = anovan(look_roi,{dose},'model','full','varnames',{'Dose'});
% [test_face] = multcompare(stats_face,'dimension',[1],'CType','hsd');

% % JUST DOSE OUT
% [p_out,tbl_out,stats_out] = anovan(look_roi_out,{dose},'model','full','varnames',{'Dose'});
% [test_out] = multcompare(stats_out,'dimension',[1],'CType','hsd');

% JUST DOSE SCR
[p_scr,tbl_scr,stats_scr] = anovan(look_roi_scr,{dose},'model','full','varnames',{'Dose'});
[test_scr] = multcompare(stats_scr,'dimension',[1],'CType','hsd');

% dose and expression anova
% [p_e,tbl_e,stats_e] = anovan(norm_look_roi,{dose,expression},... %add grouping variables here
%     'model','full','varnames',{'Dose','Expression'}); %change variable names here
% 
% [test_e] = multcompare(stats_e,'dimension',[1,2],'CType','hsd');

% % dose and gaze anova
% [p_g,tbl_g,stats_g] = anovan(norm_look_roi,{dose,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Gaze'}); %change variable names here
% 
% [test_g] = multcompare(stats_g,'dimension',[1,2],'CType','hsd');

% % threat anova
% [p_t,tbl_t,stats_t] = anovan(threat,{dose,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Gaze'}); %change variable names here
% 
% [test_t] = multcompare(stats_t,'dimension',[1,2],'CType','lsd');

% threat anova direct
% [p_td,tbl_td,stats_td] = anovan(threat_d,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_td] = multcompare(stats_td,'dimension',[1],'CType','hsd');

% % threat anova indirect
% [p_ti,tbl_ti,stats_ti] = anovan(threat_i,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_ti] = multcompare(stats_ti,'dimension',[1],'CType','hsd');

% %LS anova
% [p_l,tbl_l,stats_l] = anovan(lipsmack,{dose,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Gaze'}); %change variable names here
% 
% [test_l] = multcompare(stats_l,'dimension',[1,2],'CType','hsd');

% %LS anova direct
% [p_ld,tbl_ld,stats_ld] = anovan(lipsmack_d,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_ld] = multcompare(stats_ld,'dimension',[1],'CType','hsd');

% %LS anova indirect
% [p_li,tbl_li,stats_li] = anovan(lipsmack_i,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_li] = multcompare(stats_li,'dimension',[1],'CType','hsd');

% %FG anova
% [p_s,tbl_s,stats_s] = anovan(sub,{dose,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Gaze'}); %change variable names here
% 
% [test_s] = multcompare(stats_s,'dimension',[1,2],'CType','hsd');

% %FG anova direct
% [p_sd,tbl_sd,stats_sd] = anovan(sub_d,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_sd] = multcompare(stats_sd,'dimension',[1],'CType','hsd');

% %FG anova indirect
% [p_si,tbl_si,stats_si] = anovan(sub_i,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_si] = multcompare(stats_si,'dimension',[1],'CType','hsd');

%neutral anova
% [p_n,tbl_n,stats_n] = anovan(neutral,{dose,gaze},... %add grouping variables here
%     'model','full','varnames',{'Dose','Gaze'}); %change variable names here
% 
% [test_n] = multcompare(stats_n,'dimension',[1,2],'CType','hsd');

% %neutral anova direct
% [p_nd,tbl_nd,stats_nd] = anovan(neutral_d,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_nd] = multcompare(stats_nd,'dimension',[1],'CType','hsd');

% %neutral anova indirect
% [p_ni,tbl_ni,stats_ni] = anovan(neutral_i,{dose},... %add grouping variables here
%     'model','full','varnames',{'Dose'}); %change variable names here
% 
% [test_ni] = multcompare(stats_ni,'dimension',[1],'CType','hsd');

%direct anova
% [p_d,tbl_d,stats_d] = anovan(direct,{dose,expression},... %add grouping variables here
%     'model','full','varnames',{'Dose','Expression'}); %change variable names here
% 
% [test_d] = multcompare(stats_d,'dimension',[1,2],'CType','hsd');

%indirect anova
% [p_i,tbl_i,stats_i] = anovan(indirect,{dose,expression},... %add grouping variables here
%     'model','full','varnames',{'Dose','Expression'}); %change variable names here
% 
% [test_i] = multcompare(stats_i,'dimension',[1,2],'CType','hsd');



