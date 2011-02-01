function mailtoClick() {
  window.location = jQuery(this).attr("href");
  return false;
}

jQuery(document).ready(function() {
  //MVR - this stops propagation of click events for the mailto links
  jQuery('a.mailto-link').click(mailtoClick);
})
