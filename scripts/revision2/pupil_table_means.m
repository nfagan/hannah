pupil = hww.io.get_matched_pupil_and_lookdur();
%%

pup = pupil.pupil_size;
pup.data = mean( cell2mat(pup.data), 2 );

%%

pup = hww.process.saline_normalize( pup );
pup.data = (pup.data-1) * 100;
pup = pup.rm( 'saline' );

%%
do_save = true;
meas_type = 'pupil';
outer_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/analyses';
table_dir = fullfile( outer_dir, datestr(now, 'mmddyy'), meas_type, 'tables' );

if ( do_save && exist(table_dir, 'dir') ~= 7 ), mkdir( table_dir ); end

meaned = pup.each1d({'sessions', 'images'}, @rowops.mean );

means = meaned.each1d( {'monkeys', 'doses'}, @rowops.mean );
devs = meaned.each1d( {'monkeys', 'doses'}, @rowops.std );

tbl_means = means.table( tbl_cats{:} );
tbl_devs = devs.table( tbl_cats{:} );

if ( do_save )
  writetable( tbl_means, fullfile(table_dir, 'means'), tbl_write_props{:} );
  writetable( tbl_devs, fullfile(table_dir, 'devs'), tbl_write_props{:} );
end
