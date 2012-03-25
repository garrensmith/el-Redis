-module(elredis_app).

-behaviour(application).

%% Application callbacks
-export([start/0,start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start() ->
  application:start(elredis).

start(_StartType, _StartArgs) ->
  SupPid = elredis_sup:start_link(),
  elredis_listener:start({},{}),
  io:format("el-Redis is running on port 6379 ~n"),
  SupPid.

stop(_State) ->
  %elredis_listener:stop({}),
  ok.

% application:which_applications().
