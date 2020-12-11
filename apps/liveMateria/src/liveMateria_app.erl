%%%-------------------------------------------------------------------
%% @doc liveMateria public API
%% @end
%%%-------------------------------------------------------------------

-module(liveMateria_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    liveMateria_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
