xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @blogcasts_user_name_possesive+" blogcasts"
    xml.description @blogcasts_user_settings_name_possesive+" blogcasts"
    xml.link profile_url :username => @blogcasts_user.name 
    for blogcast in @blogcasts
      xml.item do
        xml.title blogcast.title
        xml.description blogcast.description
        if (!blogcast.starting_at.nil?)
          xml.pubDate blogcast.starting_at.to_s(:rfc822)
        else
          xml.pubDate blogcast.created_at.to_s(:rfc822)
        end
        xml.link blogcast_permalink_url(:username => @blogcasts_user.name, :year => blogcast.year, :month => blogcast.month, :day => blogcast.day, :title => blogcast.link_title)
      end
    end
  end
end
