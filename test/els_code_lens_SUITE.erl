-module(els_code_lens_SUITE).

%% CT Callbacks
-export([ suite/0
        , init_per_suite/1
        , end_per_suite/1
        , init_per_testcase/2
        , end_per_testcase/2
        , groups/0
        , all/0
        ]).

%% Test cases
-export([ default_lenses/1
        , server_info/1
        ]).

%%==============================================================================
%% Includes
%%==============================================================================
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

%%==============================================================================
%% Types
%%==============================================================================
-type config() :: [{atom(), any()}].

%%==============================================================================
%% CT Callbacks
%%==============================================================================
-spec suite() -> [tuple()].
suite() ->
  [{timetrap, {seconds, 30}}].

-spec all() -> [{group, atom()}].
all() ->
  [{group, tcp}, {group, stdio}].

-spec groups() -> [atom()].
groups() ->
  els_test_utils:groups(?MODULE).

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
  els_test_utils:init_per_suite(Config).

-spec end_per_suite(config()) -> ok.
end_per_suite(Config) ->
  els_test_utils:end_per_suite(Config).

-spec init_per_testcase(atom(), config()) -> config().
init_per_testcase(server_info, Config) ->
  meck:new(els_code_lens_server_info, [passthrough, no_link]),
  meck:expect(els_code_lens_server_info, is_default, 0, true),
  els_test_utils:init_per_testcase(server_info, Config);
init_per_testcase(TestCase, Config) ->
  els_test_utils:init_per_testcase(TestCase, Config).

-spec end_per_testcase(atom(), config()) -> ok.
end_per_testcase(server_info, Config) ->
  els_test_utils:end_per_testcase(server_info, Config),
  meck:unload(els_code_lens_server_info),
  ok;
end_per_testcase(TestCase, Config) ->
  els_test_utils:end_per_testcase(TestCase, Config).

%%==============================================================================
%% Testcases
%%==============================================================================

-spec default_lenses(config()) -> ok.
default_lenses(Config) ->
  Uri = ?config(code_navigation_uri, Config),
  #{result := Result} = els_client:document_codelens(Uri),
  ?assertEqual([], Result),
  ok.

-spec server_info(config()) -> ok.
server_info(Config) ->
  Uri = ?config(code_navigation_uri, Config),
  #{result := Result} = els_client:document_codelens(Uri),
  PrefixedCommand = els_command:with_prefix(<<"server-info">>),
  Title = <<"Erlang LS (in code_navigation) info">>,
  Expected =
    [ #{ command => #{ arguments => []
                     , command   => PrefixedCommand
                     , title     => Title
                     }
       , data => []
       , range =>
           #{'end' => #{character => 0, line => 1},
             start => #{character => 0, line => 0}}
       }
    ],
  ?assertEqual(Expected, Result),
  ok.
