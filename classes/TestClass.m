%         function obj = TestClass(data,labels)
%             obj.original_data = data;
%             obj.original_labels = labels;
%         end

classdef TestClass < handle
    
    properties
        original_data;
        original_labels;
        mutated_data;
        use_mutated_data;
        mutated_labels;
        mutation_history = struct;
        n_mutations;
    end
    
    methods(Static)
        function this = TestClass(data,labels)
            this.original_data = data;
            this.original_labels = labels;
            this.n_mutations = 0;
            this.use_mutated_data = false;
        end
        function reset_mutations(this)
            this.n_mutations = 0;
        end
        function newLabels = collapse_across(this,toCollapse)
            if ~this.use_mutated_data
                labels = this.original_labels;
            else
                labels = this.mutated_labels;
            end
            
            if isstruct(labels)
                image_names = labels.images; new_method = 1;
            elseif iscell(labels)
                image_names = labels{4}; new_method = 0;
            else
                error('Labels must be a cell array or struct');
            end

            for i = 1:length(image_names);
                if any(strcmp(toCollapse,'gender')); % if collapsing across gender
                    if length(image_names{i}) == 4;
                                                        % replace gender tag with A
                                                        % for all

                        image_names{i} = [image_names{i}(1) 'A' image_names{i}(3:4)];

                    end
                end
                if any(strcmp(toCollapse,'gaze')); % if collapsing across gaze
                    if length(image_names{i}) == 4;
                                                        % replace gaze tag with A
                                                        % for all

                        image_names{i} = [image_names{i}(1:2) 'A' image_names{i}(4)];

                    end
                end
                if any(strcmp(toCollapse,'expression')); % if collapsing across expression
                    if length(image_names{i}) == 4;
                                                        % replace expression tag with A
                                                        % for all
                        image_names{i} = [image_names{i}(1:3) 'A'];

                    end
                end
            end

            newLabels = labels;

            if new_method
                newLabels.images = image_names;
            else
                newLabels{4} = image_names;
            end
            
            this.mutated_labels = newLabels;
            
        end
        function separate_data_struct(this,varargin)
            
            if ~this.use_mutated_data
                values = this.original_data;
                labels = this.original_labels;
            else
                values = this.mutated_data;
                labels = this.mutated_labels;
            end
            
            if ~isstruct(labels)
                error(['This separate_data function requires the data labels to be made into a struct.' ...
                    , ' Use make_struct.m to convert the cell array labels to struct-form.']);
            end

            label_fields = fieldnames(labels);

            if length(values) ~= length(labels.(label_fields{1}))
                error(['The lengths of the data and data-labels do not match. Possibly you are using' ...
                    , ' the wrong data labels.']);
            end     

            for i = 1:length(label_fields)  % by default, assume we want all data associated with
                                            % each label
                params.(label_fields{i}) = 'all';
            end

            params = structInpParse(params,varargin); % overwrite 'all' labels with desired labels

            use_index = true(length(values),1);
            for i = 1:length(label_fields)
                current_field = label_fields{i};
                if ~sum(strcmp(params.(current_field),'all'))
                    desired_labels = params.(current_field);
                    matches_current_label = false(length(values),1);
                    current_labels = labels.(current_field);
                    if ischar(current_labels{1})
                        for k = 1:length(desired_labels)
                            if ~strncmpi(desired_labels{k},'--',2)
                                matches_current_label = matches_current_label | ...
                                    strcmp(current_labels,desired_labels{k});
                            else
                                fprintf('\nNewmethod');
                                matches_current_label = matches_current_label | ...
                                    ~strcmp(current_labels,desired_labels{k}(3:end));
                            end
                        end
                    else % if labels are a cell array of integers (block number, etc.)
                        for k = 1:length(desired_labels)
                            matches_current_label = matches_current_label | ...
                                current_labels == desired_labels{k};
                        end
                    end
                else
                    matches_current_label = true(length(values),1);
                end
                use_index = use_index & matches_current_label;
            end

            output_values = values(use_index,:);
            output_labels = labels;
            for i = 1:length(label_fields);
                output_labels.(label_fields{i})(~use_index) = [];
            end
            this.mutated_data = output_values;
            this.mutated_labels = output_labels;
            this.n_mutations = this.n_mutations + 1;
            this.mutation_history = params;
        end
        function means_and_errors_plot(this)
            means_and_errors_plot(this.mutated_values,this.mutated_labels)
        end
    end
end
        
        