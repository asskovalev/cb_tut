function listen(url, selector, timestamp) {
    var url_param = url + timestamp;
    $.get(url_param).done(process_data(url, selector));
}

function format_message(msg){
    var mem_email = " title='" + msg.member.email + "'";
    var mem_name = "<strong" + mem_email + ">" 
	+ msg.member.name 
        + "</strong>&nbsp;";
    var message = "<p>" + mem_name + msg.text + "</p>";
    return message;
}

function scroll_down(target, speed){
    target.animate({scrollTop: target.height()}, speed || 500);    
}

function process_data(url, selector) {
    var target = $(selector);
    return function(data) {
        for (var i = 0; i < data.greetings.length; i++) {
	    var message = format_message(data.greetings[i]);
	    target.append(message);
	    scroll_down(target);
	}
        listen(url, selector, data.timestamp);
    }
}

function send_data(url, data) {
    $.post(url, { message_text: data });
}

function process_input(event) {
    if ( event.which == 13 ) {
        event.preventDefault();
        var source = $(event.target);
        if (source.val().length > 0)
            send_data("/greeting/push", source.val());
        source.val("");
    }
}
