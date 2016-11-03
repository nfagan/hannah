function varargout = concatenateData(varargin)

varargout = cell(1,length(varargin));

for i = 1:length(varargin);
    toConcat = varargin{i};
    concatenated = [];
    for j = 1:length(toConcat);
        if j < 2;
            concatenated = toConcat{j};
        else
            concatenated = vertcat(concatenated,toConcat{j});
        end
    end
    
    varargout{i} = concatenated;
    
end