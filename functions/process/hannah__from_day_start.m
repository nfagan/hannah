function session_start = hannah__from_day_start( session_start )

days = session_start.enumerate( {'days', 'monkeys'} );

for i = 1:numel(days)
  day = days{i};
  day_label = unique( day('days') );
  monk_label = unique( day('monkeys') );
  day_label = day_label{1};
  monk_label = monk_label{1};
  sessions = day( 'session_numbers' );
  if ( numel(sessions) == 1 ), continue; end
  ind = session_start.where( {sessions{1}, day_label, monk_label} );
  offset = max( session_start.data(ind) );
  for j = 2:numel(sessions)
    ind = session_start.where( {sessions{j}, day_label, monk_label} );
    session_start.data(ind) = session_start.data(ind) + offset;
    offset = max( session_start.data(ind) );
  end
end

end