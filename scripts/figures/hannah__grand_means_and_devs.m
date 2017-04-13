%%  Raw looking means, social vs. nonsocial

roi = 'image';
extr = looks.only( roi );

meaned = extr.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
social_index = ~meaned.where( {'outdoors', 'scrambled'} );
meaned( 'images', social_index ) = 'social';
meaned( 'images', ~social_index ) = 'nonsocial';

meaned = meaned.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
%%
grand_meaned = meaned.do_per( {'monkeys', 'doses', 'images'}, @mean );
grand_dev = meaned.do_per( {'monkeys', 'doses', 'images'}, @std );

%%
meaned = meaned.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
meaned = meaned.replace( {'cron', 'hitch', 'lager'}, 'downGroup' );

%%  save

save( sprintf('soc_vs_nonsocial_raw_means_%s.mat', roi), 'grand_meaned' );
save( sprintf('soc_vs_nonsocial_raw_devs_%s.mat', roi), 'grand_dev' );

%%  Raw looking means, by gaze / expression, collapsed groups

meaned = extr.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );

gaze_means = meaned.do_per( {'gazes', 'doses'}, @mean );
gaze_devs = meaned.do_per( {'gazes', 'doses'}, @std );

exp_means = meaned.do_per( {'expressions', 'doses'}, @mean );
exp_devs = meaned.do_per( {'expressions', 'doses'}, @std );

save( 'raw_means_per_gaze.mat', 'gaze_means' );
save( 'raw_devs_per_gaze.mat', 'gaze_devs' );
save( 'raw_means_per_exp.mat', 'exp_means' );
save( 'raw_devs_per_exp.mat', 'exp_devs' );

%%  Raw looking means, by gaze / expression, per group

meaned = extr.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
meaned = meaned.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
meaned = meaned.replace( {'cron', 'hitch', 'lager'}, 'downGroup' );

gaze_means = meaned.do_per( {'monkeys', 'gazes', 'doses'}, @mean );
gaze_devs = meaned.do_per( {'monkeys', 'gazes', 'doses'}, @std );

exp_means = meaned.do_per( {'monkeys', 'expressions', 'doses'}, @mean );
exp_devs = meaned.do_per( {'monkeys', 'expressions', 'doses'}, @std );

save( 'raw_means_per_gaze_per_group.mat', 'gaze_means' );
save( 'raw_devs_per_gaze_per_group.mat', 'gaze_devs' );
save( 'raw_means_per_exp_per_group.mat', 'exp_means' );
save( 'raw_devs_per_exp_per_group.mat', 'exp_devs' );

%%  Raw looking means, threat vs. non-threat

meaned = extr.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
meaned = meaned.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
meaned = meaned.replace( {'cron', 'hitch', 'lager'}, 'downGroup' );
non_threat = ~meaned.where( 'expressions__t' );
meaned( 'images', non_threat ) = 'non_threat';

threat_nonthreat_means = meaned.do_per( {'monkeys', 'expressions', 'doses'}, @mean );
threat_nonthreat_devs = meaned.do_per( {'monkeys', 'expressions', 'doses'}, @std );

save( 'raw_means_threat_v_nonthreat_per_group.mat', 'threat_nonthreat_means' );
save( 'raw_devs_threat_v_nonthreat_per_group.mat', 'threat_nonthreat_devs' );

threat_nonthreat_means = meaned.do_per( {'expressions', 'doses'}, @mean );
threat_nonthreat_devs = meaned.do_per( {'expressions', 'doses'}, @std );

save( 'raw_means_threat_v_nonthreat.mat', 'threat_nonthreat_means' );
save( 'raw_devs_threat_v_nonthreat.mat', 'threat_nonthreat_devs' );




