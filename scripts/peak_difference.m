%%  peak difference means

roi = 'eyes';

prop_ = prop.only( roi );

%%  minus sal

low = collapse( prop_.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop_.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop_.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @minus ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @minus ); 
high('doses') = 'highMinusSal';
prop_ = low.append( high );

%%  peak difference

meaned = prop_.do_per( {'monkeys', 'doses'}, @mean );

low = meaned.only( 'lowMinusSal' );
high = meaned.only( 'highMinusSal' );
subbed = high.opc( low, 'doses', @minus );
subbed( 'doses' ) = 'highMinusLow';
