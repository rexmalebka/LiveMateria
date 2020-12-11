%%%-------------------------------------------------------------------
%% @doc tidalcycles public API
%% @end
%%%-------------------------------------------------------------------

-module(tidalcycles_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    tidalcycles_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
