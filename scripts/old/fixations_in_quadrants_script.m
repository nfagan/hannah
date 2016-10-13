quadrants_file = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0718/fixEventDuration.mat';

load(quadrants_file);

%%

%   if wanting to look per session

look_per_session = false;

%   initial, unmodified data

fixations = fixEventDuration;

%   remove scrambled + outdoor images

fixations = separate_data_obj(fixations,'images',{'--scrambled'});
fixations = separate_data_obj(fixations,'images',{'--outdoors'});

%   get unique rois, images, doses, and the gaze of the image
%   decide whether to look per session

all_rois = unique(fixations.labels.rois);
all_quadrants_ind = cellfun(@(x) sum(isstrprop(x,'digit')) == 1,all_rois);
all_quadrants = str2num(cell2mat(unique(...
    cellfun(@(x) x(end),all_rois(all_quadrants_ind),'UniformOutput',false))));

images = unique(fixations.labels.images);
doses = unique(fixations.labels.doses);
imgGazes = unique(fixations.labels.imgGaze);

if look_per_session
    sessions = unique(fixations.labels.sessions);
else sessions = {'all'};
end

for ii = 1:length(imgGazes)
figure;
for i = 1:length(all_quadrants)

quadrant_ind = i;

big_quad_name = sprintf('quadrant%d',quadrant_ind);
little_quad_name = sprintf('littleQuadrant%d',quadrant_ind);

n_fix_big_only = zeros(length(doses),length(images));
errors = zeros(length(doses),length(images));

for k = 1:length(images)
    disp(k);
    for j = 1:length(doses)
        disp(j);
        per_session_diff = zeros(1,length(sessions));
        for s = 1:length(sessions)
            disp(s);

            big_quad = separate_data_obj(fixations,...
                'rois',     {big_quad_name},...
                'imgGaze',  {num2str(ii)},...
                'images',   {images{k}},...
                'doses',    {doses{j}},...
                'sessions', {sessions{s}});

            little_quad = separate_data_obj(fixations,...
                'rois',     {little_quad_name},...
                'imgGaze',  {num2str(ii)},...
                'images',   {images{k}},...
                'doses',    {doses{j}},...
                'sessions', {sessions{s}});

            %   number of fixations = number of non-zero fixation durations

            n_fix_big = length(big_quad.data(big_quad.data ~= 0));
            n_fix_little = length(little_quad.data(little_quad.data ~= 0));
            
            per_session_diff(s) = n_fix_big - n_fix_little;
%             n_fix_big_only(j,k) = n_fix_big - n_fix_little;
        end
        n_fix_big_only(j,k) = mean(per_session_diff);
        errors(j,k) = SEM(per_session_diff);
    end
end

% figure;
subplot(length(all_quadrants),1,i);
bar(n_fix_big_only');
hold on;

set(gca,'XTick',1:length(images));
set(gca,'XTickLabel',images);
legend(doses);
title(sprintf('%s img gaze %d',big_quad_name,ii));
hold off;

end

end





