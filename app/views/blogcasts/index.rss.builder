xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @possesive_username + " blogcasts"
    xml.description @possesive_full_name + "Blogcastr RSS feed."
    xml.link profile_url :username => @user.username 
    for blogcast in @blogcasts
      xml.item do
        xml.title blogcast.title
        xml.description blogcast.description
        if (!blogcast.starting_at.nil?)
          xml.pubDate blogcast.starting_at.to_s(:rfc822)
        else
          xml.pubDate blogcast.created_at.to_s(:rfc822)
        end
        xml.link blogcast_permalink_url(:username => @user.username, :year => blogcast.year, :month => blogcast.month, :day => blogcast.day, :title => blogcast.link_title)
      end
    end
  end
end
