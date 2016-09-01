%{
    normalize_per_file.m -- function for normalizing the data in obj to the
    mean of the corresponding saline data. <within> controls the
    specificity of the normalization. Usually, we will normalize within
    monkey, file
%}

function [obj, keep] = normalize_per_file(obj,within)

if nargin < 2
    within = {'monkeys','file_names','doses'};
end

%   ensure that 'doses' is in <within>, and mark its place

doses_index = strcmp(within,'doses');

if ~any(doses_index)
    error('<within> must include ''doses''');
end

if ~isa(obj,'DataObject');
    obj = DataObject(obj);
end

[indices, combs] = getindices(obj,within,'showProgress');

keep = false(count(obj,1),1);
for i = 1:length(indices)
    
    data = obj(indices{i});
    
    %   look for all the same labels in combs, except for dose; replace it
    %   with saline
    
    search = [combs(i,~doses_index) {'saline'}];
    
    saline = obj(obj == search);
    
    if isempty(saline)
        continue;
    end
    
    normed = data ./ mean(saline);
    
    obj(indices{i}) = normed.data;
    keep(indices{i}) = true;
    
end

obj = obj(keep);

end




% 
% 
% 
% function test()
% 
% 
% monkeys = unique(obj('monkeys'));
% 
% kept = true(count(obj,1));
% 
% for i = 1:length(monkeys)
%     
%     monk_index = obj == monkeys{i};
%     
%     onemonk = obj(monk_index);
%     
%     %   normalize per monkey
%     
%     [onemonk_normed, index] = normalize_per_monkey(onemonk);
%     
%     %   mark which were kept
%     
%     kept(monk_index) = index;
%     
%     if i == 1
%         all_normed = onemonk_normed; continue;
%     end
%     
%     %   store across monkeys
%     
%     all_normed = [all_normed;onemonk_normed];
%     
% end
% 
% end
% 
% 
% function [obj, was_normed] = normalize_per_monkey(obj)
% 
% files = unique(obj('file_names'));
% doses = unique(obj('doses'));
% 
% was_normed = false(count(obj,1),1);     % for keeping track of which data points were
%                                         % and were not normalized
% 
% for i = 1:length(files)
%     fprintf('\nProcessing %d of %d',i,length(files));
%     
%     saline = obj(obj == files{i} & obj == 'saline');
%     
%     if isempty(saline)
%         continue;
%     end
%     
%     for d = 1:length(doses)
%         
%         %   index of the current dose
%         
%         dose_index = obj == files{i} & obj == doses{d};
%         
%         dose = obj(dose_index);
%         
%         if isempty(dose)
%             continue;
%         end
%         
%         data = dose.data;
%         
%         obj(dose_index) = data ./ mean(saline);
%         
%         %   mark the normalized data points for retention
%         
%         was_normed(dose_index) = true;
%         
%     end
%     
% end
% 
% obj = obj(was_normed);  % only keep the data that could be normalized
% 
% end