-module(member, [Id, Email, Name, PasswordHash]).
-compile(export_all).
-define(SECRET_STRING, "Secret string").

validation_tests() ->
    [{fun () -> length(Email) > 0 end,
      "Email is required"},
     {fun () -> length(Name) > 0 end,
      "Name is required"}].

check_password(Password) ->
    ComputedHash = user_lib:hash_for(Email, Password),
    PasswordHash =:= ComputedHash.

login_cookies() ->
    UserId = user_lib:root_cookie("user_id", Id),
    SessionId = user_lib:root_cookie("session_id", user_lib:session_id(Id)),
    [UserId, SessionId].
    

session_id() ->
    user_lib:session_id(Id).
