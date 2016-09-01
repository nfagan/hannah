function data_objects = get_data_from_fix_events(processed_image_data,data_labels)

tic;

% - parse global inputs
   
image_times = processed_image_data.image_times;
fix_events = processed_image_data.fix_events;
positional_boundaries = processed_image_data.roi_data;
pupil_data = processed_image_data.pupil_data;

label_fields = fieldnames(data_labels);

% - pupil paramaters

ADD_PUPIL_DATA = true;
LOOK_BACK_FROM_IMAGE_START = -1000;  % ms - t = 0 for getting pupil data
PUPIL_VECTOR_LENGTH = 1200;          % ms - amount of pupil data to get


%{

    Define data that are w/r/t to each fix event

%}


data_per_fix_event = struct();

data_per_fix_event.fix_event_duration = preallocate_data([10000 1],'zeros');
data_per_fix_event.x_y_coords =         preallocate_data([10000 2],'nans');
data_per_fix_event.time =               preallocate_data([10000 4],'zeros');

data_per_fix_event.meta.labels =        preallocate_labels([10000 1],label_fields);
data_per_fix_event.meta.stp =           0;

data_per_fix_event.meta.cols_from_fix_events.fix_event_duration = 3;
data_per_fix_event.meta.cols_from_fix_events.x_y_coords = 4:5;
data_per_fix_event.meta.cols_from_fix_events.time = 1:2;

%   get the field names of the data structure (e.g.: fix_event_duration,
%   time, etc.) for future reference. don't include 'meta' as a data field

per_fix_data_labels = fieldnames(data_per_fix_event);
per_fix_data_labels = per_fix_data_labels(~strcmp(per_fix_data_labels,'meta'));


%{

    define data that are w/r/t each image presentation

%}


data_per_image = struct();

data_per_image.looking_duration =   preallocate_data([10000 1],'zeros');
data_per_image.n_fixations =        preallocate_data([10000 1],'zeros');
data_per_image.successful_trial =   preallocate_data([10000 1],'zeros');

if ADD_PUPIL_DATA
    data_per_image.pupil_size =     preallocate_data([10000 1],'cellsWithValue',nan(1,PUPIL_VECTOR_LENGTH+1));
end

data_per_image.meta.labels =        preallocate_labels([10000 1],label_fields);
data_per_image.meta.stp =           0;

%   get the field names of the data structure (e.g.: looking_duration,
%   etc.) for future reference. don't include 'meta' as a data field

per_img_data_labels = fieldnames(data_per_image);
per_img_data_labels = per_img_data_labels(~strcmp(per_img_data_labels,'meta'));

