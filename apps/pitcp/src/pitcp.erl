-module(pitcp).

-author("Naupio Z.Y. Huang").

-export([start_listener/5]).

start_listener(Ref, LisOpt, ProMod, ProModOpt,
	       OtherOpt) ->
    ChildSpec = #{id => {pitcp_listener_sup, Ref},
		  start =>
		      {pitcp_listener_sup, start_link,
		       [Ref, LisOpt, ProMod, ProModOpt, OtherOpt]},
		  restart => permanent, shutdown => infinity,
		  type => supervisor, modules => [pitcp_listener_sup]},
    supervisor:start_child(pitcp_sup, ChildSpec).
