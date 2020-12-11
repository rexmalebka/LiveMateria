-module(scserialize).
-export([
	 serialize/0, serialize/1
	]).
-include("macros.hrl").

serialize() -> <<>>.
serialize({}) -> <<>>;
serialize("") -> <<>>;
serialize('') -> <<>>;
serialize(Raw) ->
	case Raw of
		X when is_atom(X) -> list_to_binary( io_lib:format("\~w", [X]) );
		X when is_number(X) -> list_to_binary( io_lib:format("~w", [X]) );
		X when is_list(X) -> 
			A =[<<(serialize(Y))/bitstring , ",">> || Y <- X],
			list_to_binary([<<"[">>, A, <<"]">>] );
		{Name, Args} when 
			  is_atom(Name) ->
			case proplists:lookup({ok}, [{?CaseOp(X,Name),X } || X <- [ar,kr]]) of
				none ->
					<<(serialize(Name))/bitstring,"(",(serialize(Args))/bitstring , ")">>;
				{{ok}, M} ->
					apply(M, serialize, [Name,Args])
			end;
		_ -> <<" 666 ">>
	end.

		%{Name, Args}
%serialize(Data) when
%	  is_atom(Data) or is_number(Data) ->
%	io:format("is atom or number~n"),
%	Data;
%serialize([Data]) ->
%	io:format("is [data]~n"),
%	  serialize(Data);
%	% [5], [a]
%serialize({Data}) ->
%	io:format("is {data}~n"),
%	  serialize(Data);
%serialize(Data) when
%	  is_list(Data) ->
%	%[lists:flatten(serialize(X)) || X <- Data];
%	io:format("is data[] ~n"),
%	lists:flatten(io_lib:format("~s",[lists:flatten(string:join([serialize(X) || X <- Data],","))]));
%serialize({Name, Value}) when 
%	  is_atom(Name) and not is_list(Value)->
	% {freq, 555} {mul, 1}
%	io:format("is {name, data} ~n"),
%	lists:flatten(io_lib:format("~w:~w",[Name, serialize(Value)]));
%serialize({Name, Value}) when 
%	  is_atom(Name) and is_list(Value)->
	% {sinosc.ar, [{freq, 66}, {mul, 1}]}
%	io:format("is {name, data[]} ~n"),
%	lists:flatten(io_lib:format("~w( ~s )",[Name, lists:flatten(serialize(Value))])).

