%%
base_dir = pathfor('processedImageData');

original.times = load_save_field(fullfile(base_dir,'/0725/Time.mat'));
original.coordinates = load_save_field(fullfile(base_dir,'/0725/Coordinates.mat'));
original.fixations = load_save_field(fullfile(base_dir,'/0725/fixEventDuration.mat'));

coords = DataObject(original.coordinates);
time = DataObject(original.times);
fix = DataObject(original.fixations);

%%

eph = coords(coords == {'hitch','image','saline'} & coords ~= {'scrambled','outdoors'});

perc = percentage_coordinates(eph,'image');
%%

% roi.minX = 1280/2 - 200;
% roi.maxX = 1280/2 + 200;
% roi.minY = 720/2 - 200;
% roi.maxY = 720/2 + 200;

roi.minX = 1; 
roi.maxX = 1.845;
roi.minY = 1;
roi.maxY = 2.25;

bin.x = .005;
bin.y = .005;

binned = gaze_heatmap(perc,roi,bin,'clims',[0 1],'overlaidImage',[],'flip',false);

%%

eph = coords(coords == {'ephron','face','low'} & coords ~= {'scrambled','outdoors'});
[perc,largest_roi] = look_coords_scaled_to_roi(eph);

%%



