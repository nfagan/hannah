function arr2 = arr_join( arr, join_char )

arr2 = cell( size(arr, 1), 1 );
for i = 1:size(arr, 1)
  arr2{i} = strjoin( arr(i, :), join_char );
end

end