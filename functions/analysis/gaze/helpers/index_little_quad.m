function keep = index_little_quad(ind,big_quad,little_quad)


big_fix_starts_to_remove = big_quad.data(ind,3);

keep = true(length(little_quad.data(:,3)),1);
for i = 1:length(big_fix_starts_to_remove)
    
    d = little_quad.data(:,3) == big_fix_starts_to_remove(i);
    keep(d) = false;
    
end