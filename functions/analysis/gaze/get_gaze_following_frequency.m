function output = get_gaze_following_frequency(fixations,look_per_session,look_at,varargin)

params = struct(...
    'title',[], ...
    'yLimits',[] ...
    );
params = structInpParse(params,varargin);

if nargin < 3
    look_at = 'frequency';
end

%   get unique rois, images, doses, and the gaze of the image
%   decide whether to look per session

all_rois = unique(fixations.labels.rois);
all_quadrants_ind = cellfun(@(x) sum(isstrprop(x,'digit')) == 1,all_rois);
all_quadrants = str2num(cell2mat(unique(...
    cellfun(@(x) x(end),all_rois(all_quadrants_ind),'UniformOutput',false))));

big_quadrants = all_rois(cellfun(@(x) isempty(strfind(x,'little')),all_rois));
little_quadrants = all_rois(cellfun(@(x) ~isempty(strfind(x,'little')),all_rois));

images = unique(fixations.labels.images);
doses = flipud(unique(fixations.labels.doses));
imgGazes = unique(fixations.labels.imgGaze);

if look_per_session
    sessions = unique(fixations.labels.sessions);
else sessions = {'all'};
end

total_frequency =   zeros(length(images),length(doses));
plot_error =        zeros(length(images),length(doses));

for k = 1:length(images)
for d = 1:length(doses)

    image_dose = separate_data_obj(fixations,...
        'images',   {images{k}}, ...
        'doses',    {doses{d}} ...
        );

    present_gazes = unique(image_dose.labels.imgGaze);
    num_present_gazes = str2num(char(present_gazes));

    sessions = unique(image_dose.labels.sessions);
    matching = zeros(length(sessions),length(present_gazes));
    for i = 1:length(present_gazes)
        total_fixations = zeros(length(sessions),1);
        for s = 1:length(sessions)
            
            %   get total number of fixations to outer quadrants only

            only_big_image_dose = separate_data_obj(image_dose,...
                'rois',     big_quadrants,...
                'sessions', {sessions{s}});
            only_little_image_dose = separate_data_obj(image_dose,...
                'rois',     little_quadrants,...
                'sessions', {sessions{s}});
            
            if strcmp(look_at,'frequency')

                n_fix_big = size(only_big_image_dose.data(only_big_image_dose.data(:,1) ~= 0,:),1);
                n_fix_little = size(only_little_image_dose.data(only_little_image_dose.data(:,1) ~= 0,:),1);

                total_fixations(s) = n_fix_big - n_fix_little;
                
                if n_fix_big < n_fix_little
                    fprintf('\n---------------');
                    fprintf('\n%s',sessions{s});
                    fprintf('\n%s',images{k});
                    fprintf('\n%s',doses{d});
                    fprintf('\n---------------');
                end
                
    %             total_fixations(s) = n_fix_big;
            end
            
            if strcmp(look_at,'duration')
                
                look_length_big = sum(only_big_image_dose.data(only_big_image_dose.data ~= 0));
                look_length_little = sum(only_little_image_dose.data(only_little_image_dose.data ~= 0));

                total_fixations(s) = look_length_big - look_length_little;
%                 total_fixations(s) = look_length_big
            end
            
            if num_present_gazes(i) ~= 5
                big_quad_name = sprintf('quadrant%d',num_present_gazes(i));
                little_quad_name = sprintf('littleQuadrant%d',num_present_gazes(i));

                 big_quad = separate_data_obj(image_dose,...
                    'rois',     {big_quad_name},...
                    'imgGaze',  {present_gazes(i)},...
                    'sessions', {sessions{s}});

                little_quad = separate_data_obj(image_dose,...
                    'rois',     {little_quad_name},...
                    'imgGaze',  {present_gazes(i)},...
                    'sessions', {sessions{s}});
                
                if strcmp(look_at,'frequency')
                    %   number of fixations = number of non-zero fixation durations

                    n_fix_big = size(big_quad.data(big_quad.data(:,1) ~= 0,:),1);
                    n_fix_little = size(little_quad.data(little_quad.data(:,1) ~= 0,:),1);

                    matching(s,i) = n_fix_big - n_fix_little;
    %                 matching(s,i) = n_fix_big;

                end
                
                if strcmp(look_at,'duration')
                    look_length_big = sum(big_quad.data(big_quad.data ~= 0));
                    look_length_little = sum(little_quad.data(little_quad.data ~= 0));

                    matching(s,i) = look_length_big - look_length_little;
%                     matching(s,i) = look_length_big;
                end

            else
                
               little_quad = separate_data_obj(image_dose,...
                    'rois',     little_quadrants,...
                    'imgGaze',  {present_gazes(i)},...
                    'sessions', {sessions{s}});

                matching(s,i) = length(little_quad.data(little_quad.data ~= 0));

            end    
        end
    end
    null_sessions = ~total_fixations;
    matching(null_sessions,:) = []; total_fixations(null_sessions,:) = [];
    
    total_frequency(k,d) = mean(sum(matching,2) ./ total_fixations);
    plot_error(k,d) = SEM(sum(matching,2) ./ total_fixations);
    
%     total_frequency(k,d) = mean(sum(matching,2) / total_fixations;
end
end

figure;
h = bar(total_frequency); set(h,'BarWidth',1);
hold on;
groups = size(total_frequency,1); bars = size(total_frequency,2);
groupwidth = min(0.8, bars/(bars+1.5));

for i = 1:bars
  x = (1:groups) - groupwidth/2 + (2*i-1) * groupwidth / (2*bars); 
  errorbar(x, total_frequency(:,i), plot_error(:,i), 'k', 'linestyle', 'none');
end

legend(doses);

set(gca,'xtick',1:length(images))
set(gca,'xticklabel',images);

if ~isempty(params.yLimits)
    ylim(params.yLimits);
end

if ~isempty(params.title)
    title(params.title);
end

output.values = total_frequency;
output.error = plot_error;