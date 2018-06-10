-module(piotcp).
-author("Naupio Z.Y. Huang").

-export([start_listener/5]).

start_listener(Ref, LisOpt, ProMod, ProModOpt, OtherOpt) ->
    ChildSpec = #{id => {piotcp_listener_sup, Ref}
                   , start => {piotcp_listener_sup, start_link, [Ref, LisOpt, ProMod, ProModOpt, OtherOpt]}
                   , restart => permanent
                   , shutdown => infinity
                   , type => supervisor
                   , modules => [piotcp_listener_sup]
                   },
    supervisor:start_child(piotcp_sup, ChildSpec).