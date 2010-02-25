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

window.addEventListener("load", blogcastrOnLoad, false);
