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
      io:format("L ~p ~n",[Length]),
      Commands = split_commands(Rest),
      io:format("Rest ~p ~n",[Rest]),
      process_bulk_message(Length, Commands);
    _ -> process_bulk_message(1,error)
   end.

split_commands(Buffer) ->
  split_commands(Buffer,[]).

split_commands(Buffer, Commands) ->
  io:format("split ~p ~n",[binary:split(Buffer,<<"\r\n">>)]),
  case binary:split(Buffer,<<"\r\n">>) of
    [<<"$",_CommandLengthBin/binary>>, Buffer2] -> split_commands(Buffer2, Commands);
    [NewCommand, Buffer2] -> split_commands(Buffer2, [string:to_upper(binary_to_list(NewCommand)) | Commands]);
    [_EmptyBuffer] -> lists:reverse(Commands)
  end.    


process_bulk_message(1, ["PING"]) ->
  <<"+PONG\r\n">>;
process_bulk_message(1,["INFO"]) ->
  <<"+elredis:0.0.1\r\n\r\n">>;
process_bulk_message(_, _) ->
  <<"-ERR Unknown or disabled command\r\n">>.

%%
%%%X = "*3\r\n$3\r\nSET\r\n$5\r\nmykey\r\n$7\r\nmyvalue\r\n",
%%  X="+PONG\r\n",
  %X = <<"*1\r\n$19\r\nredis_version:2.2.2\r\n">>,

