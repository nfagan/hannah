%% anova script -- define which roi to use

[norm_look_roi,norm_look_roi_labels] = ...
    separate_data_hannah(norm_look_dur,norm_look_dur_labs,'rois',{'image'});

[raw_look_roi,raw_look_roi_labels] = ...
    separate_data_hannah(storeLookingDuration,lookLabels,'rois',{'image'});

%% -- isolate outdoors + scrambled images

allImages = unique(norm_look_roi_labels{4});
allImages = allImages(~(strcmp(allImages,'Out') | strcmp(allImages,'Scr')));

allImages_raw = unique(look_roi_labels{4});
allImages_raw = allImages_raw(~(strcmp(allImages_raw,'Out') | strcmp(allImages_raw,'Scr')));

outImages = unique(lookLabels{4});
outImages = outImages((strcmp(outImages,'Out')));

scrImages = unique(lookLabels{4});
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
% roi = norm_look_roi_labels{1};
% monkeys = norm_look_roi_labels{2};
% dose = norm_look_roi_labels{3};
% category = norm_look_roi_labels{4};
% session = norm_look_roi_labels{5};
% gender = norm_look_roi_labels{6};
% gaze = norm_look_roi_labels{7};
% expression = norm_look_roi_labels{8};

% %all not separated raw
% roi = raw_look_roi_labels{1};
% monkeys = raw_look_roi_labels{2};
% dose = raw_look_roi_labels{3};
% category = raw_look_roi_labels{4};
% session = raw_look_roi_labels{5};
% gender = raw_look_roi_labels{6};
% gaze = raw_look_roi_labels{7};
% expression = raw_look_roi_labels{8};

% %RAW FACES
% roi = look_roi_labels{1};
% monkeys = look_roi_labels{2};
% dose = look_roi_labels{3};
% category = look_roi_labels{4};
% session = look_roi_labels{5};
% gender = look_roi_labels{6};
% gaze = look_roi_labels{7};
% expression = look_roi_labels{8};

% %RAW OUT
% roi = look_roi_labels_out{1};
% monkeys = look_roi_labels_out{2};
% dose = look_roi_labels_out{3};
% category = look_roi_labels_out{4};
% session = look_roi_labels_out{5};
% gender = look_roi_labels_out{6};
% gaze = look_roi_labels_out{7};
% expression = look_roi_labels_out{8};

%RAW SCR
roi = look_roi_labels_scr{1};
monkeys = look_roi_labels_scr{2};
dose = look_roi_labels_scr{3};
category = look_roi_labels_scr{4};
session = look_roi_labels_scr{5};
gender = look_roi_labels_scr{6};
gaze = look_roi_labels_scr{7};
expression = look_roi_labels_scr{8};

% %NUMBER OF TRIALS
% roi = triallabels_all{1};
% monkeys = triallabels_all{2};
% dose = triallabels_all{3};
% category = triallabels_all{4};
% session = triallabels_all{5};
% gender = triallabels_all{6};
% gaze = triallabels_all{7};
% expression = triallabels_all{8};

% %threat
% roi = threatLabels{1};
% monkeys = threatLabels{2};
% dose = threatLabels{3};
% category = threatLabels{4};
% session = threatLabels{5};
% gender = threatLabels{6};
% gaze = threatLabels{7};
% expression = threatLabels{8};

% %threat direct
% roi = threatLabels_d{1};
% monkeys = threatLabels_d{2};
% dose = threatLabels_d{3};
% category = threatLabels_d{4};
% session = threatLabels_d{5};
% gender = threatLabels_d{6};
% gaze = threatLabels_d{7};
% expression = threatLabels_d{8};

% %threat indirect
% roi = threatLabels_i{1};
% monkeys = threatLabels_i{2};
% dose = threatLabels_i{3};
% category = threatLabels_i{4};
% session = threatLabels_i{5};
% gender = threatLabels_i{6};
% gaze = threatLabels_i{7};
% expression = threatLabels_i{8};

%LS
% roi = lipsmackLabels{1};
% monkeys = lipsmackLabels{2};
% dose = lipsmackLabels{3};
% category = lipsmackLabels{4};
% session = lipsmackLabels{5};
% gender = lipsmackLabels{6};
% gaze = lipsmackLabels{7};
% expression = lipsmackLabels{8};

% %LS_d
% roi = lipsmackLabels_d{1};
% monkeys = lipsmackLabels_d{2};
% dose = lipsmackLabels_d{3};
% category = lipsmackLabels_d{4};
% session = lipsmackLabels_d{5};
% gender = lipsmackLabels_d{6};
% gaze = lipsmackLabels_d{7};
% expression = lipsmackLabels_d{8};

%LS_i
% roi = lipsmackLabels_i{1};
% monkeys = lipsmackLabels_i{2};
% dose = lipsmackLabels_i{3};
% category = lipsmackLabels_i{4};
% session = lipsmackLabels_i{5};
% gender = lipsmackLabels_i{6};
% gaze = lipsmackLabels_i{7};
% expression = lipsmackLabels_i{8};

% %FG
% roi = subLabels{1};
% monkeys = subLabels{2};
% dose = subLabels{3};
% category = subLabels{4};
% session = subLabels{5};
% gender = subLabels{6};
% gaze = subLabels{7};
% expression = subLabels{8};

% %FG direct
% roi = subLabels_d{1};
% monkeys = subLabels_d{2};
% dose = subLabels_d{3};
% category = subLabels_d{4};
% session = subLabels_d{5};
% gender = subLabels_d{6};
% gaze = subLabels_d{7};
% expression = subLabels_d{8};

% %FG averted
% roi = subLabels_i{1};
% monkeys = subLabels_i{2};
% dose = subLabels_i{3};
% category = subLabels_i{4};
% session = subLabels_i{5};
% gender = subLabels_i{6};
% gaze = subLabels_i{7};
% expression = subLabels_i{8};

% %Neutral
% roi = neutralLabels{1};
% monkeys = neutralLabels{2};
% dose = neutralLabels{3};
% category = neutralLabels{4};
% session = neutralLabels{5};
% gender = neutralLabels{6};
% gaze = neutralLabels{7};
% expression = neutralLabels{8};

% %Neutral Direct
% roi = neutralLabels_d{1};
% monkeys = neutralLabels_d{2};
% dose = neutralLabels_d{3};
% category = neutralLabels_d{4};
% session = neutralLabels_d{5};
% gender = neutralLabels_d{6};
% gaze = neutralLabels_d{7};
% expression = neutralLabels_d{8};

%Neutral Indirect
% roi = neutralLabels_i{1};
% monkeys = neutralLabels_i{2};
% dose = neutralLabels_i{3};
% category = neutralLabels_i{4};
% session = neutralLabels_i{5};
% gender = neutralLabels_i{6};
% gaze = neutralLabels_i{7};
% expression = neutralLabels_i{8};

% %Direct
% roi = directLabels{1};
% monkeys = directLabels{2};
% dose = directLabels{3};
% category = directLabels{4};
% session = directLabels{5};
% gender = directLabels{6};
% gaze = directLabels{7};
% expression = directLabels{8};

% %Indirect
% roi = indirectLabels{1};
% monkeys = indirectLabels{2};
% dose = indirectLabels{3};
% category = indirectLabels{4};
% session = indirectLabels{5};
% gender = indirectLabels{6};
% gaze = indirectLabels{7};
% expression = indirectLabels{8};

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