for i = 1:length(image_times);
fprintf('\nProcessing session %d of %d ...',i,length(image_times));
    
    one_session_times = image_times{i}; %get one file's timing info
    one_session_fix_events = fix_events{i}; %get one file's fixation events
    one_session_rois = positional_boundaries{i};
    one_session_pup_data = pupil_data{i};
    one_session_labels = get_one_session_labels(data_labels,i);
    
    fix_starts = one_session_fix_events(:,1); %separate columns of fixation events for clarity; start of all fixations
    fix_ends = one_session_fix_events(:,2); %end of all fixations
    
    for j = 1:size(one_session_times,1); %for each image display time ...
        
        image_start = one_session_times(j,1);
        image_end = one_session_times(j,2);
        
        if image_end > max(fix_ends); % if invalid display time
            continue;
        end
        
        %   start index is the index of the first fixation *endtime* that
        %       occurred after the image was presented. 
        %   end index is the index of the final fixation *starttime* that
        %       occurred before the image ended.
        
        start_index = find(fix_ends > image_start,1,'first');
        end_index = find(fix_starts < image_end,1,'last');
        
        %   validate
        
        if end_index < start_index
            error('End index is less than start index');
        end
        
        if isempty(end_index) || isempty(start_index)
            error('Could not find a start or end index');
        end
        
        %   if the first fixation started before the image was presented,
        %   the first fixation length is the first fixation end time minus
        %   the image start time
        
        if (image_start - fix_starts(start_index)) < 0
            one_session_fix_events(start_index,3) = fix_ends(start_index) - image_start;
        end
        
        %   if the last fixation ended after the image ended, the last
        %   fixation duration is the image end time minus the final
        %   fixation start time
        
        if (image_end - fix_ends(end_index)) < 0 && start_index ~= end_index
            one_session_fix_events(end_index,3) = image_end - fix_starts(end_index);        
        end
        
        within_time_bounds = one_session_fix_events(start_index:end_index,:);
        
        if any(within_time_bounds(:,3) < 0)
            error('Impossible fixation duration');
        end

        %   remove out of bounds data

        within_pos_bounds =...
            within_time_bounds(:,4) >= one_session_rois{j}.minX & ...
            within_time_bounds(:,4) <= one_session_rois{j}.maxX & ...
            within_time_bounds(:,5) >= one_session_rois{j}.minY & ...
            within_time_bounds(:,5) <= one_session_rois{j}.maxY;

        within_time_bounds = within_time_bounds(within_pos_bounds,:);

        %{
            begin data storage
        %}

        fix_stp = data_per_fix_event.meta.stp;
        img_stp = data_per_image.meta.stp;

        %{
            get pupil size -- special case
        %}

        if ADD_PUPIL_DATA

            for_row_indexing = 1:size(one_session_pup_data,1);

            pupil_start_time = image_start + LOOK_BACK_FROM_IMAGE_START;
            pupil_end_time = pupil_start_time + PUPIL_VECTOR_LENGTH;

            pupil_start_index = one_session_pup_data(:,1) == pupil_start_time; 
            pupil_end_index = one_session_pup_data(:,1) == pupil_end_time;

            if isempty(pupil_start_index) || isempty(pupil_end_index)
                error('Could not find the image start time or end time in this pupil data');
            end

            pupil_start_index = for_row_indexing(pupil_start_index); % get the indices, (equiv. to 'find(...)')
            pupil_end_index = for_row_indexing(pupil_end_index);

            one_image_pupil_size = one_session_pup_data(pupil_start_index:pupil_end_index,2);

            data_per_image.pupil_size.data(img_stp+1) = {one_image_pupil_size'};

        end

        %{
            gather looking duration, fix event duration, and an index 
            of successful trials
        %}

        if ~isempty(within_time_bounds)

            img_size = 1;
            fix_size = size(within_time_bounds,1);

            %   - record data per image

            data_per_image.looking_duration.data(img_stp+1:img_stp+img_size,:) = ...
                sum(within_time_bounds(:,3));
            data_per_image.n_fixations.data(img_stp+1:img_stp+img_size,:) = ...
                fix_size;
            data_per_image.successful_trial.data(img_stp+1:img_stp+img_size,:) = ...
                1;

            data_per_image.meta.stp = img_stp + img_size;

            %   - record data per fix event

            for lab = 1:length(per_fix_data_labels)
                desired_cols = data_per_fix_event.meta.cols_from_fix_events.(per_fix_data_labels{lab});
                if strcmp(per_fix_data_labels{lab},'time')
                    modified_image_times = repmat([image_start,image_end],size(within_time_bounds,1),1);
                    data_per_fix_event.(per_fix_data_labels{lab}).data(fix_stp+1:fix_stp+fix_size,:) = ...
                        [modified_image_times cols_from_fix_events(within_time_bounds,desired_cols)];
                else
                    data_per_fix_event.(per_fix_data_labels{lab}).data(fix_stp+1:fix_stp+fix_size,:) = ...
                        cols_from_fix_events(within_time_bounds,desired_cols);
                end
            end

            data_per_fix_event.meta.stp = fix_stp + fix_size;

            %{
                get labels
            %}

            %   - labels per image

            labels = data_per_image.meta.labels;

            update_label_info.index_of_label_to_repeat = j;
            update_label_info.start = img_stp;
            update_label_info.n_reps = 1;

            data_per_image.meta.labels = update_labels(one_session_labels,labels,update_label_info);

            %   - labels per fix event

            labels = data_per_fix_event.meta.labels;

            update_label_info.index_of_label_to_repeat = j;
            update_label_info.start = fix_stp;
            update_label_info.n_reps = fix_size;

            data_per_fix_event.meta.labels = update_labels(one_session_labels,labels,update_label_info);

        else

            data_per_fix_event.meta.stp = data_per_fix_event.meta.stp + 1;
            data_per_image.meta.stp = data_per_image.meta.stp + 1;

            %   - labels per image

            labels = data_per_image.meta.labels;

            update_label_info.index_of_label_to_repeat = j;
            update_label_info.start = img_stp;
            update_label_info.n_reps = 1;

            data_per_image.meta.labels = update_labels(one_session_labels,labels,update_label_info);

            %   - labels per fix event

            labels = data_per_fix_event.meta.labels;

            update_label_info.index_of_label_to_repeat = j;
            update_label_info.start = fix_stp;
            update_label_info.n_reps = 1;

            data_per_fix_event.meta.labels = update_labels(one_session_labels,labels,update_label_info);

        end
        
    end
    
end

%   - get rid of excess labels based on whether the labels are empty

empty_img_index = cellfun(@isempty,data_per_image.meta.labels.(label_fields{1}));
empty_fix_index = cellfun(@isempty,data_per_fix_event.meta.labels.(label_fields{1}));

img_data_labels_empty_removed = remove_empty_labels(data_per_image.meta.labels,empty_img_index);
fix_data_labels_empty_removed = remove_empty_labels(data_per_fix_event.meta.labels,empty_fix_index);

%   - get rid of associated data based on the empty labels indices, and
%   transform the data into DataObject form

data_objects = struct(); data_struct = struct();
for i = 1:length(per_img_data_labels)
    
    temp_data = data_per_image.(per_img_data_labels{i}).data;
    temp_data(empty_img_index,:) = [];
    
    data_struct.data = temp_data;
    data_struct.labels = img_data_labels_empty_removed;
    
    data_objects.(per_img_data_labels{i}) = DataObject(data_struct);
end

data_struct = struct();
for i = 1:length(per_fix_data_labels)
    
    temp_data = data_per_fix_event.(per_fix_data_labels{i}).data;
    temp_data(empty_fix_index,:) = [];
    
    data_struct.data = temp_data;
    data_struct.labels = fix_data_labels_empty_removed;
    
    data_objects.(per_fix_data_labels{i}) = DataObject(data_struct);
end

toc;


end

%   - other functions

function pre = preallocate_data(dimensions,preallocate_with,preallocate_inner_cells_with)

    if nargin < 3 && strcmp(preallocate_with,'cellsWithValue')
        preallocate_inner_cells_with = NaN;
    end

    if strcmp(preallocate_with,'nans')
        data = nan(dimensions);
    elseif strcmp(preallocate_with,'zeros')
        data = zeros(dimensions);
    elseif strcmp(preallocate_with,'cells')
        data = cell(dimensions);
    elseif strcmp(preallocate_with,'cellsWithValue')
        data = cell(dimensions);
        to_replace = true(size(data));
        data(to_replace) = {preallocate_inner_cells_with};
    else
        error('Preallocate with ''nans'' or ''zeros''');
    end
    
    pre.data = data;
    
end

function labels = preallocate_labels(dimensions,label_fields)

    labels = struct();
    for i = 1:length(label_fields)
        one_field = cell(dimensions);
        labels.(label_fields{i}) = one_field;
    end

end

function extr = cols_from_fix_events(fix_events,cols)
    extr = fix_events(:,cols);
end

function labels_to_update = update_labels(session_labels,labels_to_update,update_info)
    index = update_info.index_of_label_to_repeat;
    start = update_info.start;
    n_reps = update_info.n_reps;
    
    label_fields = fieldnames(labels_to_update);
    
    for i = 1:length(label_fields)
        labels_to_update.(label_fields{i})(start+1:start+n_reps) = session_labels.(label_fields{i})(index);
    end
    
end

function out = get_one_session_labels(data_labels,index)

    out = struct();
    label_fields = fieldnames(data_labels);
    
    for i = 1:length(label_fields)
        out.(label_fields{i}) = data_labels.(label_fields{i}){index};
    end

end

function labels = remove_empty_labels(labels,index)
    label_fields = fieldnames(labels);
    for i = 1:length(label_fields)
        labels.(label_fields{i})(index,:) = [];
    end
end

        
%             
%         start_index = find(fix_starts < image_start,1,'last');
% %         end_index = find(fix_starts > image_end,1,'first') - 1;
%         end_index = find(fix_ends < image_end,1,'last');


%   adjust the first and last fixation duration such that
        %   fixation time is specific to the image presentation

%         if start_index ~= end_index
%             %   the first fixation length is equal to the end of the first
%             %   fixation - the image start time
%             within_time_bounds(1,3) = within_time_bounds(1,2) - image_start;
%             %   the last fixation length is equal to the end of the image
%             %   presentation - the start of the last fixation
%             within_time_bounds(end,3) = image_end - within_time_bounds(end,1);
%         end
        






