function store_correlations = revision_roi_plots()
%%  load + setup

bounds = ...
  load( fullfile(pathfor('processedImageData'), '030617', 'eye_mouth_bounds.mat') );
fs = fieldnames( bounds );
bounds = bounds.( fs{1} );

eye_looks = ...
  load( fullfile(pathfor('processedImageData'), '022017', 'eye_roi_look_dur_and_times.mat') );
mouth_looks = ...
  load( fullfile(pathfor('processedImageData'), '022017', 'mouth_roi_look_dur_and_times.mat') );
eye_looks = eye_looks.( char(fieldnames(eye_looks)) ).looking_duration;
mouth_looks = mouth_looks.( char(fieldnames(mouth_looks)) ).looking_duration;
eye_looks = eye_looks.sparse();
mouth_looks = mouth_looks.sparse();
looks = eye_looks.append( mouth_looks );
% looks = looks.keep( looks.data ~= 0 );

iti_bounds = hww.io.load_iti_bounds();
iti_bounds = hannah__bin_within_bounds( iti_bounds, 50 );
iti_prop = iti_bounds.do_per( {'sessions', 'images'} ...
  , @hannah__relative_proportion_within_bounds, 0:1 );
iti_prop = iti_prop.rm( 'roi__0' );
iti_prop = iti_prop.replace( 'roi__1', 'image' );

within_bounds = bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
prop = within_bounds.do_per( {'sessions', 'images'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

prop = prop.rm( 'roi__0' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );

prop_orig = prop.mean( 2 );
% prop_orig = prop_orig.keep( prop_orig.data ~= 0 );

pl = ContainerPlotter();

savepath_plots = fullfile( pathfor('plots'), '051817', 'lookdur', 'raw' );
if ( exist(savepath_plots, 'dir') ~= 7 ), mkdir(savepath_plots); end;

savepath_data = fullfile( '~/Desktop/hannah_data', '051817' );
if ( exist(savepath_data, 'dir') ~= 7 ), mkdir(savepath_data); end;

%%  plot saline low high proportion means

prop = prop_orig;
prop = prop.mean( 2 );
prop = prop.do( {'sessions', 'rois'}, @mean );

figure;
pl.default();
pl.y_lim = [0 .3];
pl.order_by = { 'saline', 'low', 'high' };
pl.plot_by( prop, 'doses', 'monkeys', 'rois' );

%%  plot saline low high look dur means

per_roi = looks;
per_roi = per_roi.do( {'sessions', 'rois'}, @mean );

figure;
pl.default();
pl.y_lim = [0 2500];
pl.order_by = { 'saline', 'low', 'high' };
pl.plot_by( per_roi, 'doses', 'monkeys', 'rois' );

%%  get saline vs. percent change low high proportion means

raw_prop = prop_orig;
raw_prop = raw_prop.mean( 2 );
normed_prop = raw_prop.do( 'rois', @saline_normalize );
normed_prop = normed_prop.keep( ~isnan(normed_prop.data) & ~isinf(normed_prop.data) );
% % new
% normed_prop.data = abs( normed_prop.data - 1 );
% % end new
normed_prop = normed_prop.do( {'sessions', 'rois'}, @mean );
raw_prop = raw_prop.do( {'sessions', 'rois'}, @mean );

scatter_x = append( raw_prop.only('saline'), raw_prop.only('saline') );
N = scatter_x.shape(1);
scatter_x( 'doses', 1:N/2 ) = 'low';
scatter_x( 'doses', N/2+1:N ) = 'high';

scatter_y = normed_prop.rm( 'saline' );

X = scatter_x.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
Y = scatter_y.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );

%%  plot saline vs. percent change low high proportion means

pl.default();
pl.marker_size = 40;
pl.x_lim = [];
pl.y_lim = [];
pl.x_label = 'Raw proportion';
pl.y_label = 'Percent change from saline proportion';

pl.scatter( X, Y, 'images', 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportions' ...
  , 'with_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

pl.scatter( X, Y, {'monkeys', 'doses'}, 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportions' ...
  , 'without_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

% % old
% [r, p] = corr( X.data, Y.data, 'rows', 'complete' );
% % end old

%   new
[x_dose, ~, doses] = X.enumerate( 'rois' );
y_dose = Y.enumerate( 'rois' );
rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(rs) );
for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end
%   end new

correlations = struct();
across_doses = struct();
across_doses.rs = rs; across_doses.ps = ps; across_doses.labels = doses;
correlations.across_doses = across_doses;

[x_dose, ~, doses] = X.enumerate({'doses', 'rois'});
y_dose = Y.enumerate({'doses', 'rois'});

rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(x_dose, 1), 1 );

for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end

correlations.per_dose.r = rs;
correlations.per_dose.p = ps;
correlations.per_dose.doses = doses;

store_correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_proportions' );
store_correlations = store_correlations.sparse();

%%  get saline vs. percent change low high proportion means

raw_looks = looks;
raw_looks = raw_looks.mean( 2 );
normed_looks = raw_looks.do( 'rois', @saline_normalize );
normed_looks = normed_looks.keep( ~isnan(normed_looks.data) & ~isinf(normed_looks.data) );
% % new
% normed_looks.data = abs( normed_looks.data - 1 );
% % end new
normed_looks = normed_looks.do( {'sessions', 'rois'}, @mean );
raw_looks = raw_looks.do( {'sessions', 'rois'}, @mean );

scatter_x = append( raw_looks.only('saline'), raw_looks.only('saline') );
N = scatter_x.shape(1);
scatter_x( 'doses', 1:N/2 ) = 'low';
scatter_x( 'doses', N/2+1:N ) = 'high';

scatter_y = append( normed_looks.only('low'), normed_looks.only('high') );

X = scatter_x.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
Y = scatter_y.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );

