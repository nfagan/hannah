%% reformat from combined_data

measures.fixdur = combined_data.fix_event_duration;
measures.lookdur = combined_data.looking_duration;
measures.nfix = combined_data.n_fixations;

%%

static.time = combined_data.time;
static.coords = combined_data.x_y_coords;

pupilsize.pupil = combined_data.pupil_size;

measures = DataObjectStruct( measures );
static = DataObjectStruct( static );
pupilsize = DataObjectStruct( pupilsize );

measures = measures.foreach( @add_session_id );
static = static.foreach( @add_session_id );
pupilsize = pupilsize.foreach( @add_session_id );

%% save the reformatted version

save( 'measures.mat', 'measures' );
save( 'static.mat', 'static' );
save( 'pupil.mat', 'pupilsize' );
