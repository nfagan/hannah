function gaze = get_property_gaze(image,coordinates_and_labels)

if nargin < 2
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

row_numbers = 1:size(labels,1); % for indexing later on

roi_boundary_labels = labels(1,(~cellfun('isempty',labels(1,:))));
image_row = row_numbers(strcmp(labels(:,1),image)) - 1; % subtract one because the values
                                                   % in all_coordinates
                                                   % have rows starting
                                                   % from 1, whereas the
                                                   % image labels in labels
                                                   % start on row 2
coordinates_of_wanted_image = all_coordinates(image_row,:);
gaze = coordinates_of_wanted_image(strncmpi(roi_boundary_labels,'gaze',4));
