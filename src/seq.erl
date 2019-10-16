-module(seq).
-author("rexmalebka@krutt.org").
-compile(export_all).

-record(sequence, {name, time=0, samples=[], timing = [], effects = [], clock = main}).

init() ->
	%% sequencer initializer
	sequence(seq1@),
	sequence(seq2@),
	sequence(seq3@),
	sequence(seq4@),
	sequence(seq5@),
	{ok, initialized}.

sequence(Name) when is_atom(Name)->
        case lists:member(Name, registered()) of
                true ->
                        {error, sequence_already_exists};
                false ->
                        Pid = spawn(?MODULE, sequence_proc,[Name]),
                        global:register_name(Name, Pid),
                        register(Name, Pid),
                        {ok, Pid}
        end.

getraw(Seq) when is_atom(Seq)->
        Seq ! {self(), raw},
        receive 
                X when is_list(X)->
                        {ok, X}
        end,
        {ok, X}.

sequence_proc(Name) when is_atom(Name)->
        SeqReg = #sequence{name=Name, clock=main, time=0},
        io:write(SeqReg#sequence.name),
        sequence_proc(SeqReg);

sequence_proc(SeqReg) ->
        receive	
                Sequence_list when is_list(Sequence_list)-> 
                        SeqReg2 = #sequence{name=
                                            SeqReg#sequence.name,
                                            clock=main,
                                            time = 0,
                                            samples=seq_parse(Sequence_list)
                                           },
                        sequence_proc(SeqReg2);
                {From, raw} ->
                        From ! (SeqReg#sequence.samples),
                        sequence_proc(SeqReg);
                _ ->
                        sequence_proc(SeqReg)
	end.


seq_parse() ->
        {}.

seq_parse(SampleList) when is_list(SampleList) ->
        lists:flatten([seq_parse(Sample, length(SampleList)) || Sample <- SampleList]).

seq_parse(Sample, Len) when is_atom(Sample), is_integer(Len) ->
        1/Len;

seq_parse(SampleList, Level) when is_list(SampleList), is_integer(Level) ->
        [seq_parse(Sample, length(SampleList)*Level) || Sample <- SampleList ].


