-module(parser). 
-export([
    evaluate_expression/1
]).
-include("records.hrl").
-include("macros.hrl").


evaluate_expression(Expression) ->
	{ok, Tokens, _} = erl_scan:string(Expression),    % scan the code into tokens
	%handleUnbound(proplists:lookup_all(var, Tokens)),
	case erl_parse:parse_exprs(Tokens) of
		{error, Reason } ->
			{_, R,_} = Reason,
			{error, R};
		{ok, Parsed} ->
			try erl_eval:exprs(Parsed, [], {value, fun handle_functions/2}, {value, fun handle_non_local_functions/2}) of
				{value, Result, Variables} -> 
					%io:format("~p",[ binary_to_list(scserialize:serialize(Result))]),	
					handleBounds(Variables),
					{ok,Result,Variables};
				{error, Reason} -> {error, Reason}
			catch
				_:Reason -> {error, Reason}
			end
	end.



handle_functions(FunctionName, Args) ->
	case ?CaseOp(ar,FunctionName) of
		{ok} ->
			try apply(ar, FunctionName, Args) of
				{error, Reason} -> Reason;
				Result -> Result
			catch 
				_:Reason ->{error, Reason}
			end;
		{error} ->
			case ?CaseOp(kr,FunctionName) of
				{ok} ->
					try apply(kr, FunctionName, Args) of
						{error, Reason} -> Reason;
						Result -> Result
					catch 
						_:Reason ->{error, Reason}
					end;
				{error} ->
					throw(FunctionName)
			end
	end.

handle_non_local_functions({Module, FunctionName}, Args ) ->
	case Module of
		ar ->
			try apply(ar, FunctionName, Args) of
				{error, Reason} -> Reason;
				Result -> Result
			catch 
				_:Reason ->{error, Reason}
			end;
		kr ->
			try apply(kr, FunctionName, Args) of
				{error, Reason} -> Reason;
				Result -> Result
			catch 
				_:Reason ->{error, Reason}
			end;
		erlang ->
			NativeOp = fun(Operator) ->
					try apply(erlang, Operator, Args) of
						{error, Reason} -> Reason;
						Result -> Result
					catch 
						_:Reason ->{error, Reason}
					end
				   end,
			case ?CaseOp(scmath,FunctionName) of
				{ok} ->
					try apply(scmath, FunctionName, Args) of
						{error, _} -> NativeOp(FunctionName);
						Result -> Result
					catch
						_:_ -> NativeOp(FunctionName)
					end;
				{error} -> NativeOp(FunctionName)
			end;
		_ ->
			{error}
	end.

handleUnbounds(Vars) ->
	{}.
handleBounds(Vars) ->
	io:format("~w~n",[Vars]),
	{}.
