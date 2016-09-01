function saccade_matches(saccades)

baseregions = {'quadrant','littleQuadrant'};
quads = get_quadrant(saccades,baseregions);

per_quad = struct();
for i = 1:length(baseregions)
    per_quad.(baseregions{i}) = compare_one_quadrant(quads.(baseregions{i}));
end

only_big = per_quad.quadrant & ~per_quad.littleQuadrant;
% only_big = per_quad.quadrant;

images = unique(saccades.labels.images);
doses = unique(saccades.labels.doses);

freqs = zeros(length(images),length(doses));
for i = 1:length(images)
    for d = 1:length(doses)
        ind = saccades == images{i} & saccades == doses{d};
        if sum(ind) >= 1
            freqs(i,d) = sum(only_big & ind) / sum(ind);
        else
            fprintf('\nNo saccades to %s / %s',images{i},doses{d});
        end
    end
end

bar(freqs);
legend(doses);
set(gca,'xtick',1:length(images));
set(gca,'xticklabel',images);


end

function matches = compare_one_quadrant(quadrant)

obj = quadrant.quad;

saccade = obj.data;
gaze = obj.labels.imgGaze;

saccade = cellfun(@(x) {num2str(x)}, saccade);
gaze = cellfun(@(x) {num2str(x)}, gaze);

matches = strcmp(gaze,saccade);

end



function store = get_quadrant(saccades,baseregions)

for i = 1:length(baseregions)
   [quads, keep] = within_quadrant(saccades,baseregions{i});
   store.(baseregions{i}).quad = quads;
   store.(baseregions{i}).index = keep;
end

end



function [quads, keep] = within_quadrant(saccades,baseregion)

pos = cell(1,4);
for i = 1:4
    pos{i} = define_custom_rois(sprintf('%s%d',baseregion,i));
end

data = saccades.data;

keep = true(size(data)); quads = cell(size(data));
for i = 1:length(data)
    x = data{i}.x;
    y = data{i}.y;
        
    x_ind = cellfun(@(z) x > z.minX && x < z.maxX, pos);
    y_ind = cellfun(@(z) y > z.minY && y < z.maxY, pos);

    quad = x_ind & y_ind;

    if sum(quad) ~= 1
        quads(i) = {0}; keep(i) = false; continue;
    end
    quads(i) = {find(quad == 1)};
end

inputs.data = quads;
inputs.labels = saccades.labels;

quads = DataObject(inputs);

end





