-module(kr).
-export([
	 sinosc/0, sinosc/1, sinosc/4,
	 'sinosc.kr'/0, 'sinosc.kr'/1, 'sinosc.kr'/4,
	 pulse/0, pulse/1, pulse/4,
	 'pulse.kr'/0, 'pulse.kr'/1, 'pulse.kr'/4,
	 saw/0, saw/1, saw/3,
	 'saw.kr'/0, 'saw.kr'/1, 'saw.kr'/3,
	 lftri/0, lftri/1, lftri/4,
	 'lftri.kr'/0, 'lftri.kr'/1, 'lftri.kr'/4
	]).
-include("synths.hrl").
-include("macros.hrl").


'sinosc.kr'() -> sinosc().
'sinosc.kr'(Y) -> sinosc(Y).
'sinosc.kr'(Freq, Phase, Mul,Add) ->sinosc(Freq, Phase, Mul,Add).

sinosc() ->
	Osc = #sinosc{},
	Props =  ?R2L(Osc,sinosc),
	{'sinosc.kr', Props}.
sinosc(X) ->
	?L2args(X, sinosc).

sinosc(Freq, Phase, Mul,Add) ->
	Osc = #sinosc{freq=Freq, phase=Phase, mul=Mul, add=Add},
	Props =  ?R2L(Osc,sinosc),
	{'sinosc.kr', Props}.

'pulse.kr'() -> pulse().
'pulse.kr'(Y) -> pulse(Y).
'pulse.kr'(Freq, Width, Mul,Add) -> pulse(Freq, Width, Mul,Add).

pulse() ->
	Osc = #pulse{},
	Props =  ?R2L(Osc,pulse),
	{'pulse.kr',Props}.
pulse(X) ->
	?L2args(X, pulse).
pulse(Freq, Width, Mul,Add) ->
	Osc = #pulse{freq=Freq, width=Width, mul=Mul, add=Add},
	Props =  ?R2L(Osc,pulse),
	{'pulse.kr', Props}.


'saw.kr'() -> saw().
'saw.kr'(Y) -> saw(Y).
'saw.kr'(Freq, Mul,Add) -> saw(Freq,Mul,Add).

saw() ->
	Osc = #saw{},
	Props =  ?R2L(Osc,saw),
	{'saw.kr',Props}.
saw(X) ->
	?L2args(X, saw).
saw(Freq, Mul,Add) ->
	Osc = #saw{freq=Freq, mul=Mul, add=Add},
	Props =  ?R2L(Osc,saw),
	{'saw.kr', Props}.

'lftri.kr'() -> lftri().
'lftri.kr'(X) -> lftri(X).
'lftri.kr'(Freq, Iphase, Mul, Add) -> lftri(Freq, Iphase, Mul, Add).

lftri() ->
	Osc = #lftri{},
	Props =  ?R2L(Osc,lftri),
	{'lftri.kr',Props}.
lftri(X) ->
	?L2args(X, lftri).
lftri(Freq, Iphase, Mul,Add) ->
	Osc = #lftri{freq=Freq, iphase=Iphase, mul=Mul, add=Add},
	Props =  ?R2L(Osc,lftri),
	{'lftri.kr', Props}.
