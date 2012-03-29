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
    fun should_handle_message_that_exceeds_receive_buffer/1,
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

should_handle_message_that_exceeds_receive_buffer(_Info) ->
  Message = <<"*3\r\n$3\r\nset\r\n$15\r\nsurvey:stats:14\r\n$1513\r\n{\"start_time\":\"2012-03-20T14:34:51+02:00\",\"end_time\":null,\"status\":\"running\",\"introduction\":\"Welcome to this fancy report test\",\"conclusion\":\"Thanks for playing\",\"total_responses\":4,\"completed_responses\":4,\"completed_mxit_responses\":0,\"total_mxit_response\":0,\"completed_web_responses\":4,\"total_web_responses\":4,\"complete_mobile_web_responses\":0,\"total_mobile_web_responses\":0,\"questions\":[{\"text\":\"Enter your name\",\"total_answers\":4,\"answer_count\":[0],\"duration\":38.75,\"question_type\":\"text\"},{\"text\":\"Select one\",\"total_answers\":4,\"answer_count\":[1,1,2],\"duration\":42.5,\"question_type\":\"single\",\"options\":[\"cat\",\"dog\",\"cow\"]},{\"text\":\"Select a bunch\",\"total_answers\":4,\"answer_count\":[2,2,2,2,2],\"duration\":47.5,\"question_type\":\"multiple\",\"options\":[\"grapes\",\"avo\",\"apples\",\"tomatoes\",\"strawberries\"]},{\"text\":\"How old are you?\",\"total_answers\":5,\"answer_count\":[2,1,0,1,1],\"duration\":43.6,\"question_type\":\"single\",\"options\":[\"14 or younger\",\"15-17\",\"18-24\",\"25-34\",\"35+\"]},{\"text\":\"Are you...\",\"total_answers\":5,\"answer_count\":[5,0],\"duration\":47.0,\"question_type\":\"single\",\"options\":[\"Male\",\"Female\"]},{\"text\":\"Which ethnic group do you belong to?\",\"total_answers\":5,\"answer_count\":[1,4,0,0],\"duration\":49.4,\"question_type\":\"single\",\"options\":[\"Black\",\"White\",\"Coloured\",\"Indian/Asian\"]},{\"text\":\"How did you feel about answering these questions?\",\"total_answers\":6,\"answer_count\":[6,0],\"duration\":48.166666666666664,\"question_type\":\"single\",\"options\":[\"Happy to answer them\",\"Wouldn't like to do it again\"]}]}\r\n">>, 
  Response = elredis_message_handler:process_message(Message),
  [?_assertEqual(<<"+OK\r\n">>, Response)].

