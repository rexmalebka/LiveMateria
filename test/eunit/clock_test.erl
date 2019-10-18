-module(clock_test).
-author("rexmalebka@krutt.org").
-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-define(reg, registered).

clock_init_clock() ->
	?assertEqual(clock:init(),{ok, initialized}),
        ok.

mainclock_exists_test() ->
        ?assertEqual(lists:member(mainClock@, ?reg()),true),
        ok.

custom_sequence_test() ->
	clock:sequence(customclock),
        ?assertEqual(lists:member(customclock, ?reg()),true),            
        ?assertEqual(clock:sequence(customclock), {error, clock_already_exists}),
        ok.
