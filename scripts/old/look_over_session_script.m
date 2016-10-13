ind = time == {'ephron','high','eyes'} & time ~= {'outdoors','scrambled'};

eph_time = collapse(time(ind),{'gaze','gender'});
eph_fix = collapse(fix(ind),{'gaze','gender'});

%%

means = look_over_session(eph_time,eph_fix,'lookDuration','yLims',[0 2e3],'minutes',5);