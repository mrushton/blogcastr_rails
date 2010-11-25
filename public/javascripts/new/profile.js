function profileOnLoad() {
  //MVR - attach click events to blogcasts
  jQuery('li.blogcast').click(blogcastClick);
}

window.addEventListener("load", profileOnLoad, false);
