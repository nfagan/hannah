%% Load Data
mat_files = dir('*.mat');

for i = 1:length(mat_files);
    filename = mat_files(i).name;
    sans_extension = fliplr(filename);
    sans_extension = fliplr(sans_extension(5:end)); % get rid of .mat extension
    load(filename);
    combined_data.(sans_extension) = DataObject(save_field);
end

%% Remove Outliers

non_pupil = rmfield(combined_data, 'pupil_size');
datastruct = DataObjectStruct(non_pupil);

no_outliers = datastruct.foreach(@add_session_id);

[no_out_fix_dur, inds.fixDur] = remove_outliers(datastruct.fix_event_duration);
[no_out_look_dur, inds.lookDur] = remove_outliers(datastruct.looking_duration);
[no_out_fix_num, inds.fixN] = remove_outliers(datastruct.n_fixations);

%% Isolate the face roi:
no_out_fix_dur_faces = no_out_fix_dur.only( 'face' );
no_out_look_dur_faces = no_out_look_dur.only( 'face' );
no_out_fix_num_faces = no_out_fix_num.only( 'face' );

%% Isolate the image roi:
no_out_fix_dur_image = no_out_fix_dur.only( 'image' );
no_out_look_dur_image = no_out_look_dur.only( 'image' );
no_out_fix_num_image = no_out_fix_num.only( 'image' );

%% Normalize Face ROIS to saline by calling normalize:

no_out_fix_dur_faces_norm = normalize(no_out_fix_dur_faces);
no_out_look_dur_faces_norm = normalize(no_out_look_dur_faces);
no_out_fix_num_faces_norm = normalize(no_out_fix_num_faces);

no_out_face_norm.fix_dur = no_out_fix_dur_faces_norm;
no_out_face_norm.look_dur = no_out_look_dur_faces_norm;
no_out_face_norm.fix_num = no_out_fix_num_faces_norm;

fields = fieldnames(no_out_face_norm);

for i = 1:length(fields)
    save_field = no_out_face_norm.(fields{i});
    save([fields{i} '.mat'],'save_field','-v7.3'); 
end

%% Normalize Image ROIS to saline by calling normalize:

no_out_fix_dur_image_norm = normalize(no_out_fix_dur_image);
no_out_look_dur_image_norm = normalize(no_out_look_dur_image);
no_out_fix_num_image_norm = normalize(no_out_fix_num_image);

no_out_image_norm.fix_dur = no_out_fix_dur_image_norm;
no_out_image_norm.look_dur = no_out_look_dur_image_norm;
no_out_image_norm.fix_num = no_out_fix_num_image_norm;

fields = fieldnames(no_out_image_norm);

for i = 1:length(fields)
    save_field = no_out_image_norm.(fields{i});
    save([fields{i} '.mat'],'save_field','-v7.3'); 
end


%% Remove Outdoor and Scrambled Images

no_out_face_norm_soc.fix_dur = remove(no_out_face_norm.fix_dur, {'outdoors','scrambled'});
no_out_face_norm_soc.look_dur = remove(no_out_face_norm.look_dur, {'outdoors','scrambled'});
no_out_face_norm_soc.fix_num = remove(no_out_face_norm.fix_num, {'outdoors','scrambled'});

no_out_image_norm_soc.fix_dur = remove(no_out_image_norm.fix_dur, {'outdoors','scrambled'});
no_out_image_norm_soc.look_dur = remove(no_out_image_norm.look_dur, {'outdoors','scrambled'});
no_out_image_norm_soc.fix_num = remove(no_out_image_norm.fix_num, {'outdoors','scrambled'});

%% Plot %change (mag) from saline for monks, out, and scr with ind dots for ind animals

%collapse across all face categories
no_out_image_norm_full_collapse.fix_dur = collapse(no_out_image_norm.fix_dur, {'gender','gaze','expression','monks'});

%plot


%% Plot %change from saline as a function of baseline looking per animal

%% Plot two plots with 8 image categories --- up and down animals --- to show null effects
%NEED TO HAVE THIS BE REGULAR LOOKING TIME BUT STILL ACCOUNT FOR ANIMAL???

%collapse across up regulated animals
no_out_face_norm_soc_up.fix_dur = replace(no_out_face_norm_soc.fix_dur, {'ephron','kubrick','tarantino'},'up'});

%collapse across down regulated animals
no_out_face_norm_soc_down.fix_dur = replace(no_out_face_norm_soc.fix_dur, {'lager','cron','hitch'},'down'});

%% Plot %change from saline pupil constriction collapsed across all animals and all images during 300 ms
% remove outliers from pupil (hopefully above)

%normalize by saline (hopefully above)

%collapse across all image categories

%collapse across all animals

%plot average pupil size during 300 ms when fixation is up and they are
%looking

%overlay individual animals results with dots 

%% NEW ROI CODE

%% ROI relative probability 


%% Timecourse





