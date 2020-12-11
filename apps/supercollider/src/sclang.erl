-module(sclang).
-behaviour(gen_server).
-export([
	start_link/0,
	init/1,
	handle_info/2,
	handle_call/3,
	handle_cast/2
	]).

start_link()->
	gen_server:start_link({local,?MODULE},?MODULE, [],[]).

init([]) ->
	Port = open_port({spawn, "/Applications/SuperCollider.app/Contents/MacOS/sclang"}, [exit_status, use_stdio, stderr_to_stdout]),
	Pid =  spawn(fun()-> handler(Port) end),
	port_connect(Port,Pid),
	{ok, {Port,Pid,""}}.

handle_call(quit,_From, State) ->
	{Port,Pid,_} = State,
	Port ! {Pid, close},
	port_close(Port),
	{stop, quit, State}.


handle_cast({call, Msg},State) ->
	{Port,Pid,_} = State,
	Port ! {Pid, {command, Msg}},
	{noreply, State}.

handle_info(Msg, State) ->
	gen_server:cast(?MODULE,{call, Msg}),
	{noreply, State}.

handler(Port) ->
	receive 
		{Port, {data,Data}} ->
			io:format("~s",[color:blue([Data])]),
			handler(Port);
		{Port, {exit_status, X}} ->
			io:format("closed ~p~n",[X]),
			gen_server:call(?MODULE, quit);
		{Port, closed} ->
			exit(normal);
		{'EXIT', Port, _} ->
			exit(port_terminated);
		X ->
			io:format("~w~n",[X]),
			handler(Port)
	end.
