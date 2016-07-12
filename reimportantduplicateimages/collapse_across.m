function newLabels = collapse_across(toCollapse,labels)

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
        
        
        
        









