function binned = time_course(data_values,labels,start_times,varargin)

params = struct(...
    'binBy','mean'...
);

params = structInpParse(params,varargin);

unique_days = unique(labels.days);
images = unique(labels.images);

for i = 1:length(images);
    stp = 0; store_data_values = nan(size(data_values,1),2);
    for j = 1:length(unique_days)
        start_time = start_times.(['day_' unique_days{j}]);
        data_values_one_image = separate_data_struct(data_values,labels,...
            'images',{images{i}},'days',{unique_days{j}});

        data_values_one_image(isnan(data_values_one_image(:,2)),:) = [];
        data_values_one_image(:,2) = data_values_one_image(:,2) - start_time;
        
        update_size = size(data_values_one_image,1);
        store_data_values(1+stp:stp+update_size,:) = data_values_one_image;
        stp = stp + update_size;
    end
    data_values_from_start.(images{i}) = store_data_values(~isnan(store_data_values(:,1)),:);
end


%%

%%% binning section

check_max = [0 0];
for i = 1:length(images)
    check_max(2) = max(data_values_from_start.(images{i})(:,2));
    check_max = max(check_max);
end

bin_size = 1000 * 60; % 1 min
n_bins = ceil(check_max/bin_size);

binned = zeros(length(images),n_bins-1);
for j = 1:length(images)
    current_image_times = data_values_from_start.(images{j});
    bin_index = [0 bin_size]; store_binned = zeros(1,n_bins-1);
    for i = 1:n_bins-1
        one_bin_times_index = current_image_times(:,2) > bin_index(1) & ...
            current_image_times(:,2) < bin_index(2);
        if strcmp(params.binBy,'mean')
            one_bin_vals = mean(current_image_times(one_bin_times_index,1));
        elseif strcmp(params.binBy,'sum')
            one_bin_vals = sum(current_image_times(one_bin_times_index,1));
        else
            error('binVals must either be ''mean'' or ''sum''');
        end
        store_binned(i) = one_bin_vals;
        bin_index = [bin_size*i bin_size*(i+1)];
    end
%     binned.(images{j}) = store_binned;
    binned(j,:) = store_binned;
end

%% plot

plot_x = repmat([1:size(binned,2)],size(binned,1),1);
figure;
plot(plot_x',binned','*');
lsline

legend(images);
xlabel('Elapsed time from session start (m)');
ylabel('Mean Looking Time (ms)');



% %%
% 
% for i = 1:length(images)
%     hold on;
%     plot_binned = binned.(images{i});
%     plot_x = 1:size(plot_binned,2);
%     h = scatter(plot_x,plot_binned,'DisplayName',images{i});
% %     set(h,{'DisplayName'},{images{i}});
%     legend('-dynamicLegend');
% end
% 
% % legend('show');
% 
% xlabel('Elapsed time from session start (m)');
% ylabel('Looking Time (ms)');
% 
% 
% 

