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
    elredis_sup:start_link(),
    elredis_listener:start({},{}).

stop(_State) ->
  io:format("stopped app ~n"),
  elredis_listener:stop({}),
  ok.

  % application:which_applications().
