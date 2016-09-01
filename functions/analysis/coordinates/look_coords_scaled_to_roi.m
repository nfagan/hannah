function [coords,largest_roi] = look_coords_scaled_to_roi(coords)

%{
    TODO: percent of roi for x and y, scaled by x_target_roi / x_max_roi,
    and y_target_roi / y_max_roi, respectively
%}

coords = coords(~sum(isnan(coords),2) >= 1);

monkey =    unique(coords.labels.monkeys);
imgs =      unique(coords.labels.file_names);
rois =      unique(coords.labels.rois);

if length(monkey) > 1
    error('Can only look at one monkey at a time!');
end

if length(rois) > 1
    error('Can only look at one roi at a time!');
end

monkey = monkey{1};
region = rois{1};

largest_roi = get_master_roi(region,char(monkey),'max');

excel_coords = load_excel_roi_coordinates();

for i = 1:length(imgs)
    img = imgs{i};
    img_index = coords == img;
    img_coords = coords(img_index);
    
    pos = looking_coordinates_mult_images(img,monkey,region,excel_coords);
    
    %   get looking coordinates in percent *relative to top-left corner of
    %   image
    
    perc_x = img_coords(:,1).data ./ pos.minX;
    perc_y = img_coords(:,2).data ./ pos.minY;
    
    scale_factor_x = (pos.maxX - pos.minX) / (largest_roi.pos.maxX - largest_roi.pos.minX);
    scale_factor_y = (pos.maxY - pos.minY) / (largest_roi.pos.maxY - largest_roi.pos.minY);
    
    perc_x = perc_x .* scale_factor_x;
    perc_y = perc_y .* scale_factor_y;
    
    coords(img_index,:) = [perc_x perc_y];
    
end
