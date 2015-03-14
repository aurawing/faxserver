%%%-------------------------------------------------------------------
%%% @author xu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 三月 2015 21:52
%%%-------------------------------------------------------------------
-module(fax_send_handler).
-author("xu").

%% API
-export([init/3, handle/2, terminate/3]).

init({tcp, http},Req, Opts) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    <<"POST">> -> {ok, Req2, Opts};
    _ ->
      Body = "{\"message\": \"method invalidate\"}",
      {ok, Req2} = cowboy_req:reply(404, [{<<"content-type">>, <<"text/json; charset=utf-8">>}], Body, Req),
      {shutdown, Req2, Opts}
  end.

%% string_join(Items, Sep) ->
%%   lists:flatten(lists:reverse(string_join(Items, Sep, []))).
%% string_join([Head | []], _Sep, Acc) ->
%%   [Head | Acc];
%% string_join([Head | Tail], Sep, Acc) ->
%%   string_join(Tail, Sep, [Sep, Head | Acc]).

stream_req({_Req, no}) -> eof;
stream_req({Req,yes}) ->
  case cowboy_req:body(Req) of
    {ok, Data, Req2} ->
      io:format("~s", [Data]),
      {ok, Data, {Req2, no}};
    {more, Data, Req2} ->
      io:format("~s", [Data]),
      {ok, Data,{Req2,yes}}
  end.

handle(Req, State) ->
  {RawQs, Req2} = cowboy_req:qs(Req),
%%   QsVals = cow_qs:parse_qs(RawQs),
%%   Ret = string_join(lists:map(fun({Key, Val}) -> binary_to_list(<<Key/binary, $=, Val/binary>>) end, QsVals), $&),
%%   io:format("~p", [Ret]),
  {basepath, BasePath} = lists:keyfind(basepath, 1, State),
  {auth, Auth} = lists:keyfind(auth, 1, State),
  AuthHead = lists:concat(["Basic ", Auth]),
  ReqUrl = lists:concat([BasePath, "/outbound/faxes?", binary_to_list(RawQs)]),
  {ok, Status, _ResponseHeaders, _ResponseBody} = ibrowse:send_req(ReqUrl, [{"Authorization", AuthHead}], post, {fun stream_req/1, {Req2, yes}}),
%%   case FaxId of
%%     undefined ->
%%       Body = "{\"message\": \"resource not found\"}",
%%       {ok, Req3} = cowboy_req:reply(404, [{<<"content-type">>, <<"text/json; charset=utf-8">>}], Body, Req2);
%%     _ ->
%%       {basepath, BasePath} = lists:keyfind(basepath, 1, State),
%%       {auth, Auth} = lists:keyfind(auth, 1, State),
%%       AuthHead = lists:concat(["Basic ", Auth]),
%%       ReqUrl = lists:concat([BasePath, "/outbound/faxes/", binary_to_list(FaxId)]),
%%       {ok, Status, _ResponseHeaders, ResponseBody} = ibrowse:send_req(ReqUrl, [{"Authorization", AuthHead}], get),
%%       {ok, Req3} = cowboy_req:reply(list_to_integer(Status), [{<<"content-type">>, <<"text/json; charset=utf-8">>}], ResponseBody, Req2)
%%   end,
  {ok, Req3} = cowboy_req:reply(list_to_integer(Status), [{<<"content-type">>, <<"text/json; charset=utf-8">>}], <<"finished!">>, Req2),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
