-module(seq).
-author("rexmalebka@krutt.org").
-compile(export_all).

-record(sequence, {
          name, 
          clock = main,
          state = stopped,
          samples=[], 
          timing = [], 
          effects = [], 
          current = 1,
          globaltime=0, 
          localtime=0,
          bpm = 120,
          schedfunc
         }).

init() ->
	%% sequencer initializer
	sequence(seq1@),
	sequence(seq2@),
	sequence(seq3@),
	sequence(seq4@),
	sequence(seq5@),
        
        mainclock@ ! {append, seq1@},
        mainclock@ ! {append, seq2@},
        mainclock@ ! {append, seq3@},
        mainclock@ ! {append, seq4@},
        mainclock@ ! {append, seq5@},
	mainclock@ ! play,
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
        SeqReg = #sequence{name=Name, clock=mainclock@},
        sequence_proc(SeqReg);

sequence_proc(SeqReg) ->
        receive	
                Sequence_list when is_list(Sequence_list)-> 
                        SeqReg2 = SeqReg#sequence{
                                            timing=seq_parse(Sequence_list),
                                            samples=lists:flatten(Sequence_list)
                                           },
                        sequence_proc(SeqReg2);
                play ->
                        case length(SeqReg#sequence.samples)>0 of
                                true ->
                                        Timeout = lists:nth(SeqReg#sequence.current,SeqReg#sequence.timing)* (60*1000/SeqReg#sequence.bpm) ,
                                        Pid = spawn(?MODULE, schedule, [Timeout,self()] ),
                                        SeqReg2 = SeqReg#sequence{state=playing, schedfunc = Pid},
                                        sequence_proc(SeqReg2);
                                _ ->
                                        SeqReg2 = SeqReg#sequence{state=playing},
                                        sequence_proc(SeqReg2)
                        end;
                tick ->
                        %SeqReg#sequence.schedfunc ! die,
                        case length(SeqReg#sequence.timing)>0 of
                                true ->
                                        Timeout = lists:nth(1,SeqReg#sequence.timing)*(60*1000/SeqReg#sequence.bpm),
                                        Pid = spawn(?MODULE, schedule, [Timeout,self()] ),
                                        SeqReg2 = SeqReg#sequence{current=0, schedfunc = Pid},
                                        sequence_proc(SeqReg2);
                                false ->
                                        sequence_proc(SeqReg)
                        end;
                next ->
                        case SeqReg#sequence.current==length(SeqReg#sequence.timing) of
                                true ->
                                        sequence_proc(SeqReg);
                                false ->
                                        Timeout = lists:nth(SeqReg#sequence.current+1,SeqReg#sequence.timing)* (60*1000/SeqReg#sequence.bpm),
                                        CurrentSample = lists:nth(SeqReg#sequence.current+1,SeqReg#sequence.samples),
                                        osc:play2(CurrentSample),
                                        Pid = spawn(?MODULE, schedule, [Timeout,self()] ),
                                        SeqReg2 = SeqReg#sequence{current=SeqReg#sequence.current+1, schedfunc = Pid},
                                        sequence_proc(SeqReg2)
                        end;
                {From, raw} ->
                        From ! (SeqReg#sequence.samples),
                        sequence_proc(SeqReg);
                {set, bpm, BPM} ->
                        SeqReg2 = SeqReg#sequence{bpm = BPM},
                        sequence_proc(SeqReg2);
                {set, clock, Clock} when is_atom(Clock) ->
                        SeqReg2 = SeqReg#sequence{clock  = Clock},
                        sequence_proc(SeqReg2);
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


schedule(Timeout,From) ->
        receive 
                {tick,From} ->
                        From ! next;
                die ->
                        dieyng
        after
                round(Timeout) ->
                        From ! next
        end.

