function subtracted = hannah__subtract_across( obj, label1, label2, replacewith )

first = obj.only( label1 );
second = obj.only( label2 );

assert( count(first,1) == count(second,1), 'Objects do not match in dimension' );

[~, category1] = obj == label1; category1 = category1{1};
[~, category2] = obj == label2; category2 = category2{1};

assert( strcmp( category1, category2 ), 'Labels must come from the same category' );

first = first.collapse( category1 );
second = second.collapse( category2 );

[~, combs] = getindices( first, first.fieldnames() );

subtracted = DataObject();

for i = 1:size(combs,1)    
    extr_first = first.only(combs(i,:));
    extr_sec = second.only(combs(i,:));
    
    assert( count(extr_first,1) == count(extr_sec,1), 'Dimension mismatch' );
    
    subtracted = subtracted.append( extr_first - extr_sec );
end

if ( nargin < 4 ); return; end;

subtracted( category1 ) = replacewith;

end