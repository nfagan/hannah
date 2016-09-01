function data_obj = hacky_obj_concat(varargin)

data_obj = [];
for i = 1:length(varargin)
    
    one_obj = varargin{i};
    
    rois = unique(one_obj.labels.rois);
    
    for j = 1:length(rois)
        data_obj.(rois{j}).data_field = separate_data_obj(one_obj,'rois',{rois{j}});
    end
    
end

data_obj = combine_structs_across_rois(data_obj);
data_obj = data_obj.data_field;
    



