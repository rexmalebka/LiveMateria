liveMateria
=====

The idea came after reading this:[Controling Live Music](https://joearms.github.io/published/2016-01-27-Controlling-Live-Music.html) and this: [Controlling sound with OSC Messages](https://joearms.github.io/published/2016-01-29-Controlling-Sound-with-OSC-Messages.html).

the main ideas are:

- Creating a distributed environment for connecting livecoders around the world, sharing different ideas and ways of programming.
- Esoteric programming, the weirdness and dark world of erlang.
- Attemp simpler logics and setup.


Aproaches
----

I propose:

- Work with standalone process wich can set, retrieve and process timing of the sequences,
- Work with process timing clocks,
- Work with tcp/udp epmd servers for distributed networks of nodes around everywhere, the nodes could retrieve, set and modify sequences from the conection,
- SuperDirt as musical base (for now),
- OSC and known connection interface,
- Port drivers in the future for interfacing with different languages.


Proposed Sintax 
-----

```erl
% sequence are attached to a main clock

% seq1@ it's a registered atom (the @ it's for avoiding name collision with sample names).
% 5 default sequencer, seq1@, seq2@, seq3@, seq4@, seq5@

seq1@ ! [bd] % automatically starts playing sample.
seq1@ ! [bd, sn]. % timing it's being stretch for fitting one cycle of the clock, so this would play at half time.
seq1@ ! pause. % pause | stop | play for each sequencer.
seq1@ ! play.

% base it's a custom made sequence playing at time as seq1@.

seq:sequence('base').
base ! Repeat(bd,3). % built in functions for repeating samples, etc;
base ! [bd3]. % could specify sample name.
base ! [bd |Repeat(sd3,3)]. % pipes allows list extending.

base ! [cp, silence@, ]. % still don't have a nice version of "silence" sample.
base ! [[bd, sd, sd], cp]. % timing would stretch to [[1/2], 1/2], then [[1/6, 1/6,1/6], 1/2]
base ! [[bd, bd], [sd, sd, sd, sd]]. % timing would stretch to [[1/2],[1/2]] then [[1/4,1/4], [1/8, 1/8, 1/8, 1/8]]

seq1@ ! [cp, cp, [hh, hh]].
base ! [seq1@, hh, cp | seq1@]. % would map to [[cp,cp,[hh,hh]],hh,cp,cp,cp,[hh,hh]]

% also
seq1@ ! base.

% fo applying effects, could be accumulative throught all the levels of the list

seq2@ ! [Coarse(20), cp, bd, [hh, Gain(2), bd], [Speed(2), hh, bd]].  % Coarse(20), would affect all the samples in the sequence, Gain(2) would only affect bd in the inner sequence [hh, bd], Speed(2) would affect [hh, bd].

(base ! seq1@) ! seq2@. % seq1 it's applied to base, and seq2@ it's applied to seq1@.

% 

% for distributed network using epmd could be:
conn:name(username).
conn:connect(username2).
{seq1@, username2} ! [Gain(0.5), cp, hh, bd]. % modifying others sequences.

% for modifing the sequences along the time, could be


clockMain ! {
  seq1,
  fun({Bpm, CycleTime, CycleNumber}) ->
                  case CycleNumber rem 2 of
                          0 ->
                                  seq1 ! [cp, hh];
                          1 ->    
                                  seq1 ! [hh | Repeat(bd, 6)]
                  end
  end
 }.


```

Config
-----
config/sys.config
```erl
[
  {liveMateria, [
	{tcpport, 9999},
	{cookie, 'liveMateria-cookie'}
]},
  {supercollider, [
	{sclang_path, "/Applications/SuperCollider.app/Contents/MacOS/sclang"},
	{scsynth_udp_port, 57110}
]}
].
```

config/vm.args
```erl
-sname liveMateriamiau


+K true
+A30
```

Build
-----
    $ rebar3 release
    $ ./_build/default/rel/liveMateria/bin/liveMateria foreground
