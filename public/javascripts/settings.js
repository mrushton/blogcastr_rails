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

window.addEventListener("load",blogcastrOnLoad,false);
