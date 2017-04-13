function tc = hannah__tc_within_day( measure, times, within, n_bins )

assert( measure.labels == times.labels, 'Labels must be equivalent.' );

combined = Structure( 'measure', measure, 'times', times );
combined = combined.enumerate( {'monkeys', 'days'} );

tc = Container();

for i = 1:numel(combined{1})
  fprintf( '\n - Processing %d of %d', i, numel(combined{1}) );
  day_meas = combined.measure{i};
  day_time = combined.times{i};
  monks = day_meas( 'monkeys' );
  if ( numel(monks) > 1 )
    error( 'More than one monkey present on this day.' );
  end
  session_length = max( day_time.data ) - min( day_time.data );
  bin_size = floor( session_length / n_bins );
  start = 0;
  c = day_meas.combs( within );
  new_data = zeros( size(c, 1), n_bins );
  %   handle data
  for k = 1:n_bins
    if ( k == n_bins && bin_size*k < session_length )
      bin_size = session_length - bin_size;
    end
    time_ind = day_time.data >= start & day_time.data <= start + bin_size;
    if ( ~any(time_ind) ), continue; end;
    extr = day_meas.keep( time_ind );
    for j = 1:size(c, 1)
      extr_within = extr.only( c(j, :) );
      if ( extr_within.isempty() ), continue; end;
      new_data(j, k) = mean( extr_within.data );
    end
    start = start + bin_size;
  end
  %   handle labels
  new_labels = SparseLabels();
  for k = 1:size(c, 1)
    ind = day_meas.where( c(k, :) );
    if (~any(ind) ), continue; end;
    extr = day_meas.keep( ind );
    extr = extr.collapse_non_uniform();
    extr = extr(1);
    new_labels = new_labels.append( extr.labels );
  end  
  all_zeros = all( new_data == 0, 2 );
  new_data( all_zeros ) = [];
  new_labels = new_labels.keep( ~all_zeros );
  tc = tc.append( Container(new_data, new_labels) );
end

end