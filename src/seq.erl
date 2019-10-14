-module(seq).
-author("rexmalebka@krutt.org").
-compile(export_all).
-record(sequence, {name, pattern, time=0}).

init() ->
	%% sequencer initializer
	sequence(seq1@),
	sequence(seq2@),
	sequence(seq3@),
	sequence(seq4@),
	sequence(seq5@),
	{ok, initialized}.

sequence(Name) when is_atom(Name)->
	Pid = spawn(?MODULE, sequence_proc,[Name]),
        case lists:member(Name, registered()) of
                true ->
                        {error, sequence_already_exists};
                false ->
                        register(Name, Pid),
                        {ok, Pid}
        end.

getraw(Seq) when is_atom(Seq)->
        case lists:member(Seq, registered()) of
                true ->
                        Seq ! {get, raw, self()},
                        receive 
                                RawSeq when is_list(RawSeq) ->
                                        RawSeq
                        end;
                false ->
                        {error, not_a_sequence}
        end.
        
        

sequence_proc(Name)->
        Sequence = #sequence{name=Name, pattern=[], time=0},
        receive	
		X when is_list(X) ->
			sequence_proc(Name);
                {get, Key,From} ->
                        case Key of
                                raw ->
                                        % retrieves value
                                        RawSeq = [],
                                        From ! RawSeq
                        end
	end.

sequence_parse() ->


