function roi_look_order(time,wanted_rois,bin_size,varargin)

params = struct(...
    'imageLength',          5000, ...
    'savePlots',            false, ...
    'baseSaveDirectory',    '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/plots/', ...
    'appendToDirectory',    '0725/saline', ...
    'monkey',               [], ...            
    'flip',                 false, ...
    'method',               'singleP', ...
    'plotMethod',           'oneLine' ...
    );
params = structInpParse(params,varargin);

%   define a numeric value for each roi

roi_mapping = struct(...
    'eyes',1, ...
    'mouth',2 ...
    );

roi_fields = fieldnames(roi_mapping);

images = unique(time.labels.images);

image_presentation_length = params.imageLength;

%   make sure the specified rois are present in the roi_mapping struct

for i = 1:length(wanted_rois)
    if ~any(strcmp(fieldnames(roi_mapping),wanted_rois{i}))
        error(['The specified roi ''%s'' does not yet have a numeric' ...
            , ' value defined in roi_mapping'],wanted_rois{i});
    end
end

figure;
n_plots = length(images);

save_last_plot = false;

for i = 1:n_plots
    
    stp = 1; hold off;

    times_from_wanted_roi = separate_data_obj(time,...
        'images',{images{i}},...
        'rois',wanted_rois);
    
    times = times_from_wanted_roi.data;
    rois = times_from_wanted_roi.labels.rois;
    
    errors = ~times(:,1);
    
    times(errors,:) = [];
    rois(errors,:) = [];
    
    numeric_labels = zeros(size(rois));
    
    for k = 1:length(wanted_rois)
        numeric_labels(strcmp(rois,wanted_rois{k})) = ...
            roi_mapping.(wanted_rois{k});
    end
    
    unique_start_times = unique(times(:,1));
    
    psth = nan(size(times,1),image_presentation_length);
    
    for k = 1:length(unique_start_times)
        index_of_current_start_time = times(:,1) == unique_start_times(k);
        
        fix_events = times(index_of_current_start_time,3:4);
        current_numeric_rois = numeric_labels(index_of_current_start_time);
        
        aligned_to_image_start = fix_events - unique_start_times(k);
        
        if any(sign(aligned_to_image_start(:,2)) == -1)
            error('Fixation ended before image was presented');
        end
        
        aligned_to_image_start(sign(aligned_to_image_start(:,1)) == -1,1) = 0;
        
        %   account for zero-indexing
        
        aligned_to_image_start = aligned_to_image_start + 1;
        
        if length(current_numeric_rois) ~= size(aligned_to_image_start,1)
            error('sizes don''t match');
        end
        
        max_diff = max(aligned_to_image_start(:,2) - aligned_to_image_start(:,1));
        
        if max_diff > 10000
            fprintf('\nhuge diff');
            aligned_to_image_start(aligned_to_image_start(:,2) - aligned_to_image_start(:,1) > 10000,:) = [];
            current_numeric_rois(aligned_to_image_start(:,2) - aligned_to_image_start(:,1) > 10000,:) = [];
        end
        
        if ~isempty(aligned_to_image_start)
            for j = 1:size(aligned_to_image_start,1)
                psth(stp,:) = 0;

                psth(stp,aligned_to_image_start(j,1):aligned_to_image_start(j,2)) = ...
                    current_numeric_rois(j);
                stp = stp + 1;
            end
        end
    end
    
    %   bin data
    
    n_bins = floor(size(psth,2)/bin_size);
    binned = zeros(size(psth,1),n_bins);
    for k = 0:n_bins-1
        bin_range = ((k * bin_size)+1):((k+1) * bin_size);
        for j = 1:size(psth,1)
            one_trial = psth(j,bin_range);
            non_zero_els = unique(one_trial(one_trial ~= 0));
            if ~isempty(non_zero_els)
                binned(j,k+1) = non_zero_els;
            end
        end
    end
    
    all_present_rois = unique(binned(binned ~= 0));
    
    if params.flip
        all_present_rois = flipud(all_present_rois);
    end
    
    if strcmp(params.method,'singleP')
    
        freqs = zeros(1,size(binned,2));
        for k = 1:size(binned,2)
            non_zero_bin = binned(binned(:,k) ~= 0,k);
            if ~isempty(non_zero_bin)
                freqs(k) = sum(non_zero_bin == all_present_rois(1)) / length(non_zero_bin);
            end
        end

        present_roi_index = structfun(@(x) x == all_present_rois(1),roi_mapping);

        plot(1:length(freqs),freqs)   
        ylim([0 1]); xlim([0 image_presentation_length/bin_size + 1]);
        ylabel(sprintf('P (%s)',char(roi_fields(present_roi_index))));
        title(char(images{i}));

        hold on;

        equal_line = repmat(0.5,1,size(freqs,2));
        plot(1:size(freqs,2),equal_line,'k--');

    end
    
    if strcmp(params.method,'multP')
        legend_items = cell(size(roi_fields));
        freqs = zeros(1,size(binned,2));
        for k = 1:size(binned,2)
            for j = 1:length(all_present_rois)
                freqs(j,k) = sum(binned(:,k) == all_present_rois(j)) / size(binned,1);
                if k == 1
                    legend_items(j) = roi_fields(structfun(@(x) x == all_present_rois(j),roi_mapping));
                end
            end
        end
        
        if strcmp(params.plotMethod,'twoLines')
        
            plot(repmat((1:size(freqs,2)),size(freqs,1),1)',freqs')
            ylim([0 1]); xlim([0 image_presentation_length/bin_size + 1]);
            legend(legend_items);
            title(char(images{i}));
            
        end
        
        if strcmp(params.plotMethod,'oneLine')
            
            hold on;
            
            freqs = freqs(2,:) - freqs(1,:);
            
            plot(1:size(freqs,2),freqs);
            ylim([-.5 .5]); xlim([0 image_presentation_length/bin_size + 1]);
            ylabel(sprintf('Relative Probability %s - %s',legend_items{2},legend_items{1}));
            
            %   only add legend on last loop-through
            
            if i == n_plots
                legend(images);
            end
            
            %   only save the last plot
            
            if params.savePlots || save_last_plot
                save_last_plot = true;
                params.savePlots = false;
                if i == n_plots
                    params.savePlots = true;
                end
            end
            
        end
        
    end
    
    if params.savePlots
        full_plot_file_name = fullfile(params.baseSaveDirectory,params.appendToDirectory,char(images{i}));
        if isempty(params.monkey)
            full_plot_file_name = sprintf('%s.png',full_plot_file_name);
        else full_plot_file_name = sprintf('%s_%s.png',full_plot_file_name,params.monkey);
        end
        saveas(gcf,full_plot_file_name);
    end
    
end
