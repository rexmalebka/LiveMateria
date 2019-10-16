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

seq_parse_test() ->
        ?assertEqual(seq:seq_parse([cp,cp]),[1/2, 1/2]), 
        ?assertEqual(seq:seq_parse([cp,cp,cp]),[1/3, 1/3, 1/3]),
        ?assertEqual(seq:seq_parse([cp,[cp,cp]]), [1/2, 1/4, 1/4]),
        ?assertEqual(seq:seq_parse([hh, [hh, [cp, [hh,hh]]]]), [0.5,0.25,0.125,0.0625,0.0625]),
        ok.
