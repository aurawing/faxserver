%%%-------------------------------------------------------------------
%%% @author xu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 二月 2015 22:31
%%%-------------------------------------------------------------------
-module(hello_handler).
-author("xu").

%% API
-export([init/3, handle/2, terminate/3]).

init({tcp, http},Req, Opts) ->
  lager:info("receive request!"),
  {ok, Req2} = cowboy_req:reply(200,
    [{<<"content-type">>, <<"text/plain">>}],
    <<"你好，Erlang!">>,
    Req),
  {shutdown, Req2, Opts}.

handle(Req, State) ->
  {ok, Req, State}.

terminate(_Reason, _Req, _State) ->
  ok.
