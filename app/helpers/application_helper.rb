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

  def time_ago_helper(time)
    elapsed_time = Time.now - time
    days = (elapsed_time / 1.day).floor
    hours = (elapsed_time / 1.hour).floor
    time_ago = nil
    if days > 0
      if days == 1
        time_ago = "1 day ago";
      else
        time_ago = days.to_s + " days ago";
      end
    elsif hours > 0
      if hours == 1
        time_ago = "1 hour ago";
      else
        time_ago = hours.to_s + " hours ago";
      end
    else
      minutes = ((elapsed_time - (hours * 1.hour)) / 1.minute).floor
      if minutes == 0
        time_ago = "less than 1 minute ago";
      elsif (minutes == 1)
        time_ago = "1 minute ago";
      else
        time_ago = minutes.to_s + " minutes ago";
      end
    end
    return time_ago
    #return "<span class=\"date time\" timestamp=\"" + time.to_i.to_s + "\">" + time_ago + "</span>"
  end

  def time_from_now_helper(time)
    time_difference = time - Time.now
    days = (time_difference / 1.day).floor
    hours = (time_difference / 1.hour).floor
    time_from_now = nil
    if days > 0
      if days == 1
        time_from_now = "1 day from now";
      else
        time_from_now = days.to_s + " days from now";
      end
    elsif hours > 0
      if hours == 1
        time_from_now = "1 hour from now";
      else
        time_from_now = hours.to_s + " hours from now";
      end
    else
      minutes = ((time_difference - (hours * 1.hour)) / 1.minute).floor
      if minutes == 0
        time_from_now = "less than 1 minute from now";
      elsif (minutes == 1)
        time_from_now = "1 minute from now";
      else
        time_from_now = minutes.to_s + " minutes from now";
      end
    end
    #return "<span class=\"date time\" timestamp=\"" + time.to_i.to_s + "\">" + time_from_now + "</span>"
    return time_from_now
  end

  def time_helper(time)
    if (time > Time.now)
      return time_from_now_helper(time)
    else
      return time_ago_helper(time)
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
