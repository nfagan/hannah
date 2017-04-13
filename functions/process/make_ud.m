function obj = make_ud( obj )

upgroup = { 'ephron', 'kubrick', 'tarantino' };
downgroup = { 'lager', 'hitch', 'cron' };

obj = obj.replace( upgroup, 'upGroup' );
obj = obj.replace( downgroup, 'downGroup' );

end