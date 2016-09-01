function Helper__Plot__bar_image_dose(means,errors,labels,params)

if nargin < 4
    
params = paraminclude('Params__plot.mat');

end
  
axis_size = length(labels.images) - 1;
start_amt = .3;
stp = 0;
colors = {'r','g','b'};

figure; hold on;
for i = 1:size(means,2)
    x = start_amt+stp:1:start_amt+stp+axis_size;
    hs(i) = bar(x,means(:,i),.15,colors{i});
    errorbar(x,means(:,i),errors(:,i),'k.');
    stp = stp + start_amt;
end

set(gca,'xtick',[.6:1:.6+axis_size])
set(gca,'xticklabel',labels.images);
    
legend(hs,labels.doses)

if ~isempty(params.yLabel)
    ylabel(params.yLabel);
end
if ~isempty(params.yLimits);
    ylim(params.yLimits);
end
if ~isempty(params.title)
    title(params.title);
end

end
% bar(.3:1:.3+axis_size,means(:,1),.15,'r');
% bar(.6:1:.6+axis_size,means(:,2),.15,'g');
% bar(.9:1:.9+axis_size,means(:,3),.15,'b');
% errorbar(.3:1:.3+axis_size,means(:,1),errors(:,1),'k.')
% errorbar(.6:1:.6+axis_size,means(:,2),errors(:,2),'k.')
% errorbar(.9:1:.9+axis_size,means(:,3),errors(:,3),'k.')