-module(clock).
-author("rexmalebka@krutt.org").
-compile(export_all).

-record(clock, {
          name, 
          state=stopped,
          globaltime=0, 
          localtime=0,
          bpm=120,
          beatcount=0
         }).

init() ->
	%% sequencer initializer
        clock(mainClock@).

clock(Name) when is_atom(Name)->
        case lists:member(Name, registered()) of
                true ->
                        {error, clock_already_exists};
                false ->
                        Pid = spawn(?MODULE, clock_proc,[Name]),
                        register(Name, Pid),
                        Name ! play,
                        {ok, Pid}
        end.

clock_proc(Name) when is_atom(Name) ->
        Clock = #clock{
                   name=Name, 
                   state=stopped,
                   globaltime=0, 
                   localtime=0,
                   bpm=120,
                   beatcount=0
                  },
        clock_proc(Clock);
clock_proc(Name) ->
        receive
                play ->
                        %% starts ticking clock.
                        clock_proc(Name);
                {set, {bpm, BPM}} ->
                        ClockMod = #clock{
                                   name=Clock#clock.name, 
                                   state=Clock#clock.state, 
                                   globaltime=Clock#clock.globaltime, 
                                   localtime=Clock#clock.localtime, 
                                   localtime=Clock#clock.localtime, 
                                   bpm=BPM,
                                   beatcount=Clock#clock.beatcount
                                  },
                        clock_proc(ClockMod)
        end.



