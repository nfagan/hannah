function plot__pupil( obj, kind, varargin )

params = struct( ...
  'time', [], ...
  'plotRibbon', false, ...
  'yLimits', [] ...
  );
params = parsestruct( params, varargin );

line_kinds = { 'images', 'doses' };

%   make sure we specified a valid `kind`

assert( isa(kind,'char'), 'Expected `kind` to be a string; was a ''%s''', class(kind) );
if ( ~any(strcmp(line_kinds, kind)) )
  fprintf( '\n%s\n\n', strjoin(line_kinds) );
  error( 'Unrecognized `kind` ''%s''; see above for possible `kinds`', kind );
end

if ( isequal(kind, 'doses') )
  title_str = strjoin( unique(obj('images')) );
else title_str = strjoin( unique(obj('doses')) );
end

line_separators = unique( obj(kind) );
means = zeros( size(obj.data, 2), numel(line_separators) );
stds = zeros( size(means) );

for i = 1:numel(line_separators)
  one_category = obj.only( line_separators{i} );
  means(:, i) = mean( one_category.data, 1 );
  stds(:, i) = std( one_category.data, [], 1 );
end

if ( ~isempty(params.time) )
  assert( numel(params.time) == size(obj.data, 2), ['The provided timecourse does' ...
  , ' not match the dimensions of the pupil data. Perhaps you have already' ...
  , ' adjusted the timecourse?'] );
  xs = repmat( params.time(:), 1, size(means, 2) );
else xs = repmat( (1:size(means,1))', 1, size(means, 2) );
end

figure; hold on;

for i = 1:size(xs, 2)
  h(i) = plot( xs(:,i), means(:,i), 'linewidth', 2 );
  color = get(h(i), 'color' );
  if ( params.plotRibbon )
    r(1) = plot( xs(:,i), means(:,i) + stds(:,i) );
    r(2) = plot( xs(:,i), means(:,i) - stds(:,i) );
    set(r(1), 'color', color );
    set(r(2), 'color', color );
  end
end

legend( h, line_separators );
title( title_str );

if ( ~isempty(params.yLimits) ), ylim( params.yLimits ); end

end


% figure;
% plot( xs, means, 'linewidth', 2 );
% legend( line_separators );
% if ( params.plotRibbon )
%   hold on;
%   plot( xs, (means+stds), 'k' );
%   plot( xs, (means-stds), 'k' );
% end
