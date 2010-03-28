var is_featured_animating = false;
var is_left_arrow_animating = false;
var is_right_arrow_animating = false;
var left_arrow_effect;
var right_arrow_effect;
var animate_interval;
var num_featured;

function blogcastrOnLoad()
{
  //MVR - number of featured users
  num_featured = jQuery("#featured-list").children().size();
  //MVR - every five seconds
  animate_interval = setInterval(blogcastrAnimateFeatured, 3000);
  //MVR - hover intent
  jQuery("#right").hoverIntent(blogcastrStopAnimatingFeatured, blogcastrStartAnimatingFeatured);
}

function blogcastrAfterAnimateFeatured()
{
  is_featured_animating = false;
}

function blogcastrAfterAnimateFeaturedLeft()
{
  is_featured_animating = false;
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (pos == num_featured - 1)
    jQuery("#right-arrow").hide();
  jQuery("#left-arrow").show();
}

function blogcastrAfterAnimateFeaturedRight()
{
  is_featured_animating = false;
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (pos == 0)
    jQuery("#left-arrow").hide();
  jQuery("#right-arrow").show();
}

function blogcastrAfterAnimateLeftArrow()
{
  is_left_arrow_animating = false;
}

function blogcastrAfterAnimateRightArrow()
{
  is_right_arrow_animating = false;
}

function blogcastrStopAnimatingFeatured()
{
  is_featured_animating = false;
  clearInterval(animate_interval);
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (pos != 0)
  {
    is_left_arrow_animating = true;
    left_arrow_effect = new Effect.Appear("left-arrow", {duration: 0.5, afterFinish: blogcastrAfterAnimateLeftArrow});
  }
  if (pos != num_featured - 1)
  {
    is_right_arrow_animating = true;
    right_arrow_effect = new Effect.Appear("right-arrow", {duration: 0.5, afterFinish: blogcastrAfterAnimateRightArrow});
  }
}

function blogcastrStartAnimatingFeatured()
{
  //MVR - cancel arrow animations hide them
  if (is_left_arrow_animating == true)
    left_arrow_effect.cancel();
  if (is_right_arrow_animating == true)
    right_arrow_effect.cancel();
  jQuery("#right div.arrow").hide();
  //MVR - move featured every five seconds 
  animate_interval = setInterval(blogcastrAnimateFeatured, 3000);
}

function blogcastrAnimateFeatured()
{
  if (is_featured_animating == true)
    return;
  is_featured_animating = true;
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (pos == num_featured - 1)
    new Effect.Move("featured-list", {x: 340*pos, y: 0, mode: 'relative', duration: 0.5, afterFinish: blogcastrAfterAnimateFeatured});
  else
    new Effect.Move("featured-list", {x: -340, y: 0, mode: 'relative', duration: 0.5, afterFinish: blogcastrAfterAnimateFeatured});
}

function blogcastrAnimateFeaturedLeft()
{
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (is_featured_animating == true || pos == num_featured - 1)
    return;
  is_featured_animating = true;
  new Effect.Move("featured-list", {x: -340, y: 0, mode: 'relative', duration: 0.5, afterFinish: blogcastrAfterAnimateFeaturedLeft});
}

function blogcastrAnimateFeaturedRight()
{
  var left = jQuery("#featured-list").position().left;
  //MVR - subtract 5 for padding
  var pos = Math.abs(left - 5) / 340;
  if (is_featured_animating == true || pos == 0)
    return;
  is_featured_animating = true;
  new Effect.Move("featured-list", {x: 340, y: 0, mode: 'relative', duration: 0.5, afterFinish: blogcastrAfterAnimateFeaturedRight});
}

window.addEventListener("load", blogcastrOnLoad, false);
