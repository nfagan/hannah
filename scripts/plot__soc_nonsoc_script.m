fixdur = analysis.socialNonSocialMeans.image__lookdur;

soclow = fixdur.only({'low', 'social'});
sochigh = fixdur.only({'high', 'social'});
nonlow = fixdur.only({'low', 'nonsocial'});
nonhigh = fixdur.only({'high','nonsocial'});

soclow_mean = soclow.data(1);
sochigh_mean = sochigh.data(1);
nonlow_mean = nonlow.data(1);
nonhigh_mean = nonhigh.data(1);

plt_means = [soclow_mean sochigh_mean nonlow_mean nonhigh_mean];

soclow_error = soclow.data(2);
sochigh_error = sochigh.data(2);
nonlow_error = nonlow.data(2);
nonhigh_error = nonhigh.data(2);

plt_errors = [soclow_error sochigh_error nonlow_error nonhigh_error];

figure;
errorbar(plt_means, plt_errors, 'linestyle','none');
hold on;
bar( plt_means );

set(gca, 'xtick', 1:4);
set(gca, 'xticklabel', {'soc-low', 'soc-high', 'non-low', 'non-high'});

%%

currentMeasure = analysis.lookdurMean;
currentMeasure = currentMeasure.remove( {'saline'} );
% currentMeasure = currentMeasure.only( {'social'} );

currentMeasure.data = abs( currentMeasure.data - 1 );

plot__mean_within( currentMeasure, {'monkeys','doses', 'images'}, 'manualOrder', false);

% [indices, combs] = getindices( currentMeasure, { 'monkeys', 'doses' } );



%%

doses = currentMeasure.uniques( 'doses' );
images = currentMeasure.uniques( 'images' );

for k = 1:numel(doses)
    for i = 1:numel(images)
        extr = currentMeasure.only( { doses{k}, images{i} } );
        means(stp) = extr.data(1);
        errors(stp) = extr.data(2);
        labelPairs{stp} = [ doses{k} '_' images{i} ];
        stp = stp + 1;
    end
end

figure;
errorbar( means, errors, 'linestyle','none');
hold on;
bar( means );

set( gca, 'xtick', 1:numel(means) );
set( gca, 'xticklabels', labelPairs );

%%

sochigh = sochigh.collapse( 'images' );
soclow = soclow.collapse( 'images' );

nonlow = nonlow.collapse( 'images' );
nonhigh = nonhigh.collapse( 'images' );

% sochigh = sochigh.data;
% soclow = soclow.data;
% nonlow = nonlow.data;
% nonhigh = nonhigh.data;

high_diff = sochigh - nonhigh;
low_diff = soclow - nonlow;

high_diff_means = mean( high_diff.data(:,1) );
low_diff_means = mean( low_diff.data(:,1) );

high_diff_sem = SEM( high_diff.data(:,1) );
low_diff_sem = SEM( low_diff.data(:,1) );

combined_means = [high_diff_means low_diff_means];
combined_errors = [ high_diff_sem low_diff_sem ];

figure;
bar( combined_means );
hold on;
errorbar( [1 2], combined_means, combined_errors, 'linestyle', 'none');

set( gca, 'xtick', 1:2 );
set( gca, 'xticklabel', { 'HIGH', 'LOW' } );


%%

monk_mapping.ephron = 'b';
monk_mapping.hitch = 'r';
monk_mapping.lager = 'g';
monk_mapping.kubrick = 'y';
monk_mapping.cron = 'k';
monk_mapping.tarantino = 'm';

% hold on; 
fixdur = meansPerMonk.image__fixdur; fixdur = fixdur.remove('saline');

monks = fixdur.uniques('monkeys');
inds = fixdur.getindices({'doses', 'images'});

matrix = zeros(numel(inds), numel(monks) ); xs = zeros( size(matrix) );

store_monks = cell( size(matrix) );

for i = 1:numel(inds)
    
    extr = fixdur(inds{i});
    
    monks = extr.labels.monkeys;
    
    matrix(i,1:count(extr,1)) = extr.data(:,1);
    
    xs(i,:) = i;
    
    store_monks(i,1:count(extr,1)) = monks;
    
end

hold on;

for i = 1:size(matrix,1)
    row = matrix(i,:);
    ind = row ~= 0;
    row = row(ind);
    
    x = xs(i,ind);
    
    current_monks = store_monks(i,ind);
    
    for j = 1:numel(current_monks)
        color = [monk_mapping.(current_monks{j})];
        plot( x(j), row(j), color );
    end
    
%     plot(x, row, '*');
end

% plot( xs', matrix', '*' );

%%
hold on;
for i = 1:size(matrix,2)
    
    col = matrix(:,i);
    x = xs(:,i);
    
    monks = store_monks(:,i); monks = monks( ~cellfun(@isempty, monks) ); 
    monks = unique(monks);
    
    x = x( col ~= 0 );
    col = col( col ~= 0 );
    
%     monk = store_monks{i};
    color = monk_mapping.(monks{1});
    plot( x, col, 'linewidth', 2);
end




