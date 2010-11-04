//MVR - is a remote request pending
var remote_request = false;

function blogcastrOnLoad()
{
  //MVR - determine clock offset
  //TODO: we could do much better but since we are only going for sub-minute synchronization it's not a big deal 
  var client_date = new Date;
  client_timestamp = Math.floor(client_date.getTime()/1000);
  //MVR - every second update timers
  setInterval(blogcastrUpdateHoursMinutesAgo, 1000);
  //MVR - avatar popup 
  //jQuery(".avatar-small").hoverIntent(
  //function (event) {
  //var x = event.pageX;
  //var y = event.pageY;
  //  user_name = jQuery(this).attr("alt");
  //  h5 = jQuery("<h5>").addClass("avatar-small").attr("style","left: "+x+"px; top: "+y+"px;").text(user_name);
    ////jQuery("body:first").prepend(h5);
  //},
  //function () {
//jQuery("h5.avatar-small").remove();
  //}
//);
  //preload images
  var i = 0;
  //image list
  image_array = new Array();
  image_array[0] = up_image;
  image_array[1] = email_add_image;
  image_array[2] = email_delete_image;
  image_array[3] = sms_add_image;
  image_array[4] = sms_delete_image;
  //preload
  for(i = 0; i < image_array.length; i++)
  {
    image = new Image();
    image.src = image_array[i];
  }
}

window.addEventListener("load", blogcastrOnLoad, false);
