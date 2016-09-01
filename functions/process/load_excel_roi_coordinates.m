function coordinates_and_labels = load_excel_roi_coordinates(excel_file)

if nargin < 1
    excel_file = ...
        '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/roi_coordinates/ROI Coordinates_one_sheet_2.xlsx';
end

[all_coordinates,labels] = xlsread(excel_file);

% - empty rows are loaded in as nans -- remove them. Mark the first
% value of empty_index to be false, because we don't want to remove the
% column headers, which start in column 2, and thus leave an empty cell in
% (1,1)

nan_index = sum(isnan(all_coordinates),2) >= 1;
empty_index = cellfun(@(x) isempty(x),labels); 
empty_index = empty_index(:,1); empty_index(1) = false;
all_coordinates(nan_index,:) = [];
labels(empty_index,:) = [];

labels = cellfun(@(x) lower(x),labels,'UniformOutput',false);

% - ensure that each image has an roi associated w/ it

if size(labels,1) ~= size(all_coordinates,1) + 1
    error('The sizes of the coordinates / numerical values and image file names do not match')
end

coordinates_and_labels.labels = labels;
coordinates_and_labels.all_coordinates = all_coordinates;

end