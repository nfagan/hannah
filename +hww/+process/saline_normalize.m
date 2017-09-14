function meaned = saline_normalize(obj)

within1 = { 'monkeys', 'doses', 'images', 'sessions' };
within2 = { 'monkeys', 'doses', 'images' };

meaned = obj.for_each_1d( within1, @Container.mean_1d );
sal = obj.only( 'saline' );
sal = sal.for_each_1d( within2, @Container.mean_1d );

[inds, C] = meaned.get_indices( {'monkeys', 'doses', 'images', 'sessions'} );

meaned_data = meaned.data;
sal_data = sal.data;

for i = 1:numel(inds)
  index = inds{i};
  row = C(i, :);
  monk_lab = row{1};
  image_lab = row{3};
  sal_ind = sal.where( {monk_lab, image_lab} );
  meaned_data(index) = meaned_data(index) ./ sal_data(sal_ind);
end

meaned.data = meaned_data;

end