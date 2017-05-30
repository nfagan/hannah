function subbed = soc_minus_non_fnc( obj, per, to_collapse )

if ( nargin < 3 )
  to_collapse = { 'images', 'gazes', 'genders', 'expressions', 'imgGaze' };
end

per_dose = obj.enumerate( per );
subbed = Container();
for i = 1:numel(per_dose)
  soc = per_dose{i}.only( 'social' );
  non = per_dose{i}.only( 'nonsocial' );
  per_dose{i} = soc.opc( non, to_collapse, @minus );
  per_dose{i}('images') = 'socialMinusNonSocial';
end

subbed = subbed.extend( per_dose{:} );

end