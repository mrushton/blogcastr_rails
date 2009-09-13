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
      return "<span class=\"hours_minutes_ago\" timestamp=\"" + time.to_i.to_s + "\">" + hours_minutes_ago + "</span>"
    else
      return time.strftime("%b %d, %Y %I:%M %p %Z").gsub(/ 0/,' ')
    end
  end
end
