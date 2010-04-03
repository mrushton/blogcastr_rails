disconnecting_facebook_account = false;
disconnecting_twitter_account = false;

function blogcastrOnLoad()
{
  //MVR - clear success alerts 
  setTimeout('blogcastrHideSuccessAlerts()', 3000);
  //MVR - set up color picker
  jQuery("#colorpicker").farbtastic("#setting_background_color");
}

function blogcastrHideSuccessAlerts()
{
  //MVR - hide success alerts if any exist 
  var element = jQuery("div.alert.success:first").get(0);
  if (element != null)
    new Effect.SlideUp(element, {duration: 0.5, queue: "end"});
}

function blogcastrSelectTheme(obj, id)
{
  //AS DESIGNED - hide everything and then display selected thumbnail 
  jQuery("img.thumbnail").removeClass("selected");
  jQuery(obj).addClass("selected");
  jQuery("#setting_theme_id").val(id);
}

function blogcastrFacebookConnectSuccess()
{
  //TODO: error handling
  //AS DESIGNED: reload page
  window.location.reload();
}

function blogcastrFacebookConnectError()
{
  alert('Error: Failed to connect your Facebook account.');
}

function blogcastrFacebookExtendedPermissionsCallback(permissions)
{
  if (permissions == "")
    return;
  //MVR - parse permissions and send POST
  var permissions_array = permissions.split(',');
  var has_publish_stream = 0;
  var has_create_event = 0;
  var has_offline_access = 0;
  jQuery.each(permissions_array, function(index, value) { if (value == "publish_stream") has_publish_stream = 1; else if (value == "create_event") has_create_event = 1; else if (value == "offline_access") has_offline_access = 1; })
  jQuery.ajax({type: "POST", url: "/facebook_connect", data: {'blogcastr_user[has_facebook_publish_stream]': has_publish_stream, 'blogcastr_user[has_facebook_create_event]': has_create_event, offline_access: has_offline_access, authenticity_token: authenticity_token}, success: blogcastrFacebookConnectSuccess, error: blogcastrFacebookConnectError});
}

function blogcastrFacebookExtendedPermissions()
{
  //MVR - ask user for extended permissions
  FB.Connect.showPermissionDialog("publish_stream,create_event,offline_access", blogcastrFacebookExtendedPermissionsCallback);
}

function blogcastrCheckTwitterOauth()
{
  if (twitter_sign_in_window.closed)
  {
    clearInterval(twitter_sign_in_interval);
  }
  else
  {
    //MVR - check if we are signed in or not
    var ret = jQuery(twitter_sign_in_window.document.body).find("#twitter-oauth").text();
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

function blogcastrTwitterOauth()
{
  //MVR - open window 
  twitter_sign_in_window = window.open("/twitter_oauth", "Twitter Sign In", "location=0, status=0, width=800, height=400");
  //MVR - check twitter sign in window every 1 second 
  twitter_sign_in_interval = setInterval(blogcastrCheckTwitterOauth, 1000);
}

window.addEventListener("load", blogcastrOnLoad, false);
