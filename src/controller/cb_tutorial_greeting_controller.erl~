-module(cb_tutorial_greeting_controller, [Req]).
-compile(export_all).

before_(_) ->
    case user_lib:require_login(Req) of
	fail-> {redirect, "/member/login"};
	{ok, Member} -> {ok, Member}
    end.
	     

list('GET', []) ->
    Greetings = boss_db:find(greeting, []),
    {ok, [{greetings, Greetings}]}.

create('GET',  []) -> ok;
create('POST', []) ->
    GreetingText = Req:post_param("greeting_text"),
    NewGreeting = greeting:new(id, GreetingText),
    case NewGreeting:save() of
	{ok, SavedGreeting} ->
	    {redirect, [{action, "list"}]};
	{error, ErrorList} ->
	    {ok, [{errors, ErrorList}, {new_msg, NewGreeting}]}
    end.

delete('POST', []) ->
    DeleteId = Req:post_param("greeting_id"),
    boss_db:delete(DeleteId),
    {redirect, [{action, "list"}]}.

push('POST', [], Member) ->
    MessageText = Req:post_param("message_text"),
    NewMessage = greeting:new(id, MessageText, Member:id(), now()),
    case NewMessage:save() of
	{ok, Saved} -> {json, [{text, MessageText}]};
	{error, Errors} -> {json, [{errors, Errors}]}
    end.


pull('GET', [LastTimestamp]) ->
    LastTimestampValue = list_to_integer(LastTimestamp),
    {ok, Timestamp, Messages} = boss_mq:pull("new-messages", LastTimestampValue),
    Greetings = lists:map(fun extend_message/1,
			 Messages),
    {json, [{timestamp, Timestamp}, 
	    {greetings, Greetings}]}.

live('GET', [], Member) ->
    Greetings = lists:map(fun extend_message/1,
			  boss_db:find(greeting, [], [{order_by, ts}])),
    Timestamp = boss_mq:now("new-messages"),
    {ok, [{greetings, Greetings}, 
	  {timestamp, Timestamp},
	  {member, Member},
	  {session_id, Member:session_id()}]}.

extend_message(Message) ->
    Member = Message:member(),
    [{text, Message:greeting_text()},
     {member, [{id, Member:id()},
	       {name, Member:name()},
	       {email, Member:email()}]}].
