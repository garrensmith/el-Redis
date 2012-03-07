-module(elredis_db).
-behaviour(gen_server).

-export([start_link/0, stop/0, add/2, lookup/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

add(Key,Value) ->
  gen_server:call(?MODULE, {add,{Key,Value}}).

lookup(_Key) ->
  ok.

stop() ->
  gen_server:call(?MODULE, stop).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  ets:new(elredis_set, [set, named_table, protected]),
  {ok, #state{}}.

handle_call({add, {Key, Value}}, _From, State) ->
    ets:insert(elredis_set,{Key,Value}),
    {reply, ok, State};
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

