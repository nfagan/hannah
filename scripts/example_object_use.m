look = load('looking_duration.mat'); look = look.save_field;

%%

out = only(look, {'out'});
no_out = remove(look, {'outdoors','scrambled'});
collapse(look, {'gender','gaze','expression'});

%%

inds = look.getindices({'monkeys','doses','images','rois'});

for i = 1:numel(inds)
    
    one_object = look( inds{i} );
    
end


