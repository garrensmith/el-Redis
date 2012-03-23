-module(elredis_message_handler_tests).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  elredis_db:start_link().
  
teardown(_Info) ->
  elredis_db:stop().

store_retrieve_set_data_test_() ->
  {foreach,
    fun setup/0,
    fun teardown/1,
   [fun should_reply_to_ping_message/1,
    fun should_reply_to_lower_case_ping_message/1,
    fun should_set_key_and_respond_with_ok/1,
    fun should_get_set_key_value/1]}.

should_reply_to_ping_message(_Info) ->
  Response = elredis_message_handler:process_message(<<"*1\r\n$4\r\nPING\r\n">>),
  [?_assertEqual(<<"+PONG\r\n">>, Response)].

should_reply_to_lower_case_ping_message(_Info) ->
  Response = elredis_message_handler:process_message(<<"*1\r\n$4\r\nping\r\n">>),
  [?_assertEqual(<<"+PONG\r\n">>, Response)].

should_set_key_and_respond_with_ok(_Info) ->
  Response = elredis_message_handler:process_message(<<"*3\r\n$3\r\nset\r\n$5\r\nmykey\r\n$5\r\nhello\r\n">>),
  [?_assertEqual(<<"+OK\r\n">>, Response)].

should_get_set_key_value(_Info) -> 
  elredis_message_handler:process_message(<<"*3\r\n$3\r\nset\r\n$5\r\nmykey\r\n$5\r\nhello\r\n">>),
  Response = elredis_message_handler:process_message(<<"*2\r\n$3\r\nget\r\n$5\r\nmykey\r\n">>),
  [?_assertEqual(<<"$5\r\nhello\r\n">>, Response)].

