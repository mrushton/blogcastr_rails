var is_carousel_animating = false;
var carousel_animation_interval;
var z_index = 100;

function siteOnLoad() {
  //MVR - attach click events
  jQuery('div.carousel-button').click(carouselButtonClick);
  jQuery('li.blogcast').click(blogcastClick);
  //TODO: play with hoverIntent settings
  //MVR - carousel hovering 
  jQuery("#carousel-container").hoverIntent(stopCarousel, startCarousel);
  //MVR - avatar hovering
  jQuery("div.large-rounded-avatar").hoverIntent(avatarIn, avatarOut);
  //TODO: make sure mouse is not inside carousel
  startCarousel();
}

function startCarousel() {
  //MVR - move carousel right every five seconds 
  carousel_animation_interval = setInterval(moveCarouselRight, 5000);
}

function stopCarousel() {
  //MVR - clear interval
  is_carousel_animating = false;
  clearInterval(carousel_animation_interval);
}

function moveCarouselToPos(pos) {
  if (is_carousel_animating == true)
    return;
  var left = jQuery("#carousel").position().left;
  var current_pos = Math.abs(left) / 470 + 1;
  if (current_pos == pos)
    return;
  is_carousel_animating = true;
  //MVR - set carousel button
  jQuery("div.carousel-button").removeClass("selected");
  jQuery("[button-id=" + pos + "]").addClass("selected");
  if (current_pos > pos)
    new Effect.Move("carousel", { x: 470 * (current_pos - pos), y: 0, mode: 'relative', duration: 0.5, afterFinish: afterMoveCarousel });
  else
    new Effect.Move("carousel", { x: -470 * (pos - current_pos), y: 0, mode: 'relative', duration: 0.5, afterFinish: afterMoveCarousel });
}

function moveCarouselRight() {
  var left = jQuery("#carousel").position().left;
  var current_pos = Math.abs(left) / 470 + 1;
  if (current_pos == 3)
    moveCarouselToPos(1);
  else
    moveCarouselToPos(current_pos + 1); 
}

function afterMoveCarousel() {
  is_carousel_animating = false;
}

function carouselButtonClick() {
  var button_id = jQuery(this).attr("button-id");
  moveCarouselToPos(button_id);
}

function avatarIn() {
  jQuery(this).css("z-index", z_index);
  z_index = z_index + 1;
}

function avatarOut() {
}

window.addEventListener("load", siteOnLoad, false);
