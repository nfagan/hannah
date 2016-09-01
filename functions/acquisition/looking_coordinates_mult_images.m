function pos = looking_coordinates_mult_images(image,monkey,region,coordinates_and_labels)

if strcmp(monkey,'tarantino')
    screen_width = 1680;
    screen_height = 1050;
    fprintf('\nUsing tarantino''s resolution');
else
    screen_width = 1280; % resolution of the screen
    screen_height = 960;
end
    

keynote_arbitrary_width_and_height = 768;
actual_image_width_and_height = 400; % px;

middle_x = screen_width/2;
middle_y = screen_height/2;


if nargin < 4
    coordinates_and_labels = load_excel_roi_coordinates();
    labels = coordinates_and_labels.labels;
    all_coordinates = coordinates_and_labels.all_coordinates;
else
    all_coordinates = coordinates_and_labels.all_coordinates;
    labels = coordinates_and_labels.labels;    
end

if length(image) > 3
    if strncmpi(image,'out',3)
        image = 'out';
    elseif strncmpi(image,'scr',3)
        image = 'scr';
    end
end

if ~strcmp(region,'image')

    row_numbers = 1:size(labels,1); % for indexing later on

    roi_boundary_labels = labels(1,(~cellfun('isempty',labels(1,:))));
    image_row = row_numbers(strcmp(labels(:,1),image)) - 1; % subtract one because the values
                                                       % in all_coordinates
                                                       % have rows starting
                                                       % from 1, whereas the
                                                       % image labels in labels
                                                       % start on row 2

    if isempty(image_row)
        error('Could not find image ''%s''',image)
    end

    coordinates_of_wanted_image = all_coordinates(image_row,:);

    width_label = sprintf('%s width',region);
    height_label = sprintf('%s height',region);
    x_label = sprintf('%s x',region);
    y_label = sprintf('%s y',region);

    width = coordinates_of_wanted_image(strncmpi(roi_boundary_labels,width_label,length(width_label)));
    height = coordinates_of_wanted_image(strncmpi(roi_boundary_labels,height_label,length(height_label)));
    x = coordinates_of_wanted_image(strncmpi(roi_boundary_labels,x_label,length(x_label)));
    y = coordinates_of_wanted_image(strncmpi(roi_boundary_labels,y_label,length(y_label)));

    if isempty(width) || isempty(height) || isempty(x) || isempty(y) 
        error('Could not find complete set of roi coordinates for image ''%s'' and region ''%s''',image,region)
    end

    min_x = -actual_image_width_and_height/2 + (actual_image_width_and_height/768) * x;
    max_y = actual_image_width_and_height/2 - (actual_image_width_and_height/768) * y;

    max_x = min_x + (actual_image_width_and_height/keynote_arbitrary_width_and_height) * width;
    min_y = max_y - (actual_image_width_and_height/keynote_arbitrary_width_and_height) * height;
    
elseif strcmp(region,'image')
   min_x = -200;
   max_x = 200;
   min_y = -200;
   max_y = 200;
else
    error('Unrecognized region %s',region);
end

pos.minX = min_x + middle_x;
pos.maxX = max_x + middle_x;
pos.minY = min_y + middle_y;
pos.maxY = max_y + middle_y;



% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% y_pos_shift = (((y+height)/768)*400) - 200;
% y_neg_shift = ((y/768)*400) - 200;
% x_neg_shift = (((x+width)/768)*400) - 200;
% x_pos_shift = ((x/768)*400) - 200;
% 
% pos.minY = middle_y + y_neg_shift;
% pos.maxY = middle_y + y_pos_shift;
% pos.minX = middle_x + x_neg_shift;
% pos.maxX = middle_x + x_pos_shift;







% pos.minY = (((y+height)/768)*400) - 200;
% pos.maxY = ((y/768)*400) - 200;
% pos.minX = (((x+width)/768)*400) - 200;
% pos.maxX = ((x/768)*400) - 200;

% for i = 1:length(bounds);
% %     full_image_label = sprintf('%s %s',region,bounds{i});
% %     wanted_region_index = strncmpi(roi_boundary_labels,full_image_label,length(full_image_label));
% %     if sum(wanted_region_index) == 0
% %         error('Could not find gaze coordinates associated with ''%s %s''',region,bounds{i});
% %     end
% %     pos.(field_names{i}) = coordinates_of_wanted_image(wanted_region_index);
% end

% cd(start_path); % put us back where we started


