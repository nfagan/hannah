function per_file = get_edfs( edf_dir, sample_kinds )

if ( nargin < 2 )
  sample_kinds = { 'time', 'posX', 'posY', 'pupilSize' };
end

edfs = dirstruct( edf_dir, '.edf' );
edfs = { edfs(:).name };
edfs = cellfun( @(x) fullfile(edf_dir, x), edfs, 'un', false );

per_file = cell( 1, numel(edfs) );

for i = 1:numel(edfs)  
  edf0 = Edf2Mat( edfs{i} );
  mat = [];
  for k = 1:numel(sample_kinds)
    mat(:, k) = edf0.Samples.(sample_kinds{k});
  end  
  per_file{i} = mat;
end

end
