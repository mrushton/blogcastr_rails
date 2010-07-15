function blogcastrOnLoad()
{
  //MVR - create a BOSH connection with Strophe
  connection = new Strophe.Connection("/http-bind");  
  //MVR - connect with resource equal to dashboard
  connection.connect(username + "@" + hostname + "/dashboard", password, blogcastrOnConnect);
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timers
  setInterval(blogcastrUpdateTimeAgo, 1000);
  //MVR - event handling for exandable links
  //jQuery("h3.expandable").find("a").click(blogcastrOnExpandableHeaderLinkClick);
  //jQuery("h3.expandable").find("a").hover(blogcastrOnExpandableHeaderLinkHoverOn, blogcastrOnExpandableHeaderLinkHoverOff);
}

//TODO: need to come up with a cross browser way to do logging
function blogcastrOnConnect(status, error)
{
  if (status == Strophe.Status.CONNECTING)
  {
    //console.log("Strophe is connecting");
  }
  else if (status == Strophe.Status.CONNFAIL)
  {
   // console.log("Strophe connection failed");
  }
  else if (status == Strophe.Status.DISCONNECTING)
  {
    //console.log('----------> Strophe is disconnecting.');
  }
  else if (status == Strophe.Status.AUTHENTICATING)
  {
    //console.log('----------> Strophe is authenticating.');
  }
  else if (status == Strophe.Status.AUTHFAIL)
  {
    //console.log('----------> Strophe failed to authenticate.');
  }
  else if (status == Strophe.Status.DISCONNECTED)
  {
    //console.log('----------> Strophe is disconnected.');
  }
  else if (status == Strophe.Status.CONNECTED)
  {
    //MVR - register message handlers 
    connection.addHandler(blogcastrPostCallback, null, 'message', 'groupchat', null, "blogcast." + blogcast_id + "@conference." + hostname + "/dashboard");
    connection.addHandler(blogcastrCommentCallback, null, 'message', 'chat', null, null);
    //MVR - send presence to muc
    mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/dashboard"}).c("x", {xmlns: "http://jabber.org/protocol/muc"});
    connection.send(mucPresenceStanza);
  }
}

function blogcastrSendMucPresenceUnavailable()
{
    //MVR - nickname is always username
    mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/dashboard", type: "unavailable"});
    connection.send(mucPresenceStanza);
}

