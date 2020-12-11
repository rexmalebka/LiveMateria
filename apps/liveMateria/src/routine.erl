-module(routine).
-behaviour(gen_server).
-export([
	 start_link/0,
	 init/1,
	 handle_cast/2,
	 handle_call/3,
	 handle_info/2
	]).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [],[]).

init([]) ->
	{ok,[]}.

handle_call(X,_From,State) ->
	{reply, X, State}.

handle_cast({timeout, },State) ->
	{noreply, State}.
handle_cast(X,State) ->
	{noreply, State}.

handle_info(X,State) ->
	gen_server:cast(X).
