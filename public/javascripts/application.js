function blogcastrLog(message)
{
  if (typeof(console) != "undefined")
    console.log(message);
}

function blogcastrTimeAgo(timestamp)
{
  var current_client_date = new Date;
  var current_client_timestamp = Math.floor(current_client_date.getTime()/1000);
  var elapsed_time = current_client_timestamp - client_timestamp;
  var current_server_timestamp = server_timestamp + elapsed_time;
  var timestamp_elapsed_time = current_server_timestamp - timestamp;
  //current server timestamp is inherently a little slow
  if (timestamp_elapsed_time < 0)
    timestamp_elapsed_time = 0;
  var days = Math.floor(timestamp_elapsed_time/86400);
  var hours = Math.floor(timestamp_elapsed_time/3600);
  if (days > 0)
  {
    if (days == 1)
    {
      return "1 day ago";
    }
    else
    {
      return days + " days ago";
    }
  }
  else if (hours > 0)
  {
    if (hours == 1)
    {
      return "1 hour ago";
    }
    else
    {
      return hours + " hours ago";
    }
  }
  else
  {
    var minutes = Math.floor((timestamp_elapsed_time-hours*3600)/60);
    if (minutes == 0)
    {
      return "less than 1 minute ago";
    }
    else if (minutes == 1)
    {
      return "1 minute ago";
    }
    else
    {
      return minutes + " minutes ago";
    }
  }
}

function blogcastrUpdateTimeAgo()
{
  jQuery("span.time-ago")
    .each(function ()
    {
      var timestamp = jQuery(this).attr("timestamp");
      var time_ago = blogcastrTimeAgo(timestamp);
      //TODO - check before setting or not?
      var prev_time_ago = jQuery(this).text();
      if (time_ago != prev_time_ago)
        jQuery(this).text(time_ago);
    });
}

//MVR - not used it just looks too awkward, dates to be set to relative timestamps
function blogcastrSetLocaltime()
{
  //MVR - find all date spans and convert their GMT timestamps to a localtime string
  jQuery("span.date")
    .each(function ()
    {
      var timestamp = jQuery(this).attr("timestamp");
      var date = new Date;
      date.setTime(timestamp);
      jQuery(this).text(date.toDateString());
    });
}

function blogcastrFacebookSignInCallback()
{
  //TODO: error handling
  //AS DESIGNED: reload page
  window.location.reload();
}

function blogcastrFacebookSignOutCallback()
{
  //TODO: error handling
  //AS DESIGNED: reload page
  window.location.reload();
}

function blogcastrFacebookSignIn()
{
  //MVR - get facebook uid
  var api = FB.Facebook.apiClient;
  jQuery.post("/facebook_session", {facebook_id: api.get_session().uid, authenticity_token: authenticity_token}, blogcastrFacebookSignInCallback);
}

function blogcastrFacebookSignOut(err)
{
  //MVR - get facebook uid
  var api = FB.Facebook.apiClient;
  jQuery.post("/facebook_session", {facebook_id: facebook_id, authenticity_token: authenticity_token, _method: "delete"}, blogcastrFacebookSignOutCallback);
}

function blogcastrTwitterSignOutCallback()
{
  //TODO: error handling
  //AS DESIGNED: reload page
  window.location.reload();
}

function blogcastrCheckTwitterSignIn()
{
  if (twitter_sign_in_window.closed)
  {
    clearInterval(twitter_sign_in_interval);
  }
  else
  {
    //MVR - check if we are signed in or not
    var ret = jQuery(twitter_sign_in_window.document.body).find("#twitter-sign-in").text();
    if (ret == "success")
    {
      twitter_sign_in_window.close();
      //AS DESIGNED: reload page
      window.location.reload();
    }
    else if (ret == "failure")
    {
      twitter_sign_in_window.close();
      alert('Error: failed to connect Twitter account.');
    }
  }
}

