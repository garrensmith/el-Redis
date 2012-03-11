-module(elredis_app).

-behaviour(application).

%% Application callbacks
-export([start/0,start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================
start() ->
    io:format("boom started ~n"),
    application:start(elredis).

start(_StartType, _StartArgs) ->
  io:format("boom started with args ~n"),
    elredis_sup:start_link().

stop(_State) ->
  io:format("stopped app ~n"),
    ok.

  % application:which_applications().
