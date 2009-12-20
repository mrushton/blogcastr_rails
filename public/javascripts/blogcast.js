function blogcastrOnLoad()
{
  //MVR - create a BOSH connection with Strophe
  connection = new Strophe.Connection("/http-bind");  
  //TODO: connect as user if logged in
  if (username == undefined)
    connection.connect(hostname,"",onConnect);
  else
    connection.connect(username + "@" + hostname, password, onConnect);
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timers
  setInterval(blogcastrUpdateHoursMinutesAgo, 1000);
}

function onConnect(status, error)
{
  if (status == Strophe.Status.CONNECTING)
  {
    console.log("Strophe is connecting");
  }
  else if (status == Strophe.Status.CONNFAIL)
  {
    console.log("Strophe connection failed");
  }
  else if (status == Strophe.Status.DISCONNECTING)
  {
    console.log('----------> Strophe is disconnecting.');
  }
  else if (status == Strophe.Status.AUTHENTICATING)
  {
    console.log('----------> Strophe is authenticating.');
  }
  else if (status == Strophe.Status.AUTHFAIL)
  {
    console.log('----------> Strophe failed to authenticate.');
  }
  else if (status == Strophe.Status.DISCONNECTED)
  {
    console.log('----------> Strophe is disconnected.');
  }
  else if (status == Strophe.Status.CONNECTED)
  {
    console.log('----------> Strophe is connected.' );
    //MVR - set jid resource
    //TODO: hack for now
    jQuery("input[id='jid']").attr("value", connection.jid);
    console.log('----------> Strophe is connected 2.' );
    //MVR - register message handlers 
    connection.addHandler(blogcastrPostCallback, null, 'message', 'groupchat', null, "blogcast." + blogcast_id + "@conference." + hostname + "/dashboard");
    console.log('----------> Strophe is connected 3.' );
    //MVR - join muc, nickname is resource 
    console.log('----------> Strophe is connected 4.' );
   mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/" + Strophe.getResourceFromJid(connection.jid)}).c("x", {xmlns: "http://jabber.org/protocol/muc"});
    console.log('----------> Strophe is connected 5.' );
blogcastrPrintStanza(mucPresenceStanza);
    console.log('----------> Strophe is connected 6.' );
    connection.send(mucPresenceStanza);
    console.log('----------> Strophe is connected 7.' );
  }
}

function blogcastrPostCallback(stanza)
{
  //Prototype has no XML support using jQuery
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
    console.log('GOT A POST' );
  var body = jQuery(stanza).find("body:first");
  var type = body.find("type:first").text();
  if (type == "textPost")
  {
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var text = body.find("text:first").text();
    var medium = body.find("medium:first").text();
    //create new post element
    var text_p = jQuery("<p>").addClass("text").text(text);
    var hours_minutes_ago_span = jQuery("<span>").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var info_p = jQuery("<p>").addClass("info").text("Posted ");
    info_p.append(hours_minutes_ago_span);
    info_p.append(" from " + medium);
    var effect_div = jQuery("<div>").addClass("stream-effect").append(text_p).append(info_p);
    var post_li = jQuery("<li>").attr("id",id).css("display", "none").append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("ol:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "imagePost")
  {
    var id = body.find("id:first").text();
    var timestamp = body.find("timestamp:first").text();
    var image_url = body.find("image_url:first").text();
    var medium = body.find("medium:first").text();
    //create new post element
    var image_img = jQuery("<img>").addClass("image").attr("src", image_url);
    var hours_minutes_ago_span = jQuery("<span>").addClass("hours_minutes_ago").attr("timestamp", timestamp).text(blogcastrHoursMinutesAgo(timestamp));
    var info_p = jQuery("<p>").addClass("info").text("Posted ");
    info_p.append(hours_minutes_ago_span);
    info_p.append(" from " + medium);
    var effect_div = jQuery("<div>").addClass("stream-effect").append(image_img).append(info_p);
    var post_li = jQuery("<li>").attr("id",id).append(effect_div);
    //add post to document if not present
    if (jQuery("li[id=" + id + "]").length == 0)
    {
      jQuery("ol:first").prepend(post_li);
      var element = jQuery("li:first").get(0);
      new Effect.SlideDown(element, {duration: 0.5, queue: "end"});
    }
  }
  else if (type == "commentPost")
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
    else
    {

    }
  }
  else
  {
    //console.log("received unknown blogcastr event type: " + type);
  }
  return true;
}

function pubsubSubscribeCallback(stanza)
{
//  var error = $(stanza).getElementsByTagName("error");

//  if(error.length != 0)
//  {
//    console.log("Failed to subscribe to node");
//  }
}

Strophe.log = function(log,msg)
{
//  console.log(msg);
}

function blogcastrPrintStanza(stanza)
{
//  var string = (new XMLSerializer()).serializeToString(stanza);
}

window.addEventListener("load",blogcastrOnLoad,false);
