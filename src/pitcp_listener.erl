-module(pitcp_listener).

-author("Naupio Z.Y. Huang").

-behaviour(gen_server).

-export([start_link/5]).

%% gen_server call_back function
-export([code_change/3, handle_call/3, handle_cast/2,
	 handle_info/2, init/1, terminate/2]).

-define(SERVER, ?MODULE).

-define(TABLE, ?SERVER).

start_link(Ref, LisOpt, ProMod, ProModOpt, OtherOpt) ->
    gen_server:start_link({local,
			   list_to_atom(lists:concat([ProMod, '_',
						      pitcp_listener]))},
			  ?SERVER,
			  [Ref, LisOpt, ProMod, ProModOpt, OtherOpt, self()],
			  []).

init([Ref, LisOpt, ProMod, ProModOpt, OtherOpt,
      ListenerSup]) ->
    self() ! init,
    State = #{ref => Ref, lis_opt => LisOpt,
	      pro_mod => ProMod, pro_mod_opt => ProModOpt,
	      other_opt => OtherOpt, listener_sup => ListenerSup},
    {ok, State}.

handle_call(_Msg, _From, _State) ->
    {reply, _Msg, _State}.

handle_cast(_Msg, _State) -> {noreply, _State}.

handle_info(init, State) ->
    #{ref := Ref, lis_opt := LisOpt, pro_mod := ProMod,
      pro_mod_opt := ProModOpt, other_opt := OtherOpt,
      listener_sup := ListenerSup} =
	State,
    NewLisOpt = listen_option_pre_process(LisOpt),
    {ok, ListenSocket} = pitcp_util:listen(NewLisOpt),
    ChildSpecAcceptorSup = #{id =>
				 {pitcp_acceptor_sup, Ref},
			     start =>
				 {pitcp_acceptor_sup, start_link,
				  [Ref, ListenSocket, ProMod, ProModOpt,
				   OtherOpt, ListenerSup]},
			     restart => permanent, shutdown => infinity,
			     type => supervisor,
			     modules => [pitcp_acceptor_sup]},
    supervisor:start_child(ListenerSup,
			   ChildSpecAcceptorSup),
    ChildSpecClientSup = #{id => {pitcp_client_sup, Ref},
			   start =>
			       {pitcp_client_sup, start_link, [Ref, ProMod]},
			   restart => permanent, shutdown => infinity,
			   type => supervisor, modules => [pitcp_client_sup]},
    supervisor:start_child(ListenerSup, ChildSpecClientSup),
    {noreply, State#{listen_socket => ListenSocket}};
handle_info(_Msg, _State) -> {noreply, _State}.

terminate(_Reson, _State) -> ok.

code_change(_OldVsn, _State, _Extra) -> ok.

listen_option_pre_process(LisOpt) ->
    ReturnList = lists:map(fun (X) -> X end, LisOpt),
    ReturnList.
