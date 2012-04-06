-module(elredis_aof_tests).
-include_lib("eunit/include/eunit.hrl").

save_commands_to_disk_test_() ->
  {foreach,
   fun setup/0,
   fun teardown/1,
   [fun should_save_command_to_disk/1]}.

setup() ->
  elredis_db:start_link().

teardown(_Info) ->
  elredis_db:stop(),
  file:delete("appendonly.aof").

should_save_command_to_disk(_Info) ->
  Response = elredis_aof:write_command(<<"*3\r\n$3\r\nset\r\n$5\r\nmykey\r\n$5\r\nhello\r\n">>),
  [?_assertEqual(ok, Response)]. 

%should_write_received_command_to_disk(_Info) ->
%  Command = <<"*3\r\n$3\r\nset\r\n$5\r\nmykey\r\n$5\r\nhello\r\n">>, 
%  elredis_message_handler:process_message(Command),
%  Contents = <<"boom">>,
%  %{ok, Contents} = file:read_file("appendonly.aof"),
%  [?_assertEqual(Command, Contents)].

%should_read_commands(_Info) ->
%  elredis_aof:write_command("boom"),
%  Commands = elredis_aof:read_commands(),
%  [?_assertEqual(
