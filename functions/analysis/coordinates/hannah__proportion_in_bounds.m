function proportion = hannah__proportion_in_bounds( within_bounds )

prop = sum( within_bounds.data, 1 ) ./ shape(within_bounds, 1);
proportion = within_bounds.collapse_non_uniform();
proportion = proportion.keep_one(1);
proportion.data = prop;

end