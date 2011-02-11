//MVR - is a remote request pending
var remote_request = false;
//MVR - Facebook and Twitter sign in
var facebook_login_window;
var facebook_login_interval;
var twitter_sign_in_window;
var twitter_sign_in_interval;

function blogcastrLog(message) {
  if (typeof(console) != "undefined")
    console.log(message);
}

function itemClick() {
  var item_link = jQuery(this).attr("item-link");
  if (item_link != null)
    window.location = item_link;
}

function itemSettingsButtonClick() {
  jQuery(this).parents("li.item").find("ul.item-settings").toggle();
  return false;
}

function stopPropagation() {
  return false;
}

function blogcastrPastTimestampInWords(timestamp) {
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
  if (days > 0) {
    if (days == 1) {
      return "1 day ago";
    }
    else {
      return days + " days ago";
    }
  }
  else if (hours > 0) {
    if (hours == 1) {
      return "1 hour ago";
    }
    else {
      return hours + " hours ago";
    }
  }
  else {
    var minutes = Math.floor((timestamp_elapsed_time-hours*3600)/60);
    if (minutes == 0) {
      return "less than 1 minute ago";
    }
    else if (minutes == 1) {
      return "1 minute ago";
    }
    else {
      return minutes + " minutes ago";
    }
  }
}

function blogcastrUpdateTimestampInWords() {
  jQuery("span.timestamp-in-words")
    .each(function () {
      var timestamp = jQuery(this).attr("timestamp");
      var timestamp_in_words = blogcastrPastTimestampInWords(timestamp);
      //TODO - check before setting or not?
      var prev_timestamp_in_words = jQuery(this).text();
      if (timestamp_in_words != prev_timestamp_in_words)
        jQuery(this).text(timestamp_in_words);
    });
}

//do not check username if it is blank
function checkUsername() {
  val = jQuery('#blogcastr_user_username').val();
  if (val == '') {
    //hide background image
    jQuery('#pick-username-container').removeClass('loading valid invalid');
    return false;
  } 
  else {
    return true;
  }
}

function checkFacebookLogin() {
  if (facebook_login_window.closed)
    clearInterval(facebook_login_interval);
  //MVR - check if we are signed in or not
  var ret = jQuery("#facebook-login").text();
  if (ret == "0") {
    facebook_login_window.close();
    //AS DESIGNED: reload page
    window.location.reload();
    clearInterval(facebook_login_interval);
  }
  else if (ret == "1") {
    facebook_login_window.close();
    clearInterval(facebook_login_interval);
  }
  else if (ret == "2") {
    facebook_login_window.close();
    alert('Oops! Failed to login with Facebook account.');
    clearInterval(facebook_login_interval);
  }
}

function facebookLogin() {
  //MVR - open window 
  facebook_login_window = window.open("https://graph.facebook.com/oauth/authorize?client_id=" + facebook_client_id + "&redirect_uri=" + "http://" + hostname + "/facebook_login_redirect&display=popup", "Blogcastr -Blogcastr -  Facebook Login", "location=0, status=0, width=620, height=340");
  //MVR - check facebook login in window every 1 second 
  facebook_login_interval = setInterval(checkFacebookLogin, 1000);
}

function facebookLoginSecure() {
  //MVR - open window 
  facebook_login_window = window.open("https://graph.facebook.com/oauth/authorize?client_id=" + facebook_client_id + "&redirect_uri=" + "https://" + hostname + "/facebook_login_redirect&display=popup", "Blogcastr - Facebook Login", "location=0, status=0, width=620, height=340");
  //MVR - check facebook login in window every 1 second 
  facebook_login_interval = setInterval(checkFacebookLogin, 1000);
}

function checkTwitterSignIn() {
  if (twitter_sign_in_window.closed)
    clearInterval(twitter_sign_in_interval);
  //MVR - check if we are signed in or not
  var ret = jQuery("#twitter-sign-in").text();
  if (ret == "0") {
    //MVR - success
    twitter_sign_in_window.close();
    window.location.reload();
    clearInterval(twitter_sign_in_interval);
  }
  else if (ret == "1") {
    //MVR - failure
    twitter_sign_in_window.close();
    alert('Oops! Failed to sign in with Twitter account.');
    clearInterval(twitter_sign_in_interval);
  }
}

function twitterSignIn() {
  //MVR - open window 
  twitter_sign_in_window = window.open("/twitter_sign_in_init", "Blogcastr - Twitter Sign In", "location=0, status=0, width=800, height=420");
  //MVR - check twitter sign in window every 1 second 
  twitter_sign_in_interval = setInterval(checkTwitterSignIn, 1000);
}

function preloadImages(image_array) {
  //preload each image in the array images
  for(var i = 0; i < image_array.length; i++) {
    image = new Image();
    image.src = image_array[i];
  }
}

jQuery(document).ready(function() {
  //MVR - attach click events
  jQuery('li.item').click(itemClick);
  jQuery('div.item-settings-button').click(itemSettingsButtonClick);
  //MVR - this stops propagation of click events for the delete action 
  jQuery('a.destroy').click(stopPropagation);
})
