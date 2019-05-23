-module(pitcp_server).

-author("Naupio Z.Y. Huang").

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server call_back function
-export([code_change/3, handle_call/3, handle_cast/2,
	 handle_info/2, init/1, terminate/2]).

-define(SERVER, ?MODULE).

-define(TABLE, ?SERVER).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [],
			  []).

init([]) -> self() ! init, {ok, undefined}.

handle_call(_Msg, _From, _State) ->
    {reply, _Msg, _State}.

handle_cast(_Msg, _State) -> {noreply, _State}.

handle_info(init, _State) ->
    ets:new(?TABLE,
	    [set, named_table, {keypos, 1}, public,
	     {read_concurrency, true}]),
    {noreply, _State};
handle_info(_Msg, _State) -> {noreply, _State}.

terminate(_Reson, _State) -> ok.

code_change(_OldVsn, _State, _Extra) -> ok.
