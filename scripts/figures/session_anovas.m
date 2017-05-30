function anovas = session_anovas()
%%  ANOVAS

load_path = ...
  fullfile( pathfor('processedImageData'), '110716', 'sparse_measures_outliersremoved.mat' );
measures = load( load_path );
fields = fieldnames( measures );
measures = measures.( fields{1} );

looks = measures.lookdur;
looks = looks.only( 'image' );

anovas = Container();
anova_labels = struct();

%%  NORMED

normed = saline_normalize( looks );

%%  NTRIALS

ntrials = looks;
n_total_trials = ntrials.shape(1);
new_data = ones( n_total_trials, 1 );
ntrials.data = new_data;

ntrials = ntrials.do_per( {'sessions'}, @sum );
ntrials = ntrials.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
ntrials = ntrials.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

groups = { 'monkeys', 'doses' };
labels = labels_for_anova( ntrials, groups );

[~, tbl, stats] = anovan( ntrials.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

ntrials_anova = struct();
for i = 1:numel(groups)
  ntrials_anova.effects.(groups{i}).means = ntrials.do_per( groups{i}, @mean );
  ntrials_anova.effects.(groups{i}).devs = ntrials.do_per( groups{i}, @std );
end

ntrials_anova.effects.interaction.mean = ntrials.do_per( groups, @mean );
ntrials_anova.effects.interaction.dev = ntrials.do_per( groups, @std );

ntrials_anova.comparisons = c;
ntrials_anova.group_names = gnames;

anova_labels.type = {'ntrials'};
data_struct = struct( 'table', {tbl}, 'descriptives', ntrials_anova );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect ALL images, with group

bidirect = looks;

bidirect = bidirect.do_per( {'images', 'sessions'}, @mean );
bidirect = bidirect.do_per( {'monkeys', 'doses', 'sessions'}, @mean );

bidirect = bidirect.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
bidirect = bidirect.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

groups = { 'monkeys', 'doses' };

labels = labels_for_anova( bidirect, groups );

[~, tbl, stats] = anovan( bidirect.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

bidirect_anova_with_group = struct();
for i = 1:numel(groups)
  bidirect_anova_with_group.effects.(groups{i}).means = bidirect.do_per( groups{i}, @mean );
  bidirect_anova_with_group.effects.(groups{i}).devs = bidirect.do_per( groups{i}, @std );
end

bidirect_anova_with_group.effects.interaction.mean = bidirect.do_per( groups, @mean );
bidirect_anova_with_group.effects.interaction.dev = bidirect.do_per( groups, @std );

bidirect_anova_with_group.comparisons = c;
bidirect_anova_with_group.group_names = gnames;

anova_labels.type = {'bidirect_with_group'};
data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_anova_with_group );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect ALL images, per group

per_group = bidirect.enumerate( 'monkeys' );
groups = { 'doses' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  bidirect_anova_per_group = struct();
  for k = 1:numel(groups)
    bidirect_anova_per_group.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    bidirect_anova_per_group.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  bidirect_anova_per_group.comparisons = [];
  bidirect_anova_per_group.group_names = gnames;
  
  anova_labels.type = { sprintf('bidirect_per_group_%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_anova_per_group );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end

%%  bidirect, social v nonsocial, with group

social_bidirect = looks;

social_bidirect = social_bidirect.do_per( {'images', 'sessions'}, @mean );
social_bidirect = social_bidirect.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
social_bidirect = social_bidirect.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

nonsoc_ind = social_bidirect.where( {'outdoors', 'scrambled'} );
social_bidirect( 'images', nonsoc_ind ) = 'nonsocial';
social_bidirect( 'images', ~nonsoc_ind ) = 'social';

groups = { 'monkeys', 'doses', 'images' };

labels = labels_for_anova( social_bidirect, groups );

[~, tbl, stats] = anovan( social_bidirect.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

bidirect_social_v_nonsocial_with_group = struct();
for i = 1:numel(groups)
  bidirect_social_v_nonsocial_with_group.effects.(groups{i}).means = social_bidirect.do_per( groups{i}, @mean );
  bidirect_social_v_nonsocial_with_group.effects.(groups{i}).devs = social_bidirect.do_per( groups{i}, @std );
end

bidirect_social_v_nonsocial_with_group.effects.interaction.mean = social_bidirect.do_per( groups, @mean );
bidirect_social_v_nonsocial_with_group.effects.interaction.dev = social_bidirect.do_per( groups, @std );

bidirect_social_v_nonsocial_with_group.comparisons = c;
bidirect_social_v_nonsocial_with_group.group_names = gnames;

anova_labels.type = {'bidirect_social_v_nonsocial_with_group'};
data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_v_nonsocial_with_group );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, social v nonsocial, per group

per_group = social_bidirect.enumerate( 'monkeys' );
groups = { 'doses', 'images' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  bidirect_social_v_nonsocial_per_group = struct();
  for k = 1:numel(groups)
    bidirect_social_v_nonsocial_per_group.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    bidirect_social_v_nonsocial_per_group.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  bidirect_social_v_nonsocial_per_group.effects.interaction.mean = current_group.do_per( groups, @mean );
  bidirect_social_v_nonsocial_per_group.effects.interaction.dev = current_group.do_per( groups, @std );
  
  bidirect_social_v_nonsocial_per_group.comparisons = c;
  bidirect_social_v_nonsocial_per_group.group_names = gnames;
  
  anova_labels.type = { sprintf('bidirect_social_v_nonsocial_per_group%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_v_nonsocial_per_group );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end

%%  bidirect, social only, with group

social_only = social_bidirect.only( 'social' );

groups = { 'monkeys', 'doses', 'gazes', 'expressions' };

labels = labels_for_anova( social_only, groups );

[~, tbl, stats] = anovan( social_only.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

bidirect_social_only_with_group = struct();
for i = 1:numel(groups)
  bidirect_social_only_with_group.effects.(groups{i}).means = social_only.do_per( groups{i}, @mean );
  bidirect_social_only_with_group.effects.(groups{i}).devs = social_only.do_per( groups{i}, @std );
end

bidirect_social_only_with_group.effects.interaction.mean = social_only.do_per( groups, @mean );
bidirect_social_only_with_group.effects.interaction.dev = social_only.do_per( groups, @std );

bidirect_social_only_with_group.comparisons = c;
bidirect_social_only_with_group.group_names = gnames;

anova_labels.type = {'bidirect_social_only_with_group'};
data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_only_with_group );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, social only, per group

per_group = social_only.enumerate( 'monkeys' );
groups = { 'doses', 'gazes', 'expressions' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  bidirect_social_only_per_group = struct();
  for k = 1:numel(groups)
    bidirect_social_only_per_group.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    bidirect_social_only_per_group.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  bidirect_social_only_per_group.effects.interaction.mean = current_group.do_per( groups, @mean );
  bidirect_social_only_per_group.effects.interaction.dev = current_group.do_per( groups, @std );
  
  bidirect_social_only_per_group.comparisons = c;
  bidirect_social_only_per_group.group_names = gnames;
  
  anova_labels.type = { sprintf('bidirect_social_only_per_group%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_only_per_group );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end

%%  bidirect, social only, with group %change from saline

social_only_normed = make_ud( normed );
nonsoc = social_only_normed.where( {'outdoors', 'scrambled'} );
social_only_normed = social_only_normed( ~nonsoc );
social_only_normed = social_only_normed.rm( 'saline' );

groups = { 'monkeys', 'doses', 'gazes', 'expressions' };

labels = labels_for_anova( social_only_normed, groups );

[~, tbl, stats] = anovan( social_only_normed.data, labels, 'varnames', groups, 'model', 'full', 'display', 'off' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

bidirect_social_only_with_group_percent_change = struct();
for i = 1:numel(groups)
  bidirect_social_only_with_group_percent_change.effects.(groups{i}).means = ...
    social_only_normed.do_per( groups{i}, @mean );
  bidirect_social_only_with_group_percent_change.effects.(groups{i}).devs = ...
    social_only_normed.do_per( groups{i}, @std );
end

bidirect_social_only_with_group_percent_change.effects.interaction.mean = social_only_normed.do_per( groups, @mean );
bidirect_social_only_with_group_percent_change.effects.interaction.dev = social_only_normed.do_per( groups, @std );

bidirect_social_only_with_group_percent_change.comparisons = c;
bidirect_social_only_with_group_percent_change.group_names = gnames;

anova_labels.type = {'bidirect_social_only_with_group_percent_change'};
data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_only_with_group_percent_change );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, social only, per group %change from saline

per_group = social_only_normed.enumerate( 'monkeys' );
groups = { 'doses', 'gazes', 'expressions' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full', 'display', 'off' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  bidirect_social_only_per_group_percent_change = struct();
  for k = 1:numel(groups)
    bidirect_social_only_per_group_percent_change.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    bidirect_social_only_per_group_percent_change.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  bidirect_social_only_per_group_percent_change.effects.interaction.mean = current_group.do_per( groups, @mean );
  bidirect_social_only_per_group_percent_change.effects.interaction.dev = current_group.do_per( groups, @std );
  
  bidirect_social_only_per_group_percent_change.comparisons = c;
  bidirect_social_only_per_group_percent_change.group_names = gnames;
  
  anova_labels.type = { sprintf('bidirect_social_only_per_group_percent_change%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_only_per_group_percent_change );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end


%%  bidirect, social vs. nonsocial, %change from saline, with group

soc_nonsoc_perc = looks;

sal = do_per( soc_nonsoc_perc.only('saline'), {'monkeys', 'doses', 'images'}, @mean );
soc_nonsoc_perc = soc_nonsoc_perc.do_per( {'images', 'sessions'}, @mean );
[objs, inds] = soc_nonsoc_perc.enumerate( {'monkeys', 'doses', 'images', 'sessions'} );
for i = 1:numel( objs )
  current = objs{i};
  monk_lab = char( current('monkeys') );
  image_lab = char( current('images') );
  sal_ind = sal.where( {monk_lab, image_lab} );
  soc_nonsoc_perc.data( inds{i} ) = soc_nonsoc_perc.data(inds{i}) ./ sal.data(sal_ind); 
end

soc_nonsoc_perc = soc_nonsoc_perc.rm( 'saline' );
soc_nonsoc_perc = soc_nonsoc_perc.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
soc_nonsoc_perc = soc_nonsoc_perc.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

nonsoc_ind = soc_nonsoc_perc.where( {'outdoors', 'scrambled'} );
soc_nonsoc_perc( 'images', nonsoc_ind ) = 'nonsocial';
soc_nonsoc_perc( 'images', ~nonsoc_ind ) = 'social';

%   added this

% soc_nonsoc_perc = soc_nonsoc_perc.do_per( {'sessions', 'images'}, @mean );

%   end added this


groups = { 'monkeys', 'doses', 'images' };

labels = labels_for_anova( soc_nonsoc_perc, groups );

[~, tbl, stats] = anovan( soc_nonsoc_perc.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

bidirect_social_v_nonsocial_with_group = struct();
for i = 1:numel(groups)
  bidirect_social_v_nonsocial_with_group.effects.(groups{i}).means = soc_nonsoc_perc.do_per( groups{i}, @mean );
  bidirect_social_v_nonsocial_with_group.effects.(groups{i}).devs = soc_nonsoc_perc.do_per( groups{i}, @std );
end

bidirect_social_v_nonsocial_with_group.effects.interaction.mean = soc_nonsoc_perc.do_per( groups, @mean );
bidirect_social_v_nonsocial_with_group.effects.interaction.dev = soc_nonsoc_perc.do_per( groups, @std );

bidirect_social_v_nonsocial_with_group.comparisons = c;
bidirect_social_v_nonsocial_with_group.group_names = gnames;

anova_labels.type = {'bidirect_social_v_nonsocial_with_group_percent_change'};
data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_v_nonsocial_with_group );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, social vs. nonsocial, %change from saline, per group

per_group = soc_nonsoc_perc.enumerate( 'monkeys' );
groups = { 'doses', 'images' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  bidirect_social_v_nonsocial_per_group = struct();
  for k = 1:numel(groups)
    bidirect_social_v_nonsocial_per_group.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    bidirect_social_v_nonsocial_per_group.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  bidirect_social_v_nonsocial_per_group.effects.interaction.mean = current_group.do_per( groups, @mean );
  bidirect_social_v_nonsocial_per_group.effects.interaction.dev = current_group.do_per( groups, @std );
  
  bidirect_social_v_nonsocial_per_group.comparisons = c;
  bidirect_social_v_nonsocial_per_group.group_names = gnames;
  
  anova_labels.type = { sprintf('bidirect_social_v_nonsocial_with_group_percent_change%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', bidirect_social_v_nonsocial_per_group );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end

%%  bidirect, with group, social v. nosocial, only saline, raw

social_bidirect = looks.only( 'saline' );

social_bidirect = social_bidirect.do_per( {'images', 'sessions'}, @mean );
social_bidirect = make_ud( social_bidirect );

nonsoc_ind = social_bidirect.where( {'outdoors', 'scrambled'} );
social_bidirect( 'images', nonsoc_ind ) = 'nonsocial';
social_bidirect( 'images', ~nonsoc_ind ) = 'social';

groups = { 'monkeys', 'images' };

labels = labels_for_anova( social_bidirect, groups );

[~, tbl, stats] = anovan( social_bidirect.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

social_v_nonsocial_with_group_only_saline = struct();
for i = 1:numel(groups)
  social_v_nonsocial_with_group_only_saline.effects.(groups{i}).means = social_bidirect.do_per( groups{i}, @mean );
  social_v_nonsocial_with_group_only_saline.effects.(groups{i}).devs = social_bidirect.do_per( groups{i}, @std );
end

social_v_nonsocial_with_group_only_saline.effects.interaction.mean = social_bidirect.do_per( groups, @mean );
social_v_nonsocial_with_group_only_saline.effects.interaction.dev = social_bidirect.do_per( groups, @std );

social_v_nonsocial_with_group_only_saline.comparisons = c;
social_v_nonsocial_with_group_only_saline.group_names = gnames;

anova_labels.type = {'social_v_nonsocial_with_group_only_saline'};
data_struct = struct( 'table', {tbl}, 'descriptives', social_v_nonsocial_with_group_only_saline );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, per group, social v. nosocial, only saline, raw

per_group = social_bidirect.enumerate( 'monkeys' );
groups = { 'images' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  social_v_nonsocial_per_group_only_saline = struct();
  for k = 1:numel(groups)
    social_v_nonsocial_per_group_only_saline.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    social_v_nonsocial_per_group_only_saline.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  social_v_nonsocial_per_group_only_saline.effects.interaction.mean = current_group.do_per( groups, @mean );
  social_v_nonsocial_per_group_only_saline.effects.interaction.dev = current_group.do_per( groups, @std );
  
  social_v_nonsocial_per_group_only_saline.comparisons = c;
  social_v_nonsocial_per_group_only_saline.group_names = gnames;
  
  anova_labels.type = { sprintf('social_v_nonsocial_per_group_only_saline%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', social_v_nonsocial_per_group_only_saline );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end

%%  bidirect, with group, social only, saline only, raw

social_bidirect = social_bidirect.only( 'social' );

groups = { 'monkeys', 'expressions', 'gazes' };

labels = labels_for_anova( social_bidirect, groups );

[~, tbl, stats] = anovan( social_bidirect.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

social_with_group_only_saline = struct();
for i = 1:numel(groups)
  social_with_group_only_saline.effects.(groups{i}).means = social_bidirect.do_per( groups{i}, @mean );
  social_with_group_only_saline.effects.(groups{i}).devs = social_bidirect.do_per( groups{i}, @std );
end

social_with_group_only_saline.effects.interaction.mean = social_bidirect.do_per( groups, @mean );
social_with_group_only_saline.effects.interaction.dev = social_bidirect.do_per( groups, @std );

social_with_group_only_saline.comparisons = c;
social_with_group_only_saline.group_names = gnames;

anova_labels.type = {'social_with_group_only_saline'};
data_struct = struct( 'table', {tbl}, 'descriptives', social_with_group_only_saline );

anovas = anovas.append( Container(data_struct, anova_labels) );

%%  bidirect, per group, social v. nosocial, only saline, raw

per_group = social_bidirect.enumerate( 'monkeys' );
groups = { 'expressions', 'gazes' };
for i = 1:numel(per_group)
  
  current_group = per_group{i};
  current_group_name = char( current_group('monkeys') );
  labels = labels_for_anova( current_group, groups );
  [~, tbl, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );
  
  social_per_group_only_saline = struct();
  for k = 1:numel(groups)
    social_per_group_only_saline.(groups{k}).mean = current_group.do_per( groups{k}, @mean );
    social_per_group_only_saline.(groups{k}).dev = current_group.do_per( groups{k}, @std );
  end
  
  social_per_group_only_saline.effects.interaction.mean = current_group.do_per( groups, @mean );
  social_per_group_only_saline.effects.interaction.dev = current_group.do_per( groups, @std );
  
  social_per_group_only_saline.comparisons = c;
  social_per_group_only_saline.group_names = gnames;
  
  anova_labels.type = { sprintf('social_per_group_only_saline%s', current_group_name) };
  data_struct = struct( 'table', {tbl}, 'descriptives', social_per_group_only_saline );
  
  anovas = anovas.append( Container(data_struct, anova_labels) );
end
