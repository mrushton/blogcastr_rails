module BlogcastsHelper
  def select_hour_helper(time, id)
    #MVR - convert hour to 12 hour clock 
    if time.hour == 0
      hour = 12
    elsif time.hour < 12
      hour = time.hour
    elsif time.hour == 12
      hour = 12
    elsif
      hour = time.hour - 12
    end
    select = "<select id=\"#{id}\">"
    for i in 1..12
      if i == hour
        select = select + "<option value=\"#{i}\" selected=\"selected\">#{i}</option>"
      else
        select = select + "<option value=\"#{i}\">#{i}</option>"
      end 
    end
    select = select + "</select>"
  end

  def select_12_hour_clock_period_helper(time, id)
    select = "<select id=\"#{id}\">"
    #MVR - midnight is 12am and noon is 12pm
    if time.hour < 12
      select = select + "<option value=\"am\" selected=\"selected\">am</option><option value=\"pm\">pm</option>"
    else
      select = select + "<option value=\"am\">am</option><option value=\"pm\" selected=\"selected\">pm</option>"
    end
    select = select + "</select>"
  end
end
