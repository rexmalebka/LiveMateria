supercollider
=====

An OTP application

```erl

A = sinosc().
B = pulse([{mul,100}, {freq,2}, {add, 100}]).

{sc, s} ! boot.
{sc, play} ! sinosc().
```

Build
-----

    $ rebar3 compile
