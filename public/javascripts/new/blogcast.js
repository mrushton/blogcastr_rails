var can_play_audio = false;
var can_play_mp3 = false;
var can_play_ogg = false;
var remote_request = false;
var twitter_sign_in_window;
var twitter_sign_in_interval;

function blogcastrOnLoad()
{
  //MVR - create a BOSH connection with Strophe
  connection = new Strophe.Connection("/http-bind");  
  //TODO: connect as user if logged in
  if (username == undefined)
    connection.connect(hostname, "", onConnect);
  else
    connection.connect(username + "@" + hostname, password, onConnect);
  //MVR - detect audio and video support 
  var audio = jQuery("<audio>")[0];
  if (audio.canPlayType != null)
  {
    if (audio.canPlayType("audio/mpeg") == "maybe" || audio.canPlayType("audio/mpeg") == "probably")
      can_play_mp3 = true;
    if (audio.canPlayType("audio/ogg") == "maybe" || audio.canPlayType("audio/ogg") == "probably")
      can_play_ogg = true;
    if (can_play_mp3 == true || can_play_ogg == true)
      can_play_audio = true;
  }
  //MVR - show html5 or flash player
  if (can_play_audio == true)
    jQuery("div.player.audio div.html5").show();
  else
    jQuery("div.player.audio div.flash").show();
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timestamp in words
  setInterval(blogcastrUpdateTimestampInWords, 1000);
}

function onConnect(status, error)
{
  if (status == Strophe.Status.CONNECTING)
  {
    blogcastrLog("strophe connecting");
  }
  else if (status == Strophe.Status.CONNFAIL)
  {
    blogcastrLog("strophe connection failed");
  }
  else if (status == Strophe.Status.DISCONNECTING)
  {
    blogcastrLog("strophe disconnecting");
  }
  else if (status == Strophe.Status.AUTHENTICATING)
  {
    blogcastrLog("strophe authenticating");
  }
  else if (status == Strophe.Status.AUTHFAIL)
  {
    blogcastrLog("stophe authentication failed");
  }
  else if (status == Strophe.Status.DISCONNECTED)
  {
    blogcastrLog("strophe disconnected");
  }
  else if (status == Strophe.Status.CONNECTED)
  {
    blogcastrLog("strophe connected");
    //MVR - set jid resource
    //TODO: hack for now
    jQuery("input[id='jid']").attr("value", connection.jid);
    //MVR - register message handlers 
    //connection.addHandler(blogcastrPostCallback, null, 'message', 'groupchat', null, "blogcast." + blogcast_id + "@conference." + hostname + "/dashboard");
    connection.addHandler(blogcastrPostCallback, null, 'message', 'groupchat', null, null);
    //MVR - join muc, nickname is resource 
   mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/" + Strophe.getResourceFromJid(connection.jid)}).c("x", {xmlns: "http://jabber.org/protocol/muc"});
blogcastrPrintStanza(mucPresenceStanza);
    connection.send(mucPresenceStanza);
  }
}

