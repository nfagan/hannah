function coords = percentage_coordinates(coords,region)

coords = coords(~isnan(coords));
coordinates_map = load_excel_roi_coordinates();
monkeys = unique(coords.labels.monkeys);

for m = 1:length(monkeys)

monk_ind = coords == monkeys{m};
monk = coords(monk_ind);
filenames = unique(monk.labels.file_names);

for i = 1:length(filenames)
    
    filename_ind = coords == {monkeys{m},filenames{i}};
    
    roi = looking_coordinates_mult_images(filenames{i},monkeys{m},region,coordinates_map);
    
    extr_coords = obj2struct(coords(filename_ind));
    
%     x = extr_coords.data(:,1); 
%     y = extr_coords.data(:,2);
    x = coords(filename_ind,1).data;
    y = coords(filename_ind,2).data;
    
    percent_x = (x - roi.minX)./(roi.maxX - roi.minX);
    percent_y = (y - roi.minY)./(roi.maxY - roi.minY);
    
%     coords([filename_ind filename_ind]) = [percent_x percent_y];
    coords(filename_ind,:) = [percent_x percent_y];
end
end