pl.default();
pl.marker_size = 40;
pl.x_lim = [];
pl.y_lim = [];
pl.x_label = 'Raw looking duration';
pl.y_label = 'Percent change from saline looking duration';

pl.scatter( X, Y, 'images', 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'looks' ...
  , 'with_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

pl.scatter( X, Y, {'monkeys', 'doses'}, 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'looks' ...
  , 'without_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

% % old
% [r, p] = corr( X.data, Y.data, 'rows', 'complete' );
% % end old

%   new
[x_dose, ~, doses] = X.enumerate( 'rois' );
y_dose = Y.enumerate( 'rois' );
rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(rs) );
for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end
%   end new

correlations = struct();
across_doses = struct();
across_doses.rs = rs; across_doses.ps = ps; across_doses.labels = doses;
correlations.across_doses = across_doses;

[x_dose, ~, doses] = X.enumerate({'doses', 'rois'});
y_dose = Y.enumerate({'doses', 'rois'});

rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(x_dose, 1), 1 );

for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end

correlations.per_dose.r = rs;
correlations.per_dose.p = ps;
correlations.per_dose.doses = doses;

correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_looks' );
correlations = correlations.sparse();

store_correlations = store_correlations.append( correlations );


%%  get saline vs. percent change low high over_image means;

filename = 'image_face_mouth_eyes_roi_look_dur.mat';
looks = load( fullfile(pathfor('processedImageData'), '022017', filename) );
looks = looks.( char(fieldnames(looks)) );

[per_roi, ~, rois] = looks.enumerate( 'rois' );
img = per_roi{ strcmp(rois, 'image') };
others = per_roi( ~strcmp(rois, 'image') );
mouth_eyes = extend( others{:} );
img = cellfun( @(x) img, others, 'un', false );
image = extend( img{:} );

image.labels = mouth_eyes.labels;

over_image = mouth_eyes ./ image;
over_image = over_image.keep( ~isnan(over_image.data) );

raw_looks = over_image;
raw_looks = raw_looks.mean( 2 );
normed_looks = raw_looks.do( 'rois', @saline_normalize );
normed_looks = normed_looks.keep( ~isnan(normed_looks.data) & ~isinf(normed_looks.data) );
% % new
% normed_looks.data = abs( normed_looks.data - 1 );
% % end new
normed_looks = normed_looks.do( {'sessions', 'rois'}, @mean );
raw_looks = raw_looks.do( {'sessions', 'rois'}, @mean );

scatter_x = append( raw_looks.only('saline'), raw_looks.only('saline') );
N = scatter_x.shape(1);
scatter_x( 'doses', 1:N/2 ) = 'low';
scatter_x( 'doses', N/2+1:N ) = 'high';

scatter_y = append( normed_looks.only('low'), normed_looks.only('high') );

X = scatter_x.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
Y = scatter_y.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );

pl.default();
pl.marker_size = 40;
pl.x_lim = [];
pl.y_lim = [];
pl.x_label = 'Proportional looking duration';
pl.y_label = 'Percent change from saline proportional looking duration';

pl.scatter( X, Y, 'images', 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportional_looks' ...
  , 'with_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

pl.scatter( X, Y, {'monkeys', 'doses'}, 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportional_looks' ...
  , 'without_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

% % old
% [r, p] = corr( X.data, Y.data, 'rows', 'complete' );
% % end old

%   new
[x_dose, ~, doses] = X.enumerate( 'rois' );
y_dose = Y.enumerate( 'rois' );
rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(rs) );
for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end
%   end new

correlations = struct();
across_doses = struct();
across_doses.rs = rs; across_doses.ps = ps; across_doses.labels = doses;
correlations.across_doses = across_doses;

[x_dose, ~, doses] = X.enumerate({'doses', 'rois'});
y_dose = Y.enumerate({'doses', 'rois'});

rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(x_dose, 1), 1 );

for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end

correlations.per_dose.r = rs;
correlations.per_dose.p = ps;
correlations.per_dose.doses = doses;

correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_proportional_looks' );
correlations = correlations.sparse();

store_correlations = store_correlations.append( correlations );


