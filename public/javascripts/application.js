var twitter_sign_in_window;
var twitter_sign_in_interval;

function blogcastrHoursMinutesAgo(timestamp)
{
  var current_client_date = new Date;
  var current_client_timestamp = Math.floor(current_client_date.getTime()/1000);
  var elapsed_time = current_client_timestamp - client_timestamp;
  var current_server_timestamp = server_timestamp + elapsed_time;
  var timestamp_elapsed_time = current_server_timestamp - timestamp;
  //current server timestamp is inherently a little slow
  if (timestamp_elapsed_time < 0)
    timestamp_elapsed_time = 0;
  var hours = Math.floor(timestamp_elapsed_time/3600);
  var minutes = Math.floor((timestamp_elapsed_time-hours*3600)/60);
  var hours_minutes_ago;
  if (hours > 0)
  {
    if (hours == 1)
    {
      hours_minutes_ago = "1 hour";
    }
    else
    {
      hours_minutes_ago = hours + " hours";
    }
    if (minutes == 0)
    {
      hours_minutes_ago = hours_minutes_ago + " ago";
    }
    else if (minutes == 1)
    {
      hours_minutes_ago = hours_minutes_ago + ", 1 minute ago";
    }
    else
    {
      hours_minutes_ago = hours_minutes_ago + ", " + minutes + " minutes ago";
    }
  }
  else
  {
    if (minutes == 0)
    {
      hours_minutes_ago = "less than 1 minute ago";
    }
    else if (minutes == 1)
    {
      hours_minutes_ago = "1 minute ago";
    }
    else
    {
      hours_minutes_ago = minutes + " minutes ago";
    }
  }
  return hours_minutes_ago;
}

function blogcastrUpdateHoursMinutesAgo()
{
  jQuery("span.hours_minutes_ago")
    .each(function ()
    {
      var timestamp = jQuery(this).attr("timestamp");
      var hours_minutes_ago = blogcastrHoursMinutesAgo(timestamp);
      //TODO - check before setting or not?
      var prev_hours_minutes_ago = jQuery(this).text();
      if (hours_minutes_ago != prev_hours_minutes_ago)
        jQuery(this).text(hours_minutes_ago);
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
    var ret = jQuery(twitter_sign_in_window.document.body).find("span[id=twitter_sign_in]").text();
    if (ret == "success")
    {
      twitter_sign_in_window.close();
      //AS DESIGNED: reload page
      window.location.reload();
    }
  }
}

function blogcastrTwitterSignIn()
{
  //MVR - open window 
  twitter_sign_in_window = window.open("/twitter_oauth_init", "Twitter Sign In", "location=0, status=0, width=800, height=400");
  //MVR - check twitter sign in window every 1 second 
  twitter_sign_in_interval = setInterval(blogcastrCheckTwitterSignIn, 1000);
}

function blogcastrTwitterSignOut()
{
  jQuery.post("/twitter_session", {authenticity_token: authenticity_token, _method: "delete"}, blogcastrTwitterSignOutCallback);
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
