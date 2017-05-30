pupil = hww.io.load_sparse_measures( 'pupil_iti' );
pupil.data = cell2mat( pupil.data );
pupil = pupil.mean(2);
pupil_normed = saline_normalize( pupil );

look = hww.io.load_lookdur_mult_rois();
look = look.only( 'image' );
look_normed = saline_normalize( look );

%%
resolution = { 'sessions' };
to_collapse = setdiff( look.categories(), resolution );

pupil_ = pupil_normed;
pupil_ = pupil_.do( resolution, @mean );
look_ = look_normed;
look_ = look_.do( resolution, @mean );

pupil_ = pupil_.collapse( to_collapse );
look_ = look_.collapse( to_collapse );

%%  plot

pl = ContainerPlotter();
pl.default();

pl.scatter( look_, pupil_, [], [] );


