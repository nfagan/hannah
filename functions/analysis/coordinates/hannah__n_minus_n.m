function current = hannah__n_minus_n( obj, n, preceding_is, current_is )

preceding_ind = false( obj.shape(1), 1 );
current_ind = preceding_ind;

preceding_ind(1:end-n) = true;
current_ind(1+n:end) = true;

preceding = obj.keep( preceding_ind );
current = obj.keep( current_ind );

if ( isempty(preceding_is) )
  matches_preceding = true( preceding.shape(1), 1 );
else matches_preceding = preceding.where( preceding_is );
end

if ( isempty(current_is) )
  matches_current = true( current.shape(1), 1 );
else matches_current = current.where( current_is );
end

all_matches = matches_current & matches_preceding;
current = current.keep( all_matches );

end