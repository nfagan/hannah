function meaned = saline_normalize( obj )

meaned = obj.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
sal = do_per( obj.only('saline'), {'monkeys', 'doses', 'images'}, @mean );

[objs, inds] = meaned.enumerate( {'monkeys', 'doses', 'images', 'sessions'} );
for i = 1:numel( objs )
  current = objs{i};
  monk_lab = char( current('monkeys') );
  image_lab = char( current('images') );
  sal_ind = sal.where( {monk_lab, image_lab} );
  meaned.data( inds{i} ) = meaned.data(inds{i}) ./ sal.data(sal_ind); 
end

end