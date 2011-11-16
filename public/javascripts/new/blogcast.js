Overlay = {
  isVisible: false,
  show: function() {
    jQuery("#overlay-container").show();
    jQuery("body").css("overflow", "hidden");
    //MVR - remove post info
    var overlay_post_info_elem = jQuery("#overlay-post-info");
    overlay_post_info_elem.empty();
    //MVR - add date string
    var post_date = Date.parse(Overlay.postDate);
    overlay_post_info_elem.append('<span id="overlay-date-string">' + post_date.toString("MMM d, yyyy h:mm tt") + "</span> &bull; ");
    //MVR - add Facebook like button
    var post_url = "http://" + window.location.hostname + blogcast_permalink + "/posts/" + Overlay.id;
    overlay_post_info_elem.append('<fb:like id="overlay-facebook-like" href="' + post_url + '" layout="button_count" send="true"></fb:like>');
    //MVR - add Tweet button iframe
    if (Overlay.type == "TextPost")
      var tweet_text = "Check out the post by " + Overlay.username + ' from "' + blogcast_title + '" via @Blogcastr'; 
    else if (Overlay.type == "ImagePost")
      var tweet_text = "Check out the photo by " + Overlay.username + ' from "' + blogcast_title + '" via @Blogcastr'; 
    else if (Overlay.type == "CommentPost")
      var tweet_text = "Check out the comment by " + Overlay.username + ' from "' + blogcast_title + '" via @Blogcastr'; 
    //MVR - the short url may not exist
    if (Overlay.shortUrl)
      tweet_iframe_url = "//platform.twitter.com/widgets/tweet_button.html?url=" + encodeURIComponent(Overlay.shortUrl) + "&text=" + encodeURIComponent(tweet_text) + "&counturl=" + encodeURIComponent(post_url);
    else
      tweet_iframe_url = "//platform.twitter.com/widgets/tweet_button.html?url=" + encodeURIComponent(post_url) + "&text=" + encodeURIComponent(tweet_text);
    overlay_post_info_elem.append('<iframe id="overlay-twitter-share" class="twitter-share-button" allowtransparency="true" frameborder="0" scrolling="no" src="' + tweet_iframe_url + '" style="width:130px; height:20px;"></iframe>');
    var overlay_post_container_elem = jQuery("#overlay-post-container");
    overlay_post_container_elem.empty();
    var overlay_post_content_elem = jQuery("<div>").attr("id", "overlay-post-content");
    overlay_post_content_elem.append('<div class="clearfix"><a href="' + Overlay.userUrl + '"><div id="overlay-post-avatar" class="small-rounded-avatar" style="background-image: url(\'' + Overlay.avatarUrl + '\')"></div></a><div id="overlay-username-container"><a class="username" href="' + Overlay.userUrl + '">' + Overlay.username + "</a></div></div>");
    //MVR - add the post
    if (Overlay.type == "TextPost") {
         var text_post_p = jQuery("<p>").attr("id", "overlay-text").text(Overlay.text);
      	 overlay_post_content_elem.append(text_post_p);
    } else if (Overlay.type == "ImagePost") {
      //MVR - get the max image size as a percent of the window size
      var image_post_img = jQuery("<img>").attr("id", "overlay-image").attr("src", Overlay.defaultImageUrl);
      overlay_post_content_elem.append(image_post_img);
      if (Overlay.text) {
         var image_post_p = jQuery("<p>").attr("id", "overlay-image-caption").text(Overlay.text);
      	 overlay_post_content_elem.append(image_post_p);
      }
      //MVR - load the large image
      Overlay.imageJqXHR = jQuery.get(Overlay.largeImageUrl, function() {
        jQuery("#overlay-image").attr("src", Overlay.largeImageUrl);
        Overlay.imageJqXHR = null;
      });
    } else if (Overlay.type == "CommentPost") {
         var comment_arrow = jQuery("<div>").attr("id", "overlay-comment-arrow");
      	 overlay_post_content_elem.append(comment_arrow);
         var comment_post_p = jQuery("<p>").attr("id", "overlay-comment").text(Overlay.text);
      	 overlay_post_content_elem.append(comment_post_p);
    }
    overlay_post_container_elem.append(overlay_post_content_elem);
    //MVR - do Facebook parsing
    FB.XFBML.parse(document.getElementById("#overlay"));
    Overlay.resize();
    Overlay.isVisible = true;
  },
  hide: function() {
    Overlay.isVisible = false;
    if (Overlay.imageJqXHR) {
      Overlay.imageJqXHR.abort();
      Overlay.imageJqXHR = null;
    }
    jQuery("body").css("overflow", "visible");
    jQuery("#overlay-container").hide();
  },
  resize: function() {
    if (Overlay.type == "ImagePost") {
      //MVR - get the max image size as a percent of the window size
      var max_image_width = jQuery(window).width() * 0.8;
      var max_image_height = jQuery(window).height() * 0.7;
      var image_width = Overlay.imageWidth;
      var image_height = Overlay.imageHeight;
      if (image_width > max_image_width) {
        image_height = max_image_width * image_height / image_width; 
        image_width = max_image_width;
      }
      if (image_height > max_image_height) {
        image_width = max_image_height * image_width / image_height; 
        image_height = max_image_height;
      }
      //MVR - do not let image get smaller than the default
      if (image_width < Overlay.defaultImageWidth || image_height < Overlay.defaultImageHeight) {
        image_width = Overlay.defaultImageWidth;
        image_height = Overlay.defaultImageHeight;
      }
      //MVR - and don't let it get larger than the large image either
      if (image_width > 1000.0) {
        image_height = image_height * 1000.0 / image_width;
        image_width = 1000.0;
      }
      if (image_height > 700.0) {
        image_width = image_width * 700.0 / image_height;
        image_height = 700.0;
      }
      jQuery("#overlay-post-content").width(image_width);
      jQuery("#overlay-image").width(image_width);
      jQuery("#overlay-image").height(image_height);
    }
  }
};

