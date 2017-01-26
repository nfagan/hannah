load( 'measures.mat' );
%%
pupil = measures.pupil;
pupil = pupil__remove_zeros( pupil );
time_course = -300:900;

[adjusted, time_course] = pupil__adjust_timecourse( pupil, time_course, [0 900] );
meaned = pupil__mean_from_start( adjusted );

%%

%   cron, ephron, hitch, kubrick, lager, tarantino

separated = meaned.only( {'cron'} );
% separated = meaned

% separated = separated.remove( {'outdoors', 'scrambled'} );

separated = cat_collapse( separated, {'gender','expression'} );

%   second input can be 'doses' or 'images'

plot__pupil( separated, 'doses', ...
  'time', time_course, ...
  'plotRibbon', true, ...
  'yLimits', [] ...
  );