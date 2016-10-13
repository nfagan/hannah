%%
time = load('time.mat'); time = DataObject(time.save_field);
fix = load('fix_event_duration.mat'); fix = DataObject(fix.save_field);

%%

ind = time == {'ephron','saline','face'} & time ~= {'outdoors','scrambled'};

eph_time = collapse(time(ind),{'gaze','gender'});
eph_fix = collapse(fix(ind),{'gaze','gender'});

%%

means = look_over_session(eph_time,eph_fix,'lookDuration','yLims',[0 4e3],'minutes',5);