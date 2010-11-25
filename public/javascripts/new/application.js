//MVR - is a remote request pending
var remote_request = false;

function blogcastrLog(message) {
  if (typeof(console) != "undefined")
    console.log(message);
}

function blogcastClick() {
  window.location = jQuery(this).attr("blogcast-permalink");
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
