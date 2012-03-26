-module(elredis_aof).

% API
-export([write_command/1]).


write_command(Command) ->
  file:write_file("appendonly.aof", Command, [append]).
  
