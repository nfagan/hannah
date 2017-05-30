function over_image = rois_over_image_plots()

filename = 'image_face_mouth_eyes_roi_look_dur.mat';
looks = load( fullfile(pathfor('processedImageData'), '022017', filename) );
looks = looks.( char(fieldnames(looks)) );

savepath = fullfile( pathfor('plots'), '051117', 'lookdur', 'raw' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir(save_path); end;

%%
[per_roi, ~, rois] = looks.enumerate( 'rois' );
img = per_roi{ strcmp(rois, 'image') };
others = per_roi( ~strcmp(rois, 'image') );
mouth_eyes = extend( others{:} );
img = cellfun( @(x) img, others, 'un', false );
image = extend( img{:} );

image.labels = mouth_eyes.labels;

over_image = mouth_eyes ./ image;
over_image = over_image.keep( ~isnan(over_image.data) );
over_image = over_image.do( {'sessions', 'rois'}, @mean );

%%
pl = ContainerPlotter();
pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'eyes', 'mouth' };
h = pl.plot_by( over_image, 'doses', 'monkeys', 'rois' );

%%
set( h, 'ylim', [.5 1.2] );
saveas( gcf, fullfile(savepath, 'roi_lookdur_over_image'), 'epsc' );

end

