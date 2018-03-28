correlations = revision_roi_plots_collapsed_lowhigh();

%%
rebuilt = Container();

for i = 1:numel(correlations.data)
  
  corrs = correlations(i);
  data = corrs.data;
  rs = data.across_doses.rs;
  ps = data.across_doses.ps;
  roi_labs = data.across_doses.labels;
  
  extr = corrs.one();
  
  labs = extr.field_label_pairs();
  labs{end+1} = 'roi';
  labs{end+1} = roi_labs;
  
  cont = Container( [rs(:), ps(:)], labs{:} );
  rebuilt = rebuilt.append( cont );
end

%%

conf = hww.config.load();
save_dir = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations' );
save_dir = fullfile( save_dir, datestr(now, 'mmddyy') );
fname = 'eye_mouth_correlations.mat';

hww.util.require_dir( save_dir );

save( fullfile(save_dir, fname), 'rebuilt' ); 
