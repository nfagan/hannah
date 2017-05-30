%%  load

load( 'sparse_measures_outliersremoved.mat' );
looks = measures.lookdur;

%%  example table usage

use = looks;

%   get a logical index of nonsocial images.
nonsocial = use.where( {'outdoors', 'scrambled'} );

%   where nonsocial is true, replace the image label with 'nonsocial'.
%   where nonsocial is false, replace the image label with 'social'.
use( 'images', nonsocial ) = 'nonsocial';
use( 'images', ~nonsocial ) = 'social';

%   replace individual monkey names with up and down, as appropriate.
use = use.replace( {'ephron', 'kubrick', 'tarantino'}, 'up' );
use = use.replace( {'lager', 'hitch', 'cron'}, 'down' );

%   take a mean within the given specificity.
within = { 'monkeys', 'doses', 'images' };
meaned = use.do( within, @mean );

%   convert the result to a table, and display it
tbl = meaned.table( within );
disp( tbl );

%%  optionally specify row and column identities

%   create a table with rows as 'monkeys' and 'images', and columns as
%   'doses'
tbl = meaned.table( {'monkeys', 'images'}, 'doses' );
disp( tbl );