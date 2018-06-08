-module(piotcp_acceptor_sup).
-author("Naupio Z.Y. Huang").

-behaviour(supervisor).

-export([start_link/5]).
-export([init/1]).

start_link(Ref, ListenSocket, ProMod, ProModOpt, OtherOpt) ->
    supervisor:start_link({local,list_to_atom(lists:concat([ProMod,'_','piotcp_acceptor_sup']))}
                ,?MODULE, [Ref, ListenSocket, ProMod, ProModOpt, OtherOpt]).

init([Ref, ListenSocket, ProMod, ProModOpt, OtherOpt]) ->
    AcceptorNum = case lists:keyfind(acceptor_num, 1, OtherOpt) of
                    false -> 10;
                    {acceptor_num, Value} -> Value
                end,
    ChildSpec = acceptor_generator([AcceptorNum, Ref, ListenSocket, ProMod, ProModOpt, OtherOpt]),
    SupFlags = #{
        strategy => one_for_one,
        intensity => 1,
        period => 5
    },
    {ok, { SupFlags, ChildSpec}}.

acceptor_generator([AcceptorNum, Ref, ListenSocket, ProMod, ProModOpt, OtherOpt]) when AcceptorNum>0 andalso is_integer(AcceptorNum) ->
    lists:map(fun(NumIndex) ->
                #{id => {piotcp_acceptor, Ref, NumIndex}
                , start => {piotcp_acceptor, start_link, [Ref, NumIndex, ListenSocket, ProMod, ProModOpt, OtherOpt]}
                , restart => permanent
                , shutdown => 30000
                , type => worker
                , modules => [piotcp_acceptor]
                }
            end
        ,lists:seq(1,AcceptorNum)
        ).