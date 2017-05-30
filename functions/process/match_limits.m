function lims = match_limits( obj, within )

lims = Container();

if ( isempty(within) )
  enumed = { obj };
else
  enumed = obj.enumerate( within );
end

for i = 1:numel( enumed )
  current = enumed{i};
  data = current.data;
  maxed = max( data(:) );
  mined = min( data(:) );
  current = current.collapse_non_uniform();
  current = current(1);
  current.data = [ mined, maxed ];
  lims = lims.append( current );
end



end