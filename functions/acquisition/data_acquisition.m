function data_objects = data_acquisition( rois )

%   set path to processed .mat files (processed from edf2mat_multiple_rois.m)

data_dir = fullfile(pathfor('imageData'),'101316');

%   define which rois are present in the data files

% rois = {'image','eyes','mouth','face','quadrant1','quadrant2','quadrant3','quadrant4',...
%     'littleQuadrant1','littleQuadrant2','littleQuadrant3','littleQuadrant4'};
if ( nargin < 1 )
% rois = {'eyes','mouth'};
%   rois = { 'eyes', 'mouth', 'face' };
  rois = { 'image' };
else
  if ( ~iscell(rois) ), rois = { rois }; end;
end

use_custom_rois = 0;

%   set whether to use the per-image rois, or more general, custom rois (as
%       was done in the past)

%   get data for each roi

for r = 1:length(rois)
    current_roi = rois{r};
    fprintf('\nUsing roi %s',current_roi);
    
    all_files = get_files_hannah(data_dir);
    all_files = cellfun(@(x) x.imagedata,all_files,'UniformOutput',false);
    
    %   if wanting to only look at new data ...
    
    all_files = keep_from_all_files(all_files,'all');
    
    %   set custom rois for quadrants; otherwise use the rois embedded in
    %   all_files
    
%     if any(strfind(lower(current_roi),'quadrant'))
%         use_custom_rois = 1;
%     else
%         use_custom_rois = 0;
%     end
    
    %   get the image presentation times per session (each cell is a session)   
           
    image_times = cellfun(@(x) x.image_data.data.time,all_files,'UniformOutput',false);

    %   get the positional boundaries associated with each image -- either
    %       those stored in image_data, or custom-set ones
    
    if use_custom_rois
%         pos = define_custom_rois(current_roi); roi_data = get_custom_rois(pos,image_times);
%         all_labels.rois = cellfun(@(x) repmat({current_roi},size(x,1),1),image_times,'UniformOutput',false);
        roi_data = cellfun(@(x) x.image_data.data.rois.(current_roi),all_files,'UniformOutput',false);
        custom_roi = struct( 'minX', -10e3, 'maxX', 10e3, 'minY', -10e3, 'maxY', 10e3 );
        for i = 1:numel(roi_data)
          for j = 1:numel(roi_data{i})
            roi_data{i}{j} = custom_roi;
          end
        end
        all_labels.rois = cellfun(@(x) repmat({current_roi},size(x,1),1),image_times,'un',false);
    else
        roi_data = cellfun(@(x) x.image_data.data.rois.(rois{r}),all_files,'UniformOutput',false);
        all_labels.rois = cellfun(@(x) x.image_data.labels.rois.(current_roi),all_files,'UniformOutput',false);
    end
    
    %   get the fix events associated with each session

    fix_events = cellfun(@(x) x.image_data.data.fix_events,all_files,'UniformOutput',false);
    
    %   get pupil data
    
    pupil_data = cellfun(@(x) x.image_data.data.pupil_size,all_files,'UniformOutput',false);

    %   get data labels in cell array form
    
    all_labels.days =           cellfun(@(x) x.image_data.labels.day,all_files,'UniformOutput',false);
    all_labels.sessions =       cellfun(@(x) x.image_data.labels.session,all_files,'UniformOutput',false);
    all_labels.file_names =     cellfun(@(x) x.image_data.labels.file_names,all_files,'UniformOutput',false);
    all_labels.monkeys =        cellfun(@(x) x.image_data.labels.monkey,all_files,'UniformOutput',false);
    all_labels.doses =          cellfun(@(x) x.image_data.labels.dose,all_files,'UniformOutput',false);
    all_labels.images =         cellfun(@(x) x.image_data.labels.category,all_files,'UniformOutput',false);
%     all_labels.rois =           cellfun(@(x) x.image_data.labels.rois.(current_roi),all_files,'UniformOutput',false);
    all_labels.imgGaze =        cellfun(@(x) x.image_data.labels.gaze,all_files,'UniformOutput',false);
    
    processed_image_data.image_times = image_times;
    processed_image_data.fix_events = fix_events;
    processed_image_data.roi_data = roi_data;
    processed_image_data.pupil_data = pupil_data;
    
    start = 1;
    chunk_size = 10;
    n_total = ceil( numel(processed_image_data.image_times) / chunk_size );
    chunk_n = 1;
    
%     processed_image_data = structfun( @(x) x(1:22), processed_image_data, 'un', false );
%     all_labels = structfun( @(x) x(1:22), all_labels, 'un', false );
    
    while ( start+chunk_size-1 < numel(processed_image_data.image_times) )
      fprintf( '\n %d of %d', chunk_n, n_total );
      chunk_image = structfun( @(x) x(start:start+chunk_size-1), processed_image_data, 'un', false );
      chunk_labs = structfun( @(x) x(start:start+chunk_size-1), all_labels, 'un', false );
      one_iteration = get_data_from_fix_events(chunk_image, chunk_labs);
      if ( start == 1 )
        data_objects_to_update = one_iteration;
      else
        fs = fieldnames( data_objects_to_update );
        for i = 1:numel(fs)
          data_objects_to_update.(fs{i}) = ...
            data_objects_to_update.(fs{i}).append( one_iteration.(fs{i}) );
        end
      end
      start = start + chunk_size;
      chunk_n = chunk_n + 1;
    end
    if ( start < numel(processed_image_data.image_times) )
      fprintf( '\n %d of %d', chunk_n, n_total );
      chunk_image = structfun( @(x) x(start:end), processed_image_data, 'un', false );
      chunk_labs = structfun( @(x) x(start:end), all_labels, 'un', false );
      one_iteration = get_data_from_fix_events( chunk_image, chunk_labs );
      for i = 1:numel(fs)
        data_objects_to_update.(fs{i}) = ...
            data_objects_to_update.(fs{i}).append( one_iteration.(fs{i}) );
      end
    end
    
    data_object_types = fieldnames(data_objects_to_update);
    
%     data_objects_to_update = get_data_from_fix_events(processed_image_data,all_labels);
%     data_object_types = fieldnames(data_objects_to_update);
    
    if r == 1
        data_objects = data_objects_to_update;
    else
        for j = 1:length(data_object_types)
            data_objects.(data_object_types{j}) = [data_objects.(data_object_types{j}); data_objects_to_update.(data_object_types{j})];
        end
    end
%     data.(rois{r}) = get_fix_event_data(processed_image_data,all_labels);
    fprintf('\nWorked');
end

%   using image category labels, add gender, expression, and gaze labels.
%       We *could* just add these in the loop above (they're stored in
%       imagedata), but doing so would require get_fix_event_data to needlessly loop
%       through 3 additional fields

combined_data = struct();
for j = 1:length(data_object_types)
    combined_data.(data_object_types{j}) = obj2struct(data_objects.(data_object_types{j}));
end
combined_data = add_expr_gaze_gender_labs(combined_data);
for j = 1:length(data_object_types)
    data_objects.(data_object_types{j}).labels = combined_data.(data_object_types{j}).labels;
end

%   cleanup and convert to container


fs = fieldnames(data_objects);
for i = 1:numel(fs)
  data_objects.(fs{i}).label_fields = fieldnames( data_objects.(fs{i}).labels );
end
data_objects = structfun( @(x) namespace_categories(x, {'genders','gazes','expressions'}) ...
  , data_objects, 'un', false );
data_objects = structfun( @(x) add_session_id(x), data_objects, 'un', false );
data_objects = structfun( @(x) x.to_container(), data_objects, 'un', false );

end