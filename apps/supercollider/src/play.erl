-module(play).
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
	{ok,[]}.

handle_cast(_, State)->
	{noreply,State}.

handle_call(X,_From,State)->
	io:format("play: ~w,~s~n",[State, color:yellow(io_lib:format("~w",[X]))]),
	{reply, ok,State}.

handle_info(Data, State) ->
	io:format(" play >> ~s~n",[ color:yellow(io_lib:format("~w",[Data]))]),
	{noreply, State}.

