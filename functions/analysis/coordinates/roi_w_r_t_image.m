function difference = roi_w_r_t_image(other_roi,monkey,target_file)

if nargin < 3
    target_file = 'ugit0412';
end

image_roi = looking_coordinates_mult_images(target_file,monkey,'image');

fields = fieldnames(image_roi);

is_same = zeros(1,length(fields));

for i = 1:length(fields)
    try
        is_same(i) = image_roi.(fields{i}) == other_roi.(fields{i});
    catch
        error('Fields are not the same between image and other roi');
    end
end

if sum(is_same) == length(is_same)
    error('rois are the same');
end

difference = struct();
for i = 1:length(fields)
    difference.(fields{i}) = other_roi.(fields{i}) - image_roi.(fields{i});
end



