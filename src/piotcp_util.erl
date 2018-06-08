-module(piotcp_util).
-author("Naupio Z.Y. Huang").

-export([listen/1, accept/1, controlling_process/2, connect/3, send/2, setopts/2]).

listen(LisOpt) ->
    % LisOpt should has {port,Port} option.
    gen_tcp:listen(0,LisOpt).

accept(ListenSocket) ->
    gen_tcp:accept(ListenSocket).

send(Socket,Data) ->
    gen_tcp:send(Socket,Data).

setopts(Socket, Opts) ->
	inet:setopts(Socket, Opts).

controlling_process(Socket, Pid) ->
    gen_tcp:controlling_process(Socket, Pid).
    
connect(Address, Port, Options) ->
    gen_tcp:connect(Address, Port, Options).