function blogcastrTwitterSignIn()
{
  //MVR - open window 
  twitter_sign_in_window = window.open("/twitter_sign_in", "Twitter Sign In", "location=0, status=0, width=800, height=400");
  //MVR - check twitter sign in window every 1 second 
  twitter_sign_in_interval = setInterval(blogcastrCheckTwitterSignIn, 1000);
}

function blogcastrTwitterSignOut()
{
  jQuery.post("/twitter_sign_in", {authenticity_token: authenticity_token, _method: "delete"}, blogcastrTwitterSignOutCallback);
}

function blogcastrToggleBlindEffect(id)
{
  new Effect.toggle(id, 'blind', {duration: 0.25});
}

function blogcastrToggleSlideEffect(id)
{
  new Effect.toggle(id, 'slide', {duration: 0.25});
}

function blogcastrOnExpandableHeaderLinkClick(event)
{
  //MVR - stop the event from bubbling
  event.stopPropagation();
}

function blogcastrOnExpandableHeaderLinkHoverOn()
{
  //MVR - override the headers hover styles 
  jQuery(this.parentNode).addClass("no-hover");
}

function blogcastrOnExpandableHeaderLinkHoverOff()
{
  //MVR - revert the headers hover styles 
  jQuery(this.parentNode).removeClass("no-hover");
}

function blogcastrCollapsibleEvent(obj, id)
{
  //change the image
  //MVR - only change image if effect will run
  queue = Effect.Queues.get(id);
  if (queue.effects.length == 0)
  {
    img_src = jQuery(obj).children().filter("img").attr("src");
    if (img_src == up_image)
    {
      jQuery(obj).children().filter("img").attr("src", down_image);
    }
    else
    {
      jQuery(obj).children().filter("img").attr("src", up_image);
    }
  }
  //effect
  blogcastrToggleBlindEffect(id);
}

function blogcastrCollapsibleEvent2(obj, id)
{
  //change the image
  //MVR - only change image if effect will run
  queue = Effect.Queues.get(id);
  if (queue.effects.length == 0)
  {
    collapsible_state = jQuery(obj).hasClass("up");
    if (collapsible_state == true)
    {
      jQuery(obj).removeClass("up");
      jQuery(obj).addClass("down");
    }
    else
    {
      jQuery(obj).removeClass("down");
      jQuery(obj).addClass("up");
    }
  }
  //effect
  blogcastrToggleBlindEffect(id);
}

function blogcastrOverlayEvent(id)
{
  //effect
  blogcastrToggleHidden(id, "block");
}

function blogcastrToggleHidden(id, display)
{
  //TODO: make more general purpose with the display property
  if (jQuery("#" + id).css("display") == "none")
    jQuery("#" + id).css("display", display);
  else
    jQuery("#" + id).css("display", "none");
}

function blogcastrPageSelect(obj, section_id, page_id)
{
  //unselect current tab
  jQuery("#" + section_id).find(".tab.selected").removeClass("selected");
  //select tab
  jQuery(obj).addClass("selected");
  //AS DESIGNED - hide everything and then display selected page
  jQuery("#" + section_id).find("div.page").removeClass("selected");
  jQuery("#" + page_id).addClass("selected");
}

function blogcastrViewSelect(section_id, view_id)
{
  //AS DESIGNED - hide everything and then display selected view 
  jQuery("#" + section_id).find("div.view").removeClass("selected");
  jQuery("#" + view_id).addClass("selected");
}

//do not check username if it is blank
function blogcastrCheckUsername()
{
  val = jQuery('#blogcastr_user_username').val();
  if (val == '')
  {
    //hide images
    jQuery('#username img').hide();
    return false;
  } 
  else
  {
    return true;
  }
}

function blogcastrClickEvent()
{
  jQuery(".overlay").hide();
}

function blogcastrPopupEvent(event)
{
  //MVR - stop propogation of popup events so they do not get handled by document event handler
  //TODO: IE
  event.stopPropagation();
}
