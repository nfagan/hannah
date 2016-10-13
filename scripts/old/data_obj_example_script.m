%%
load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0727/fixEventDuration.mat');

%%

fix = DataObject(quad_fix);

eph = fix(fix == 'ephron' & fix ~= {'scrambled','outdoors'});
hitch = fix(fix == 'hitch' & fix ~= {'scrambled','outdoors'});

eph_gend = collapse(eph,'gender');

all_together = [eph;hitch];

sessions = unique(all_together.labels.sessions);

for i = 1:length(sessions)
    current_session = all_together(all_together == sessions{i});
    fprintf('\n%d',count(current_session));
end

%%
base_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/';
times = load_save_field(fullfile(base_dir,'/0725/Time.mat'));
coordinates = load_save_field(fullfile(base_dir,'/0725/Coordinates.mat'));

coords = DataObject(coordinates);
time = DataObject(times);

%%

eph = coords(coords == {'hitch','image','saline'} & coords ~= {'scrambled','outdoors'});

perc = percentage_coordinates(eph,'image');
%%

% roi.minX = 1280/2 - 200;
% roi.maxX = 1280/2 + 200;
% roi.minY = 720/2 - 200;
% roi.maxY = 720/2 + 200;

roi.minX = 0; 
roi.maxX = 1;
roi.minY = 0;
roi.maxY = 1;

bin.x = .005;
bin.y = .005;

binned = gaze_heatmap(perc,roi,bin,'clims',[0 1]);



