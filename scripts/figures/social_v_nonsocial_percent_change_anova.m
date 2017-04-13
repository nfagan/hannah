%%  overall anova -- raw data, social only

social_anova = looks;

social_anova = social_anova.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
social_anova = social_anova.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );
social_anova = social_anova.rm( {'outdoors', 'scrambled'} );

groups = { 'monkeys', 'doses', 'gazes', 'expressions' };
labs = social_anova.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( social_anova.data, labels, 'varnames', groups, 'model', 'full' );
c = multcompare( stats, 'dimension', 1:numel(groups) );

%%  overall anova -- raw data, social v. nonsocial

social_anova = looks;

social_anova = social_anova.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
social_anova = social_anova.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );
nonsoc_ind = social_anova.where( {'outdoors', 'scrambled'} );
social_anova( 'images', nonsoc_ind ) = 'nonsocial';
social_anova( 'images', ~nonsoc_ind ) = 'social';

groups = { 'monkeys', 'doses', 'images' };
labs = social_anova.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( social_anova.data, labels, 'varnames', groups );

%%  'social' anova -- % change from saline

social_anova = looks;

sal = social_anova.only( 'saline' );
sal = sal.do_per( {'monkeys', 'doses', 'images'}, @mean );
[objs, inds] = social_anova.enumerate( {'monkeys', 'doses', 'images'} );
for i = 1:numel( objs )
  current = objs{i};
  monk_lab = char( current('monkeys') );
  image_lab = char( current('images') );
  sal_ind = sal.where( {monk_lab, image_lab} );
  social_anova.data( inds{i} ) = social_anova.data(inds{i}) ./ sal.data(sal_ind); 
end

social_anova = social_anova.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
social_anova = social_anova.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );
social_anova = social_anova.rm( {'outdoors', 'scrambled'} );
social_anova = social_anova.rm( 'saline' );

groups = { 'monkeys', 'images', 'doses' };
labs = social_anova.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( social_anova.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2] );

%%  'social' anova -- per group

group_name = 'upGroup';
current_group = social_anova.only( group_name );

groups = { 'doses', 'gazes', 'expressions' };
labs = current_group.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
% [c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2] );

%%  'social' vs. nonsocial anova -- % change from saline, group x image x dose

social_anova = looks;

sal = social_anova.only( 'saline' );
sal = sal.do_per( {'monkeys', 'doses', 'images'}, @mean );
[objs, inds] = social_anova.enumerate( {'monkeys', 'doses', 'images'} );
for i = 1:numel( objs )
  current = objs{i};
  monk_lab = char( current('monkeys') );
  image_lab = char( current('images') );
  sal_ind = sal.where( {monk_lab, image_lab} );
  social_anova.data( inds{i} ) = social_anova.data(inds{i}) ./ sal.data(sal_ind); 
end

social_anova = social_anova.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
social_anova = social_anova.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

nonsoc_ind = social_anova.where( {'outdoors', 'scrambled'} );
social_anova( 'images', nonsoc_ind ) = 'nonsocial';
social_anova( 'images', ~nonsoc_ind ) = 'social';

groups = { 'monkeys', 'images', 'doses' };
labs = social_anova.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( social_anova.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2 3] );

%%  'social' vs. nonsocial anova -- % change from saline, image x dose, per group

group_name = 'downGroup';
current_group = social_anova.only( group_name );

groups = { 'images', 'doses' };
labs = current_group.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

[~, ~, stats] = anovan( current_group.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2] );

dlmwrite( [group_name '_post_hoc.txt'], c );
