-module(conn).
-compile(export_all).
-author('rexmalebka@krutt.org'). %% please email me 

init() ->
	Address = nohost,
	Config = allow,
	try
		ets:new(node_info, [named_table, public, set]),
		{ok, ets_created}
	of
		{ok, ets_created} ->
			{ok, ets_created}
	catch 
		error:Error -> {error, caught, Error}
	end,
	start(Address,Config).

start(Address, Config) ->
	ets:insert(node_info, {hostname, Address}),
	ets:insert(node_info, {config, Config}),
	{ok, ets_intialized}.

fixhostname(Address) ->
	if
		is_atom(Address) ->
			ListAddress = atom_to_list(Address);
		is_list(Address) ->
			ListAddress = Address
	end,	
	SplitAddress = string:tokens(ListAddress,"@"),
	case length(SplitAddress) of
		1 ->
			% add 127.0.0.1
			[HAddress]  = SplitAddress,
			NewAddress = HAddress++"@127.0.0.1",
			NewAddress;
		2 ->
			ets:insert(node_info, {hostname, ListAddress}),
			ListAddress
	end.

name() ->
	[Hostname] = ets:lookup(node_info, hostname),
	{ok, Hostname}.
name(Address) ->
	%% check if Addres has host if not, keep it local
	ets:insert(node_info, {hostname, fixhostname(Address)}),
	name().


config() ->
	[Config] = ets:lookup(node_info, config),
	{ok, Config}.
config({deny}) ->
	ets:insert(node_info, {config, deny}),
	config();
config({allow}) ->
	ets:insert(node_info, {config, allow}),
	config();
config({from, none}) ->
	config({deny});
config({from, all}) ->
	config({allow});
config({from, FromList}) when is_list(FromList) ->
	if 
		length(FromList)=:=0  ->
			config({deny});
		true ->
			{ok,{hostname,Address}} = name(),
			FixedFromList = [fixhostname(F) || F <- FromList, fixhostname(F) =/= Address],
			ets:insert(node_info, {config, {from, FixedFromList}}),
			config()
	end.

