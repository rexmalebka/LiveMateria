-module(r).
-behaviour(gen_server).
-export([
	 start_link/0,
	 init/1,
	 handle_info/2,
	 handle_cast/2,
	 handle_call/3
	]).

start_link()->
	ets:new(routines, [set, public, named_table]),
	gen_server:start_link({local, ?MODULE},?MODULE, [],[]).

init([])->
	{ok,[]}.

handle_cast({new, Id, Pid,Timeout}, State) when
	  is_atom(Id);
	  is_number(Timeout)->
	ets:insert(routines, {Id, [{pid,Pid},{start, erlang:monotonic_time(milli_seconds)},{timeout, Timeout}, {timings, []}, {error,0}]}),
	{noreply, State};
handle_cast({stop, Id},State) when 
	  is_atom(Id)->
	[{Id,D}] = ets:lookup(routines, Id),
	exit(proplists:get_value(pid, D), stop),
	{noreply, ets:delete(routines, Id)}; 
handle_cast(Reply,State)->
	{noreply,State}. 


handle_call(Reply,_From,State)->
	{reply,Reply,State}. 

handle_info({sched, Timeout, Function},State) when 
	  is_function(Function);
	  is_number(Timeout) ->
	Id = list_to_atom([96+rand:uniform(26) || _<- lists:seq(0,5)] ++ [47+rand:uniform(10) || _<- lists:seq(0,5)]),
	Pid = spawn(fun()->
				    Pid = self(),
				    gen_server:cast(?MODULE, {new, Id, Pid, Timeout}),
				    io:put_chars("hola"),
				    receive
					    stop -> {stop, Pid}
				    after lists:max([0,Timeout]) ->
						  io:put_chars("hola"),
						  spawn(fun()-> 
									try
										Function({Pid,Timeout}) of
										_ -> gen_server:cast(?MODULE, {stop, Id})
									catch
										_:_ -> gen_server:cast(?MODULE, {stop, Id})
									end
							end)
				    end
		    end),	
	{noreply, State};

handle_info(_,State) ->
	{noreply, State}.

a(Id) ->
	ets:insert(routines, {Id, [{start, erlang:monotonic_time(milli_seconds)},{timeout, 1000}, {timings, []}, {error,0}]}),
	spawn(fun()-> c(Id) end).

b(N,A)->
	T = 500,
	B = erlang:monotonic_time(milli_seconds),
	receive
	after lists:max([ 0, T + (N*T - (B-A))])   ->
		      io:format("~w ~w ~w ~n",[N,(B - A), (N*T) - (B - A )]),
		      b(N+1, A)
	end.

% Start, T,[
update(Id,{error, Error}) ->
	[{Id,Data}] = ets:lookup(routines, Id),
	Ndata = [{error, Error} | proplists:delete(error, Data)],
	ets:insert(routines, {Id, Ndata});

update(Id,{timings, Timeout}) ->
	[{Id,Data}] = ets:lookup(routines, Id),
	Timings = proplists:get_value(timings, Data),
	Ndata = [{timings, lists:append(Timings,[Timeout])} | proplists:delete(timings, Data)],
	ets:insert(routines, {Id, Ndata});

update(Id,{timeout, Timeout}) ->
	[{Id,Data}] = ets:lookup(routines, Id),
	io:format("DATA,~w~n",[Data]),
	Ndata = [{timeout, Timeout} | proplists:delete(timeout, Data)],
	ets:insert(routines, {Id, Ndata}).

c(Id) ->
	[{Id, Routine}] = ets:lookup(routines, Id),
	Timeout = proplists:get_value(timeout,Routine),
	Timings = proplists:get_value(timings,Routine),
	Start = proplists:get_value(start,Routine),
	Err = proplists:get_value(error,Routine),
	io:format("~w,~w,~n",[Err,Timeout]),
	receive
		stop -> {ok, stop, Id}
	after lists:max(1,Timeout + Err)->
		      Error = lists:sum(lists:append(Timings,[Timeout])) - (erlang:monotonic_time(milli_seconds) - Start),
		      update(Id,{error, Error}),
		      update(Id,{timings, Timeout}),
		      c(Id)
	end.

