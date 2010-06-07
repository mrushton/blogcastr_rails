function blogcastrOnLoad()
{
  //MVR - add document click handler
  jQuery(document).click(blogcastrClickEvent);
  //MVR - add popup click handler
  jQuery(".popup").click(blogcastrPopupEvent);
}

window.addEventListener("load", blogcastrOnLoad, false);
