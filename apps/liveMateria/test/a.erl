-module(a).
-export([
	 start/0
	]).

start()->
	register(play, spawn(fun()-> play() end)).

play()->
	receive 
		X ->
			io:format(">> ~w~n",[X]),
			play()
	end.


