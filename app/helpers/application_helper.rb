# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def reposted_via_helper(ancestors)
    reposted_via = nil
    for ancestor in ancestors
      if ancestor.id != ancestors.last.id || ancestor.instance_of?(CommentPost)
        if reposted_via.nil?
          reposted_via = link_to ancestor.blogcast.user.name, blogcast_path(:username => ancestor.blogcast.user.name), :target => "_blank"
        else
          reposted_via = reposted_via + ", " + link_to(ancestor.blogcast.user.name, blogcast_path(:username => ancestor.blogcast.user.name), :target => "_blank")
        end
      end
    end
    reposted_via
  end

  #MVR - returns markup with either the elapsed time or a timestamp
  def hours_minutes_ago_helper(time)
    elapsed_time = Time.now - time
    #MVR - less than 24 hours use hours and minutes ago past 24 hours use date
    if elapsed_time <= 24.hours 
      hours = (elapsed_time / 1.hour).floor
      minutes = ((elapsed_time - (hours * 1.hour)) / 1.minute).floor
      hours_minutes_ago = nil
      if hours > 0
        if hours == 1
          hours_minutes_ago = "1 hour";
        else
          hours_minutes_ago = hours.to_s + " hours";
        end
        if minutes == 0
          hours_minutes_ago = hours_minutes_ago + " ago";
        elsif minutes == 1
          hours_minutes_ago = hours_minutes_ago + ", 1 minute ago";
        else
          hours_minutes_ago = hours_minutes_ago + ", " + minutes.to_s + " minutes ago";
        end
      else
        if minutes == 0
          hours_minutes_ago = "less than 1 minute ago";
        elsif (minutes == 1)
          hours_minutes_ago = "1 minute ago";
        else
          hours_minutes_ago = minutes.to_s + " minutes ago";
        end
      end
      return "<span class=\"date hours_minutes_ago\" timestamp=\"" + time.to_i.to_s + "\">" + hours_minutes_ago + "</span>"
    else
      return "<span class=\"date\">" + time.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/,' ') + "</span>"
    end
  end

  #MVR - returns a human readable start time
  def starting_at_in_words(time)
    current_time = Time.now
    current_day = current_time.year*365+current_time.yday
    current_wday = current_time.wday
    starting_at_day = time.year*365+time.yday
    starting_at_wday = time.wday
    if current_day > starting_at_day
      if current_day == starting_at_day+1
        time.strftime("Yesterday at %I:%M %p %Z").gsub(/ 0/,' ')
      else
        #MVR - within the past week
        if current_day < starting_at_day+7
          #MVR - within this calender week
          if current_wday > starting_at_wday
            time.strftime("This %a at %I:%M %p %Z").gsub(/ 0/,' ')
          else
            time.strftime("This past %a at %I:%M %p %Z").gsub(/ 0/,' ')
          end
        else
          #MVR - within the previous calender week
          if current_day < starting_at_day+14 && current_wday >= starting_at_wday
            time.strftime("Last %a at %I:%M %p %Z").gsub(/ 0/,' ')
          else
            time.strftime("%a %m/%d/%y %I:%M %p %Z").gsub(/ 0/,' ')
          end
        end
      end
    else
      if current_day == starting_at_day
        time.strftime("Today at %I:%M %p %Z").gsub(/ 0/,' ')
      else
        if current_day == starting_at_day-1
          time.strftime("Tomorrow at %I:%M %p %Z").gsub(/ 0/,' ')
        else
          #MVR - within the coming week
          if current_day > starting_at_day+7
            #MVR - within this calender week
            if current_wday < starting_at_wday
              time.strftime("This %a at %I:%M %p %Z").gsub(/ 0/,' ')
            else
              time.strftime("This coming %a at %I:%M %p %Z").gsub(/ 0/,' ')
            end
          else
            #MVR - within the next calender week
            if current_day < starting_at_day+14 && current_wday >= starting_at_wday
              time.strftime("Next %a at %I:%M %p %Z").gsub(/ 0/,' ')
            else
              time.strftime("%a %m/%d/%y %I:%M %p %Z").gsub(/ 0/,' ')
            end
          end
        end
      end
    end
  end

  #MVR - for facebook users with a private profile, needs to be a helper because models can not access facebook session
  #TODO: handle the case of logging out of facebook while at site
  def get_facebook_avatar_url(facebook_id)
    if !session[:facebook_avatar_url].nil?
      session[:facebook_avatar_url]
    else
      if !facebook_session.nil?  
        facebook_avatar_url = facebook_session.fql_query("SELECT pic_square_with_logo FROM user WHERE uid = " + facebook_id.to_s)[0].pic_square_with_logo 
        session[:facebook_avatar_url] = facebook_avatar_url
      else
        nil
      end
    end
  end

  def get_facebook_name(facebook_id)
    if !session[:facebook_name].nil?
      session[:facebook_name]
    else
      if !facebook_session.nil?  
        facebook_name = facebook_session.fql_query("SELECT name FROM user WHERE uid = " + facebook_id.to_s)[0].name
        session[:facebook_name] = facebook_name
      else
        nil
      end
    end
  end
end
