image_directory = fullfile(pathfor('images'),'condensed_across_categories');

monkey = 'ephron';

roi_info = get_master_roi('face',monkey);

file = [roi_info.filename '.jpg'];
pos = roi_info.pos;

image = imread(fullfile(image_directory,file));

difference = roi_w_r_t_image(pos,monkey,roi_info.filename);
offset_x = difference.minX;
offset_y = difference.minY;

width = pos.maxX - pos.minX;
height = pos.maxY - pos.minY; 

cropped = imcrop(image,[offset_x offset_y width height]);

figure;
imshow(image);
figure;
imshow(cropped);

%% get max x- and y-max in percentage terms

max_perc.x = pos.maxX / pos.minX;
max_perc.y = pos.maxY / pos.minY;


