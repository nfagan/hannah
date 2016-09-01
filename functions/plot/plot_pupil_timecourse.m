function outputs = plot_pupil_timecourse(pup,varargin)

params = struct(...
    'startLines',[] ...
);

params = structInpParse(params,varargin);       %   parse function inputs
params = paraminclude('Params__plot',params);   %   add standard plotting parameters

images = unique(pup('images'));

means = struct(); errors = struct(); figure;
for k = 1:length(images)

    size = pup(pup == images{k});

    size.data = cellfun(@(x) x, size.data,'UniformOutput',false);

    %   cell arrays -> single matrix
    
    combined = concatenateData(size.data);
    
    %   index + remove zeros
    
    zeros_index = sum(combined == 0,2) >= 1;
    
    combined = combined(~zeros_index,:);

    means.(images{k}) = mean(combined);
    errors.(images{k}) = SEM(combined);
    
    plot(means.(images{k})); hold on;
    
end
    
outputs.means = means;
outputs.errors = errors;

legend(images);

%   add lines to indicate when the image appeared, and others as desired

if ~isempty(params.startLines)
    
    start_lines = params.startLines;
    ycoords = [min(means.(images{1})); max(means.(images{1}))];
    
    for i = 1:length(start_lines)
        plot([start_lines(i);start_lines(i)],ycoords,'k-');
    end
    
end

end