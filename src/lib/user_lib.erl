-module(user_lib).
-compile(export_all).
-define(SECRET_STRING, "Secret string").

root_cookie(N, V) ->
    mochiweb_cookies:cookie(N, V, [{path, "/"}]).


hash_password(Password, Salt) ->
    mochihex:to_hex(erlang:md5(Salt ++ Password)).


hash_for(Login, Password) ->
    Salt = mochihex:to_hex(erlang:md5(Login)),
    ComputedHash = hash_password(Password, Salt),
    ComputedHash.


session_id(Id) ->
    mochihex:to_hex(erlang:md5(?SECRET_STRING ++ Id)).


add_member(Name, Email, Password) ->
    add_member(Name, Email, Password, Password).

add_member(Name, Email, Password, Password2) ->
    case boss_db:find(member, [{email, 'equals', Email}]) of
	[] -> 
	    case Password of
		Password2 -> 
		    PasswordHash = hash_for(Email, Password),
		    Member = member:new(id, Email, Name, PasswordHash),
		    case Member:save() of
			{ok, Saved} -> {ok, Saved};
			{error, Errors} -> {error, Errors}
		    end;
		_ -> {error, ["Passwords should be equal"]}
	    end;
	_ -> {error, ["User already exists"]}
    end.


require_login(Req) ->
    case Req:cookie("user_id") of
	undefined -> fail;
	Id -> 
	    case boss_db:find(Id) of
		undefined -> fail;
		Member ->
		    case Member:session_id() =:= Req:cookie("session_id") of
			false -> fail;
			true -> {ok, Member}
		    end
	    end
    end.
		      
	    