function blogcastrPostCallback(stanza) {
  //jQuery is used for XML parsing, Prototype has no XML support
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  var body = jQuery(stanza).find("body:first");
  var type = body.find("type:first").text();
  if (type == "textPost") {
    //parse text post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    //create new post element
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("timestamp", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var post_header_div = jQuery("<div>").addClass("post-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var text_p = jQuery("<p>").addClass("text").text(text);
    var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("post-body").append(clearfix_div);
    //post container for animation 
    var post_container_div = jQuery("<div>").append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").addClass("post").attr("id", "TextPost:" + id).css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#TextPost\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("TextPost\:" + id, { duration: 0.6, queue: "end" });
      new Effect.Appear("TextPost\:" + id, { duration: 0.6, queue: "end" });
    }
  }
  else if (type == "imagePost") {
    //parse image post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    var image_url = body.find("image_url:first").text();
    //create new post element
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("timestamp", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var post_header_div = jQuery("<div>").addClass("post-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var image_img = jQuery("<img>").addClass("image").attr("src", image_url);
    var caption_p = jQuery("<p>").addClass("caption").text(text);
    if (typeof(caption_p) == "undefined")
      var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(image_img).append(caption_p);
    else
      var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(image_img).append(caption_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("post-body").append(clearfix_div);
    var post_container_div = jQuery("<div>").addClass("spacer").append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").addClass("post").attr("id", "ImagePost:" + id).css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#ImagePost\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("ImagePost\:" + id, {duration: 0.6, queue: "end"});
      new Effect.Appear("ImagePost\:" + id, {duration: 0.6, queue: "end"});
    }
  }
  else if (type == "audioPost")
  {
//alert("audio post");
    //parse audio post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    //create new post element
    var time_ago_span = jQuery("<span>").addClass("date").addClass("time_ago").attr("timestamp", timestamp).text(blogcastrTimeAgo(timestamp));
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var user_a = jQuery("<a>").addClass("user").attr("href", url).append(avatar_img).append(username); 
    var clear_div = jQuery("<div>").addClass("clear");
    var player_div = jQuery("<div>").addClass("player loading");


    var loading_img = jQuery("<img>").attr("src", ajax_loader_image);
    var loading_p = jQuery("<p>").text("Encoding audio sit tight!");
    player_div.append(loading_img).append(loading_p);



    if (text != "")
    {
      var text_p = jQuery("<p>").addClass("text").text(text);
    }
    var up_img = jQuery("<img>").attr("src", up_image);
    //AS DESIGNED: some browsers don't work when adding the onclick attribute
    var info_h4 = jQuery("<h4>").click(function() { blogcastrCollapsibleEvent(this, "ImagePost:" + id + "-info"); }).append("Info").append(up_img);
    var info_p = jQuery("<p>").addClass("info").text("Posted by " + username + " on " + date + " from " + medium);
    var info_div = jQuery("<div>").attr("id", "ImagePost:" + id + "-info").css("display", "none").append(info_p);
    if (typeof(text_p)  == "undefined")
    {
      var effect_div = jQuery("<div>").addClass("effect").append(time_ago_span).append(user_a).append(clear_div).append(player_div).append(info_h4).append(info_div);
    }
    else
    {
      var effect_div = jQuery("<div>").addClass("effect").append(time_ago_span).append(user_a).append(clear_div).append(player_div).append(text_p).append(info_h4).append(info_div);
    }
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("ol:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "audioMedia")
  {
//alert("audio media");
    //parse audio media
    var id = body.find("id:first").text();
    var mp3_url = body.find("mp3_url:first").text();
    var ogg_url = body.find("ogg_url:first").text();

  }
  else if (type == "commentPost")
  {
    //parse comment post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    var comment = jQuery(body).find("comment:first");
    var comment_id = comment.find("id:first").text();
    var comment_timestamp = comment.find("timestamp:first").text();
    var comment_date = comment.find("date:first").text();
    var comment_text = comment.find("text:first").text();
    var comment_medium = comment.find("medium:first").text();
    var comment_user = jQuery(comment).find("user:first");
    var comment_username = comment_user.find("username:first").text();
    var comment_account = comment_user.find("account:first").text();
    var comment_url = comment_user.find("url:first").text();
    var comment_avatar_url = comment_user.find("avatar_url:first").text();
    //create new post element
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", comment_avatar_url);
    var avatar_a = jQuery("<a>").attr("href", comment_url).append(avatar_img);
    var username_a = jQuery("<a>").addClass("username").attr("href", comment_url).text(comment_username); 
    var time_ago_span = jQuery("<span>").addClass("date").addClass("time-ago").attr("timestamp", timestamp).text(blogcastrTimeAgo(timestamp));
    var text_p = jQuery("<p>").addClass("text").text(text);
    var up_img = jQuery("<img>").attr("src", up_image);
    //AS DESIGNED: some browsers don't work when adding the onclick attribute
    var info_collapsible_div = jQuery("<div>").addClass("info-collapsible").click(function() { blogcastrCollapsibleEvent(this, "TextPost:" + id + "-info"); }).append("Info").append(up_img);

    var info_username_a = jQuery("<a>").addClass("username").attr("href", url).text(username);
    var date_span = jQuery("<span>").addClass("date").text(date);
    var info_span = jQuery("<span>").addClass("info").append("Posted by ").append(info_username_a).append(" on ").append(date_span).append(" from " + medium);
    var info_br = jQuery("<br>");
    var comment_info_username_a = jQuery("<a>").addClass("username").attr("href", comment_url).text(comment_username);
    var comment_date_span = jQuery("<span>").addClass("date").text(comment_date);
    var comment_info_span = jQuery("<span>").addClass("info").append("Commented by ").append(comment_info_username_a).append(" on ").append(comment_date_span).append(" from " + comment_medium);
    if (comment_account == "FacebookUser")
      comment_info_span.append(" using Facebook Connect");
    else if (comment_account == "TwitterUser")
      comment_info_span.append(" using Twitter Sign In");
    var info_div = jQuery("<div>").attr("id", "TextPost:" + id + "-info").addClass("info").css("display", "none").append(info_span).append(info_br).append(comment_info_span);
    var right_div = jQuery("<div>").addClass("right").append(username_a).append(" ").append(time_ago_span).append(text_p).append(info_collapsible_div).append(info_div);
    var clear_div = jQuery("<div>").addClass("clear");
    var spacer_div = jQuery("<div>").attr("id", "TextPost:" + id + "-spacer").addClass("spacer").css("opacity", "0.0").append(avatar_a).append(right_div).append(clear_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("post").css("display", "none").append(spacer_div);
    //add post to document if not present
    if (jQuery("#Post\\:" + id).length == 0)
    {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, {duration: 0.5, queue: "end"});
      new Effect.Appear("TextPost\:" + id + "-spacer", {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "comment") {
    //parse comment
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var text = body.find("text:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    //create new comment element
    var avatar_div = jQuery("<div>").addClass("comment-avatar").addClass("small-rounded-avatar").css("background-image", "url(\"" + avatar_url + "\")"); 
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_div); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("timestamp", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var username_timestamp_container_div = jQuery("<div>").addClass("username-timestamp-in-words-container").append(username_a).append(" ").append(timestamp_in_words_span);
    var text_p = jQuery("<p>").addClass("text").text(text);
    var comment_info_div = jQuery("<div>").addClass("comment-info").append(username_timestamp_container_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(comment_info_div);
    var comment_li = jQuery("<li>").addClass("comment").attr("id", "Comment:" + id).css("display", "none").css("opacity", "0.0").append(clearfix_div);
    //add comment to document if not present
    if (jQuery("#Comment\\:" + id).length == 0) {
      jQuery("#comments").prepend(comment_li);
      new Effect.SlideDown("Comment\:" + id, { duration: 0.4, queue: "end" });
      new Effect.Appear("Comment\:" + id, { duration: 0.4, queue: "end" });
    }
  }
  else
  {
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var medium = body.find("medium:first").text();
    var comment = body.find("comment:first");
    var comment_type = comment.find("type:first").text();
    if (comment_type == "textComment")
    {
      var comment_id = comment.find("id:first").text();
      var comment_timestamp = comment.find("timestamp:first").text();
      var comment_medium  = comment.find("medium:first").text();
      var comment_text = comment.find("text:first").text();
      var comment_user_name = comment.find("name:first").text();
      var comment_user_account = comment.find("account:first").text();
      var comment_user_url = comment.find("url:first").text();
      var comment_user_avatar_url = comment.find("avatar_url:first").text();
      //create new text comment post element
      var avatar_a = jQuery("<a>").attr("href", comment_user_url).attr("target", "_blank");
      if (comment_user_account == "BlogcastrUser")
        var avatar_div = jQuery("<div>").addClass("avatar-medium-rounded").attr("style", "background-image: url('" + comment_user_avatar_url + "');");
      else if (comment_user_account == "FacebookUser")
        var avatar_div = jQuery("<div>").addClass("facebook-avatar-medium-rounded").attr("style", "background-image: url('" + comment_user_avatar_url + "');");
      else if (comment_user_account == "TwitterUser")
        var avatar_div = jQuery("<div>").addClass("twitter-avatar-medium-rounded").attr("style", "background-image: url('" + comment_user_avatar_url + "');");
      avatar_a.append(avatar_div);
      var text_p = jQuery("<p>").addClass("text").text(comment_text);
      var comment_url_a = jQuery("<a>").attr("href", comment_user_url).attr("target", "_blank").text(comment_user_name);
      var comment_time_ago_span = jQuery("<span>").addClass("time-ago").attr("timestamp", comment_timestamp).text(blogcastrTimeAgo(comment_timestamp));
      var comment_info_p = jQuery("<p>").addClass("info").text("Commented by ");
      comment_info_p.append(comment_url_a);
      comment_info_p.append(" ");
      comment_info_p.append(comment_time_ago_span);
      comment_info_p.append(" from " + comment_medium);
      var clear_div = jQuery("<div>").addClass("clear");
      var comment_post_time_ago_span = jQuery("<span>").addClass("time_ago").attr("timestamp", timestamp).text(blogcastrTimeAgo(timestamp));
      var comment_post_info_p = jQuery("<p>").addClass("info").text("Posted ");
      comment_post_info_p.append(comment_post_time_ago_span);
      comment_post_info_p.append(" from " + medium);
      var li = jQuery("<li>").attr("id",id).append(avatar_a).append(text_p).append(comment_info_p).append(clear_div).append(comment_post_info_p);
      //add comment to document if not present
      //TODO: add class to list, this will break
      if (jQuery("li[id=" + id + "]").length == 0)
        jQuery("ol:first").prepend(li);
    }
  }
  return true;
}

Strophe.log = function(log,message)
{
    blogcastrLog(message);
}

function blogcastrPrintStanza(stanza)
{
//  var string = (new XMLSerializer()).serializeToString(stanza);
}

function checkTwitterSignIn() {
  if (twitter_sign_in_window.closed) {
    clearInterval(twitter_sign_in_interval);
  }
  else {
    //MVR - check if we are signed in or not
    var ret = jQuery(twitter_sign_in_window.document.body).find("#twitter-sign-in").text();
    if (ret == "success") {
      twitter_sign_in_window.close();
      //AS DESIGNED: reload page
      window.location.reload();
    }
    else if (ret == "failure") {
      twitter_sign_in_window.close();
      alert('Error: failed to connect Twitter account.');
    }
  }
}

function twitterSignIn() {
  //MVR - open window 
  twitter_sign_in_window = window.open("/twitter_sign_in", "Twitter Sign In", "location=0, status=0, width=800, height=400");
  //MVR - check twitter sign in window every 1 second 
  twitter_sign_in_interval = setInterval(checkTwitterSignIn, 1000);
}

window.addEventListener("load", blogcastrOnLoad, false);
