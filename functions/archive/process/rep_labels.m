function labels = rep_labels(n_reps,varargin)

labels = cell(1,length(varargin));
for i = 1:length(varargin);
    label = varargin{i};
    labels{i} = repmat({label},n_reps,1);
end
