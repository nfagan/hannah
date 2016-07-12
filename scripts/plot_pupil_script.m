pup = combined_data.pupilSize;
[hitch,hitch_labs] = separate_data_struct(pup.data,pup.labels,'monkeys',{'hitch'},'rois',{'image'});
[ephron,ephron_labs] = separate_data_struct(pup.data,pup.labels,'monkeys',{'ephron'},'rois',{'image'});

hitch_labs = set_all(hitch_labs,'images','all');
ephron_labs = set_all(ephron_labs,'images','all');

%%

means_and_errors_plot(hitch,hitch_labs,'title','hitch');
means_and_errors_plot(ephron,ephron_labs,'title','ephron');