-module(hola).
-export([
	 hola/0
	]).

hola()->
	io:format("hola ~w ~w~n",[erlang:get_cookie(), node()]),
	io:format("hola ~w ~n",[application:get_env(supercollider,scsynth_path)]).

