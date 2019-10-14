-module(connection_test).
-author("rexmalebka@krutt.org").

-include_lib("eunit/include/eunit.hrl").
init_test() ->
	?assertEqual(conn:init(),{ok,ets_intialized}),
	?assertEqual(conn:init(),{ok,ets_intialized}),
	ok.

name_test()->
	?assertEqual(conn:name(),{ok, {hostname,nohost}}),
	?assertEqual(conn:name(hola), {ok,{hostname, "hola@127.0.0.1"}}),
	?assertEqual(conn:name(hola@), {ok,{hostname, "hola@127.0.0.1"}}),
	?assertEqual(conn:name(hola@kramble), {ok,{hostname, "hola@kramble"}}),
	ok.


config_test()->
	receive 
		_ ->
			false
	after 
		100 ->
			ok
	end,

	?assertEqual(conn:config(), {ok, {config, allow}}),
	?assertEqual(conn:config({deny}), {ok, {config, deny}}),
	?assertEqual(conn:config({allow}), {ok, {config, allow}}),
	?assertEqual(conn:config({from, none}),{ok,{config, deny}}),
	?assertEqual(conn:config({from, all}),{ok,{config, allow}}),
	?assertEqual(conn:config({from, []}),{ok,{config, deny}}),
	?assertEqual(conn:config({from, [luis]}), {ok,{config,{from, ["luis@127.0.0.1"]} }}),
	?assertEqual(conn:name(hola@hola),{ok,{hostname,"hola@hola"}}),
	?assertEqual(conn:config({from, [luis@k,hola@hola]}), {ok,{config,{from, ["luis@k"]} }}),
	?assertEqual(conn:config({from, [luis@k,hola,hola@hola, ok@ok]}), {ok,{config,{from, ["luis@k","hola@127.0.0.1","ok@ok"]} }}),

	ok.

%server_test() ->
%	server:init().

%connect_all_test() ->
%	?assertEqual(conn:init(),{ok,ets_intialized}),
%	?assertEqual(conn:name(hola), {ok,{hostname, "hola@127.0.0.1"}}),
%	?assertEqual(conn:config(), {ok, {config, allow}}),
%	?assertEqual(conn:connect(),{ok, connected}),
%	ok.

	