var can_play_audio = false;
var can_play_mp3 = false;
var can_play_ogg = false;

function blogcastrOnLoad()
{
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
  if (type == "TextPost") {
    //parse text post
    var id = body.find("id:first").text();
    var timestamp = body.find("created-at:first").text();
    var text = body.find("text:first").text();
    var short_url = body.find("short-url:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var user_url = user.find("url:first").text();
    var avatar_url = user.find("avatar-url:first").text().replace("original", "small"); 
    //create new post element
    var post_a = jQuery("<a>").attr("href", blogcast_permalink + "/posts/" + id).addClass("item").attr("data-avatar-url", avatar_url).attr("data-date", timestamp).attr("data-id", id).attr("data-short-url", short_url).attr("data-type", "TextPost").attr("data-text", text).attr("data-user-url", user_url).attr("data-username", username); 
    jQuery(post_a).click(blogcastrPostClick);
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("data-date", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var post_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", user_url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", user_url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var text_p = jQuery("<p>").addClass("text").text(text);
    var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    //post container for animation 
    var post_container_div = jQuery("<div>").append(post_a).append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(post_container_div);
    if (jQuery("#Post\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, { duration: 0.6, queue: "end" });
      new Effect.Appear("Post\:" + id, { duration: 0.6, queue: "end" });
    }
  }
  else if (type == "ImagePost") {
    //parse image post
    var id = body.find("id:first").text();
    var timestamp = body.find("created-at:first").text();
    var text = body.find("text:first").text();
    var short_url = body.find("short-url:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var user_url = user.find("url:first").text();
    var avatar_url = user.find("avatar-url:first").text().replace("original", "small");
    var image_url = body.find("image-url:first").text().replace("original", "default");
    var large_image_url = body.find("image-url:first").text().replace("original", "large");
    var image_width = body.find("image-width:first").text();
    var image_height = body.find("image-height:first").text();
    //create new post element
    var post_a = jQuery("<a>").attr("href", blogcast_permalink + "/posts/" + id).addClass("item").attr("data-avatar-url", avatar_url).attr("data-date", timestamp).attr("data-id", id).attr("data-short-url", short_url).attr("data-type", "ImagePost").attr("data-image-url", large_image_url).attr("data-image-width", image_width).attr("data-image-height", image_height).attr("data-user-url", user_url).attr("data-username", username); 
    if (text)
      post_a.attr("data-text", text);
    jQuery(post_a).click(blogcastrPostClick);
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("data-date", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var post_header_div = jQuery("<div>").addClass("item-header").append(timestamp_in_words_span);
    //post body
    var avatar_img = jQuery("<img>").addClass("small-avatar").attr("src", avatar_url);
    var avatar_a = jQuery("<a>").attr("href", user_url).append(avatar_img); 
    var username_a = jQuery("<a>").addClass("username").attr("href", user_url).text(username); 
    var username_div = jQuery("<div>").addClass("username").append(username_a); 
    var image_img = jQuery("<img>").addClass("image").attr("src", image_url);
    var caption_p = jQuery("<p>").addClass("caption").text(text);
    if (typeof(caption_p) == "undefined")
      var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(image_img).append(caption_p);
    else
      var post_info_div = jQuery("<div>").addClass("post-info").append(username_div).append(image_img).append(caption_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(post_info_div);
    var post_body_div = jQuery("<div>").addClass("item-body").append(clearfix_div);
    var post_container_div = jQuery("<div>").addClass("spacer").append(post_a).append(post_header_div).append(post_body_div);
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
    //parse audio media
    var id = body.find("id:first").text();
    var mp3_url = body.find("mp3_url:first").text();
    var ogg_url = body.find("ogg_url:first").text();

  }
  else if (type == "CommentPost")
  {
    //parse text post
    var id = body.find("id:first").text();
    var timestamp = body.find("created-at:first").text();
    var text = body.find("text:first").text();
    var short_url = body.find("short-url:first").text();
    var medium = body.find("medium:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
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
    var comment_avatar_url = comment_user.find("avatar-url:first").text().replace("original", "small");
    //create new post element
    var post_a = jQuery("<a>").attr("href", blogcast_permalink + "/posts/" + id).addClass("item").attr("data-avatar-url", comment_avatar_url).attr("data-date", timestamp).attr("data-id", id).attr("data-short-url", short_url).attr("data-type", "CommentPost").attr("data-text", text).attr("data-user-url", comment_url).attr("data-username", comment_username); 
    jQuery(post_a).click(blogcastrPostClick);
    //post header
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("data-date", timestamp).text(blogcastrPastTimestampInWords(timestamp));
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
    var post_container_div = jQuery("<div>").append(post_a).append(post_header_div).append(post_body_div);
    var post_li = jQuery("<li>").attr("id", "Post:" + id).addClass("item").css("display", "none").css("opacity", "0.0").append(post_container_div);
    //add post to document if not present
    if (jQuery("#Post\\:" + id).length == 0) {
      jQuery("#posts").prepend(post_li);
      new Effect.SlideDown("Post\:" + id, { duration: 0.6, queue: "end" });
      new Effect.Appear("Post\:" + id, { duration: 0.6, queue: "end" });
    }
  }
  else if (type == "Comment") {
   //parse comment
    var id = body.find("id:first").text();
    var timestamp = body.find("created-at:first").text();
    var text = body.find("text:first").text();
    var user = jQuery(body).find("user:first");
    var username = user.find("username:first").text();
    var url = user.find("url:first").text();
    var avatar_url = user.find("avatar-url:first").text().replace("original", "small");
    //create new comment element
    var avatar_div = jQuery("<div>").addClass("comment-avatar").addClass("small-rounded-avatar").css("background-image", "url(\"" + avatar_url + "\")"); 
    var avatar_a = jQuery("<a>").attr("href", url).append(avatar_div); 
    var username_a = jQuery("<a>").addClass("username").attr("href", url).text(username); 
    var timestamp_in_words_span = jQuery("<span>").addClass("timestamp-in-words").attr("data-date", timestamp).text(blogcastrPastTimestampInWords(timestamp));
    var username_timestamp_container_div = jQuery("<div>").addClass("username-and-timestamp-in-words-container").append(username_a).append(" ").append(timestamp_in_words_span);
    var text_p = jQuery("<p>").addClass("text").text(text);
    var comment_info_div = jQuery("<div>").addClass("comment-info").append(username_timestamp_container_div).append(text_p);
    var clearfix_div = jQuery("<div>").addClass("clearfix").append(avatar_a).append(comment_info_div);
    var comment_li = jQuery("<li>").addClass("small-comment").attr("id", "Comment:" + id).css("display", "none").css("opacity", "0.0").append(clearfix_div);
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

Strophe.log = function(log,message)
{
    blogcastrLog(message);
}

function blogcastrPrintStanza(stanza)
{
//  var string = (new XMLSerializer()).serializeToString(stanza);
}

function blogcastrPostClick() {
    var history = window.History;
    if (!history.enabled)
      return true;
    Overlay.id  = jQuery(this).attr("data-id");
    Overlay.type  = jQuery(this).attr("data-type");
    Overlay.postDate = jQuery(this).attr("data-date");
    Overlay.username = jQuery(this).attr("data-username");
    Overlay.userUrl = jQuery(this).attr("data-user-url");
    Overlay.avatarUrl = jQuery(this).attr("data-avatar-url");
    Overlay.text = jQuery(this).attr("data-text");
    Overlay.shortUrl = jQuery(this).attr("data-short-url");
    if (Overlay.type == "ImagePost") {
      var image_elem = jQuery(this).parent().find("img.image");
      Overlay.defaultImageUrl = image_elem.get(0).src;
      Overlay.defaultImageWidth = image_elem.width();
      Overlay.defaultImageHeight = image_elem.height();
      Overlay.largeImageUrl = jQuery(this).attr("data-image-url");
      Overlay.imageWidth = parseInt(jQuery(this).attr("data-image-width"));
      Overlay.imageHeight = parseInt(jQuery(this).attr("data-image-height"));
    }
    history.pushState(null, null, window.location + "/posts/" + Overlay.id);
    return false;
}

jQuery(document).ready(function() {
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
  //MVR - preload images
  preloadImages([ "/images/new/ajax-loader.gif", "/images/new/tick.png" ]);
  //MVR - attach click events
  jQuery("a.item").click(blogcastrPostClick);
  jQuery("#overlay").click(function() {
    return false;
  });
  jQuery("#overlay-close").click(function() {
    var history = window.History;
    history.back(); 
  });
  jQuery(window).resize(function() {
    if (Overlay.isVisible)
      Overlay.resize();  
  });
  jQuery("#overlay-container").click(function() {
    var history = window.History;
    history.back(); 
  });
  History.Adapter.bind(window, 'statechange', function() {
    //MVR - either hide or show the overlay
    if (Overlay.isVisible)
      Overlay.hide();
    else
      Overlay.show();
  });
});
