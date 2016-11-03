function data_values = normalize_roi_to_image(region_to_normalize,data_values,data_labels,varargin)

params = struct(...
    'requireEqualLengths',0 ...
);
params = structInpParse(params,varargin);

present_img_file_names = unique(data_labels.file_names);
present_monkeys = unique(data_labels.monkeys);

coordinates_and_labels = load_excel_roi_coordinates();

for m = 1:length(present_monkeys)
    current_monk = present_monkeys{m};
    
    for i = 1:length(present_img_file_names)
        current_image = present_img_file_names{i};

        pos_region_to_norm = looking_coordinates_mult_images(...
            current_image,current_monk,region_to_normalize,coordinates_and_labels);

        pos_image = looking_coordinates_mult_images(...
            current_image,current_monk,'image',coordinates_and_labels);

        [values_to_norm,~,index_of_vals_to_norm] = separate_data_struct(...
            data_values,data_labels,...
            'file_names',{current_image},...
            'rois',{region_to_normalize},...
            'monkeys',{current_monk});

        area_region_to_norm = ...
            (pos_region_to_norm.maxX - pos_region_to_norm.minX) ...
                * (pos_region_to_norm.maxY - pos_region_to_norm.minY);
        
        area_image = (pos_image.maxX - pos_image.minX) * (pos_image.maxY - pos_image.minY);
        
        prop = area_region_to_norm / area_image;

        normed_values = values_to_norm * prop;
        data_values(index_of_vals_to_norm,:) = normed_values;

    end
end





