function data = load_lookdur_mult_rois()

data = load( fullfile(pathfor('processedImageData'), '022017' ...
  , 'image_face_mouth_eyes_roi_look_dur.mat') );

data = data.( char(fieldnames(data)) );


end