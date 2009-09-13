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
