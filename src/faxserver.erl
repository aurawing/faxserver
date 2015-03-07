%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 二月 2015 22:26
%%%-------------------------------------------------------------------
-module(faxserver).
-author("aurawing").

%% API
-export([start/0]).

start() ->
  application:start(sasl),
  application:start(crypto),
  application:start(asn1),
  application:start(public_key),
  application:start(ssl),
  application:start(cowlib),
  application:start(ranch),
  application:start(cowboy),
  ibrowse:start(),
  %{ok, Code, _Head, _Resp} = ibrowse:send_req("http://www.baidu.com", [], get),
  %io:format(Code),
  lager:start(),
  application:start(faxserver).


