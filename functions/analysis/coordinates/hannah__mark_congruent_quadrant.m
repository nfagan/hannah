function congruent = hannah__mark_congruent_quadrant( quadrant )

full_quad = quadrant.full();
gazes = full_quad( 'imgGaze' );
gazes = cellfun( @str2double, gazes );

congruent = gazes == full_quad.data;
congruent = Container( congruent, quadrant.labels );

end