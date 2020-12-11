-define(R2L(Val, Record),
        (fun() ->
                [_| V] = tuple_to_list(Val),
                Fields = record_info(fields,Record),
                lists:zip(Fields,V)
        end)()
).
-define(CaseOp(Module, Name),
	(fun() ->
			 H = proplists:delete(module_info,Module:module_info(exports)),
			 case proplists:is_defined(Name, H) of
				 true ->{ok};
				 false ->{error}
			end
	end)()
       ).
-define(L2args(Values,Record),
	(fun() ->
			 Default = ?R2L(#Record{}, Record),
			 Props = record_info(fields,Record),
			 io:format("~w -~w- is ~w, ~w ~n",[Default, Values, is_list(Values),Props]),

			 Args =[ proplists:get_value(Y,Values, proplists:get_value(Y, Default) ) || Y <- Props ], 
			 apply(?MODULE, Record, Args)
	 end)()
       ). 
