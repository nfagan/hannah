function bounds = load_iti_bounds()

bounds = load( fullfile(pathfor('processedImageData'), '030117', 'iti_bounds.mat') );
fs = char( fieldnames(bounds) );
bounds = bounds.( fs );

end