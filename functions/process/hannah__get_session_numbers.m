function session_numbers = hannah__get_session_numbers( obj )

fulled = obj.full();
labs = fulled.labels.label_struct();
labs = labs.session_numbers;
labs = str2double( cellfun( @(x) x(10:end), labs, 'un', false ) );

session_numbers = Container( labs, obj.labels );

end