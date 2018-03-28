%%

pathinit; pathadd( 'hannah' ); pathadd( 'global' );
meas_type = 'lookdur';
looks = hww.io.load_sparse_measures( meas_type );
looks = looks({'image'});

%%  normalize
normed = hww.process.saline_normalize( looks );
normed.data = (normed.data-1)*100;
%%  lookdur means + devs

do_save = true;
mis_normalized = { true, false };
mis_updown = { true, false };
kinds = { 'social_minus_nonsocial', 'all_images', 'social_v_nonsocial', 'social_v_scrambled_v_outdoors' };

CC = allcomb( {kinds, mis_normalized, mis_updown} );

for idx = 1:size(CC, 1)
  
kind = CC{idx, 1};
is_normalized = CC{idx, 2};
is_up_down = CC{idx, 3};

filename = kind;

outer_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/analyses';
table_dir = fullfile( outer_dir, datestr(now, 'mmddyy'), meas_type, 'tables' );

if ( do_save && exist(table_dir, 'dir') ~= 7 ), mkdir( table_dir ); end

if ( is_normalized )
  baseline = normed.rm( 'saline' ); 
  filename = [ filename, '_normalized' ];
else
  baseline = looks;
  filename = [ filename, '_raw' ];
end

if ( is_up_down )
  filename = [ filename, '_updown' ];
else
  filename = [ filename, '_per_monkey' ];
end

if ( strcmp(kind, 'all_images') )
  baseline = baseline.collapse( 'images' );
elseif ( strcmp(kind, 'social_v_nonsocial') || strcmp(kind, 'social_minus_nonsocial') )
  baseline = baseline.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
  baseline('images', ~baseline.where('nonsocial')) = 'social';
elseif ( strcmp(kind, 'social_v_scrambled_v_outdoors') )
  baseline('images', ~baseline.where({'outdoors', 'scrambled'})) = 'social';
else
  assert( false );
end

if ( is_up_down )
  baseline = make_ud( baseline );
end

m_within1 = { 'sessions', 'images' };
m_within2 = { 'monkeys', 'doses', 'images' };
tbl_cats = { {'monkeys', 'images'}, 'doses' };
tbl_write_props = { 'FileType', 'spreadsheet', 'WriteRowNames', true };

baseline = baseline.each1d( m_within1, @rowops.mean );

if ( strcmp(kind, 'social_minus_nonsocial') )
  baseline = baseline({'social'}) - baseline({'nonsocial'});
end

baseline_means = baseline.each1d( m_within2, @rowops.mean );
baseline_devs = baseline.each1d( m_within2, @rowops.std );

tbl_means = baseline_means.table( tbl_cats{:} );
tbl_devs = baseline_devs.table( tbl_cats{:} );

writetable( tbl_means, fullfile(table_dir, [filename, '_means']), tbl_write_props{:} );
writetable( tbl_devs, fullfile(table_dir, [filename, '_devs']), tbl_write_props{:} );

end



