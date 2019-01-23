-module(pitcp_protocol).
-author("Naupio Z.Y. Huang").

-callback start_tcp(Ref::any()
                    , Socket::inet:socket()
                    ,ProModOpt::[any()]
                    ,OtherOpt::[any()] )
                    -> {ok, pid()}.