-module(piotcp_acceptor).
-author("Naupio Z.Y. Huang").

-behaviour(gen_server).

-export([start_link/7]).

%% gen_server call_back function
-export([init/1, handle_call/3, handle_cast/2
        , handle_info/2, teminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(TABLE,?SERVER).

start_link(Ref, NumIndex, ListenSocket, ProMod, ProModOpt, OtherOpt, ListenerSup) ->
    gen_server:start_link({local,list_to_atom(lists:concat([ProMod,'_','acceptor','_',NumIndex]))}
            ,?SERVER, [Ref, ListenSocket, ProMod, ProModOpt, OtherOpt, ListenerSup], []).

init([Ref, ListenSocket, ProMod, ProModOpt, OtherOpt, ListenerSup]) ->
    State = #{ref => Ref
        , listen_socket => ListenSocket
        , pro_mod => ProMod
        , pro_mod_opt => ProModOpt
        , other_opt => OtherOpt
        , listener_sup => ListenerSup
    },

    gen_server:cast(self(), loop_accept),

    {ok, State}.

handle_call(_Msg, _From, _State) ->
    {reply, _Msg, _State}.
    
handle_cast(loop_accept, State) ->
    #{ref := Ref
        , listen_socket := ListenSocket
        , pro_mod_opt := ProModOpt
        , other_opt := OtherOpt
        , listener_sup := ListenerSup
        } = State,

    case piotcp_util:accept(ListenSocket) of
        {ok, ClientSocket} ->
            {_, ClientSup, _, _} = lists:keyfind({piotcp_client_sup, Ref}, 1,
                                        supervisor:which_children(ListenerSup)),
            {ok, ConnPid} = supervisor:start_child(ClientSup, [Ref,ClientSocket,ProModOpt,OtherOpt]),
            case ConnPid of
                undefined -> error_to_do;
                ConnPid when is_pid(ConnPid) ->
                    piotcp_util:controlling_process(ClientSocket, ConnPid)
            end;
        _ ->
            error_to_do
    end,
    gen_server:cast(self(), loop_accept),

    {noreply, State};

handle_cast(_Msg, _State) ->
    {noreply, _State}.

handle_info(_Msg, _State) ->
    {noreply, _State}.

teminate(_Reson, _State) ->
    ok.

code_change(_OldVsn, _State, _Extra) ->
    ok.