-module(elredis_db_tests).
-include_lib("eunit/include/eunit.hrl").

store_retrieve_set_data_test_() ->
  {foreach,
    fun setup/0,
    fun teardown/1,
    [fun should_add_item/1,
     fun should_retrieve_item_with_key/1 ]}.

increment_value_test_() ->
  {foreach,
    fun setup/0,
    fun teardown/1,
    [fun should_increment_by_2/1,
     fun should_check_if_key_exists/1]}.

setup() ->
  elredis_db:start_link().
  
teardown(_Info) ->
  elredis_db:stop().

should_add_item(_Info) ->
  Response = elredis_db:set(hello,world),
  [?_assertEqual(ok, Response)].

should_retrieve_item_with_key(_Info) ->
  elredis_db:set(coffee,yum),
  LookUpValue = elredis_db:lookup(coffee), 
  [?_assertEqual([{coffee,yum}], LookUpValue)].

should_increment_by_2(_Info) ->
  elredis_db:set(counter, "100"),
  IncreasedValue = elredis_db:incrby(counter, 2),
  [{counter, CounterValue}|_] = elredis_db:lookup(counter),
  [?_assertEqual(102, IncreasedValue),
   ?_assertEqual(102, CounterValue)].

%ERR value is not an integer or out of range
% If the key does not exist, it is set to 0 before performing the operation
should_check_if_key_exists(_Info) ->
  IncreasedValue = elredis_db:incrby(counter, 2),
  [?_assertEqual(102, IncreasedValue)].





