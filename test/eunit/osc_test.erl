-module(osc_test).
-author("rexmalebka@krutt.org").

-include_lib("eunit/include/eunit.hrl").

send_test() ->
        E = osc:encode(["/hola", "saludos"]),
        {ok, Socket} = gen_udp:open(0,[binary]),
        ok = gen_udp:send(Socket, "localhost", 57120, E),
        gen_udp:close(Socket),
        ok.
