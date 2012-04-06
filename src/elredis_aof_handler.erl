-module(elredis_aof_handler).

-behaviour(gen_event).

%api 
-export([add_handler/0, delete_handler/0]).

%% gen_event callbacks
-export([init/1,
         handle_event/2,
         handle_call/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {}).

add_handler() ->
    elredis_event:add_handler(?MODULE, []).

delete_handler() ->
    elredis_event:delete_handler(?MODULE, []).

%%%===================================================================
%%% gen_event callbacks
%%%===================================================================

init([]) ->
    {ok, #state{}}.
handle_event({change, {_Commands, RawCommands}}, State) ->
    elredis_aof:write_command(RawCommands), 
    {ok, State};
handle_event(_Event, State) ->
    {ok, State}.

handle_call(_Request, State) ->
    Reply = ok,
    {ok, Reply, State}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

