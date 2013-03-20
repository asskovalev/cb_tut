-module(greeting, [Id, GreetingText, MemberId, Ts]).
-compile(export_all).
-belongs_to(member).

validation_tests() ->
    [{fun () -> length(GreetingText) > 0 end,
     "Message must be non-empty"},

     {fun () -> length(GreetingText) =< 140 end,
     "Message must be tweetable"}].

before_create() ->
    case GreetingText of
	"error please" -> 
	    {error, ["You're welcome"]};
	_ ->
	    ModifiedRecord = set(greeting_text,
				 re:replace(GreetingText,
					    "eggs", "balls",
					    [{return, list}])),
	    {ok, ModifiedRecord}
    end.


