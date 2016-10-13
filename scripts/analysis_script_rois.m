%% Load Data
mat_files = dir('*.mat');

for i = 1:length(mat_files);
    filename = mat_files(i).name;
    sans_extension = fliplr(filename);
    sans_extension = fliplr(sans_extension(5:end)); % get rid of .mat extension
    load(filename);
    combined_data.(sans_extension) = save_field;
end

%% Change Data Object to Structure
% only necessary if combined_data was obtained from data_acquisition_script

data_object_fields = fieldnames(data_objects);

combined_data_structs = struct();
for i = 1:length(data_object_fields)
    combined_data_structs.(data_object_fields{i}) = obj2struct(data_objects.(data_object_fields{i}));
end

combined_data = combined_data_structs;

%% Fix syntax 
combined_data.lookingDuration = combined_data.looking_duration;
combined_data.trialSuccessIndex = combined_data.successful_trial;
combined_data.fixEventDuration = combined_data.fix_event_duration;
combined_data.nFixations = combined_data.n_fixations;

%% Parse Individual Labels from Combined Data
lookLabels = combined_data.lookingDuration.labels;
storeLookingDuration = combined_data.lookingDuration.data;
successLabels = combined_data.trialSuccessIndex.labels;
storeNSuccessfulTrials = combined_data.trialSuccessIndex.data;
fixdurLabels = combined_data.fixEventDuration.labels;
storeFixDuration = combined_data.fixEventDuration.data;
fixnumLabels = combined_data.nFixations.labels;
storeFixNum = combined_data.nFixations.data;
pupil_size_labels = combined_data.pupil_size.labels;
pupil_size_data = combined_data.pupil_size.data;

%% Separate by Subject
current_monkey = 'kubrick';
[storeLookingDuration,lookLabels] = separate_data_struct(storeLookingDuration,lookLabels,'monkeys',{current_monkey});
[storeNSuccessfulTrials,successLabels] = separate_data_struct(storeNSuccessfulTrials,successLabels,'monkeys',{current_monkey});
[storeFixDuration,fixdurLabels] = separate_data_struct(storeFixDuration,fixdurLabels,'monkeys',{current_monkey});
[storeFixNum,fixnumLabels] = separate_data_struct(storeFixNum,fixnumLabels,'monkeys',{current_monkey});
[pupil_size_data, pupil_size_labels] = separate_data_struct(pupil_size_data, pupil_size_labels,'monkeys',{current_monkey});

%% collapse across different categories looking duration
[gazelabels_raw]=collapse_across({'gender','expression'},lookLabels);
[genderlabels_raw]=collapse_across({'gaze','expression'},lookLabels);
[expressionlabels_raw]=collapse_across({'gender','gaze'},lookLabels);
[nogenderlabels_raw]=collapse_across('gender',lookLabels);
 %%%total collapse
[facelabels] = collapse_across({'gender','expression','gaze'},lookLabels);

%%% collapse across different categories fixation duration
[gazelabels_raw_fixdur]=collapse_across({'gender','expression'},fixdurLabels);
[genderlabels_raw_fixdur]=collapse_across({'gaze','expression'},fixdurLabels);
[expressionlabels_raw_fixdur]=collapse_across({'gender','gaze'},fixdurLabels);
[nogenderlabels_raw_fixdur]=collapse_across('gender',fixdurLabels);
 %%%total collapse
[facelabels_fixdur] = collapse_across({'gender','expression','gaze'},fixdurLabels);

%%% collapse across different categories fixation number
[gazelabels_raw_fixnum]=collapse_across({'gender','expression'},fixnumLabels);
[genderlabels_raw_fixnum]=collapse_across({'gaze','expression'},fixnumLabels);
[expressionlabels_raw_fixnum]=collapse_across({'gender','gaze'},fixnumLabels);
[nogenderlabels_raw_fixnum]=collapse_across('gender',fixnumLabels);
 %%%total collapse
[facelabels_fixnum] = collapse_across({'gender','expression','gaze'},fixnumLabels);

