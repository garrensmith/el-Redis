-module(elredis_db).
-behaviour(gen_server).

-export([start_link/0, stop/0, set/2, lookup/1, incrby/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

set(Key,Value) ->
  gen_server:call(?MODULE, {set,{Key,Value}}).

lookup(Key) ->
  gen_server:call(?MODULE, {lookup,Key}).

incrby(Key,Amount) ->
  gen_server:call(?MODULE, {incrby, Key, Amount}).

stop() ->
  gen_server:call(?MODULE, stop).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  ets:new(elredis_set, [set, named_table, protected]),
  {ok, #state{}}.

handle_call({set, {Key, Value}}, _From, State) ->
  ets:insert(elredis_set,{Key,Value}),
  {reply, ok, State};

handle_call({lookup, Key}, _From, State) ->
  Result = ets:lookup(elredis_set,Key),
  {reply, Result, State};

handle_call({incrby, Key, Amount}, _From, State)  ->
  Value = ets:lookup_element(elredis_set,Key,2),
  IncrementedValue = list_to_integer(Value) + Amount,
  ets:delete(elredis_set, Key),
  ets:insert(elredis_set,{Key, IncrementedValue}),
  {reply, IncrementedValue, State};

handle_call(stop, _From, Tab) ->
  {stop, normal, stopped, Tab};
handle_call(_Request, _From, State) ->
  {reply, ignored, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

