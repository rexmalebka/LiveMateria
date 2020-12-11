-module(synth).	
-export([
	 start_link/0, 
	 init/1,
	 play/0
	]).


start_link() ->
	gen_server:start_link(?MODULE, [], []).

init([]) ->
	Pid = spawn_link(fun()-> play() end),
	register(play,Pid),
	{ok, Pid}.

play() ->
	receive
		X ->
			io:format("~w~n",[X]),
			play()
	end.
