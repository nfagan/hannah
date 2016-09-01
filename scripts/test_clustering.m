coordinates_file = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0718/coordinates.mat';
load(coordinates_file);
original_coordinates = coordinates;

%%

coordinates = original_coordinates;

%   set dimensions

img_width = 400;
img_height = 400;
screen_width = 1280;
screen_height = 960;

%   get index of within-image coordinates

within_x_bounds = (original_coordinates.data(:,1) > (screen_width/2 - img_width/2)) & ...
    (original_coordinates.data(:,1) < (screen_width/2 + img_width/2));
within_y_bounds = (original_coordinates.data(:,2) > (screen_height/2 - img_height/2)) & ...
    (original_coordinates.data(:,2) < (screen_height/2 + img_height/2));
within_bounds = within_x_bounds & within_y_bounds;

%   remove nans and index based on picture coordinates

valid_ind = ~isnan(original_coordinates.data);
valid_ind = sum(valid_ind,2) >= 1 & within_bounds;
coordinates = index_obj(original_coordinates,valid_ind);

%   remove scrambled + outdoors

coordinates = separate_data_obj(coordinates,'images',{'--scrambled'});
coordinates = separate_data_obj(coordinates,'images',{'--outdoors'});

%   optionally separate further

categories = {'ubdn'};
coordinates = separate_data_obj(coordinates,'images',categories);

%   fit gm

n_clusters = 2;

options = statset('Display','final');
gm = fitgmdist(coordinates.data,n_clusters,'Options',options);

%%
figure;
scatter(coordinates.data(:,1),coordinates.data(:,2),10,'ko')

hold on;
ezcontour(@(x,y)pdf(gm,[x y]),[0 1280],[0 960]);
%%

idx = cluster(gm,coordinates.data);
cluster1 = (idx == 1); % |1| for cluster 1 membership
cluster2 = (idx == 2); % |2| for cluster 2 membership

figure;
gscatter(coordinates.data(:,1),coordinates.data(:,2),idx,'rb','+o');

%%

idx = cluster(gm,coordinates.data);
P = posterior(gm,coordinates.data);

shapes = {'+','o','*','x'};

figure;
for i = 1:n_clusters
    
current_cluster = idx == i;

scatter(coordinates.data(current_cluster,1),coordinates.data(current_cluster,2),10,P(current_cluster,1),shapes{i});
hold on;
colormap('jet');
% scatter(coordinates.data(cluster2,1),coordinates.data(cluster2,2),10,P(cluster2,1),'o');

end

title(categories);
d = colorbar;


