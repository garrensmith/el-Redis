-module(elredis_message_handler).

-export([process_message/1]).
%replies
% status: +
% bulk $
% multi bulk *

process_message(Message) ->
  case binary:split(Message,<<"\r\n">>) of
    [<<"*",LengthBin/binary>>, Rest] -> 
      Length = list_to_integer(binary_to_list(LengthBin)), 
      Commands = split_commands(Rest),
      process_bulk_message(Length, Commands);
    _ -> process_bulk_message(1,error)
  end.

split_commands(Buffer) ->
  split_commands(Buffer,[]).

split_commands(Buffer, Commands) ->
  case binary:split(Buffer,<<"\r\n">>) of
    [<<"$",_CommandLengthBin/binary>>, Buffer2] -> split_commands(Buffer2, Commands);
    [NewCommand, Buffer2] -> split_commands(Buffer2, [binary_to_list(NewCommand) | Commands]);
    [_EmptyBuffer] -> reverse_list_and_uppercase_command(Commands)     
  end.    

reverse_list_and_uppercase_command(Commands) ->
   [Head | Tail] = lists:reverse(Commands),
   [string:to_upper(Head) | Tail].

create_reply_for(bulk,RawResponse) ->
  create_reply_for(bulk, RawResponse, []).

create_reply_for(bulk, [], Response) ->
  list_to_binary(lists:reverse(Response));
create_reply_for(bulk, [Head | Tail], Response) ->
  Msg = lists:concat(["$",length(Head),"\r\n",Head,"\r\n"]), 
  create_reply_for(bulk, Tail, [Msg | Response]).

process_bulk_message(1, ["PING"]) ->
  <<"+PONG\r\n">>;
process_bulk_message(1,["INFO"]) ->
  <<"+elredis:0.0.1\r\n\r\n">>;
process_bulk_message(3,["SET",Key, Value]) ->
  case elredis_db:set(Key, Value) of
    ok -> <<"+OK\r\n">>;
    _ -> <<"-error occured">>
  end;
process_bulk_message(2,["GET",Key]) ->
  Value = elredis_db:lookup(Key),
  create_reply_for(bulk, [Value]);
process_bulk_message(_, _) ->
  <<"-ERR Unknown or disabled command\r\n">>.


