function pos = looking_coordinates_mult_images(image,region,coordinates_and_labels)

keynote_arbitrary_width_and_height = 768;
actual_image_width_and_height = 400; % px;

screen_width = 1280; % resolution of the screen
screen_height = 960;

middle_x = screen_width/2;
middle_y = screen_height/2;


if nargin < 3
    coordinates_and_labels = load_excel_roi_coordinates();
    labels = coordinates_and_labels.labels;
    all_coordinates = coordinates_and_labels.all_coordinates;
else
    all_coordinates = coordinates_and_labels.all_coordinates;
    labels = coordinates_and_labels.labels;    
end

row_numbers = 1:size(labels,1); % for indexing later on

roi_boundary_labels = labels(1,(~cellfun('isempty',labels(1,:))));
image_row = row_numbers(strcmp(labels(:,1),image)) - 1; % subtract one because the values
                                                   % in all_coordinates
                                                   % have rows starting
                                                   % from 1, whereas the
                                                   % image labels in labels
                                                   % start on row 2
if ~strcmp(region,'image')
    
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
    
else
    
    min_x = -200;
    max_x = 200;
    min_y = -200;
    max_y = 200;
    
end

pos.minX = min_x;
pos.maxX = max_x;
pos.minY = min_y;
pos.maxY = max_y;
% 
% pos.minX = min_x + middle_x;
% pos.maxX = max_x + middle_x;
% pos.minY = min_y + middle_y;
% pos.maxY = max_y + middle_y;


