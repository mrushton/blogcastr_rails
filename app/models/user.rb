class User < ActiveRecord::Base
  include Clearance::User

  has_one :blogcast
  has_one :setting
  has_many :posts
  has_many :comments
  has_many :subscriptions
  has_many :subscribed_blogcasts, :through => :subscriptions, :source => :blogcasts

  def get_user_name
    return "Matt Rushton"
    if instance_of?(BlogcastrUser)
      name
    elsif instance_of?(FacebookUser)
      s = Facebooker::Session.create
      u = Facebooker::User.new(facebook_id, s)
      u.name
    elsif instance_of?(TwitterUser)
    else
    end
  end

  def get_user_url
    return "/avatar/medium/missing.png"
    if instance_of?(BlogcastrUser)
      #MVR - it looks like objects don't get helpers so can't use blogast_path
      name 
    elsif instance_of?(FacebookUser)
      s = Facebooker::Session.create
      u = Facebooker::User.new(facebook_id, s)
      u.profile_url
    elsif instance_of?(TwitterUser)
    else
    end
  end

  def get_user_avatar_url(size)
    return "/avatar/medium/missing.png"
    if instance_of?(BlogcastrUser)
      setting.avatar.url(size)
    elsif instance_of?(FacebookUser)
      if size == :medium
        s = Facebooker::Session.create
        u = Facebooker::User.new(facebook_id, s)
        u.pic_square_with_logo
      end
    elsif instance_of?(TwitterUser)
    else
    end
  end

  def get_user_avatar_class(size)
    if instance_of?(BlogcastrUser)
      if size == :small
        "avatar-small-rounded"
      elsif size == :medium
        "avatar-medium-rounded"
      elsif size == :large
        "avatar-large-rounded"
      end
    elsif instance_of?(FacebookUser)
      if size == :small
        "facebook-avatar-small-rounded"
      elsif size == :medium
        "facebook-avatar-medium-rounded"
      elsif size == :large
        "facebook-avatar-large-rounded"
      end
    elsif instance_of?(TwitterUser)
      if size == :small
        "twitter-avatar-small-rounded"
      elsif size == :medium
        "twitter-avatar-medium-rounded"
      elsif size == :large
        "twitter-avatar-large-rounded"
      end
    end
  end
end
