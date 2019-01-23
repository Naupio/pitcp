%%%-------------------------------------------------------------------
%% @doc pitcp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pitcp_sup).
-author("Naupio Z.Y. Huang").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    SupFlags = #{
                strategy => one_for_one,
                intensity => 10,
                period => 1
                    },
    ChildSpec = [#{
                    id => pitcp_server,
                    start => {pitcp_server,start_link,[]},
                    restart => permanent,
                    shutdown => 30000,
                    type => worker,
                    modules => [pitcp_server]
                }],
    {ok, { SupFlags, ChildSpec} }.

%%====================================================================
%% Internal functions
%%====================================================================
