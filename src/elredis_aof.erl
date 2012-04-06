-module(elredis_aof).

% API
-export([write_command/1]).


write_command(Commands) ->
  file:write_file("appendonly.aof", Commands, [append]).
  
