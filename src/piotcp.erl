-module(piotcp).
-author("Naupio Z.Y. Huang").

-export([start_listener/5]).

start_listener(Ref, LisOpt, ProMod, ProModOpt, OtherOpt) ->
    ChildSpec = #{id => {piotcp_listener, Ref}
                   , start => {piotcp_listener, start_link, [Ref, LisOpt, ProMod, ProModOpt, OtherOpt]}
                   , restart => permanent
                   , shutdown => infinity
                   , type => worker
                   , modules => [piotcp_listener]
                   },
    supervisor:start_child(piotcp_sup, ChildSpec).