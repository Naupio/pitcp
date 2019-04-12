-module(pitcp_client_sup).

-author("Naupio Z.Y. Huang").

-behaviour(supervisor).

-export([start_link/2]).

-export([init/1]).

start_link(Ref, ProMod) ->
    supervisor:start_link({local,
			   list_to_atom(lists:concat([ProMod, '_',
						      pitcp_client_sup]))},
			  ?MODULE, [Ref, ProMod]).

init([Ref, ProMod]) ->
    SupFlags = #{strategy => simple_one_for_one,
		 intensity => 1, period => 5},
    ChildSpec = #{id => {pitcp_client, Ref, ProMod},
		  start => {ProMod, start_tcp, []}, restart => transient,
		  shutdown => 30000, type => worker, modules => [ProMod]},
    {ok, {SupFlags, [ChildSpec]}}.
