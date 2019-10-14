-module(sequences_test).
-author("rexmalebka@krutt.org").
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-define(reg, registered).
sequences_init_test() ->
	?assertEqual(seq:init(),{ok, initialized}),
        ok.

sequences_exists_test() ->
        ?assertEqual(lists:member(seq1@, ?reg()),true),
        ?assertEqual(lists:member(seq2@, ?reg()),true),
        ?assertEqual(lists:member(seq3@, ?reg()),true),
        ?assertEqual(lists:member(seq4@, ?reg()),true),
        ?assertEqual(lists:member(seq5@, ?reg()),true),          
        ok.

custom_sequence_test() ->
	seq:sequence(custom),
        ?assertEqual(lists:member(custom, ?reg()),true),            
        ?assertEqual(seq:sequence(custom), {error, sequence_already_exists}),              ok.