%%  get saline vs. percent change low high proportion means
% 
% raw_looks = looks;
% raw_looks = raw_looks.mean( 2 );
% normed_looks = raw_looks.do( 'rois', @saline_normalize );
% normed_looks = normed_looks.keep( ~isnan(normed_looks.data) & ~isinf(normed_looks.data) );
% % % new
% % normed_looks.data = abs( normed_looks.data - 1 );
% % % end new
% normed_looks = normed_looks.do( {'sessions', 'rois'}, @mean );
% raw_looks = raw_looks.do( {'sessions', 'rois'}, @mean );
% 
% scatter_x = append( raw_looks.only('saline'), raw_looks.only('saline') );
% N = scatter_x.shape(1);
% scatter_x( 'doses', 1:N/2 ) = 'low';
% scatter_x( 'doses', N/2+1:N ) = 'high';
% 
% scatter_y = append( normed_looks.only('low'), normed_looks.only('high') );
% 
% X = scatter_x.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
% Y = scatter_y.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
% 
% pl.default();
% pl.marker_size = 40;
% pl.x_lim = [];
% pl.y_lim = [];
% pl.x_label = 'Raw looking duration';
% pl.y_label = 'Percent change from saline looking duration';
% 
% pl.scatter( X, Y, 'images', 'rois' );
% 
% filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'looks' ...
%   , 'with_line' );
% saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );
% 
% pl.scatter( X, Y, {'monkeys', 'doses'}, 'rois' );
% 
% filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'looks' ...
%   , 'without_line' );
% saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );
% 
% [r, p] = corr( X.data, Y.data, 'rows', 'complete' );
% 
% [x_dose, ~, doses] = X.enumerate({'doses', 'rois'});
% y_dose = Y.enumerate({'doses', 'rois'});
% 
% rs = zeros( size(x_dose, 1), 1 );
% ps = zeros( size(x_dose, 1), 1 );
% 
% for i = 1:numel(x_dose)
%   [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
% end
% 
% correlations = struct();
% correlations.across_doses = struct( 'r', r, 'p', p );
% correlations.per_dose.r = rs;
% correlations.per_dose.p = ps;
% correlations.per_dose.doses = doses;
% 
% correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_looks' );
% correlations = correlations.sparse();
% 
% store_correlations = store_correlations.append( correlations );


%%  get saline vs. percent change low high over_image means;

iti_prop = iti_prop.mean( 2 );
normed_iti_prop = iti_prop.do( 'rois', @saline_normalize );
normed_iti_prop = normed_iti_prop.keep( ...
  ~isnan(normed_iti_prop.data) & ~isinf(normed_iti_prop.data) );
raw_iti_prop = iti_prop;
% % new
% normed_looks.data = abs( normed_iti_prop.data - 1 );
% % end new
normed_iti_prop = normed_iti_prop.do( {'sessions', 'rois'}, @mean );
raw_iti_prop = raw_iti_prop.do( {'sessions', 'rois'}, @mean );

scatter_x = append( raw_iti_prop.only('saline'), raw_iti_prop.only('saline') );
N = scatter_x.shape(1);
scatter_x( 'doses', 1:N/2 ) = 'low';
scatter_x( 'doses', N/2+1:N ) = 'high';

scatter_y = append( normed_iti_prop.only('low'), normed_iti_prop.only('high') );

X = scatter_x.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );
Y = scatter_y.do( {'monkeys', 'doses', 'images', 'rois'}, @mean );

pl.default();
pl.marker_size = 40;
pl.x_lim = [];
pl.y_lim = [];
pl.x_label = 'Proportional looking duration during the iti';
pl.y_label = 'Percent change from saline proportional looking duration';

pl.scatter( X, Y, 'images', 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportional_iti_looks' ...
  , 'with_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

pl.scatter( X, Y, {'monkeys', 'doses'}, 'rois' );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'proportional_iti_looks' ...
  , 'without_line' );
saveas( gcf, fullfile(savepath_plots, filename), 'epsc' );

% % old
% [r, p] = corr( X.data, Y.data, 'rows', 'complete' );
% % end old

%   new
[x_dose, ~, doses] = X.enumerate( 'rois' );
y_dose = Y.enumerate( 'rois' );
rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(rs) );
for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end
%   end new

correlations = struct();
across_doses = struct();
across_doses.rs = rs; across_doses.ps = ps; across_doses.labels = doses;
correlations.across_doses = across_doses;

[x_dose, ~, doses] = X.enumerate({'doses', 'rois'});
y_dose = Y.enumerate({'doses', 'rois'});

rs = zeros( size(x_dose, 1), 1 );
ps = zeros( size(x_dose, 1), 1 );

for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data, 'rows', 'complete' );
end

correlations.per_dose.r = rs;
correlations.per_dose.p = ps;
correlations.per_dose.doses = doses;

correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_proportional_iti_looks' );
correlations = correlations.sparse();

store_correlations = store_correlations.append( correlations );


