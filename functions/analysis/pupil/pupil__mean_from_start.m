function obj = pupil__mean_from_start( obj )

data = obj.data;
first_col = data(:,1);
for i = 1:size(data, 2)
  data(:, i) = data(:, i) ./ first_col;
end
obj.data = data;

end