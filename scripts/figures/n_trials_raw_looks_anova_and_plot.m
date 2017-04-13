%%  load

load( 'sparse_measures_outliersremoved' );
looks = measures.lookdur;
looks = looks.only( 'image' );

%%  raw looking duration to all images, across monkeys, per dose

meaned = looks.do_per( 'doses', @mean );

%%  raw looking duration to all images, up / down per dose

updown = looks;
updown_mean = looks;

updown_mean = updown_mean.do_per( {'monkeys', 'doses'}, @mean );
updown_mean = updown_mean.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
updown_mean = updown_mean.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

updown = updown.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
updown = updown.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

%%  group means for raw looks

means = updown_mean.do_per( {'monkeys', 'doses'}, @mean );
devs = updown_mean.do_per( {'monkeys', 'doses'}, @std );

%%  plot raw look

figure;
pl = ContainerPlotter();
pl.default();
pl.add_points = true;
pl.order_by = { 'upGroup', 'downGroup' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.save_outer_folder = '~/Desktop/hannah_data/032817/raw_looks/plots';
pl.plot_and_save( updown_mean, 'rois', @bar, 'monkeys', 'doses', 'rois' );

%%  anova for raw looking duration to all images, group x dose x image

groups = { 'monkeys', 'doses', 'images' };
labs = updown.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

figure;
[~, ~, stats] = anovan( updown.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2 3] );

%%  anova for raw looking duration to all images, within group, dose x image

group_name = 'downGroup';
current_group = updown.only( group_name );
groups = { 'doses', 'images' };
labs = current_group.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

figure;
[~, ~, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2] );

dlmwrite( [group_name '_post_hoc.txt'], c );

%%  n trials completed per dose for up / down, per session,
%
%   anova with group and dose as factors; get means and devs per group x
%   dose

n_trials = updown;
n_trials_total = n_trials.shape(1);
data = ones( n_trials_total, 1 );
n_trials.data = data;

n_trials = n_trials.do_per( {'monkeys', 'doses', 'sessions'}, @sum );

groups = { 'monkeys', 'doses' };
labs = n_trials.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( n_trials.data, labels, 'varnames', groups, 'model', 'full' );
c = multcompare( stats, 'dimension', [1 2] );

means = n_trials.do_per( {'monkeys', 'doses'}, @mean );
devs = n_trials.do_per( {'monkeys', 'doses'}, @std );

cd ~/Desktop/

%%  plot n trials

pl = ContainerPlotter();
pl.default();
pl.order_by = { 'upGroup', 'downGroup' };
pl.bar( n_trials, 'monkeys', 'doses', 'rois' );
