function gaze_following(time,fix,ind)

lookat = 'duration';

debug = true;
if ~debug
    [~,ind] = looks_after_eyes(time);
end

[~,index] = no_zeros(time); fix(index,:) = [];
fix = fix(fix ~= {'eyes','mouth','image','face'});

after_eyes = fix(ind); after_eyes = after_eyes(after_eyes == 'tarantino');
after_eyes = after_eyes(after_eyes ~= '5');
after_eyes = collapse(after_eyes,{'gender'});

images = unique(after_eyes.labels.images);

across_images = struct();
for i = 1:length(images)
    one_image = after_eyes(after_eyes == images{i});
    across_images.(images{i}) = per_session_means(one_image,lookat);    
end

[means, errors, labels] = get_means(across_images);
plot_means(means,errors,labels);

end

function plot_means(means,errors,labels)

axis_size = length(labels.images) - 1;

figure; hold on;
bar(.3:1:.3+axis_size,means(:,1),.15,'b');
bar(.6:1:.6+axis_size,means(:,2),.15,'g');
bar(.9:1:.9+axis_size,means(:,3),.15,'r');
errorbar(.3:1:.3+axis_size,means(:,1),errors(:,1),'k.')
errorbar(.6:1:.6+axis_size,means(:,2),errors(:,2),'k.')
errorbar(.9:1:.9+axis_size,means(:,3),errors(:,3),'k.')

set(gca,'XTick',[.6:1:.6+axis_size])
set(gca,'xticklabel',labels.images);

legend(labels.doses)

end


function freqs = per_session_means(after_eyes,lookat)

sessions = unique(after_eyes.labels.sessions);
doses = unique(after_eyes.labels.doses);
rois = unique(after_eyes.labels.rois);

freqs = struct();
stps = struct();
for i = 1:length(doses)
    stps.(doses{i}) = 1;
end

for i = 1:length(sessions)
    one_session = after_eyes(after_eyes == sessions{i});
    dose = unique(one_session.labels.doses);
    
    if length(dose) > 1
        error('more than one dose');
    end
    
    dose = char(dose);
    
    gaze = cellfun(@(x) {num2str(x)}, one_session.labels.imgGaze);
    quads = one_session.labels.rois;
    quadnumber = cellfun(@(x) {x(isstrprop(x,'digit'))},quads);
    uniquequads = str2num(char(unique(quadnumber)));
    
    little_rois_ind = cellfun(@(x) ~isempty(strfind(x,'little')),rois);
    big_rois_ind = ~little_rois_ind;
    
    little_rois = rois(little_rois_ind);
    big_rois = rois(big_rois_ind);
    
    totals = zeros(length(uniquequads),1);
    for k = 1:length(uniquequads)
        strquad = num2str(uniquequads(k));
        
        current_big_roi = ['quadrant' strquad];
        current_little_roi = ['littleQuadrant' strquad];
        
        big = one_session(one_session ~= little_rois);
        little = one_session(one_session ~= big_rois);
        
        big_matches_index = strcmp(gaze,strquad) & strcmp(quads,current_big_roi);
        little_matches_index = strcmp(gaze,strquad) & strcmp(quads,current_little_roi);
        
        if strcmp(lookat,'frequency')
            big_matches = sum(big_matches_index);
            little_matches = sum(little_matches_index);
            
            totals(k) = (big_matches - little_matches) / (count(big,1) - count(little,1));
            
        elseif strcmp(lookat,'duration')
            big_matches = sum(one_session(big_matches_index));
            little_matches = sum(one_session(little_matches_index));
            
            totals(k) = (big_matches - little_matches) / (sum(big) - sum(little));
            
        end
        
    end
%     
%     if strcmp(lookat,'frequency')
% %         freq = sum(totals) / size(gaze,1);
%         for k = 1:size(totals,1)
%             others = totals; others(k) = [];
%             freq(k) = totals(k) / sum(others);
%         end
%         freq = mean(freq);
%     elseif strcmp(lookat,'duration')
% %         freq = sum(totals) / sum(one_session);
%         freq = sum(totals);
%     end
    freq = sum(totals);
    
    freqs.(dose)(stps.(dose)) = freq;
    stps.(dose) = stps.(dose) + 1;
    
end

end

function [means, errors, labels] = get_means(structure)
    images = fieldnames(structure);
    doses = fieldnames(structure.(images{1}));
    
    if length(doses) == 3
        doses = {'saline','low','high'};
%         d = 10;
    end
    
    means = zeros(length(images),length(doses));
    errors = zeros(length(images),length(doses));
    for i = 1:length(images)
        for d = 1:length(doses)
            means(i,d) = mean(structure.(images{i}).(doses{d}));
            errors(i,d) = SEM(structure.(images{i}).(doses{d}));
        end
    end
    
    labels.images = images;
    labels.doses = doses;
end
