%%%-------------------------------------------------------------------
%% @doc livemateriaatom top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(liveMateria_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    create_ets(),
    set_cookie(),
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    %ChildSpecs = [
    %#{
    %		    id => tdpSocket,
    %		    start => {tcpSocket, start_link, []}
    %		    },
    %		    #{
    %		    id => synth,
    %		    start => {synth, start_link, []}
    %		    },
    ChildSpecs = [
		  #{
		    id => tcpSocket,
		    start => {tcpSocket, start_link, []}
		   }
		 ],
    %{ok, {SupFlags, []}}.
    {ok, {SupFlags, ChildSpecs}}.

set_cookie() ->
	erlang:set_cookie( node(), application:get_env(liveMateria,cookie,liveMateria)),
	io:format("\tnode:~s\n\tCookie:~s~n",[color:yellow(io_lib:format("~w",[node()])), color:yellow( io_lib:format("~w",[erlang:get_cookie()]) )]),
	{ok, erlang:get_cookie()}.

%% internal functions
create_ets() ->
	ets:new(proxies, [set, public, named_table]),
	ets:new(buses, [set, public, named_table]),
	ets:new(bounds, [set, public, named_table]).


