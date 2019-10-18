-module(clock).
-author("rexmalebka@krutt.org").
-compile(export_all).

-record(clock, {
          name, 
          state = stopped,
          globaltime = 0,
          localtime = 0,
          current = 0,
          bpm = 120,
          sequences = [],
          timings  = [],
          countfunc,
          beatfunc
         }).

init() ->
        clock(mainclock@),
        {ok, initialized}.

clock(Name) when is_atom(Name) ->
        case lists:member(Name, registered()) of
                true ->
                        {error, clock_already_exists};
                false ->
                        Pid = spawn(?MODULE, clock_proc, [Name]),
                        register(Name, Pid),
                        global:register_name(Name, Pid),
                        Name ! play,
                        {ok, Pid}
        end.

clock_proc(Name) when is_atom(Name) ->
        ClockReg = #clock{name=Name},
        clock_proc(ClockReg);

clock_proc(ClockReg) ->
        receive
                {append, Sequence} when is_atom(Sequence) ->
                        io:write('appended'),
                        ClockRegMod = ClockReg#clock{sequences=[Sequence | ClockReg#clock.sequences]},
                        clock_proc(ClockRegMod);
                tick ->
                        %% send all the sequences in charge to tick
                        case length(ClockReg#clock.sequences) > 0 of
                                true ->
                                        lists:foreach(fun(Seq) ->
                                                                      Seq ! tick
                                                      end, ClockReg#clock.sequences),
                                        clock_proc(ClockReg);
                                false ->
                                        clock_proc(ClockReg)
                        end;
                play ->
                        %% starts beating 🔥🔥
                        io:write("starting"),
                        %% starts global counter
                        GlobalPid = spawn(?MODULE, counttime, [0]),
                        BeatPid = spawn(?MODULE, beat, [120, self()]),
                        ClockRegMod = ClockReg#clock{countfunc=GlobalPid, beatfunc=BeatPid},

                        clock_proc(ClockRegMod);
                {get, globaltime} ->
                        ClockReg#clock.countfunc ! {get, self()},
                        receive 
                                {time, Time} ->
                                        io:write(Time)
                        end,
                        clock_proc(ClockReg);
                {set, bpm, BPM} ->
                        io:write('changing bpm'),
                        ClockReg#clock.beatfunc ! {set, BPM},                        
                        lists:foreach(fun(Seq) ->
                                                      Seq ! {set, bpm, BPM}
                                      end, ClockReg#clock.sequences),
                        clock_proc(ClockReg)
        end.

counttime(Time) ->
        receive 
                {get, From} ->
                        From ! {time, Time},
                        counttime(Time);
                {die, From} ->
                        From ! {time, Time}
        after 
                11 ->
                        counttime(Time+11)
        end.

beat(Bpm, From) ->
        receive 
                {set, NewBpm} ->
                        beat(NewBpm, From)
        after 
                round(60*1000/Bpm)->
                        From ! tick,
                        beat(Bpm, From)
        end.



