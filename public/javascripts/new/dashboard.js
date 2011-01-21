function onConnect(status, error) {
  if (status == Strophe.Status.CONNECTING) {
    blogcastrLog("strophe connecting");
  }
  else if (status == Strophe.Status.CONNFAIL) {
    blogcastrLog("strophe connection failed");
  }
  else if (status == Strophe.Status.DISCONNECTING) {
    blogcastrLog("strophe disconnecting");
  }
  else if (status == Strophe.Status.AUTHENTICATING) {
    blogcastrLog("strophe authenticating");
  }
  else if (status == Strophe.Status.AUTHFAIL) {
    blogcastrLog("stophe authentication failed");
  }
  else if (status == Strophe.Status.DISCONNECTED) {
    blogcastrLog("strophe disconnected");
  }
  else if (status == Strophe.Status.CONNECTED) {
    blogcastrLog("strophe connected");
    //MVR - set jid resource
    //TODO: hack for now
    jQuery("input[id='jid']").attr("value", connection.jid);
    //MVR - register message handlers 
    connection.addHandler(blogcastrPostCallback, null, 'message', 'groupchat', null, null);
    //MVR - join muc, nickname is resource 
    mucPresenceStanza = $pres().attrs({ from: connection.jid, to: "Blogcast." + blogcast_id + "@conference." + hostname + "/" + Strophe.getResourceFromJid(connection.jid) }).c("x", { xmlns: "http://jabber.org/protocol/muc" });
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
    var post_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var text_p = jQuery("<p>").addClass("text").text(text);
    var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    //post container for animation 
    var post_container_div = jQuery("<div>").append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#Post\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, { duration: 0.6, queue: "end" });
      new Effect.Appear("Post\:" + id, { duration: 0.6, queue: "end" });
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
    var post_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
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
    var post_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    var post_container_div = jQuery("<div>").addClass("spacer").append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#Post\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, {duration: 0.6, queue: "end"});
      new Effect.Appear("Post\:" + id, {duration: 0.6, queue: "end"});
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
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
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
    var info_h4 = jQuery("<h4>").click(function() { blogcastrCollapsibleEvent(this, "Post:" + id + "-info"); }).append("Info").append(up_img);
    var info_p = jQuery("<p>").addClass("info").text("Posted by " + username + " on " + date + " from " + medium);
    var info_div = jQuery("<div>").attr("id", "Post:" + id + "-info").css("display", "none").append(info_p);
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
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("timestamp", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var post_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", comment_avatar_url);
    var avatar_a = jQuery("<a>").attr("href", comment_url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", comment_url).text(comment_username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var text_p = jQuery("<p>").addClass("text").text(text);
    var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    //post container for animation 
    var post_container_div = jQuery("<div>").append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#Post\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, { duration: 0.6, queue: "end" });
      new Effect.Appear("Post\:" + id, { duration: 0.6, queue: "end" });
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
    //comment header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("timestamp", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var comment_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //comment body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var text_p = jQuery("<p>").addClass("text").text(text);
    var comment_info_div = jQuery("<div>").addClass("comment-info").append(username_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(comment_info_div);
    var comment_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    //comment container for animation 
    var comment_container_div = jQuery("<div>").append(comment_header_div).append(comment_body_div);
    var comment_li = jQuery("<li>").attr("id", "Comment:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(comment_container_div);
    //add comment to document if not present
    if (jQuery("#Comment\\:" + id).length == 0) {
      jQuery("#comments").prepend(comment_li);
      new Effect.SlideDown("Comment\:" + id, { duration: 0.5, queue: "end" });
      new Effect.Appear("Comment\:" + id, { duration: 0.5, queue: "end" });
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


Strophe.log = function(log, msg) {
}

function clickTextPostButton() {
  jQuery("li.post-button").removeClass("selected");
  jQuery("div.post").hide();
  jQuery(this).addClass("selected");
  jQuery("#text-post").show();
}

function clickImagePostButton() {
  jQuery("li.post-button").removeClass("selected");
  jQuery("div.post").hide();
  jQuery(this).addClass("selected");
  jQuery("#image-post").show();
}

function clickPostTab() {
  jQuery("li.tab").removeClass("selected");
  jQuery("#comments").hide();
  jQuery(this).addClass("selected");
  jQuery("#posts").show();
}

function clickCommentTab() {
  jQuery("li.tab").removeClass("selected");
  jQuery("#posts").hide();
  jQuery(this).addClass("selected");
  jQuery("#comments").show();
}

jQuery(document).ready(function() {
  //MVR - attach click events
  jQuery('#text-post-button').click(clickTextPostButton);
  jQuery('#image-post-button').click(clickImagePostButton);
  jQuery('#posts-tab').click(clickPostTab);
  jQuery('#comments-tab').click(clickCommentTab);
  //MVR - create a BOSH connection with Strophe
  connection = new Strophe.Connection("/http-bind");  
  //MVR - connect with resource equal to dashboard
  connection.connect(username + "@" + hostname + "/dashboard", password, onConnect);
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timestamp in words
  setInterval(blogcastrUpdateTimeAgo, 1000);
  //MVR - preload images
  preloadImages([ "/images/new/ajax-loader.gif", "/images/new/tick.png" ]);
})
