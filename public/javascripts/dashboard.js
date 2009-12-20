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
  setInterval(blogcastrUpdateHoursMinutesAgo, 1000);
  //MVR - event handling for exandable links
  jQuery("h3.expandable").find("a").click(blogcastrOnExpandableHeaderLinkClick);
  jQuery("h3.expandable").find("a").hover(blogcastrOnExpandableHeaderLinkHoverOn, blogcastrOnExpandableHeaderLinkHoverOff);
}

function blogcastrPostComment(id)
{
  jQuery.post("/comment_posts?comment_id=" + id + "&from=Web" + "&authenticity_token=" + encodeURIComponent(authenticity_token));
}

function blogcastrSendMucPresence()
{
    //MVR - nickname is always username
    mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/dashboard"}).c("x", {xmlns: "http://jabber.org/protocol/muc"});
    connection.send(mucPresenceStanza);
}

function blogcastrSendMucPresenceUnavailable()
{
    //MVR - nickname is always username
    mucPresenceStanza = $pres().attrs({from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/dashboard", type: "unavailable"});
    connection.send(mucPresenceStanza);
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
   // console.log('----------> Strophe is connected.' );
    //MVR - register message handlers 
    connection.addHandler(blogcastrCommentCallback, null, 'message', 'chat', null, null);
    connection.addHandler(blogcastrSubscriptionCallback, null, 'message', null, null, 'pubsub.blogcastr.com');
    //MVR - send presence for pubsub
    presenceStanza = $pres().attrs({from: connection.jid}).c("priority", {}).t("5");
    connection.send(presenceStanza);
    //MVR - send presence to muc
    blogcastrSendMucPresence();
  }
}

function blogcastrCommentCallback(stanza)
{
  //Prototype has no XML support using jQuery
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  //TODO: from needs to be parsed better or included in message
   console.log("received blogcastr event type: ");
  var from = jQuery(stanza).attr("from");
  var body = jQuery(stanza).find("body:first");
  var type = body.find("type:first").text();
  if (type == "comment")
  {
   console.log("received blogcastr event type comment ");
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
    if (jQuery("li.comment_stream_list_item[id=" + id + "]").length == 0)
  { console.log("received blogcastr event type comment ");
      jQuery("ol#comment-stream:first").prepend(li);
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

function blogcastrSubscriptionCallback(stanza)
{
  //Prototype has no XML support so using jQuery
  //TODO: alternative could be to use a json convertor like http://www.thomasfrank.se/xml_to_json.html
  var from = jQuery(stanza).find("items:first").attr("node");
  //var events = jQuery(stanza).find("event[xmlns='http://jabber.org/protocol/pubsub#event']:first").find("items[node='" + nodename + "']:first").find("event[xmlns='http://blogcastr.com']")
  var events = jQuery(stanza).find("event[xmlns='http://jabber.org/protocol/pubsub#event']:first").find("event[xmlns='http://blogcastr.com']")
    .each(function ()
    {
      var type = jQuery(this).find("type:first").text();
      if (type == null)
        console.log("blogcastr event type not defined");

//MVR - here I need to work with four types... text posts, image posts, comment posts, and reposts
//best place to start.... probably comment posts and then at least that piece of stuf will be working

      if (type == "textPost")
      {
        var id = jQuery(this).find("id:first").text();
        var date = jQuery(this).find("date:first").text();
        var text = jQuery(this).find("text:first").text();
        //create new comment element
        var p1 = jQuery("<p>").addClass("list_item_text").text(text);
        var p2 = jQuery("<p>").addClass("list_item_info").text("Posted by " + from + " on " + date);
        var li = jQuery("<li>").attr("id",id).append(p1).append(p2);
        //add comment to document if not present
        var post = jQuery("li[id='" + id + "']");
        if (jQuery("li.subscription_stream_list_item[id=" + id + "]").length == 0)
          jQuery("ol#subscription_stream_list:first").prepend(li);
      }
      else if (type == "imagePost")
      {
        var id = jQuery(this).find("id:first").text();
        var date = jQuery(this).find("date:first").text();
        var image_url = jQuery(this).find("image_url:first").text();
        //create new comment element
        var img = jQuery("<img>").attr("src",image_url);
        var p = jQuery("<p>").addClass("list_item_info").text("Posted by " + from + " on " + date);
        var li = jQuery("<li>").append(img).append(p).attr("id",id);
        //add comment to document if not present
        if (jQuery("li.subscription_stream_list_item[id=" + id + "]").length == 0)
          jQuery("ol#subscription_stream_list:first").prepend(li);
      }
      else
      {
     //   console.log("received unknown blogcastr event type: " + type);
      }
    });
  return true;
}

function blogcastrPostTextMenuSelect()
{
  jQuery("#post").find("li.selected").removeClass("selected");
  jQuery("#post").find("li.text").addClass("selected");
  //MVR - hide all forms and then display the text form
  jQuery("#post").find("form").addClass("hidden");
  jQuery("#post").find("form.text").removeClass("hidden");
}

function blogcastrPostImageMenuSelect()
{
  jQuery("#post").find("li.selected").removeClass("selected");
  jQuery("#post").find("li.image").addClass("selected");
  //MVR - hide all forms and then display the image form
  jQuery("#post").find("form").addClass("hidden");
  jQuery("#post").find("form.image").removeClass("hidden");
}

function blogcastrCommentStreamMenuSelect()
{
  jQuery("#streams-menu").find("li.selected").removeClass("selected");
  jQuery("#streams-menu").find("li.comments").addClass("selected");
  //MVR - hide all streams and then display the comment stream
  jQuery(".stream").addClass("hidden");
  jQuery("#comment-stream").removeClass("hidden");
}

function blogcastrSubscriptionStreamMenuSelect()
{
  jQuery("#streams-menu").find("li.selected").removeClass("selected");
  jQuery("#streams-menu").find("li.subscriptions").addClass("selected");
  //MVR - hide all streams and then display the comment stream
  jQuery(".stream").addClass("hidden");
  jQuery("#subscription-stream").removeClass("hidden");
}

Strophe.log = function(log, msg)
{
  //console.log(msg);
}

window.addEventListener("load", blogcastrOnLoad, false);