%%% collapse across different categories successful trials
%total collapse
[facelabels_success] = collapse_across({'gender','expression','gaze'},successLabels);
[all_images] = collapse_across({'all'},successLabels);
[all_images_pupil] = collapse_across({'all'},pupil_size_labels);

%% Remove Outdoor and Scrambled Looking Duration
%raw
[norm_look_dur_gaze_raw, norm_look_dur_labels_gaze_raw] = separate_data_struct(storeLookingDuration,gazelabels_raw,'images',{'uada','uaia'});
[norm_look_dur_gender_raw, norm_look_dur_labels_gender_raw] = separate_data_struct(storeLookingDuration,genderlabels_raw,'images',{'UBAA','UGAA'});
[norm_look_dur_expression_raw, norm_look_dur_labels_expression_raw] = separate_data_struct(storeLookingDuration,expressionlabels_raw,'images',{'UAAT','UAAS','UAAL','UAAN'});
[norm_look_dur_nogender_raw, norm_look_dur_labels_nogender_raw] = separate_data_struct(storeLookingDuration,nogenderlabels_raw,'images',{'UADT','UADS','UADL','UADN','UAIT','UAIS','UAIL','UAIN'});

[raw_no_out, raw_now_out_labs] = separate_data_struct(storeLookingDuration, lookLabels,'images', {'--outdoors'});
[raw_faces, raw_faces_labs] = separate_data_struct(raw_no_out, raw_now_out_labs,'images', {'--scrambled'});

%%% Remove Outdoor and Scrambled Fixation Duration
%raw
[norm_look_dur_gaze_raw_fixdur, norm_look_dur_labels_gaze_raw_fixdur] = separate_data_struct(storeFixDuration,gazelabels_raw_fixdur,'images',{'uada','uaia'});
[norm_look_dur_gender_raw_fixdur, norm_look_dur_labels_gender_raw_fixdur] = separate_data_struct(storeFixDuration,genderlabels_raw_fixdur,'images',{'UBAA','UGAA'});
[norm_look_dur_expression_raw_fixdur, norm_look_dur_labels_expression_raw_fixdur] = separate_data_struct(storeFixDuration,expressionlabels_raw_fixdur,'images',{'UAAT','UAAS','UAAL','UAAN'});
[norm_look_dur_nogender_raw_fixdur, norm_look_dur_labels_nogender_raw_fixdur] = separate_data_struct(storeFixDuration,nogenderlabels_raw_fixdur,'images',{'UADT','UADS','UADL','UADN','UAIT','UAIS','UAIL','UAIN'});

[raw_no_out_fixdur, raw_now_out_labs_fixdur] = separate_data_struct(storeFixDuration, fixdurLabels,'images', {'--outdoors'});
[raw_faces_fixdur, raw_faces_labs_fixdur] = separate_data_struct(raw_no_out_fixdur, raw_now_out_labs_fixdur,'images', {'--scrambled'});

%%% Remove Outdoor and Scrambled Fixation Number
%raw
[norm_look_dur_gaze_raw_fixnum, norm_look_dur_labels_gaze_raw_fixnum] = separate_data_struct(storeFixNum,gazelabels_raw_fixnum,'images',{'uada','uaia'});
[norm_look_dur_gender_raw_fixnum, norm_look_dur_labels_gender_raw_fixnum] = separate_data_struct(storeFixNum,genderlabels_raw_fixnum,'images',{'UBAA','UGAA'});
[norm_look_dur_expression_raw_fixnum, norm_look_dur_labels_expression_raw_fixnum] = separate_data_struct(storeFixNum,expressionlabels_raw_fixnum,'images',{'UAAT','UAAS','UAAL','UAAN'});
[norm_look_dur_nogender_raw_fixnum, norm_look_dur_labels_nogender_raw_fixnum] = separate_data_struct(storeFixNum,nogenderlabels_raw_fixnum,'images',{'UADT','UADS','UADL','UADN','UAIT','UAIS','UAIL','UAIN'});

[raw_no_out_fixnum, raw_now_out_labs_fixnum] = separate_data_struct(storeFixNum, fixnumLabels,'images', {'--outdoors'});
[raw_faces_fixnum, raw_faces_labs_fixnum] = separate_data_struct(raw_no_out_fixnum, raw_now_out_labs_fixnum,'images', {'--scrambled'});

