-module(pitcp_listener_sup).

-author("Naupio Z.Y. Huang").

-behaviour(supervisor).

-export([start_link/5]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Ref, LisOpt, ProMod, ProModOpt, OtherOpt) ->
    supervisor:start_link({local,
			   list_to_atom(lists:concat([ProMod, '_',
						      pitcp_listener_sup]))},
			  ?SERVER, [Ref, LisOpt, ProMod, ProModOpt, OtherOpt]).

init([Ref, LisOpt, ProMod, ProModOpt, OtherOpt]) ->
    SupFlags = #{strategy => one_for_one, intensity => 10,
		 period => 1},
    ChildSpec = #{id => {pitcp_listener, Ref},
		  start =>
		      {pitcp_listener, start_link,
		       [Ref, LisOpt, ProMod, ProModOpt, OtherOpt]},
		  restart => permanent, shutdown => 30000, type => worker,
		  modules => [pitcp_listener]},
    {ok, {SupFlags, [ChildSpec]}}.
