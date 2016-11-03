
%   set path to processed .mat files (processed from edf2mat_multiple_rois.m)

data_dir = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/data/image_data/101316';

%   define which rois are present in the data files

 rois = {'image','eyes','mouth','face'};
% rois = {'quadrant1','quadrant2','quadrant3','quadrant4',...
%     'littleQuadrant1','littleQuadrant2','littleQuadrant3','littleQuadrant4','image','eyes','mouth','face'};

%   set whether to use the per-image rois, or more general, custom rois (as
%       was done in the past)

% use_custom_rois = 1;

%   get data for each roi

for r = 1:length(rois)
    current_roi = rois{r};
    fprintf('\nUsing roi %s',current_roi);
    
    all_files = get_files_hannah(data_dir);
    all_files = cellfun(@(x) x.imagedata,all_files,'UniformOutput',false);
    
    if ~isempty(strfind(lower(current_roi),'quadrant'))
        use_custom_rois = 1;
    else use_custom_rois = 0;
    end
    
    %   if wanting to only look at new data ...
    
%    all_files = keep_from_all_files(all_files,'all');
    
    %   get the image presentation times per session (each cell is a session)   
           
    image_times = cellfun(@(x) x.image_data.data.time,all_files,'UniformOutput',false);

    %   get the positional boundaries associated with each image -- either
    %       those stored in image_data, or custom-set ones
    
    if use_custom_rois
        pos = define_custom_rois(current_roi); roi_data = get_custom_rois(pos,image_times);
        all_labels.rois = cellfun(@(x) repmat({current_roi},size(x,1),1),image_times,'UniformOutput',false);
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
    all_labels.imgGaze =        cellfun(@(x) x.image_data.labels.gaze,all_files,'UniformOutput',false);
    
    processed_image_data.image_times = image_times;
    processed_image_data.fix_events = fix_events;
    processed_image_data.roi_data = roi_data;
    processed_image_data.pupil_data = pupil_data;
    
    data_objects_to_update = get_data_from_fix_events(processed_image_data,all_labels);
    data_object_types = fieldnames(data_objects_to_update);
    
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

%   combine across rois

% combined_data = combine_structs_across_rois(data);

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

%datastruct = DataObjectStruct(data_objects);
%datastruct.replace();

% combined_data = add_expr_gaze_gender_labs(combined_data);

%   optionally remove zeros from selected (or all) fields of combined_data

% combined_data = remove_zeros_from_data_struct(combined_data,{'lookingDuration'});
