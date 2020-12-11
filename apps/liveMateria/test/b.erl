-module(b).
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
	Port = 9999,
	{ok, Socket} = gen_tcp:listen(Port, [binary, {active, false}]),
	spawn(fun() -> connection(Socket) end),
	{ok, []}.


handle_cast(X, State) ->
	io:format("cast >> ~w ~n",[X]),
	{noreply,State}.


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
	{reply, ok, proplists:delete(Socket,State)};


handle_call({parse, Socket, Text}, _From, State) ->
	% when peer sends text to parse.
	Reply = parser:evaluate_expression(Text),
	Nstate = [{Socket ,Reply} | proplists:delete(Socket,State)],
	{reply, Reply, Nstate}.



handle_info(X, State) ->
	io:format("info >> ~w ~n",[X]),
	{noreply, State}.

connection(ListenSocket) ->
	{ok, Socket} = gen_tcp:accept(ListenSocket),
	io:format("new connection (~w).~n",[Socket]),
	gen_server:call(?MODULE, {new,Socket}),
	spawn(fun()-> connection(ListenSocket) end),
	handler(ListenSocket,Socket).

handler(ListenSocket,Socket)->
	inet:setopts(Socket, [{active, once}]),
	receive
		{tcp, Socket, <<"quit", _/binary>>} ->
			io:format("Connection closed (~w).~n",[Socket]),
			gen_tcp:close(Socket);
		{tcp, Socket, <<13,10>>} ->
			gen_tcp:send(Socket, <<13,10>>),
			handler(ListenSocket,Socket);
		{tcp, Socket, Msg} ->
			io:format("(~w): msg: ~w~n",[Socket,Msg]),
			Reply = io_lib:format("~w~n", [gen_server:call(?MODULE, {parse, Socket, binary_to_list(Msg)})] ),
			gen_tcp:send(Socket, list_to_binary(Reply)),
			handler(ListenSocket,Socket);
		{tcp_closed,Socket} ->
			gen_server:call(?MODULE, {close,Socket}),
			io:format("Connection closed (~w).~n",[Socket]),
			gen_tcp:close(Socket)
	end.

