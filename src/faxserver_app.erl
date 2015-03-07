-module(faxserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, custom_404_hook/4]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, Conf} = application:get_env(faxserver),
    {basepath, BasePath} = lists:keyfind(basepath, 1, Conf),
    {username, Username} = lists:keyfind(username, 1, Conf),
    {password, Password} = lists:keyfind(password, 1, Conf),
    Auth = base64:encode_to_string(lists:concat([Username, ":", Password])),
    Dispatch = cowboy_router:compile([
      {'_', [
        {"/", hello_handler, []},
        {"/fax/[:id]", fax_handler, [{auth, Auth}, {basepath, BasePath}]},
        {"/static/[...]", cowboy_static, {priv_dir, faxserver, "static"}}
      ]}
    ]),
    cowboy:start_http(fax_http_listener, 100, [{port, 8080}],
      [{env, [{dispatch, Dispatch}
       % , {onresponse, fun ?MODULE:custom_404_hook/4}
      ]}]
    ),
    faxserver_sup:start_link().

stop(_State) ->
    ok.

custom_404_hook(404, Headers, Body, Req) ->
  %Body = <<"404 Not Found.">>,
  Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
    {<<"content-length">>, integer_to_list(byte_size(Body))}),
  {ok, Req2} = cowboy_req:reply(404, Headers2, Body, Req),
  io:format("Body:"),
  io:format(Body),
  Req2;
custom_404_hook(_, _, _, Req) ->
  Req.