%% Normalize by ROI Looking Duration
eyes_by_face = normalize_roi_to_roi('eyes','face',raw_faces,raw_faces_labs);
mouth_by_face = normalize_roi_to_roi('mouth','face',raw_faces,raw_faces_labs);
face_by_image = normalize_roi_to_roi('face','image',raw_faces,raw_faces_labs);
eye_to_mouth = normalize_roi_to_roi('eyes','mouth',raw_faces,raw_faces_labs);

%%   new face

face_by_size = normalize_roi_to_image('face',raw_faces,raw_faces_labs);

%% Normalize by ROI Fixation Number
eyes_by_face_fixnum = normalize_roi_to_roi('eyes','face',raw_faces_fixnum,raw_faces_labs_fixnum);
mouth_by_face_fixnum = normalize_roi_to_roi('mouth','face',raw_faces_fixnum,raw_faces_labs_fixnum);
face_by_image_fixnum = normalize_roi_to_roi('face','image',raw_faces_fixnum,raw_faces_labs_fixnum);
eye_to_mouth_fixnum = normalize_roi_to_roi('eyes','mouth',raw_faces_fixnum,raw_faces_labs_fixnum);

%% collapse across different categories for eyes and mouth
[gazelabels_face]=collapse_across({'gender','expression'},raw_faces_labs);
[genderlabels_face]=collapse_across({'gaze','expression'},raw_faces_labs);
[expressionlabels_face]=collapse_across({'gender','gaze'},raw_faces_labs);
[nogenderlabels_face]=collapse_across('gender',raw_faces_labs);

%%% collapse across different categories for eyes and mouth fixation duration
[gazelabels_face_fixdur]=collapse_across({'gender','expression'},raw_faces_labs_fixdur);
[genderlabels_face_fixdur]=collapse_across({'gaze','expression'},raw_faces_labs_fixdur);
[expressionlabels_face_fixdur]=collapse_across({'gender','gaze'},raw_faces_labs_fixdur);
[nogenderlabels_face_fixdur]=collapse_across('gender',raw_faces_labs_fixdur);

%%% collapse across different categories for eyes and mouth fixation number
[gazelabels_face_fixnum]=collapse_across({'gender','expression'},raw_faces_labs_fixnum);
[genderlabels_face_fixnum]=collapse_across({'gaze','expression'},raw_faces_labs_fixnum);
[expressionlabels_face_fixnum]=collapse_across({'gender','gaze'},raw_faces_labs_fixnum);
[nogenderlabels_face_fixnum]=collapse_across('gender',raw_faces_labs_fixnum);

%% Raw to Images
%RAWall
[means,errors] = means_and_errors_plot(storeLookingDuration, lookLabels, ...
    'yLabel','Looking Duration','wantedRoi','image');

%%Rawcollapsed
[means,errors] = means_and_errors_plot(storeLookingDuration,facelabels_success, 'xtickLabel', {'Landscapes','Scrambled','Faces'}, 'wantedRoi', 'image');

%% Face by Size Looking Duration
%%Face all

