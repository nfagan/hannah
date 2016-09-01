%{

    normalize.m -- function for normalizing the data in <obj> to the
    mean of the corresponding saline data. <within> controls the
    specificity of the normalization. Usually, we will normalize within
    monkey, file, dose, and roi.

    <obj> must be a DataObject; otherwise, the function will attempt to 
    convert it into one. Try typing ''help DataObject'' if you are unsure
    about its usage.

    N.B. It is advisable that you first call remove_outliers(obj) and
    truthy(obj) before attempting to normalize.

%}

function [obj, keep] = normalize(obj,within)
tic;

if nargin < 2
    within = {'monkeys','doses','rois','file_names'};
end

%   ensure that 'doses' is in <within>, and mark its place

doses_index = strcmp(within,'doses');

if ~any(doses_index)
    error('<within> must include ''doses''');
end

if ~isa(obj,'DataObject');
    obj = DataObject(obj);
end

%   getindices returns <indices> of all the unique combinations of unique
%   labels in the categories of <within>. <combs> indicates the combination
%   of labels used to construct each index.

[indices, combs] = getindices(obj,within,'showProgress');

keep = false(count(obj,1),1);
for i = 1:length(indices)
    fprintf('\nNormalizing %d of %d',i,length(indices));
    
    data = obj(indices{i});
    
    %   look for all the same labels in combs, except for dose; replace it
    %   with saline
    
    search = [combs(i,~doses_index) {'saline'}];
    
    saline = obj(eq(obj,search,within));    %   same as saying obj(obj == search)
                                            %   but much faster, because we
                                            %   limit which fields to
                                            %   search through
    
    if isempty(saline)
        continue;
    end
    
    normed = data ./ mean(saline);
    
    obj(indices{i}) = normed.data;
    keep(indices{i}) = true;
    
end

obj = obj(keep);

toc;
end