function img_info = get_master_roi(region,monkey,metric)

    possible_metrics = {'max','min'};

    if nargin < 3
        metric = 'max';
    end
    
    if ~any(strcmp(possible_metrics,metric))
        disp(possible_metrics);
        error('Above are the possible metrics');
    end

    excel_coords = load_excel_roi_coordinates();
    imgs = unique(excel_coords.labels(:,1));
    
    imgs(cellfun(@isempty,imgs)) = [];
    
    img_info = struct();
    for i = 1:length(imgs)
        img = imgs{i};
        pos = looking_coordinates_mult_images(img,monkey,region,excel_coords);
        current_area = (pos.maxX - pos.minX) * (pos.maxY - pos.minY);
        
        if i > 1
            if strcmp(metric,'max') && i > 1
                test_cnd = current_area > prev_area;
            elseif strcmp(metric,'min') && i > 1
                test_cnd = current_area < prev_area;
            end
        else
            test_cnd = true;
        end
        
        if test_cnd
            img_info.filename = img;
            img_info.area = current_area;
            img_info.pos = pos;
        end
        
        prev_area = current_area;
        
    end
    
end





