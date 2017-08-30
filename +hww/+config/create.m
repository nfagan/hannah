function opts = create(do_save)

%   CREATE -- Create the config file.
%
%     IN:
%       - `do_save` (logical) |OPTIONAL| -- True if the config file should
%         be saved. Default is true.
%     OUT:
%       - `opts` (struct)

if ( nargin == 0 ), do_save = true; end

opts = struct();

% - PATHS - %
PATHS.processedImageData = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data';
PATHS.repositories = '/Volumes/My Passport/NICK/Chang Lab 2016/repositories';

% - SAVE - %
opts.PATHS = PATHS;

if ( do_save )
  hww.config.save( opts );
  hww.config.save( opts, '-default' );
end

end