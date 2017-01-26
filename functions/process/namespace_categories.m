function obj = namespace_categories( obj, categories )

assert( iscellstr(categories), 'Specify categories as a cell array of strings' );

for i = 1:numel( categories )
  cat = obj(categories{i});
  cat = cellfun( @(x) [categories{i} '__' x], cat, 'UniformOutput', false );
  obj(categories{i}) = cat;
end


end