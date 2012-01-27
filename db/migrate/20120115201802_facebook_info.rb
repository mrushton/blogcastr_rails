class FacebookInfo < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_full_name, :string
    add_column :users, :facebook_expires_at, :datetime
  end

  def self.down
    #remove_column :users, :facebook_full_name
    remove_column :users, :facebook_expires_at
  end
end
