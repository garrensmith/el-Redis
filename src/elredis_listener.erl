-module(elredis_listener).

-export([start/2, stop/1]).

%% called for each new socket connection
-export([start_link/4]).

%% socket handler
-export([init/4]).

start(_StartType, _StartArgs) ->
  io:format("starting ~n"),
  ok = application:start(cowboy),
  {ok, _} = cowboy:start_listener(
    ?MODULE, 100,
    cowboy_tcp_transport, [{port, 6379}],
    ?MODULE, []).

%% @private Spawn a process to handle a new connection.
start_link(ListenerPid, Socket, Transport, Options) ->
  io:format("start link called ~n"),
  Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, Options]),
  {ok, Pid}.

init(ListenerPid, Socket, Transport, _Options) ->
  cowboy:accept_ack(ListenerPid), 
  command_loop(Socket, Transport).

command_loop(Socket, Transport) ->
  case Transport:recv(Socket, 0,infinity) of
    {ok, Data} ->
      io:format("RECEIVED ~p ~n",[Data]),
      Response = elredis_message_handler:process_message(Data),
      io:format("Replied ~p ~n",[Response]),
      Transport:send(Socket, Response),
      command_loop(Socket, Transport);
    {error, closed} ->
      ok
  end.

stop(_State) ->
  io:format("stopping tcp ~n"),
  application:stop(cowboy).

