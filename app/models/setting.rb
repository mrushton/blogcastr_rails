class Setting < ActiveRecord::Base
  belongs_to :user
  has_attached_file :avatar, :styles => {:large => "100x100#", :medium => "80x80#", :small => "20x20#"}
  has_attached_file :background
end
