function proportions = hannah__relative_proportion_within_bounds( within_bounds, unqs )

if ( nargin < 2 )
  unqs = unique( within_bounds.data(:) );
end
proportions = Container();
for i = 1:numel(unqs)
  ind = within_bounds.data == unqs(i);
  prop = sum( ind, 1 ) / size(ind, 1);
  proportion = within_bounds.keep_one(1);
  proportion = proportion.collapse_non_uniform();
  proportion( 'rois' ) = sprintf( 'roi__%d', unqs(i) );
  proportion.data = prop;
  proportions = proportions.append( proportion );
end

end