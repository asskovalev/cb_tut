-module(cb_tutorial_member_controller, [Req]).
-compile(export_all).

register('GET', []) ->
    {ok, []};
register('POST', []) ->
    Email = Req:post_param("email"),
    Name = Req:post_param("name"),
    Password = Req:post_param("password1"),
    Password2 = Req:post_param("password2"),
    case user_lib:add_member(Name, Email, Password, Password2) of
	{ok, Member} -> login_and_redirect(Member);
	{error, Errors} -> {ok, [{errors, Errors},
				 {name, Name},
				 {email, Email},
				 {password1, Password},
				 {password2, Password2}]}
    end.
    

logout('GET', [SessionId]) ->
    case Req:cookie("session_id") of
	SessionId -> 
	    Cookies = [user_lib:root_cookie("user_id", ""),
		       user_lib:root_cookie("session_id", "")],
	    {redirect, "/greeting/live", Cookies};
	_ -> {redirect, "/greeting/live"}
    end.	


login('GET', []) ->
    {ok, [{redirect, Req:header(referer)}]};

login('POST', []) ->
    Email = Req:post_param("email"),
    Password = Req:post_param("password"),
    case boss_db:find(member, [{email, 'equals', Email}]) of
	[Member] ->
	    case Member:check_password(Password) of
		true -> login_and_redirect(Member);
		false -> {ok, [{error, "Wrong password"}]}
	    end;
	[] -> {ok, [{error, "User with email " ++ Email ++ " not found: "}]}
    end.

login_and_redirect(Member) ->
    Cookies = Member:login_cookies(),
    RedirectTo = "/greeting/live",
    {redirect, RedirectTo, Cookies}.
    

list('GET', []) ->
    MemberList = boss_db:find(member, []),
    Members = lists:map(fun (M) -> [{id, M:id()}, 
				    {name, M:name()},
				    {email, M:email()}] end,
			MemberList),
    {json, [{members, Members}]}.
