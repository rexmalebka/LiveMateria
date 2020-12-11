-module(tcpSocket).
-behaviour(gen_server).
-export([
	start_link/0,
	init/1,
	handle_info/2,
	handle_call/3,
	handle_cast/2
	]).


start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [],[]).

init([]) ->
	Port = application:get_env(liveMateria, tcpport, 9999),
	{ok, Socket} = gen_tcp:listen(Port, [binary, {active, false}]),
	io:format("(TCP) listening on port (~s).~n",[color:green(io_lib:format("~w",[Port]))]),
	spawn(fun() -> connection(Socket) end),
	{ok, []}.


handle_cast({Socket, {ok, Reply,_}}, State) ->
	% send back to socket
	gen_tcp:send(Socket, list_to_binary(io_lib:format("~w",[{ok,Reply}]))),
	{noreply,State};

handle_cast({Socket, {error, Reply}}, State) ->
	% send back to socket
	gen_tcp:send(Socket, list_to_binary(io_lib:format("~w",[{error,Reply}]))),
	{noreply,State};

handle_cast({update, Socket, Reply}, State) ->
	Nstate = [{Socket ,Reply} | proplists:delete(Socket,State)],
	{noreply, Nstate};

handle_cast({parse, Socket, Text}, State) ->
	% when peer sends text to parse.
	PID = spawn(fun()->
		      Reply = parser:evaluate_expression(Text),
		      gen_server:cast(?MODULE,{Socket, Reply}),
		      gen_server:cast(?MODULE,{update, Socket, Reply})
	      end),
	Nstate = [{Socket , PID} | proplists:delete(Socket,State)],
	{noreply, Nstate}.



handle_call(quit, _From,State) ->
	% when host leaves.
	lists:foreach(fun(X) -> 
				      {Pid,Value} = X,
				      Socket = proplists:get_value(socket,Value),
				      Pid ! {tcp,Socket,<<"quit">>}
		      end, State),
	{stop, quit, State};

handle_call({new,Socket}, _From,State) ->
	% when a new peer comes in 
	Nstate = [{Socket, {}}|proplists:delete(Socket,State)],
	{reply, ok, Nstate};

handle_call({close,Socket}, _From,State) ->
	% when a peer leaves 
	{reply, ok, proplists:delete(Socket,State)}.



handle_info(X, State) ->
	io:format("info >> ~w ~n",[X]),
	{noreply, State}.

connection(ListenSocket) ->
	{ok, Socket} = gen_tcp:accept(ListenSocket),
	io:format("new connection (~s).~n",[color:green(io_lib:format("~w",[Socket]))]),
	gen_server:call(?MODULE, {new,Socket}),
	spawn(fun()-> connection(ListenSocket) end),
	handler(ListenSocket,Socket).

handler(ListenSocket,Socket)->
	inet:setopts(Socket, [{active, once}]),
	receive
		{tcp, Socket, <<"quit", _/binary>>} ->
			io:format("Connection closed (~s).~n",[color:green(io_lib:format("~w",[Socket]))]),
			gen_tcp:close(Socket);
		{tcp, Socket, <<13,10>>} ->
			gen_tcp:send(Socket, <<13,10>>),
			handler(ListenSocket,Socket);
		{tcp, Socket, Msg} ->
			io:format("(~s): msg: \"~s\"~n",[color:green(io_lib:format("~w",[Socket])),
							 color:yellow(string:trim(binary_to_list(Msg)))]),
			gen_server:cast(?MODULE, {parse, Socket, binary_to_list(Msg)}),
			handler(ListenSocket,Socket);
		{tcp_closed,Socket} ->
			io:format("Connection closed (~s).~n",[color:green(io_lib:format("~w",[Socket]))]),
			gen_server:call(?MODULE, {close,Socket}),
			gen_tcp:close(Socket)
	end.

