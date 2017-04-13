function reformatted = hannah__add_session_number( obj )

monks = obj.enumerate( 'monkeys' );

sessions = unique( obj('sessions') );
lengths = cellfun( @(x) numel(x), sessions );
assert( all(lengths == 8), ['Expected sessions to be of the format' ...
  , ' ''MMmmddSS'', where M is monkey, m is month, d is day, and S is session.'] );

reformatted = Container();

for i = 1:numel(monks)
  monk = monks{i};
  sessions = unique( monk('sessions') );
  days = cellfun( @(x) x(3:6), sessions, 'un', false );
  days = cellfun( @(x) [x(1:2) '/' x(3:end)], days, 'un', false );
  times = datetime( days, 'InputFormat', 'MM/dd' );
  [~, ind] = sort( times );
  sessions = sessions( ind );
  monk = monk.add_field( 'session_numbers', '<undf>' );
  for j = 1:numel(sessions)
    ind = monk.where( sessions{j} );
    monk( 'session_numbers', ind ) = sprintf( 'session__%d', j );
  end
  reformatted = reformatted.append( monk );
end

end