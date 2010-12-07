function profileOnLoad() {
  //MVR - attach click events
  jQuery('li.blogcast').click(blogcastClick);
}

window.addEventListener("load", profileOnLoad, false);
