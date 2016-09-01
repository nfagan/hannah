function labels = get_labels(dataField,varargin)

nReps = size(dataField,1);

labels = cell(1,length(varargin));
for i = 1:length(varargin);
    label = varargin{i};
    labels{i} = repmat({label},nReps,1);
end



    
    
    