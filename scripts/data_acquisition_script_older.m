%%
%   set path to processed .mat files (processed from edf2mat_multiple_rois.m)

data_dir = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/data/processed_data';

%   define which rois are present in the data files

rois = {'eyes','mouth','face','image'};
% rois = {'image'};

%   set whether to use the per-image rois, or more general, custom rois (as
%       was done in the past)

use_custom_rois = 0;

%   get data for each roi

for r = 1:length(rois)
    current_roi = rois{r};
    fprintf('\nUsing roi %s',current_roi);
    
    all_files = get_files_hannah(data_dir);
    all_files = cellfun(@(x) x.imagedata,all_files,'UniformOutput',false);
    
    %   get the image presentation times per session (each cell is a session)   
           
    image_times = cellfun(@(x) x.image_data.data.time,all_files,'UniformOutput',false);

    %   get the positional boundaries associated with each image -- either
    %       those stored in image_data, or custom-set ones
    
    if strcmp(current_roi,'image')
        use_custom_rois = 1;
    else
        use_custom_rois = 0;
    end
    
    if use_custom_rois
        pos = define_custom_rois(current_roi); roi_data = get_custom_rois(pos,image_times);
    else
        roi_data = cellfun(@(x) x.image_data.data.rois.(rois{r}),all_files,'UniformOutput',false);
    end
    
    %   get the fix events associated with each session

    fix_events = cellfun(@(x) x.image_data.data.fix_events,all_files,'UniformOutput',false);

    %   get data labels in cell array form
    
    all_labels.days =           cellfun(@(x) x.image_data.labels.day,all_files,'UniformOutput',false);
    all_labels.sessions =       cellfun(@(x) x.image_data.labels.session,all_files,'UniformOutput',false);
    all_labels.file_names =     cellfun(@(x) x.image_data.labels.file_names,all_files,'UniformOutput',false);
    all_labels.monkeys =        cellfun(@(x) x.image_data.labels.monkey,all_files,'UniformOutput',false);
    all_labels.doses =          cellfun(@(x) x.image_data.labels.dose,all_files,'UniformOutput',false);
    all_labels.images =         cellfun(@(x) x.image_data.labels.category,all_files,'UniformOutput',false);
    all_labels.rois =           cellfun(@(x) x.image_data.labels.rois.(current_roi),all_files,'UniformOutput',false);

    data.(rois{r}) = get_fix_event_data(image_times,fix_events,all_labels,roi_data);
end

%   combine across rois

combined_data = combine_structs_across_rois(data);

%   using image category labels, add gender, expression, and gaze labels.
%       We *could* just add these in the loop above (they're stored in
%       imagedata), but doing so would require get_fix_event_data to needlessly loop
%       through 3 additional fields

combined_data = add_expr_gaze_gender_labs(combined_data);

%   optionally remove zeros from selected (or all) fields of combined_data

% combined_data = remove_zeros_from_data_struct(combined_data,{'lookingDuration'});
