look_data = TestClass(combined_data.lookingDuration.data,combined_data.lookingDuration.labels);

%%

look_data.use_mutated_data = false;
look_data.collapse_across(look_data,{'gender'});
look_data.separate_data_struct(look_data,'images',{'--scrambled'});
look_data.use_mutated_data = true;
look_data.separate_data_struct(look_data,'images',{'--outdoors'});





