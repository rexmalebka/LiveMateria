-module(ar).
-export([
	 serialize/2,
	 sinosc/0, sinosc/1, sinosc/4,
	 'sinosc.ar'/0, 'sinosc.ar'/1, 'sinosc.ar'/4,
	 pulse/0, pulse/1, pulse/4,
	 'pulse.ar'/0, 'pulse.ar'/1, 'pulse.ar'/4,
	 saw/0, saw/1, saw/3,
	 'saw.ar'/0, 'saw.ar'/1, 'saw.ar'/3,
	 lftri/0, lftri/1, lftri/4,
	 'lftri.ar'/0, 'lftri.ar'/1, 'lftri.ar'/4
	]).
-include("synths.hrl").
-include("macros.hrl").


serialize(Name,Args) when is_list(Args) ->
	case Name of
		'sinosc' ->
			    list_to_binary([<<"SinOsc.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'sinosc.ar' -> 
			    list_to_binary([<<"SinOsc.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'pulse' ->
			    list_to_binary([<<"Pulse.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'pulse.ar' ->
			    list_to_binary([<<"Pulse.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'saw' ->
			    list_to_binary([<<"Saw.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'saw.ar' ->
			    list_to_binary([<<"Saw.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'lftri' ->
			    list_to_binary([<<"LFTri.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		'lftri.ar' ->
			    list_to_binary([<<"LFTri.ar(">>,[list_to_binary([io_lib:format("~w:",[X]), scserialize:serialize(V),","]) ||{X, V} <- Args],<<")">>]);
		_ ->
			<<>>
	end.

'sinosc.ar'() -> sinosc().
'sinosc.ar'(Y) -> sinosc(Y).
'sinosc.ar'(Freq, Phase, Mul,Add) ->sinosc(Freq, Phase, Mul,Add).

sinosc() ->
	Osc = #sinosc{},
	Props =  ?R2L(Osc,sinosc),
	{'sinosc.ar', Props}.
sinosc(X) ->
	?L2args(X, sinosc).

sinosc(Freq, Phase, Mul,Add) ->
	Osc = #sinosc{freq=Freq, phase=Phase, mul=Mul, add=Add},
	Props =  ?R2L(Osc,sinosc),
	{'sinosc.ar', Props}.

'pulse.ar'() -> pulse().
'pulse.ar'(Y) -> pulse(Y).
'pulse.ar'(Freq, Width, Mul,Add) -> pulse(Freq, Width, Mul,Add).

pulse() ->
	Osc = #pulse{},
	Props =  ?R2L(Osc,pulse),
	{'pulse.ar',Props}.
pulse(X) ->
	?L2args(X, pulse).
pulse(Freq, Width, Mul,Add) ->
	Osc = #pulse{freq=Freq, width=Width, mul=Mul, add=Add},
	Props =  ?R2L(Osc,pulse),
	{'pulse.ar', Props}.


'saw.ar'() -> saw().
'saw.ar'(Y) -> saw(Y).
'saw.ar'(Freq, Mul,Add) -> saw(Freq,Mul,Add).

saw() ->
	Osc = #saw{},
	Props =  ?R2L(Osc,saw),
	{'saw.ar',Props}.
saw(X) ->
	?L2args(X, saw).
saw(Freq, Mul,Add) ->
	Osc = #saw{freq=Freq, mul=Mul, add=Add},
	Props =  ?R2L(Osc,saw),
	{'saw.ar', Props}.

'lftri.ar'() -> lftri().
'lftri.ar'(X) -> lftri(X).
'lftri.ar'(Freq, Iphase, Mul, Add) -> lftri(Freq, Iphase, Mul, Add).

lftri() ->
	Osc = #lftri{},
	Props =  ?R2L(Osc,lftri),
	{'lftri.ar',Props}.
lftri(X) ->
	?L2args(X, lftri).
lftri(Freq, Iphase, Mul,Add) ->
	Osc = #lftri{freq=Freq, iphase=Iphase, mul=Mul, add=Add},
	Props =  ?R2L(Osc,lftri),
	{'lftri.ar', Props}.
