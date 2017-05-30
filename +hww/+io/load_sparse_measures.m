function loaded = load_sparse_measures( kind, subfolder )

%   LOAD_SPARSE_MEASURES -- Load in the most recent processed data.
%
%     IN:
%       - `kind` (char) -- 'lookdur', 'fixdur', 'nfix', 'pupil_iti'
%     OUT:
%       - `loaded` (Container)

if ( nargin == 0 ), kind = 'lookdur'; subfolder = '110716'; end;
if ( nargin < 2 ), subfolder = '110716'; end;

if ( ~isequal(kind, 'pupil_iti') )
  filename = 'sparse_measures_outliersremoved.mat';
else filename = 'sparse_pupil_iti.mat';
end
load_path = fullfile( pathfor('processedImageData'), subfolder, filename );
measures = load( load_path );
fields = fieldnames( measures );
measures = measures.( fields{1} );

if ( isequal(kind, 'pupil_iti') ), loaded = measures; return; end;

loaded = measures.(kind);

end