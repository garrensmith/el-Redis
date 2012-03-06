-module(elredis_db_tests).
-include_lib("eunit/include/eunit.hrl").

store_data_test_() ->
  {setup,
    fun setup/0,
    fun teardown/1,
    fun should_add_item/1}.

setup() ->
  elredis_db:start_link().

teardown(_Info) ->
  elredis_db:stop().

should_add_item(_Info) ->
  Response = elredis_db:add(hello),
  [?_assertEqual(Response, ok)].




