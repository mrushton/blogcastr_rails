var calendar;

function blogcastrOnLoad()
{
  jQuery("#blogcast_starting_at_2i").change(blogcastrCalendarChange);
  jQuery("#blogcast_starting_at_3i").change(blogcastrCalendarChange);
  jQuery("#blogcast_starting_at_1i").change(blogcastrCalendarChange);
  //MVR - YUI calender
  timestamp = new Date();
  calendar = new YAHOO.widget.Calendar("calendar", { mindate: timestamp }); 
  calendar.render();
  calendar.selectEvent.subscribe(blogcastrCalendarEvent, calendar, true);
  //MVR - hide calendar
  jQuery("body").click(blogcastrHideCalendar);
  jQuery("#calendar").click(blogcastrStopHideCalendar);
  jQuery("#blogcast_starting_at_12_hour_clock_hour").change(blogcastrHourChange);
  jQuery("#blogcast_starting_at_12_hour_clock_period").change(blogcastrHourChange);
}

function blogcastrCalendarChange()
{
  var month = jQuery("#blogcast_starting_at_2i").val(); 
  var day = jQuery("#blogcast_starting_at_3i").val();
  var year = jQuery("#blogcast_starting_at_1i").val();
  calendar.cfg.setProperty("selected", month + "/" + day + "/" + year);
  calendar.render();
}

//MVR - calendar events from YUI
function blogcastrCalendarEvent(type, args, obj)
{
  var selected = args[0];
  var timestamp = this.toDate(selected[0]);
  jQuery("#blogcast_starting_at_1i").val(timestamp.getFullYear());
  jQuery("#blogcast_starting_at_2i").val(timestamp.getMonth() + 1);
  jQuery("#blogcast_starting_at_3i").val(timestamp.getDate());
}

//MVR - hide the calendar if it is visible
function blogcastrHideCalendar(event)
{
  var display = jQuery("#calendar").css("display");
  if (display != "none")
    jQuery("#calendar").hide();
}

//MVR - do not hide the calendar if the click is inside it
function blogcastrStopHideCalendar(event)
{
  event.stopPropagation();
}

//MVR - updates the hidden hour input if either of the two 12 hour clock fields change 
function blogcastrHourChange()
{
  var hour = jQuery("#blogcast_starting_at_12_hour_clock_hour").val(); 
  var period = jQuery("#blogcast_starting_at_12_hour_clock_period").val();
  if (period == "am")
  {
    if (hour == 12)
      jQuery("#blogcast_starting_at_4i").val(0);
    else
      jQuery("#blogcast_starting_at_4i").val(hour);
  }
  else
  {
    if (hour == 12)
      jQuery("#blogcast_starting_at_4i").val(12);
    else
      jQuery("#blogcast_starting_at_4i").val(parseInt(hour, 10) + 12);
  }
}

window.addEventListener("load", blogcastrOnLoad, false);
