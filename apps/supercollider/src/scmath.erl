-module(scmath).
-include("macros.hrl").
-export([
	 '+'/2,
	 '-'/2,
	 '*'/2,
	 '/'/2
	]).

expandOp(Operator,A,B) ->
	fun() ->
		 if
			 (not is_number(A) or not is_number(B))->
				 {Operator, [{A}, {B}]};
			 true ->
				 throw("an error occurred when evaluating an arithmetic expression")
		 end
	end.



'-'(A,B) -> (expandOp('-', A, B))().
'+'(A,B) -> (expandOp('+', A, B))().
'/'(A,B) -> (expandOp('/', A, B))().
'*'(A,B) -> (expandOp('*', A, B))().
