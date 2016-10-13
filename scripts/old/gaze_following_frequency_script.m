 %%
% load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0718/fixEventDuration.mat');
% load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0725/fixEventDuration.mat');
% load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0718/lookingDuration.mat');

quad_time = load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0727/Time.mat');
quad_time = quad_time.save_field;

quad_fix = load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0727/fixEventDuration.mat');
quad_fix = quad_fix.save_field;

reg_time = load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0725/Time.mat');
reg_time = reg_time.save_field;
%%

%   paramaters

monkey = 'hitch';
look_per_session = true;
trials_preceded_by_eye_region_fixation = true;
screen_halves = false;

if trials_preceded_by_eye_region_fixation
    plot_title = sprintf('%s - Required first look to eyes',monkey);
else
    plot_title = sprintf('%s - Did not require first look to eyes',monkey);
end

%   initial, unmodified data

fixations = quad_time;

%   remove errors

errors = ~fixations.data(:,1);
fixations = index_obj(fixations,errors,'del');

if trials_preceded_by_eye_region_fixation
    
    %   get index of trials on which fixations to quadrant were preceded by
    %   fixations to eye region
    
    %   get quadrant rois
    
    quad_rois = unique(fixations.labels.rois);
    big_quad_rois = quad_rois(cellfun(@(x) isempty(strfind(x,'little')),quad_rois));
    little_quad_rois = quad_rois(cellfun(@(x) ~isempty(strfind(x,'little')),quad_rois));
    
    %   eye region specific image times
    
    eye_time = separate_data_obj(reg_time,'rois',{'eyes'});
    
    %   little and big quadrant times separately
    
    little_quad = separate_data_obj(fixations,'rois',little_quad_rois);
    big_quad = separate_data_obj(fixations,'rois',big_quad_rois);
    
    ind = trials_with_first_looks_to_eye(eye_time,big_quad);
    little_ind = index_little_quad(ind,big_quad,little_quad);
    little_quad = index_obj(little_quad,little_ind);
    big_quad = index_obj(big_quad,ind);
    
%     ind = remove_little_quad_events(eye_time,little_quad);
%     little_quad = index_obj(little_quad,ind);
   
    fixations = hacky_obj_concat(little_quad,big_quad);
    
end

%   remove scrambled + outdoor images

fixations = separate_data_obj(fixations,'images',{'--scrambled'});
fixations = separate_data_obj(fixations,'images',{'--outdoors'});

%   further separation

fixations.labels =  collapse_across({'gender'},fixations.labels);
fixations =         separate_data_obj(fixations,'imgGaze',{'--5'});
fixations =         separate_data_obj(fixations,'monkeys',{monkey});

if screen_halves
    
    %   set halves

    fixations.labels.imgGaze(strcmp(fixations.labels.imgGaze,'4')) = {'1'};
    fixations.labels.imgGaze(strcmp(fixations.labels.imgGaze,'3')) = {'2'};

    fixations.labels.rois(strcmp(fixations.labels.rois,'quadrant4')) = {'quadrant1'};
    fixations.labels.rois(strcmp(fixations.labels.rois,'quadrant3')) = {'quadrant2'};

    fixations.labels.rois(strcmp(fixations.labels.rois,'littleQuadrant4')) = {'littleQuadrant1'};
    fixations.labels.rois(strcmp(fixations.labels.rois,'littleQuadrant3')) = {'littleQuadrant2'};
end

%% plot

output = get_gaze_following_frequency(fixations,look_per_session,'frequency',...
    'title',plot_title,...
    'yLimits',[0 1]);