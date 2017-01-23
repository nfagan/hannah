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

%% save off without outliers

save('measures_outliersremoved.mat','outliers_removed');
save('measures_outliersindex.mat','outliers_index');


%% find average looking to faces for saline days for each monkey
image = outliers_removed.lookdur.only( 'image' );
saline_no_outliers_image = image.only( 'saline' );
saline_no_outliers_image = saline_no_outliers_image.remove( {'outdoors','scrambled'} );
saline_no_outliers_image = cat_collapse( saline_no_outliers_image, {'gender','gaze','expression'} );
saline_no_outliers_image = saline_no_outliers_image.replace( 'uaaa', 'social' );

saline_no_outliers_image = saline_no_outliers_image.only( 'cron' );

saline_no_outliers_image_baselinelooking = mean(saline_no_outliers_image)

%%  normalize each object in <combined> by the per-session mean of its corresponding saline data

image_measures = outliers_removed;
image_measures = image_measures.foreach( @normalize_filenames );

%%  create separate objects for face and image rois, then recombine into one

face = combined.only( 'face' );
image = combined.only( 'image' );

face = face.namespace( 'face' ); 
image = image.namespace( 'image' );

%   this will make sense if you call disp(combined) in the command window

combined = face.include( image );

%%  save normalized data

save('normalized_by_imagecat.mat','image_measures');

%% Bidirectional Plot

% lookdur = combined.image__lookdur;
lookdur = image_measures.lookdur;


% lookdur = lookdur.replace( {'ephron','tarantino','kubrick'}, 'up' );
% lookdur = lookdur.replace( {'lager','cron', 'hitch' }, 'down' );
lookdur = cat_collapse( lookdur, {'gender','gaze','expression'} );
lookdur = lookdur.replace( 'uaaa', 'social' );
lookdur = lookdur.replace( {'outdoors','scrambled'}, 'nonsocial' );

analysis.lookdurMean = hannah__mean_within( lookdur );
analysis.lookdurMeanRaw = hannah__mean_within( lookdurRaw );

analysis.bidirect = analysis.lookdurMean;
analysis.bidirect.data = analysis.bidirect.data - 1;


plot__mean_within( analysis.bidirect, {'monkeys','images','doses'} );

%%  bidirectional plot with xtick as raw looking duration
clear bidirect;
bidirect.norm = image_measures.lookdur;
bidirect.raw = outliers_removed.lookdur;

bidirect = DataObjectStruct( bidirect );
bidirect = bidirect.foreach( @cat_collapse, {'gender','gaze','expression'} );
bidirect = bidirect.replace( 'uaaa', 'social' );
bidirect = bidirect.replace( {'outdoors','scrambled'}, 'nonsocial' );

bidirect = bidirect.foreach( @hannah__mean_within );

%%

% bidirect.objects.norm.data = bidirect.norm.data - 1;

plot__mean_within( bidirect.norm.only('high'), {'monkeys', 'doses'}, ...
    'xTick', [754.3 1894.9 2137.5 3082.6 3284.4 3431.8]);

%%

analysis.pupilMean = hannah__mean_within( pupil.only('image') );

%% pupil stuff

pupil_manip = cat_collapse( pupil, {'gender','gaze','expression'} );
pupil_manip = pupil_manip.collapse( 'images' );

analysis.pupilMean = hannah__mean_within( pupil_manip, ...
    'within', {'doses', 'monkeys' });
analysis.pupilMeanManip = analysis.pupilMean;
analysis.pupilMeanManip.data = analysis.pupilMeanManip.data - 1;

plot__mean_within( analysis.pupilMeanManip.remove('saline'), ...
    {'images','doses'}, 'manualOrder', false, 'overlayMonkeyPoints', true );

%% pupil anova


toAnov.data = analysis.pupilMeanManip.data(:,1);
% toAnov.groups = cell(1,2);
toAnov.groups = analysis.pupilMeanManip.labels.doses;
[toAnov.p, ~, toAnov.stats]  = anova1( toAnov.data, toAnov.groups );
[c, m, ~, gnames] = multcompare( toAnov.stats );

%% soc-nonsoc anova

toAnova.data = image_measures.lookdur;
toAnova.data.data = abs( toAnova.data - 1 );

toAnova.data = toAnova.data.replace( {'outdoors','scrambled'},'nonsocial' );
toAnova.data = cat_collapse( toAnova.data, {'gender', 'gaze', 'expression'} );
toAnova.data = toAnova.data.replace( 'uaaa', 'social' );

% toAnova.data = hannah__mean_within( toAnova.data, 'within', {'images', 'doses', 'sessions'} );
% toAnova.data = hannah__mean_across( toAnova.data, 'sessions' );

%%

toAnova.groups = {};
toAnova.groups{1} = toAnova.data.labels.doses;
toAnova.groups{2} = toAnova.data.labels.images;
toAnova.extractedData = toAnova.data.data(:,1);

[toAnova.p, ~, toAnova.stats] = anovan( toAnova.extractedData, toAnova.groups, ...
    'model', 'interaction');

[c, m, ~, gnames] = multcompare( toAnova.stats, 'Dimension', [1 2] );


%%  remove outdoor and scrambled images

social = combined.remove( {'outdoors','scrambled'} );
save('social_normalized.mat','social');

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
current_monkey = 'ephron';
[storeLookingDuration,lookLabels] = separate_data_struct(storeLookingDuration,lookLabels,'monkeys',{current_monkey});

% Remove Outdoor and Scrambled Looking Duration
[raw_no_out, raw_now_out_labs] = separate_data_struct(storeLookingDuration, lookLabels,'images', {'--outdoors'});
[raw_faces, raw_faces_labs] = separate_data_struct(raw_no_out, raw_now_out_labs,'images', {'--scrambled'});

% Normalize Face by Size 
face_by_size = normalize_roi_to_image('face',raw_faces,raw_faces_labs);

% collapse across different categories
% [gazelabels_face]=collapse_across({'gender','expression'},raw_faces_labs);
% [expressionlabels_face]=collapse_across({'gender','gaze'},raw_faces_labs);
[nogenderlabels_face]=collapse_across('gender',raw_faces_labs);

% Face by Size Looking Duration
% %gaze
% [means,errors] = means_and_errors_plot(face_by_size,gazelabels_face, ...
%     'title','FACE SIZE NORMALIZED LOOKING DURATION',...
%     'yLabel','Normalized Looking Time','xtickLabel',{'Directed','Averted'}, 'yLimits' , [0 3000]);
% %expression
% [means,errors] = means_and_errors_plot(face_by_size,expressionlabels_face, ...
%     'title','FACE SIZE NORMALIZED LOOKING DURATION',...
%     'yLabel','Normalized Looking Time','xtickLabel',{'Lip Smack','Neutral','Fear Grimace','Threat'}, 'yLimits' , [0 3000]);
%nogender
[means,errors] = means_and_errors_plot(face_by_size,nogenderlabels_face, ...
    'title','FACE SIZE NORMALIZED LOOKING DURATION',...
    'yLabel','Normalized Looking Time','xtickLabel',{'Directed Lip Smack','Directed Neutral','Directed Fear Grimace','Directed Threat','Averted Lip Smack','Averted Neutral','Averted Fear Grimace','Averted Threat'},'yLimits' , [0 3000]);

