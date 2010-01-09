function blogcastrOnLoad()
{
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timers
  setInterval(blogcastrUpdateHoursMinutesAgo, 1000);
  //MVR - avatar popup 
  jQuery(".avatar-small").hoverIntent(
  function (event) {
  var x = event.pageX;
  var y = event.pageY;
    user_name = jQuery(this).attr("alt");
    h5 = jQuery("<h5>").addClass("avatar-small").attr("style","left: "+x+"px; top: "+y+"px;").text(user_name);
    //jQuery("body:first").prepend(h5);
  },
  function () {
jQuery("h5.avatar-small").remove();
  }
);



}

window.addEventListener("load", blogcastrOnLoad, false);
