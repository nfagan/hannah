function [data_values,store_areas] = normalize_roi_to_roi(region_to_normalize,region_to_normalize_by,data_values,data_labels,varargin)

params = struct(...
    'requireEqualLengths',0 ...
);
params = structInpParse(params,varargin);

present_rois = unique(data_labels.rois);
present_img_file_names = unique(data_labels.file_names);

if ~any(strcmpi(present_rois,region_to_normalize)) || ...
        ~any(strcmpi(present_rois,region_to_normalize_by))
    error(['Either the region to normalize or the region to normalize by' ...
        , ' is not present in the data labels struct']);
end

coordinates_and_labels = load_excel_roi_coordinates(); stp = 1;
for i = 1:length(present_img_file_names)
    current_image = present_img_file_names{i};
    
    pos_region_to_norm = looking_coordinates_mult_images(...
        current_image,region_to_normalize,coordinates_and_labels);
    pos_region_to_norm_by = looking_coordinates_mult_images(...
        current_image,region_to_normalize_by,coordinates_and_labels);
    
    [values_to_norm,~,index_of_vals_to_norm] = separate_data_struct(...
        data_values,data_labels,'file_names',{current_image},'rois',{region_to_normalize});
    values_to_norm_by = separate_data_struct(...
        data_values,data_labels,'file_names',{current_image},'rois',{region_to_normalize_by});
    
    if length(values_to_norm) ~= length(values_to_norm_by)
        if params.requireEqualLengths
            error('Sizes must match between to-normalize and normalizing-by values');
        else
            fprintf(['\nWARNING: There is an unequal amount of data associated with' ...
                , ' ''%s'' and ''%s'', and a mean of ''%s'' will be used to normalize.']...
                , region_to_normalize,region_to_normalize_by,region_to_normalize_by);
            values_to_norm_by = mean(values_to_norm_by);
        end
    end
    
    zeros_in_values_to_norm_by = values_to_norm_by == 0;
    values_to_norm_by(zeros_in_values_to_norm_by) = NaN;
    values_to_norm(zeros_in_values_to_norm_by) = NaN;
    
    area_region_to_norm = ...
        (pos_region_to_norm.maxX - pos_region_to_norm.minX) ...
            * (pos_region_to_norm.maxY - pos_region_to_norm.minY);

    area_region_to_norm_by = ...
        (pos_region_to_norm_by.maxX - pos_region_to_norm_by.minX) ...
            * (pos_region_to_norm_by.maxY - pos_region_to_norm_by.minY);
    
    store_areas(stp).to_norm = area_region_to_norm;
    store_areas(stp).to_norm_by = area_region_to_norm_by;
    stp = stp + 1;

%     %when norming by both looking times
        normed_values = (values_to_norm .* area_region_to_norm_by)...
        ./(values_to_norm_by .* area_region_to_norm);

%     %when norming by both areas but not larger looking time
%         normed_values = (values_to_norm .* area_region_to_norm_by)...
%         ./(area_region_to_norm);

    data_values(index_of_vals_to_norm,:) = normed_values;
    
end





