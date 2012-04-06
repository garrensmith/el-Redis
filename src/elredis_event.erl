-module(elredis_event).

%% API
-export([start_link/0,
         add_handler/2,
         delete_handler/2,
         db_change/2]).

start_link() ->
  gen_event:start_link({local, ?MODULE}).

add_handler(Handler, Args) ->
  gen_event:add_handler(?MODULE, Handler, Args).

delete_handler(Handler, Args) ->
  gen_event:delete_handler(?MODULE, Handler, Args).

lookup(Key) ->
  gen_event:notify(?MODULE, {lookup, Key}).

db_change(Commands, RawCommands) ->
  gen_event:notify(?MODULE, {change, {Commands, RawCommands}}).