function blogcastrPostCallback(stanza)
{
    console.log("MVR - post callback");
  //jQuery is used for XML parsing, Prototype has no XML support
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  var body = jQuery(stanza).find("body:first");
  var type = body.find("type:first").text();
  if (type == "textPost")
  {
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
    var hours_minutes_ago_span = jQuery("<span>").addClass("date").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var user_a = jQuery("<a>").addClass("user").attr("href", url).append(avatar_img).append(username); 
    var clear_div = jQuery("<div>").addClass("clear");
    var text_p = jQuery("<p>").addClass("text").text(text);
    var up_img = jQuery("<img>").attr("src", up_image);
    //AS DESIGNED: some browsers don't work when adding the onclick attribute
    var info_h4 = jQuery("<h4>").click(function() { blogcastrCollapsibleEvent(this, "TextPost:" + id + "-info"); }).append("Info").append(up_img);
    var info_p = jQuery("<p>").addClass("info").text("Posted by " + username + " on " + date + " from " + medium);
    var info_div = jQuery("<div>").attr("id", "TextPost:" + id + "-info").css("display", "none").append(info_p);
    var effect_div = jQuery("<div>").addClass("effect").append(hours_minutes_ago_span).append(user_a).append(clear_div).append(text_p).append(info_h4).append(info_div);
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    console.log("MVR - about to add");
    if (jQuery("li[id=" + id + "]").length == 0)
    {
    console.log("MVR - about to add 2");
      jQuery("ol#posts-stream:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "imagePost")
  {
    //parse image post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var image_url = body.find("image_url:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    var image_url = body.find("image_url:first").text();
    //create new post element
    var hours_minutes_ago_span = jQuery("<span>").addClass("date").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var user_a = jQuery("<a>").addClass("user").attr("href", url).append(avatar_img).append(username); 
    var clear_div = jQuery("<div>").addClass("clear");
    var image_img = jQuery("<img>").addClass("image").attr("src", image_url);
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
      var effect_div = jQuery("<div>").addClass("effect").append(hours_minutes_ago_span).append(user_a).append(clear_div).append(image_img).append(info_h4).append(info_div);
    }
    else
    {
      var effect_div = jQuery("<div>").addClass("effect").append(hours_minutes_ago_span).append(user_a).append(clear_div).append(image_img).append(text_p).append(info_h4).append(info_div);
    }
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("#comments-stream:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "commentPost")
  {
    //parse comment post
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
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
    var hours_minutes_ago_span = jQuery("<span>").addClass("date").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", comment_avatar_url);
    var user_a = jQuery("<a>").addClass("user").attr("href", url).append(avatar_img).append(comment_username); 
    var clear_div = jQuery("<div>").addClass("clear");
    var text_p = jQuery("<p>").addClass("text").text(comment_text);
    var up_img = jQuery("<img>").attr("src", up_image);
    //AS DESIGNED: some browsers don't work when adding the onclick attribute
    var info_h4 = jQuery("<h4>").click(function() { blogcastrCollapsibleEvent(this, "TextPost:" + id + "-info"); }).append("Info").append(up_img);
    var info_p = jQuery("<p>").addClass("info").text("Posted by " + username + " on " + date + " from " + medium);
    if (comment_account == "FacebookUser")
      var comment_info_p = jQuery("<p>").addClass("info").text("Commented by " + comment_username + " on " + comment_date + " from " + comment_medium + " using Facebook Connect");
    else if (comment_account == "TwitterUser")
      var comment_info_p = jQuery("<p>").addClass("info").text("Commented by " + comment_username + " on " + comment_date + " from " + comment_medium + " using Twitter Sign In");
    else
      var comment_info_p = jQuery("<p>").addClass("info").text("Commented by " + comment_username + " on " + comment_date + " from " + comment_medium);
    var info_div = jQuery("<div>").attr("id", "TextPost:" + id + "-info").css("display", "none").append(info_p).append(comment_info_p);
    var effect_div = jQuery("<div>").addClass("effect").append(hours_minutes_ago_span).append(user_a).append(clear_div).append(text_p).append(info_h4).append(info_div);
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("#comments-stream:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
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
      var comment_hours_minutes_ago_span = jQuery("<span>").addClass("hours_minutes_ago").attr("timestamp", comment_timestamp).text(blogcastrHoursMinutesAgo(comment_timestamp));
      var comment_info_p = jQuery("<p>").addClass("info").text("Commented by ");
      comment_info_p.append(comment_url_a);
      comment_info_p.append(" ");
      comment_info_p.append(comment_hours_minutes_ago_span);
      comment_info_p.append(" from " + comment_medium);
      var clear_div = jQuery("<div>").addClass("clear");
      var comment_post_hours_minutes_ago_span = jQuery("<span>").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
      var comment_post_info_p = jQuery("<p>").addClass("info").text("Posted ");
      comment_post_info_p.append(comment_post_hours_minutes_ago_span);
      comment_post_info_p.append(" from " + medium);
      var li = jQuery("<li>").attr("id",id).append(avatar_a).append(text_p).append(comment_info_p).append(clear_div).append(comment_post_info_p);
      //add comment to document if not present
      //TODO: add class to list, this will break
      if (jQuery("li[id=" + id + "]").length == 0)
        jQuery("ol:first").prepend(li);
    }
    //console.log("received unknown blogcastr event type: " + type);
  }
  return true;
}

function blogcastrCommentCallback(stanza)
{
  //Prototype has no XML support using jQuery
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  var body = jQuery(stanza).find("body:first");
  var type = body.find("type:first").text();
  if (type == "comment")
  {
    //parse comment
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var date = body.find("date:first").text();
    var user = body.find("user:first");
    var username = user.find("username:first").text();
    var account = user.find("account:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar_url:first").text();
    var medium = body.find("medium:first").text();
    //create new post element
    var hours_minutes_ago_span = jQuery("<span>").addClass("date").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var avatar_img = jQuery("<img>").addClass("avatar").attr("src", avatar_url);
    var user_a = jQuery("<a>").addClass("user").attr("href", url).append(avatar_img).append(username); 
    var clear_div = jQuery("<div>").addClass("clear");
    var text_p = jQuery("<p>").addClass("text").text(text);
    var up_img = jQuery("<img>").attr("src", up_image);
    //AS DESIGNED: some browsers don't work when adding the onclick attribute
    var info_h4 = jQuery("<h4>").click(function() { blogcastrCollapsibleEvent(this, "TextPost:" + id + "-info"); }).append("Info").append(up_img);
    if (account == "FacebookUser")
      var info_p = jQuery("<p>").addClass("info").text("Commented by " + username + " on " + date + " from " + medium + " using Facebook Connect");
    else if (account == "TwitterUser")
      var info_p = jQuery("<p>").addClass("info").text("Commented by " + username + " on " + date + " from " + medium + " using Twitter Sign In");
    else
      var info_p = jQuery("<p>").addClass("info").text("Commented by " + username + " on " + date + " from " + medium);
    var info_div = jQuery("<div>").attr("id", "Comment:" + id + "-info").css("display", "none").append(info_p);
    var effect_div = jQuery("<div>").addClass("effect").append(hours_minutes_ago_span).append(user_a).append(clear_div).append(text_p).append(info_h4).append(info_div);
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("#comments-stream:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }













    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var text = body.find("text:first").text();
    var name = body.find("name:first").text();
    var account = body.find("account:first").text();
    var url = body.find("url:first").text();
    var avatar_url = body.find("avatar_url:first").text();
    var medium = body.find("medium:first").text();
    //create new comment element
    var avatar_a = jQuery("<a>").attr("href", url).attr("target", "_blank");
    if (account == "BlogcastrUser")
      var avatar_div = jQuery("<div>").addClass("avatar-medium-rounded").attr("style", "background-image: url('" + avatar_url + "');");
    else if (account == "FacebookUser")
      var avatar_div = jQuery("<div>").addClass("facebook-avatar-medium-rounded").attr("style", "background-image: url('" + avatar_url + "');");
    else if (account == "TwitterUser")
      var avatar_div = jQuery("<div>").addClass("twitter-avatar-medium-rounded").attr("style", "background-image: url('" + avatar_url + "');");
    avatar_a.append(avatar_div);
    var text_p = jQuery("<p>").addClass("list_item_text").text(text);
    var clear_div = jQuery("<div>").addClass("clear");
    var url_a = jQuery("<a>").attr("href", url).attr("target", "_blank").text(name);
    var hours_minutes_ago_span = jQuery("<span>").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var info_p = jQuery("<p>").addClass("list_item_info").text("Commented by ");
    info_p.append(url_a);
    info_p.append(" ");
    info_p.append(hours_minutes_ago_span);
    info_p.append(" from " + medium);
    var post_a = jQuery("<a>").attr("onclick", "blogcastrPostComment(" + id + "); return false;").attr("href", "#").text("Post");
    var li = jQuery("<li>").addClass("comment_stream_list_item").attr("id",id).append(avatar_a).append(text_p).append(clear_div).append(info_p).append(post_a);
    //add comment to document if not present
//    if (jQuery("li.comment_stream_list_item[id=" + id + "]").length == 0)
  {
      jQuery("ol#comments-stream:first").prepend(li);
  }}
  else
  {
   // console.log("received unknown blogcastr event type: " + type);
  }
  return true;
  //Prototype has no XML support so using jQuery
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  /*var events = jQuery(stanza).find("event[xmlns='http://jabber.org/protocol/pubsub#event']:first").find("items[node='" + nodename + "']:first").find("event[xmlns='http://blogcastr.com']")
    .each(function ()
    {
      var type = jQuery(this).find("type:first").text();
      if (type == null)
        console.log("blogcastr event type not defined");
      if (type == "postText")
      {
        var id = jQuery(this).find("id:first").text();
        var date = jQuery(this).find("date:first").text();
        var text = jQuery(this).find("text:first").text();
        //create new post element
        var h2 = jQuery("<h2>").text(date);
        var p = jQuery("<p>").text(text);
        var li = jQuery("<li>").attr("id",id).append(h2).append(p);
        //add post to document
        jQuery("ul:first").prepend(li);
      }
      else if (type == "postImage")
      {
        var id = jQuery(this).find("id:first").text();
        var date = jQuery(this).find("date:first").text();
        var image_url = jQuery(this).find("image_url:first").text();
        //create new post element
        var h2 = jQuery("<h2>").text(date);
        var img = jQuery("<img>").attr("src",image_url);
        var li = jQuery("<li>").append(h2).append(img).attr("id", id);
        //add post to document
        jQuery("ul:first").prepend(li);
      }
      else
      {
        console.log("received unknown blogcastr event type: " + type);
      }
    });*/
  return true;
}

Strophe.log = function(log, msg)
{
  //console.log(msg);
}

window.addEventListener("load", blogcastrOnLoad, false);
