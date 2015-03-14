%%%-------------------------------------------------------------------
%%% @author xu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 三月 2015 21:52
%%%-------------------------------------------------------------------
-module(fax_status_handler).
-author("xu").

%% API
-export([init/3, handle/2, terminate/3]).

init({tcp, http},Req, Opts) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    <<"GET">> -> {ok, Req2, Opts};
    _ ->
      Body = "{\"message\": \"method invalidate\"}",
      {ok, Req2} = cowboy_req:reply(404, [{<<"content-type">>, <<"text/json; charset=utf-8">>}], Body, Req),
      {shutdown, Req2, Opts}
  end.

handle(Req, State) ->
  {FaxId, Req2} = cowboy_req:binding(id, Req),
  case FaxId of
    undefined ->
      Body = "{\"message\": \"resource not found\"}",
      {ok, Req3} = cowboy_req:reply(404, [{<<"content-type">>, <<"text/json; charset=utf-8">>}], Body, Req2);
    _ ->
      {basepath, BasePath} = lists:keyfind(basepath, 1, State),
      {auth, Auth} = lists:keyfind(auth, 1, State),
      AuthHead = lists:concat(["Basic ", Auth]),
      ReqUrl = lists:concat([BasePath, "/outbound/faxes/", binary_to_list(FaxId)]),
      {ok, Status, _ResponseHeaders, ResponseBody} = ibrowse:send_req(ReqUrl, [{"Authorization", AuthHead}], get),
      {ok, Req3} = cowboy_req:reply(list_to_integer(Status), [{<<"content-type">>, <<"text/json; charset=utf-8">>}], ResponseBody, Req2)
  end,
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.
