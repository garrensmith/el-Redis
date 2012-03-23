-module(elredis_message_handler_tests).
-include_lib("eunit/include/eunit.hrl").

setup() ->
  ok.

teardown(_info) ->
  ok.

store_retrieve_set_data_test_() ->
  {foreach,
    fun setup/0,
    fun teardown/1,
   [fun should_reply_to_ping_message/1,
    fun should_reply_to_lower_case_ping_message/1]}.

should_reply_to_ping_message(_info) ->
  Response = elredis_message_handler:process_message(<<"*1\r\n$4\r\nPING\r\n">>),
  [?_assertEqual(<<"+PONG\r\n">>, Response)].

should_reply_to_lower_case_ping_message(_info) ->
  Response = elredis_message_handler:process_message(<<"*1\r\n$4\r\nping\r\n">>),
  [?_assertEqual(<<"+PONG\r\n">>, Response)].

