function corrs = iti_pupil_correlations()

pupil = hww.io.load_sparse_measures( 'pupil_iti' );
pupil.data = cell2mat( pupil.data );
looks = hww.io.load_lookdur_mult_rois();
looks = looks.only( 'image' );

iszero = looks.data == 0;

pupil = pupil.keep( ~iszero );
looks = looks.keep( ~iszero );

pupil = pupil.mean( 2 );

assert( pupil.shape(1) == looks.shape(1), ['Mismatch between trial-level' ...
  , ' pupil size and looking duration data.'] );

corrs = Container();

%%  correlations within nhp and dose

within = { 'monkeys', 'doses' };
corred = do_correlation( pupil, looks, within );
corrs = corrs.append( corred );

%%  correlations within nhp, across doses

within = { 'monkeys' };
pup = pupil.collapse( 'doses' );
lks = looks.collapse( 'doses' );
corred = do_correlation( pup, lks, within );
corrs = corrs.append( corred );

%%  correlations across nhps, per dose

within = { 'doses' };
pup = pupil.collapse( 'monkeys' );
lks = looks.collapse( 'monkeys' );
corred = do_correlation( pup, lks, within );
corrs = corrs.append( corred );

%%  correlations across nhps, across doses

pup = pupil.collapse( {'monkeys', 'doses'} );
lks = looks.collapse( {'monkeys', 'doses'} );
corred = do_correlation( pup, lks, 'monkeys' );
corrs = corrs.append( corred );

end

function corrs = do_correlation( pupil, looks, within )

pup_within = pupil.enumerate( within );
lks_within = looks.enumerate( within );

corrs = Container();

for i = 1:numel(pup_within)
  pup = pup_within{i};
  lks = lks_within{i};
  [r, p] = corr( pup.data, lks.data );
  data = struct( 'r', r, 'p', p );
  cont = Container( data, 'monkey', pup('monkeys'), 'doses', pup('doses') );
  corrs = corrs.append( cont );
end
  
end