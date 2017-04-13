%%  load in
goto( 'processedImageData' );
cd( './110716' );
load( 'looks_outliersremoved_sparse.mat' );
looks = looks.only( 'image' );

%%  change from saline

sal = looks.only( 'saline' );
others = looks;
sal = sal.do_per( {'monkeys', 'doses'}, @mean );
monks = others( 'monkeys' );
for i = 1:numel( monks )
  other_ind = others.where( monks{i} );
  sal_ind = sal.where( monks{i} );
  others.data( other_ind ) = others.data( other_ind ) / sal.data( sal_ind );
end
%%  social vs. nonsocial

nonsoc_ind = others.where( {'outdoors', 'scrambled'} );
others( 'images', nonsoc_ind ) = 'nonsocial';
others( 'images', ~nonsoc_ind ) = 'social';
%%  dose x image anova

groups = { 'doses', 'images' };
labels = others.labels.full();
labels = labels.get_fields( groups );
labels = { labels(:, 1), labels(:, 2) };
[~, ~, stats] = anovan( others.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2] );

%%  bidirectional effect

bidirec = others.rm( 'nonsocial' );
bidirec.data = (bidirec.data - 1) * 100;
bidirec = bidirec.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
bidirec = bidirec.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

%%  bidirection anova
monk_group = 'upGroup';
bidirec = bidirec.only( monk_group );
% groups = { 'monkeys', 'doses', 'gazes', 'expressions' };
groups = { 'doses', 'gazes', 'expressions' };
% groups = { 'monkeys', 'doses' };
labels = bidirec.labels.full();
labels = labels.get_fields( groups );
labels = { labels(:, 1), labels(:, 2), labels(:, 3) };
% labels = { labels(:, 1), labels(:, 2) };
[~, ~, stats] = anovan( bidirec.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', [1 2 3] );

dlmwrite( [monk_group '.txt'], c );
save( [monk_group '.mat'], 'gnames' );

