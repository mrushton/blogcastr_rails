function blogcastrOnLoad()
{
  //MVR - determine user's timezone
  var date = new Date()
  var utc_offset = -date.getTimezoneOffset();
  $("input#utc_offset").attr("value", utc_offset);
}
window.addEventListener("load", blogcastrOnLoad, false);
