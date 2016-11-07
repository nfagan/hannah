%%  load in the data

load('measures.mat');
load('pupil.mat');
load('static.mat');

%%

measures = measures.foreach( @(x) x( x.data ~= 0 ) );

%%  for each data type in <measures>, remove outliers

no_outliers = measures.foreach( @remove_outliers );

outliers_removed = no_outliers.foreach( @(x) x.object );
outliers_index = no_outliers.foreach( @(x) x.index );

%% find average looking to faces for saline days for each monkey
image = outliers_removed.lookdur.only( 'image' );
saline_no_outliers_image = image.only( 'saline' );
saline_no_outliers_image = saline_no_outliers_image.remove( {'outdoors','scrambled'} );
saline_no_outliers_image = cat_collapse( saline_no_outliers_image, {'gender','gaze','expression'} );
saline_no_outliers_image = saline_no_outliers_image.replace( 'uaaa', 'social' );

saline_no_outliers_image = saline_no_outliers_image.only( 'ephron' );

saline_no_outliers_image_baselinelooking = mean(saline_no_outliers_image)

%% save off without outliers

save('measures_outliersremoved.mat','outliers_removed');
save('measures_outliersindex.mat','outliers_index');


%%  create separate objects for face and image rois, then recombine into one

face = outliers_removed.only( 'face' );
image = outliers_removed.only( 'image' );

face = face.namespace( 'face' ); 
image = image.namespace( 'image' );

%   this will make sense if you call disp(combined) in the command window

combined = face.include( image );

%%  normalize each object in <combined> by the per-session mean of its corresponding saline data

combined = combined.foreach( @normalize );

%%

lookdur = combined2.image__lookdur;

lookdur = lookdur.replace( {'ephron','tarantino','kubrick'}, 'up' );
lookdur = lookdur.replace( {'lager','cron', 'hitch' }, 'down' );
lookdur = cat_collapse( lookdur, {'gender','gaze','expression'} );
lookdur = lookdur.replace( 'uaaa', 'social' );
lookdur = lookdur.replace( {'outdoors','scrambled'}, 'nonsocial' );

analysis.lookdurMean = hannah__mean_within( lookdur );

%%  save normalized data

save('normalized.mat','combined');

%%  remove outdoor and scrambled images

social = combined.remove( {'outdoors','scrambled'} );
save('social_normalized.mat','social');

%%

%%  collapse image categories and monkeys

full_collapse = combined;
full_collapse = full_collapse.collapse( 'monkeys' );
full_collapse = full_collapse.foreach( @cat_collapse, {'gender','gaze','expression'} );

% full_collapse = full_collapse.replace( {'outdoors','scrambled'}, 'nonsocial' );
full_collapse = full_collapse.replace( 'uaaa', 'social' );

%% Social Non Social

analysis.socialNonSocialMeans = full_collapse.foreach( @hannah__social_nonsocial_mean );

%% place monkeys into up vs. down modulated categories

updown = social;
updown = updown.replace( {'ephron', 'kubrick', 'tarantino'}, 'up' );
updown = updown.replace( {'lager', 'cron', 'hitch'}, 'down' );

%% Individual NHP Plots fix syntax 
combined_data.lookingDuration = outliers_removed.lookdur;
combined_data.lookingDuration = obj2struct(combined_data.lookingDuration);

% Parse Individual Labels from Combined Data
lookLabels = combined_data.lookingDuration.labels;
storeLookingDuration = combined_data.lookingDuration.data;

% Separate by Subject
current_monkey = 'hitch';
[storeLookingDuration,lookLabels] = separate_data_struct(storeLookingDuration,lookLabels,'monkeys',{current_monkey});

% Remove Outdoor and Scrambled Looking Duration
[raw_no_out, raw_now_out_labs] = separate_data_struct(storeLookingDuration, lookLabels,'images', {'--outdoors'});
[raw_faces, raw_faces_labs] = separate_data_struct(raw_no_out, raw_now_out_labs,'images', {'--scrambled'});

% Normalize Face by Size 
face_by_size = normalize_roi_to_image('face',raw_faces,raw_faces_labs);

% collapse across different categories
[gazelabels_face]=collapse_across({'gender','expression'},raw_faces_labs);
[expressionlabels_face]=collapse_across({'gender','gaze'},raw_faces_labs);

% Face by Size Looking Duration
%gaze
[means,errors] = means_and_errors_plot(face_by_size,gazelabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Directed','Averted'});
%RAWexpression
[means,errors] = means_and_errors_plot(face_by_size,expressionlabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'});