[means,errors] = means_and_errors_plot(face_by_size,raw_faces_labs, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','wantedRoi','face');
%gaze
[means,errors] = means_and_errors_plot(face_by_size,gazelabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Directed','Averted'},'wantedRoi','face');
%RAWgender
[means,errors] = means_and_errors_plot(face_by_size,genderlabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Male','Female'},'wantedRoi','face');
%RAWexpression
[means,errors] = means_and_errors_plot(face_by_size,expressionlabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','face');
%RAWnogender
[means,errors] = means_and_errors_plot(face_by_size,nogenderlabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','face');

%% Plot normalized ROIS LOOKING DURATION
%%Face all

[means,errors] = means_and_errors_plot(face_by_image,raw_faces_labs, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','wantedRoi','face');
%gaze
[means,errors] = means_and_errors_plot(face_by_image,gazelabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed','Averted'},'wantedRoi','face');
%RAWgender
[means,errors] = means_and_errors_plot(face_by_image,genderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Male','Female'},'wantedRoi','face');
%RAWexpression
[means,errors] = means_and_errors_plot(face_by_image,expressionlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','face');
%RAWnogender
[means,errors] = means_and_errors_plot(face_by_image,nogenderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','face');

%%Eyes all
[means,errors] = means_and_errors_plot(eyes_by_face,raw_faces_labs, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','wantedRoi','eyes');
%gaze
[means,errors] = means_and_errors_plot(eyes_by_face,gazelabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed','Averted'},'wantedRoi','eyes');
%RAWgender
[means,errors] = means_and_errors_plot(eyes_by_face,genderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Male','Female'},'wantedRoi','eyes');
%RAWexpression
[means,errors] = means_and_errors_plot(eyes_by_face,expressionlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','eyes');
%RAWnogender
[means,errors] = means_and_errors_plot(eyes_by_face,nogenderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','eyes');

%Mouth
[means,errors] = means_and_errors_plot(mouth_by_face,raw_faces_labs, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','wantedRoi','mouth');
%gaze
[means,errors] = means_and_errors_plot(mouth_by_face,gazelabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed','Averted'},'wantedRoi','mouth');
%RAWgender
[means,errors] = means_and_errors_plot(mouth_by_face,genderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Male','Female'},'wantedRoi','mouth');
%RAWexpression
[means,errors] = means_and_errors_plot(mouth_by_face,expressionlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','mouth');
%RAWnogender
[means,errors] = means_and_errors_plot(mouth_by_face,nogenderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Proportion of Looking Time','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','mouth');

%% Eye_to_Mouth
[means,errors] = means_and_errors_plot(eye_to_mouth,raw_faces_labs, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Eye to Mouth Ratio','wantedRoi','eyes');
%gaze
[means,errors] = means_and_errors_plot(eye_to_mouth,gazelabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Eye to Mouth Ratio','xtickLabel',{'Directed','Averted'},'wantedRoi','eyes');
%RAWgender
[means,errors] = means_and_errors_plot(eye_to_mouth,genderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Eye to Mouth Ratio','xtickLabel',{'Male','Female'},'wantedRoi','eyes');
%RAWexpression
[means,errors] = means_and_errors_plot(eye_to_mouth,expressionlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Eye to Mouth Ratio','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','eyes');
%RAWnogender
[means,errors] = means_and_errors_plot(eye_to_mouth,nogenderlabels_face, ...
    'title','PROPORTION OF LOOKING DURATION',...
    'yLabel','Eye to Mouth Ratio','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','eyes');

%% Plot normalized ROIS FIXATION NUMBER
%%Face all
[means,errors] = means_and_errors_plot(face_by_image_fixnum,raw_faces_labs_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','wantedRoi','face');
%gaze
[means,errors] = means_and_errors_plot(face_by_image_fixnum,gazelabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed','Averted'},'wantedRoi','face');
%RAWgender
[means,errors] = means_and_errors_plot(face_by_image_fixnum,genderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Male','Female'},'wantedRoi','face');
%RAWexpression
[means,errors] = means_and_errors_plot(face_by_image_fixnum,expressionlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','face');
%RAWnogender
[means,errors] = means_and_errors_plot(face_by_image_fixnum,nogenderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','face');

%%Eyes all
[means,errors] = means_and_errors_plot(eyes_by_face_fixnum,raw_faces_labs_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','wantedRoi','eyes');
%gaze
[means,errors] = means_and_errors_plot(eyes_by_face_fixnum,gazelabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed','Averted'},'wantedRoi','eyes');
%RAWgender
[means,errors] = means_and_errors_plot(eyes_by_face_fixnum,genderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Male','Female'},'wantedRoi','eyes');
%RAWexpression
[means,errors] = means_and_errors_plot(eyes_by_face_fixnum,expressionlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','eyes');
%RAWnogender
[means,errors] = means_and_errors_plot(eyes_by_face_fixnum,nogenderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','eyes');

%Mouth
[means,errors] = means_and_errors_plot(mouth_by_face_fixnum,raw_faces_labs_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','wantedRoi','mouth');
%gaze
[means,errors] = means_and_errors_plot(mouth_by_face_fixnum,gazelabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed','Averted'},'wantedRoi','mouth');
%RAWgender
[means,errors] = means_and_errors_plot(mouth_by_face_fixnum,genderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Male','Female'},'wantedRoi','mouth');
%RAWexpression
[means,errors] = means_and_errors_plot(mouth_by_face_fixnum,expressionlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','mouth');
%RAWnogender
[means,errors] = means_and_errors_plot(mouth_by_face_fixnum,nogenderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Proportion of Fixations','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','mouth');

%Eye_to_Mouth
[means,errors] = means_and_errors_plot(eye_to_mouth_fixnum,raw_faces_labs_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Eye to Mouth Ratio Fixation Number','wantedRoi','eyes');
%gaze
[means,errors] = means_and_errors_plot(eye_to_mouth_fixnum,gazelabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Eye to Mouth Ratio Fixation Number','xtickLabel',{'Directed','Averted'},'wantedRoi','eyes');
%RAWgender
[means,errors] = means_and_errors_plot(eye_to_mouth_fixnum,genderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Eye to Mouth Ratio Fixation Number','xtickLabel',{'Male','Female'},'wantedRoi','eyes');
%RAWexpression
[means,errors] = means_and_errors_plot(eye_to_mouth_fixnum,expressionlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Eye to Mouth Ratio Fixation Number','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','eyes');
%RAWnogender
[means,errors] = means_and_errors_plot(eye_to_mouth_fixnum,nogenderlabels_face_fixnum, ...
    'title','PROPORTION OF FIXATIONS',...
    'yLabel','Eye to Mouth Ratio Fixation Number','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','eyes');

%% Plot normalized ROIS FIXATION DURATION
%%Face all
[means,errors] = means_and_errors_plot(raw_faces_fixdur,raw_faces_labs_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','wantedRoi','face');
%gaze
[means,errors] = means_and_errors_plot(raw_faces_fixdur,gazelabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed','Averted'},'wantedRoi','face');
%RAWgender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,genderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Male','Female'},'wantedRoi','face');
%RAWexpression
[means,errors] = means_and_errors_plot(raw_faces_fixdur,expressionlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','face');
%RAWnogender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,nogenderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','face');

%%Eyes all
[means,errors] = means_and_errors_plot(raw_faces_fixdur,raw_faces_labs_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','wantedRoi','eyes');
%gaze
[means,errors] = means_and_errors_plot(raw_faces_fixdur,gazelabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed','Averted'},'wantedRoi','eyes');
%RAWgender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,genderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Male','Female'},'wantedRoi','eyes');
%RAWexpression
[means,errors] = means_and_errors_plot(raw_faces_fixdur,expressionlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','eyes');
%RAWnogender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,nogenderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','eyes');

%Mouth
[means,errors] = means_and_errors_plot(raw_faces_fixdur,raw_faces_labs_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','wantedRoi','mouth');
%gaze
[means,errors] = means_and_errors_plot(raw_faces_fixdur,gazelabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed','Averted'},'wantedRoi','mouth');
%RAWgender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,genderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Male','Female'},'wantedRoi','mouth');
%RAWexpression
[means,errors] = means_and_errors_plot(raw_faces_fixdur,expressionlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'},'wantedRoi','mouth');
%RAWnogender
[means,errors] = means_and_errors_plot(raw_faces_fixdur,nogenderlabels_face_fixdur, ...
    'title','AVERAGE FIXATION DURATION',...
    'yLabel','Fixation Duration','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'wantedRoi','mouth');

%% Plot SUCCESSFUL TRIALS
%%number of completed trials
success_trials.data = storeNSuccessfulTrials; success_trials.labels = all_images;
[means,errors] = session_plot(success_trials,'yLabel','Completed Trials','xLabel','Drug Dose','title','Average Trials Completed per Session', 'calc', 'sum', 'wantedRoi', 'image');
% [means,errors] = session_plot(success_trials,'yLabel','Completed Trials','calc', 'sum');

%% Plot pupil size during -300 -> 0 ms pre image presentation

pupil.data = pupil_size_data; pupil.labels = all_images_pupil;
[means,errors] = session_plot(pupil,'yLabel','Pupil Size','xLabel','Drug Dose','title','Average Pupil Size', 'wantedRoi', 'image');









%% OUT OF USE 
% % % %% Pull out individual expressions D/I with gender collapsed raw 
% % % [rawthreat,rawthreat_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'T'});
% % % [rawneutral,rawneutral_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'N'});
% % % [rawLS,rawLS_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'L'});
% % % [rawFG,rawFG_labs] = separate_data_struct(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw,'expressions',{'S'});
% % % 
% % % %Pull out by dose
% % % [rawsaline,rawsaline_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'saline'});
% % % [rawlow,rawlow_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'low'});
% % % [rawhigh,rawhigh_labs] = separate_data_struct(storeLookingDuration,lookLabels,'doses',{'high'});
% % % 
% % % %Pull out completed trials by dose
% % % [rawsaline_num,rawsaline_num_labs] = separate_data_struct(storeNSuccessfulTrials,successLabels,'doses',{'saline'});
% % % [rawlow_num,rawlow_num_labs] = separate_data_struct(storeNSuccessfulTrials,successLabels,'doses',{'low'});
% % % [rawhigh_num,rawhigh_num_labs] = separate_data_struct(storeNSuccessfulTrials,successLabels,'doses',{'high'});
% % % %% plot
% % % %%number of completed trials
% % % [means,errors] = means_and_errors_plot(storeNSuccessfulTrials,successLabels,'yLabel','Completed Trials','xLabel','Drug Dose','title','Average Trials Completed per Session','xtickLabel',' ', 'calc', 'sum');
% % % 
% % % %RAWgaze
% % % [means,errors] = means_and_errors_plot(norm_look_dur_gaze_raw,norm_look_dur_labels_gaze_raw, ...
% % %     'yLabel','Looking Duration','xtickLabel',{'Directed','Averted'});
% % % %RAWgender
% % % [means,errors] = means_and_errors_plot(norm_look_dur_gender_raw,norm_look_dur_labels_gender_raw, ...
% % %     'yLabel','Looking Duration','xtickLabel',{'Male','Female'});
% % % %RAWexpression
% % % [means,errors] = means_and_errors_plot(norm_look_dur_expression_raw,norm_look_dur_labels_expression_raw, ...
% % %     'yLabel','Looking Duration','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'});
% % % %RAWnogender
% % % [means,errors] = means_and_errors_plot(norm_look_dur_nogender_raw,norm_look_dur_labels_nogender_raw, ...
% % %     'yLabel','Looking Duration','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'});
% % % 
% % % %RAWall
% % % [means,errors] = means_and_errors_plot(storeLookingDuration, lookLabels, ...
% % %     'yLabel','Looking Duration');
% % % 
% % % 
% % % %%%%look at raw looking time across social and non social stimuli
% % % [means,errors] = means_and_errors_plot(storeLookingDuration,facelabels_succss, 'xtickLabel', {'Landscapes','Scrambled','Faces'});
% % % 
% % % %% Time Course
% % % % time_course(rawsaline,rawsaline_labs,start_times);
% % % % time_course(rawlow,rawlow_labs,start_times);
% % % % time_course(rawhigh,rawhigh_labs,start_times);
% % % 
% % % %% Finding outliers
% % % 
% % % % face_struct.data = face_by_image;
% % % % face_struct.labels = raw_faces_labs;
% % % % faceByImageObj = DataObject(face_struct);
% % % % 
% % % % days = unique(faceByImageObj.labels.days);
% % % % 
% % % % for i = 1:length(days)
% % % %     
% % % %     one_day = faceByImageObj(faceByImageObj == days{i});
% % % %     one_day = one_day(~isnan(one_day),:);
% % % %     
% % % %     store_deviation.(['day_' days{i}]) = std(one_day);
% % % %     store_means.(['day_' days{i}]) = mean(one_day);
% % % %     
% % % %     
% % % % end

