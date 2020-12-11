-module(scserver).
-export([
	 start_link/0,
	 init/1,
	 s/0
	]).

start_link()->
	gen_server:start_link(?MODULE,[],[]).

init([]) ->
	Pid = spawn_link( fun() -> s() end),
	register(s, Pid),
	{ok, Pid}.

s() ->
        receive
                boot ->
                        io:put_chars("booting"),
                        s();
                freeAll ->
                        io:put_chars("freeing nodes"),
                        s();
                _ ->
                        io:put_chars("miau"),
                        s()
        end.
